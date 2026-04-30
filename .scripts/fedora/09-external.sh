#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

export PATH="$HOME/.opencode/bin:$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

log_header "Installing/Updating External Tools"

confirm_install_or_update() {
  local command_name="$1"
  local display_name="$2"
  local method="$3"

  if command -v "$command_name" &>/dev/null; then
    confirm "Update $display_name with $method?"
  else
    confirm "Install $display_name with $method?"
  fi
}

if confirm_install_or_update broot "broot" "the official precompiled binary"; then
  log_info "Installing/updating broot..."
  (
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT
    broot_zip="$tmp_dir/broot.zip"

    broot_url="$(
      curl -fsSL https://api.github.com/repos/Canop/broot/releases/latest \
        | jq -r '.assets[] | select(.name | test("^broot_.*\\.zip$")) | .browser_download_url' \
        | head -n 1
    )"

    if [[ -z "$broot_url" || "$broot_url" == "null" ]]; then
      log_error "Could not find broot release archive"
      exit 1
    fi

    curl -fsSL "$broot_url" -o "$broot_zip"
    unzip -q "$broot_zip" -d "$tmp_dir"
    sudo install -m 0755 "$tmp_dir/x86_64-unknown-linux-gnu/broot" /usr/local/bin/broot
    broot --set-install-state installed
  )
  log_success "broot installed/updated"
fi

if confirm_install_or_update lazysql "lazysql" "the official binary release"; then
  log_info "Installing/updating lazysql..."
  (
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT
    lazysql_archive="$tmp_dir/lazysql.tar.gz"
    lazysql_url="$(
      curl -fsSL https://api.github.com/repos/jorgerojas26/lazysql/releases/latest \
        | jq -r '.assets[] | select(.name == "lazysql_Linux_x86_64.tar.gz") | .browser_download_url' \
        | head -n 1
    )"

    if [[ -z "$lazysql_url" || "$lazysql_url" == "null" ]]; then
      log_error "Could not find lazysql Linux x86_64 release archive"
      exit 1
    fi

    curl -fsSL "$lazysql_url" -o "$lazysql_archive"
    tar -xzf "$lazysql_archive" -C "$tmp_dir"
    sudo install -m 0755 "$tmp_dir/lazysql" /usr/local/bin/lazysql
  )
  log_success "lazysql installed/updated"
fi

if confirm_install_or_update lazydocker "lazydocker" "the official installer"; then
  log_info "Installing/updating lazydocker..."
  curl -fsSL https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash
  log_success "lazydocker installed/updated"
fi

if confirm_install_or_update opencode "opencode" "the official installer"; then
  log_info "Installing/updating opencode..."
  curl -fsSL https://opencode.ai/install | bash
  log_success "opencode installed/updated"
fi

if confirm_install_or_update pi "pi-coding-agent" "npm"; then
  if ! command -v npm &>/dev/null; then
    log_error "npm not found. Run the language setup first."
    exit 1
  fi

  log_info "Installing/updating pi-coding-agent..."
  npm install -g @mariozechner/pi-coding-agent@latest
  log_success "pi-coding-agent installed/updated"
fi

log_success "External tools installed/updated"
