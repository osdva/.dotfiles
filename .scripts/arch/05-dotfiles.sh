#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Dotfiles Setup"

if confirm "Symlink dotfiles using stow?"; then
  log_info "Creating symlinks..."
  
  cd "$DOTFILES_DIR"
  stow --adopt -v .
  
  log_success "Dotfiles symlinked"
fi

log_info "Git signing is skipped during install. Run .scripts/arch/post-install/1password.sh after login."

log_success "Dotfiles setup complete"
