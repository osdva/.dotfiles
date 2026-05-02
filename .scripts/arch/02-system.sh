#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/packages.sh"

log_header "Setting up system packages"

log_info "Installing niri..."
paru -S --needed --noconfirm niri

log_info "Installing ly..."
paru -S --needed --noconfirm ly
sudo systemctl enable ly@tty2.service

log_info "Installing Noctalia shell..."
paru -S --needed --noconfirm noctalia-shell matugen pam-u2f

log_info "Installing network manager..."
paru -S --needed --noconfirm networkmanager
sudo systemctl enable --now NetworkManager.service

log_info "Installing launcher..."
paru -S --needed --noconfirm vicinae-bin

log_info "Cleaning up unwanted niri dependencies..."

unwanted_packages=(waybar fuzzel swaylock)
mapfile -t installed_unwanted < <(installed_packages "${unwanted_packages[@]}")

if [[ ${#installed_unwanted[@]} -gt 0 ]]; then
  paru -Rsn --noconfirm "${installed_unwanted[@]}"
else
  log_info "No unwanted niri dependencies installed"
fi

log_success "System packages installed"
