#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$SCRIPT_DIR/../../lib/tui.sh"

log_header "Setup Mimeapps"

if [[ ! -f "$DOTFILES_DIR/.templates/mimeapps.list.template" ]]; then
  log_error "Template not found: .templates/mimeapps.list.template"
  exit 1
fi

detect_browser_desktop_files() {
  local app_dirs=(
    "$HOME/.local/share/applications"
    /usr/local/share/applications
    /usr/share/applications
  )

  local -A seen=()
  local app_dir desktop_file desktop_name

  shopt -s nullglob
  for app_dir in "${app_dirs[@]}"; do
    [[ -d "$app_dir" ]] || continue

    for desktop_file in "$app_dir"/*.desktop; do
      desktop_name="$(basename "$desktop_file")"
      [[ -n "${seen[$desktop_name]:-}" ]] && continue

      if grep -Eiq '^(MimeType=.*(x-scheme-handler/http|text/html)|Categories=.*WebBrowser)' "$desktop_file"; then
        seen[$desktop_name]=1
        printf '%s\n' "$desktop_name"
      fi
    done
  done
  shopt -u nullglob
}

ensure_browser() {
  if [[ -n "${BROWSER:-}" ]]; then
    log_info "Current BROWSER: $BROWSER"
    return 0
  fi

  log_warn "BROWSER environment variable is not set"

  local detected=()
  mapfile -t detected < <(detect_browser_desktop_files)

  if [[ ${#detected[@]} -gt 0 ]]; then
    BROWSER=$(choose_one "Choose default browser desktop file" "${detected[@]}")
  else
    BROWSER=$(read_input "Default browser desktop file" "zen-browser.desktop")
  fi

  export BROWSER
  log_success "Using BROWSER=$BROWSER"
}

persist_browser_env() {
  log_info "Persisting BROWSER=$BROWSER..."

  mkdir -p "$HOME/.config/environment.d"
  printf 'BROWSER=%s\n' "$BROWSER" > "$HOME/.config/environment.d/10-browser.conf"

  if command_exists systemctl; then
    systemctl --user set-environment "BROWSER=$BROWSER" 2>/dev/null || true
    systemctl --user import-environment BROWSER 2>/dev/null || true
  fi

  if command_exists dbus-update-activation-environment; then
    dbus-update-activation-environment --systemd BROWSER 2>/dev/null || true
  fi

  if command_exists fish; then
    fish -c "set -Ux BROWSER '$BROWSER'" 2>/dev/null || true
  fi

  log_success "BROWSER persisted in ~/.config/environment.d/10-browser.conf"
}

ensure_browser
persist_browser_env

log_info "Generating mimeapps.list..."

envsubst < "$DOTFILES_DIR/.templates/mimeapps.list.template" > "$DOTFILES_DIR/.config/mimeapps.list"

log_success "mimeapps.list created at .config/mimeapps.list"
