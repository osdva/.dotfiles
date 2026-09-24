#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Shell Setup"

log_info "Installing fish shell..."
paru -S --needed --noconfirm fish

log_info "Login shell stays zsh. Interactive sessions start fish from .zshrc."
log_success "Shell setup complete"
