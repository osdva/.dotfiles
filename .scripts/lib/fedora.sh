#!/usr/bin/env bash

read_package_file() {
  local package_file="$1"
  local packages=()

  while IFS= read -r pkg; do
    pkg="${pkg%%#*}"
    pkg="$(echo "$pkg" | xargs)"
    [[ -z "$pkg" ]] && continue
    packages+=("$pkg")
  done < "$package_file"

  printf '%s\n' "${packages[@]}"
}

fedora_package_exists() {
  local pkg="$1"
  local found

  found=$(dnf -q repoquery --available --installed --queryformat '%{name}' "$pkg" 2>/dev/null | head -n 1 || true)
  [[ -n "$found" ]]
}

fedora_install_packages() {
  if [[ $# -eq 0 ]]; then
    return 0
  fi

  local dnf_status=0
  local installed=()
  local not_installed=()
  local pkg

  sudo dnf install -y --allowerasing --skip-unavailable "$@" || dnf_status=$?

  for pkg in "$@"; do
    if rpm -q "$pkg" &>/dev/null || rpm -q --whatprovides "$pkg" &>/dev/null; then
      installed+=("$pkg")
    else
      not_installed+=("$pkg")
    fi
  done

  if [[ ${#installed[@]} -gt 0 ]]; then
    log_info "Installed packages:"
    for pkg in "${installed[@]}"; do
      gum style --foreground 2 "  ✓ $pkg"
    done
  fi

  if [[ ${#not_installed[@]} -gt 0 ]]; then
    log_warn "Packages not installed:"
    for pkg in "${not_installed[@]}"; do
      gum style --foreground 1 "  ✗ $pkg"
    done
  fi

  return "$dnf_status"
}

fedora_install_package_file() {
  local package_file="$1"
  local packages=()

  mapfile -t packages < <(read_package_file "$package_file")

  if [[ ${#packages[@]} -eq 0 ]]; then
    log_warn "No packages found in $package_file"
    return 0
  fi

  log_info "Found ${#packages[@]} packages to install"
  fedora_install_packages "${packages[@]}"
}

enable_systemd_unit() {
  local unit="$1"

  if systemctl list-unit-files "$unit" &>/dev/null; then
    sudo systemctl enable --now "$unit"
  else
    log_warn "Systemd unit not found, skipping: $unit"
  fi
}
