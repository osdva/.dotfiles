#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/packages.sh"

log_header "Installing Packages"

mapfile -t packages < <(read_package_list "$SCRIPT_DIR/../packages/arch/packages")

if [[ ${#packages[@]} -eq 0 ]]; then
  log_warn "No packages found in list"
  exit 0
fi

log_info "Found ${#packages[@]} packages to install"

paru -S --needed --noconfirm "${packages[@]}"

log_success "Package installation complete (${#packages[@]} packages)"
