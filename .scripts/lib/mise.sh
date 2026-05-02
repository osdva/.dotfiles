#!/usr/bin/env bash

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/tui.sh"
source "$LIB_DIR/commands.sh"

ensure_mise() {
  if ! command_exists mise; then
    log_error "mise not found. Install packages first."
    return 1
  fi
}

configure_mise() {
  log_info "Configuring mise..."
  mise settings set experimental true
  mise settings set legacy_version_file true
}

install_mise_runtimes() {
  log_info "Installing language runtimes..."

  local runtime
  for runtime in "$@"; do
    case "$runtime" in
      erlang)
        KERL_CONFIGURE_OPTIONS="--enable-wx" mise use -g erlang
        ;;
      *)
        mise use -g "$runtime"
        ;;
    esac
  done

  mise reshim

  log_success "Language runtimes installed"
  mise list
}
