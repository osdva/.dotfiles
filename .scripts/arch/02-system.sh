#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Setting up system packages"

log_info "Installing niri..."
paru -S --needed --noconfirm niri

log_info "Installing ly..."
paru -S --needed --noconfirm ly
sudo systemctl enable ly@tty2.service

log_info "Installing desktop shell..."
paru -S --needed --noconfirm dms-shell-bin matugen

log_info "Installing launcher..."
paru -S --needed --noconfirm vicinae-bin

log_info "Cleaning up niri dependencies..."

paru -Rsn --noconfirm waybar fuzzel swaylock

log_success "System packages installed"
