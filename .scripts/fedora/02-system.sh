#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/fedora.sh"

log_header "Setting up system packages"

log_info "Installing desktop/session packages..."
fedora_install_packages niri matugen pam-u2f swaybg xwayland-satellite NetworkManager

log_info "Installing Noctalia shell from Terra..."
fedora_install_packages noctalia-shell

log_info "Enabling Vicinae COPR repository..."
sudo dnf copr enable -y quadratech188/vicinae

log_info "Installing Vicinae from COPR..."
fedora_install_packages vicinae

log_info "Enabling network manager..."
enable_systemd_unit NetworkManager.service

log_success "System packages installed"
