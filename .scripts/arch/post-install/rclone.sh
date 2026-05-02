#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$SCRIPT_DIR/../../lib/tui.sh"
source "$SCRIPT_DIR/../../lib/packages.sh"

log_header "rclone Setup"

if ! confirm "Setup rclone Google Drive mount?"; then
  log_info "Skipping rclone setup"
  exit 0
fi

if ! package_installed rclone; then
  log_info "Installing rclone..."
  paru -S --needed --noconfirm rclone
else
  log_info "rclone is already installed"
fi

if ! rclone listremotes 2>/dev/null | grep -q '^gdrive$'; then
  log_info "No 'gdrive' remote found. Configuring..."
  rclone config create gdrive drive
else
  log_info "rclone 'gdrive' remote already configured"
fi

mkdir -p "$HOME/gdrive"

if [[ -f "$DOTFILES_DIR/.cp/systemd/system/rclone-gdrive.service" ]]; then
  log_info "Installing rclone-gdrive service..."
  sudo cp "$DOTFILES_DIR/.cp/systemd/system/rclone-gdrive.service" /etc/systemd/system/rclone-gdrive.service
  sudo systemctl daemon-reload
  sudo systemctl enable rclone-gdrive.service
  log_success "rclone-gdrive service installed"
else
  log_warn "rclone-gdrive.service not found in dotfiles"
fi

if confirm "Mount Google Drive now?"; then
  sudo systemctl start rclone-gdrive.service
  log_success "Google Drive mounted at $HOME/gdrive"
fi

log_success "rclone setup complete"