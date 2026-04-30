#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/fedora.sh"

log_header "Security Setup"

if ! confirm "Setup firewall (ufw)?"; then
  log_info "Skipping firewall setup"
  exit 0
fi

log_info "Installing ufw..."
fedora_install_packages ufw

if systemctl is-active --quiet firewalld.service; then
  if confirm "firewalld is running. Disable it before enabling ufw?"; then
    sudo systemctl disable --now firewalld.service
    log_success "firewalld disabled"
  fi
fi

log_info "Configuring firewall rules..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo systemctl enable --now ufw.service
sudo ufw --force enable

log_success "Firewall configured and enabled"
log_success "Security setup complete"
