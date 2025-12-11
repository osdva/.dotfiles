#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Shell Setup"

if ! command -v bash &>/dev/null; then
  log_info "Installing bash..."
  brew install bash
fi

if confirm "Set bash as default shell for $USER?"; then
  chsh -s "$(which bash)"
  log_success "bash set as default shell (requires re-login)"
fi

if ! command -v fish &>/dev/null; then
  log_info "Installing fish shell..."
  brew install fish
  log_info "Fish shell will be used as interactive shell"
fi

log_success "Shell setup complete"
