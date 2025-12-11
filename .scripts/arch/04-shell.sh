#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Shell Setup"

log_info "Installing login shell..."
paru -S --needed --noconfirm fish bash

if confirm "Set bash as default shell for $USER?"; then
  command -v bash | sudo tee -a /etc/shells
  chsh -s "$(command -v bash)"
  log_success "bash set as default shell (requires re-login)"

  log_info "Fish shell will be used as an interactive shell."
fi

log_success "Shell setup complete"
