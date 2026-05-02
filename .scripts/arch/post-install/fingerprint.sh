#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$SCRIPT_DIR/../../lib/tui.sh"
source "$SCRIPT_DIR/../../lib/packages.sh"

log_header "Fingerprint Setup"

if ! confirm "Setup fingerprint reader (fprintd)?"; then
  log_info "Skipping fingerprint setup"
  exit 0
fi

if ! package_installed fprintd; then
  log_info "Installing fprintd..."
  paru -S --needed --noconfirm fprintd
else
  log_info "fprintd is already installed"
fi

select_fingers() {
  local fingers=(
    right-thumb
    right-index-finger
    right-middle-finger
    right-ring-finger
    right-little-finger
    left-thumb
    left-index-finger
    left-middle-finger
    left-ring-finger
    left-little-finger
  )

  local selected_fingers=()

  while true; do
    mapfile -t selected_fingers < <(choose_many "Select fingers to enroll (Space to select, Enter to confirm)" "${fingers[@]}" || true)

    if [[ ${#selected_fingers[@]} -gt 0 ]]; then
      printf '%s\n' "${selected_fingers[@]}"
      return 0
    fi

    log_warn "No fingers selected. Use Space to select fingers before pressing Enter."
    if ! confirm "Try selecting fingers again?"; then
      return 0
    fi
  done
}

mapfile -t selected_fingers < <(select_fingers)

if [[ ${#selected_fingers[@]} -eq 0 ]]; then
  log_warn "No fingers selected; skipping enrollment"
else
  log_info "Starting fingerprint enrollment for $USER..."
  # fprintd enrollment requires polkit authorization. During post-install there may
  # be no graphical polkit agent available, so run it through sudo and explicitly
  # enroll the current user instead of root.
  for finger in "${selected_fingers[@]}"; do
    log_info "Enrolling $finger..."
    if sudo fprintd-enroll -f "$finger" "$USER"; then
      log_success "$finger enrolled"

      if confirm "Verify $finger now?"; then
        sudo fprintd-verify -f "$finger" "$USER" || log_warn "$finger verification failed"
      fi
    else
      log_warn "Enrollment failed for $finger; continuing"
    fi
  done
fi

if [[ -d "$DOTFILES_DIR/.cp/pam.d" ]]; then
  log_info "Installing PAM fingerprint config..."
  sudo cp "$DOTFILES_DIR/.cp/pam.d/system-local-login" /etc/pam.d/system-local-login
  sudo cp "$DOTFILES_DIR/.cp/pam.d/polkit-1" /etc/pam.d/polkit-1
  log_success "PAM configuration updated"
else
  log_warn "PAM config directory not found: $DOTFILES_DIR/.cp/pam.d"
fi

set_ly_config_value() {
  local key="$1"
  local value="$2"
  local file="/etc/ly/config.ini"

  if sudo grep -Eq "^[#[:space:]]*${key}[[:space:]]*=" "$file"; then
    sudo sed -i -E "s|^[#[:space:]]*${key}[[:space:]]*=.*|${key} = ${value}|" "$file"
  else
    echo "${key} = ${value}" | sudo tee -a "$file" >/dev/null
  fi
}

if [[ -f /etc/ly/config.ini ]]; then
  log_info "Configuring ly to focus the password/fingerprint input..."
  set_ly_config_value "default_input" "password"
  set_ly_config_value "save" "true"
  log_success "ly fingerprint input configured"
else
  log_warn "ly config not found: /etc/ly/config.ini"
fi

if [[ -f /etc/pam.d/ly ]]; then
  log_info "Configuring ly PAM for GNOME Keyring..."
  sudo sed -i -E \
    -e 's/^-auth([[:space:]]+optional[[:space:]]+pam_gnome_keyring\.so.*)$/auth\1/' \
    -e 's/^-password([[:space:]]+optional[[:space:]]+pam_gnome_keyring\.so.*)$/password\1/' \
    -e 's/^-session([[:space:]]+optional[[:space:]]+pam_gnome_keyring\.so.*)$/session\1/' \
    /etc/pam.d/ly
  log_success "ly PAM configured"
else
  log_warn "ly PAM config not found: /etc/pam.d/ly"
fi

if [[ -f "$DOTFILES_DIR/.cp/systemd/system/kill-fprintd.service" ]]; then
  log_info "Installing kill-fprintd sleep hook..."
  sudo cp "$DOTFILES_DIR/.cp/systemd/system/kill-fprintd.service" /etc/systemd/system/kill-fprintd.service
  sudo systemctl daemon-reload
  sudo systemctl enable kill-fprintd.service
  log_success "kill-fprintd sleep hook installed"
else
  log_warn "kill-fprintd service not found"
fi

log_success "Fingerprint setup complete"
