#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Shell Setup"

if ! command_exists fish; then
  log_info "Installing fish shell..."
  brew install fish
fi

log_info "Login shell stays zsh. Interactive sessions start fish from .zshrc."
log_success "Shell setup complete"
