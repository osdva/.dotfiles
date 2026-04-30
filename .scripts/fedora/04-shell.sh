#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/fedora.sh"

log_header "Shell Setup"

log_info "Installing shells..."
fedora_install_packages fish bash

if confirm "Set bash as default shell for $USER?"; then
  bash_path="$(command -v bash)"
  if ! grep -qxF "$bash_path" /etc/shells; then
    echo "$bash_path" | sudo tee -a /etc/shells >/dev/null
  fi
  sudo chsh -s "$bash_path" "$USER"
  log_success "bash set as default shell (requires re-login)"

  log_info "Fish shell will be used as an interactive shell."
fi

log_success "Shell setup complete"
