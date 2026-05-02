#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/packages.sh"

log_header "Cleanup"

broot --set-install-state installed

log_info "Removing temporary files..."
rm -rf "$SCRIPT_DIR/../../tmp"

if package_installed gum; then
  if confirm "Uninstall gum? (bootstrap UI tool, no longer needed)"; then
    paru -Rsn --noconfirm gum
    log_success "gum uninstalled"
  else
    log_info "Keeping gum installed"
  fi
else
  log_info "gum is not installed"
fi

log_success "Cleanup complete"
log_info "Bootstrap finished! Restart your shell: exec zsh"
