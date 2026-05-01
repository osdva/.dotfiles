#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Cleanup"

if command -v broot &>/dev/null; then
  broot --set-install-state installed
else
  log_warn "broot not found; skipping install-state setup"
fi

log_info "Removing temporary files..."
rm -rf "$SCRIPT_DIR/../../tmp"

if confirm "Uninstall gum? (bootstrap UI tool, no longer needed)"; then
  sudo dnf remove -y gum
  log_success "gum uninstalled"
else
  log_info "Keeping gum installed"
fi

log_success "Cleanup complete"
log_info "Bootstrap finished! Restart your shell: exec bash"
