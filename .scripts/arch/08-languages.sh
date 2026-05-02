#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/mise.sh"

log_header "Setting up Language Runtimes"

ensure_mise

log_info "Installing language dependencies..."
paru -S --needed --noconfirm jdk-openjdk unixodbc ncurses libssh wxwidgets-gtk3 wxwidgets-common unzip

configure_mise
install_mise_runtimes node go erlang elixir usage
