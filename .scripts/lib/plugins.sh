#!/usr/bin/env bash

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/tui.sh"
source "$LIB_DIR/commands.sh"

install_tmux_plugins() {
  if [[ -f "$HOME/.config/tmux/tmux.conf" ]] || [[ -f "$HOME/.tmux.conf" ]]; then
    log_info "Installing tmux plugins..."

    if [[ ! -d "$HOME/.config/tmux/plugins/tpm" ]]; then
      git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
    fi

    if command_exists tmux; then
      "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
      log_success "tmux plugins installed"
    fi
  else
    log_warn "tmux config not found, skipping tmux plugins"
  fi
}

install_neovim_plugins() {
  if command_exists nvim; then
    log_info "Installing neovim plugins..."

    nvim --headless -c "lua MiniDeps.update()" -c "qa" 2>/dev/null || true

    log_success "neovim plugins installed"
  else
    log_warn "neovim not found, skipping nvim plugins"
  fi
}

install_editor_plugins() {
  install_tmux_plugins
  install_neovim_plugins

  log_success "Plugin installation complete"
  log_info "Note: Some plugins may need additional setup on first use"
}
