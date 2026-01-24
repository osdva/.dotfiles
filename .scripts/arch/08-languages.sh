#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Setting up Language Runtimes"

if ! command -v mise &>/dev/null; then
  log_error "mise not found. Install packages first."
  exit 1
fi

log_info "Installing language dependencies..."
paru -S --needed --noconfirm jdk-openjdk unixodbc ncurses libssh wxwidgets-gtk3 wxwidgets-common unzip

log_info "Configuring mise..."
mise settings set experimental true
mise settings set legacy_version_file true

log_info "Installing language runtimes..."

mise use -g node
mise use -g go
KERL_CONFIGURE_OPTIONS="--enable-wx" mise use -g erlang
mise use -g elixir
mise use -g usage

mise reshim

log_success "Language runtimes installed"
mise list
