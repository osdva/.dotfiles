#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$SCRIPT_DIR/../../lib/tui.sh"

log_header "Hibernation Setup"

if ! confirm "Setup hibernation?"; then
  log_info "Skipping hibernation setup"
  exit 0
fi

choose_swap_device() {
  local swaps=()
  mapfile -t swaps < <(swapon --show=NAME --noheadings --raw 2>/dev/null | sed '/^[[:space:]]*$/d')

  if [[ ${#swaps[@]} -eq 0 ]]; then
    log_error "No active swap found. Create and enable swap before setting up hibernation."
    exit 1
  fi

  if [[ ${#swaps[@]} -eq 1 ]]; then
    echo "${swaps[0]}"
    return 0
  fi

  choose_one "Select swap device/file for hibernation" "${swaps[@]}"
}

swap_type_for() {
  local swap_path="$1"
  swapon --show=NAME,TYPE --noheadings --raw | awk -v path="$swap_path" '$1 == path { print $2; exit }'
}

uuid_for_block_device() {
  local block_device="$1"
  blkid -s UUID -o value "$block_device" 2>/dev/null || true
}

resume_params_for_swap_partition() {
  local swap_path="$1"
  local uuid

  if [[ "$swap_path" == /dev/zram* ]]; then
    log_error "zram swap cannot be used for hibernation. Use a swap partition or swap file."
    exit 1
  fi

  uuid="$(uuid_for_block_device "$swap_path")"
  if [[ -z "$uuid" ]]; then
    log_error "Could not determine UUID for swap device: $swap_path"
    exit 1
  fi

  echo "resume=UUID=$uuid"
}

resume_offset_for_swap_file() {
  local swap_file="$1"
  local fstype
  local offset=""

  fstype="$(findmnt -no FSTYPE -T "$swap_file" 2>/dev/null || true)"

  if [[ "$fstype" == "btrfs" ]]; then
    if ! command_exists btrfs; then
    log_error "Required command not found: btrfs"
    exit 1
  fi
    offset="$(sudo btrfs inspect-internal map-swapfile -r "$swap_file" 2>/dev/null || true)"
  else
    if ! command_exists filefrag; then
    log_error "Required command not found: filefrag"
    exit 1
  fi
    offset="$(sudo filefrag -v "$swap_file" | awk '$1 == "0:" { gsub(/\./, "", $4); print $4; exit }')"
  fi

  if [[ -z "$offset" || ! "$offset" =~ ^[0-9]+$ ]]; then
    log_error "Could not determine resume_offset for swap file: $swap_file"
    exit 1
  fi

  echo "$offset"
}

resume_params_for_swap_file() {
  local swap_file="$1"
  local source uuid offset

  source="$(findmnt -no SOURCE -T "$swap_file" 2>/dev/null || true)"
  # btrfs subvolumes can appear as /dev/device[/subvol]; blkid needs /dev/device.
  source="${source%%\[*}"
  if [[ -z "$source" ]]; then
    log_error "Could not determine backing device for swap file: $swap_file"
    exit 1
  fi

  uuid="$(uuid_for_block_device "$source")"
  if [[ -z "$uuid" ]]; then
    log_error "Could not determine UUID for backing device: $source"
    exit 1
  fi

  offset="$(resume_offset_for_swap_file "$swap_file")"
  echo "resume=UUID=$uuid resume_offset=$offset"
}

cmdline_without_resume_params() {
  local word
  for word in "$@"; do
    case "$word" in
      resume=*|resume_offset=*) ;;
      *) printf '%s\n' "$word" ;;
    esac
  done
}

merge_cmdline() {
  local current="$1"
  shift
  local resume_params=("$@")
  local words=()
  local cleaned=()

  # shellcheck disable=SC2206
  words=($current)
  mapfile -t cleaned < <(cmdline_without_resume_params "${words[@]}")
  cleaned+=("${resume_params[@]}")
  printf '%s\n' "${cleaned[*]}"
}

update_refind_linux_conf() {
  local resume_params=("$@")
  local files=()
  local file tmp line prefix options suffix new_options updated_any=0 updated_file
  local refind_regex='^("[^"]+"[[:space:]]+")([^"]*)(".*)$'

  [[ -d /boot ]] || return 1

  mapfile -t files < <(find /boot -name refind_linux.conf -type f 2>/dev/null | sort)
  [[ ${#files[@]} -gt 0 ]] || return 1

  for file in "${files[@]}"; do
    tmp="$(mktemp)"
    updated_file=0

    while IFS= read -r line || [[ -n "$line" ]]; do
      if [[ $line =~ $refind_regex ]]; then
        prefix="${BASH_REMATCH[1]}"
        options="${BASH_REMATCH[2]}"
        suffix="${BASH_REMATCH[3]}"
        new_options="$(merge_cmdline "$options" "${resume_params[@]}")"
        printf '%s%s%s\n' "$prefix" "$new_options" "$suffix"
        updated_file=1
      else
        printf '%s\n' "$line"
      fi
    done < <(sudo cat "$file") > "$tmp"

    if [[ $updated_file -eq 1 ]]; then
      sudo install -m 0644 "$tmp" "$file"
      log_success "Updated rEFInd kernel options in $file"
      updated_any=1
    else
      log_warn "No rEFInd boot option lines found in $file"
    fi

    rm -f "$tmp"
  done

  [[ $updated_any -eq 1 ]]
}


configure_mkinitcpio_resume_hook() {
  local file="/etc/mkinitcpio.conf"
  local hooks_line new_line

  [[ -f "$file" ]] || return 0

  hooks_line="$(sudo grep -m1 '^HOOKS=' "$file" || true)"
  [[ -n "$hooks_line" ]] || return 0

  if [[ "$hooks_line" == *" systemd "* || "$hooks_line" == *"(systemd "* || "$hooks_line" == *" systemd)"* ]]; then
    log_info "mkinitcpio uses the systemd hook; resume is handled by systemd initramfs"
    return 0
  fi

  if [[ "$hooks_line" == *" resume "* || "$hooks_line" == *"(resume "* || "$hooks_line" == *" resume)"* ]]; then
    log_info "mkinitcpio resume hook already present"
    log_info "Regenerating initramfs/UKI..."
    sudo mkinitcpio -P
    log_success "Initramfs/UKI regenerated"
    return 0
  fi

  new_line="$hooks_line"
  if [[ "$new_line" == *" block "* ]]; then
    new_line="${new_line/ block / block resume }"
  elif [[ "$new_line" == *" filesystems "* ]]; then
    new_line="${new_line/ filesystems / resume filesystems }"
  else
    new_line="${new_line%)} resume)"
  fi

  sudo sed -i "s|^HOOKS=.*|$new_line|" "$file"
  log_success "Added resume hook to mkinitcpio HOOKS"

  log_info "Regenerating initramfs/UKI..."
  sudo mkinitcpio -P
  log_success "Initramfs/UKI regenerated"
}

install_systemd_hibernate_configs() {
  if [[ -d "$DOTFILES_DIR/.cp/systemd/logind.conf.d" ]]; then
    sudo mkdir -p /etc/systemd/logind.conf.d
    sudo cp "$DOTFILES_DIR/.cp/systemd/logind.conf.d/"*.conf /etc/systemd/logind.conf.d/
    log_success "Installed logind hibernation config"
  fi

  if [[ -d "$DOTFILES_DIR/.cp/systemd/sleep.conf.d" ]]; then
    sudo mkdir -p /etc/systemd/sleep.conf.d
    sudo cp "$DOTFILES_DIR/.cp/systemd/sleep.conf.d/"*.conf /etc/systemd/sleep.conf.d/
    log_success "Installed systemd sleep hibernation config"
  fi
}

swap_path="$(choose_swap_device)"
swap_type="$(swap_type_for "$swap_path")"
log_info "Using swap for hibernation: $swap_path ($swap_type)"

case "$swap_type" in
  partition)
    # shellcheck disable=SC2207
    resume_params=($(resume_params_for_swap_partition "$swap_path"))
    ;;
  file)
    # shellcheck disable=SC2207
    resume_params=($(resume_params_for_swap_file "$swap_path"))
    ;;
  *)
    log_error "Unsupported swap type for hibernation: $swap_type"
    exit 1
    ;;
esac

log_info "Kernel resume parameters: ${resume_params[*]}"

install_systemd_hibernate_configs
configure_mkinitcpio_resume_hook

if ! update_refind_linux_conf "${resume_params[@]}"; then
  log_warn "Could not find /boot/refind_linux.conf to update automatically"
  log_warn "Add these kernel parameters to your rEFInd Linux entry manually: ${resume_params[*]}"
fi

log_success "Hibernation setup complete"
log_info "Reboot, then test with: systemctl hibernate"
