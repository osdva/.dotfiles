#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/tui.sh"

GITCONFIG_LOCAL="$HOME/.gitconfig.local"
OP_SIGN_PROGRAM="/opt/1Password/op-ssh-sign"
SSH_AGENT_TOML="$HOME/.config/1Password/ssh/agent.toml"
SSH_AGENT_SOCK="$HOME/.1password/agent.sock"
CUSTOM_ALLOWED_BROWSERS="/etc/1password/custom_allowed_browsers"

read_with_default() {
  local prompt="$1"
  local default="$2"
  local value

  if command -v gum &>/dev/null; then
    value=$(gum input --value "$default" --prompt "$prompt: ")
  else
    read -r -p "$prompt [$default]: " value
  fi

  echo "${value:-$default}"
}

current_git_config_value() {
  local key="$1"
  git config --file "$GITCONFIG_LOCAL" --get "$key" 2>/dev/null || true
}

ensure_1password_agent_config() {
  if [[ -f "$SSH_AGENT_TOML" ]]; then
    log_info "1Password SSH agent config already exists: $SSH_AGENT_TOML"
    return 0
  fi

  mkdir -p "$(dirname "$SSH_AGENT_TOML")"

  local vault
  vault=$(read_with_default "1Password vault for SSH keys" "Development")

  cat > "$SSH_AGENT_TOML" <<EOF
[[ssh-keys]]
vault = "$vault"
EOF

  log_success "1Password SSH agent config created: $SSH_AGENT_TOML"
}

start_1password() {
  if ! command -v 1password &>/dev/null; then
    log_warn "1Password desktop app is not installed"
    return 1
  fi

  if command -v systemctl &>/dev/null && [[ -f "$HOME/.config/systemd/user/1password.service" ]]; then
    log_info "Enabling 1Password user service..."
    systemctl --user daemon-reload || true
    if ! systemctl --user enable --now 1password.service; then
      log_warn "Could not start 1Password user service; continuing"
    fi
  elif ! pgrep -u "$USER" -x 1password &>/dev/null; then
    log_info "Starting 1Password desktop app..."
    nohup 1password --silent >/dev/null 2>&1 &
  fi
}

ensure_op_unlocked() {
  if ! command -v op &>/dev/null; then
    log_warn "1Password CLI (op) is not installed"
    return 1
  fi

  if op vault list >/dev/null 2>&1; then
    return 0
  fi

  log_warn "Unlock/sign in to 1Password so the CLI can read your SSH public key"
  start_1password || true

  if op signin >/dev/null 2>&1; then
    return 0
  fi

  log_warn "1Password CLI is still locked; will ask for the signing key manually"
  return 1
}

detect_ssh_agent_public_key() {
  command -v ssh-add &>/dev/null || return 1
  [[ -S "$SSH_AGENT_SOCK" ]] || return 1

  local keys selected
  keys=$(SSH_AUTH_SOCK="$SSH_AGENT_SOCK" ssh-add -L 2>/dev/null || true)
  [[ -n "$keys" ]] || return 1

  if command -v gum &>/dev/null; then
    mapfile -t key_choices <<< "$keys"
    selected=$(gum choose --header "Select Git GPG signing key (from 1Password agent)" "${key_choices[@]}" || true)
    [[ -n "$selected" ]] || return 1
    echo "$selected"
  else
    head -n 1 <<< "$keys"
  fi
}

detect_1password_public_key() {
  command -v op &>/dev/null || return 1
  command -v jq &>/dev/null || return 1
  ensure_op_unlocked || return 1

  local items_json
  items_json=$(op item list --categories ssh-key --format json 2>/dev/null || true)
  [[ -n "$items_json" && "$items_json" != "[]" ]] || return 1

  local selected_id
  if command -v gum &>/dev/null; then
    local selected
    local choices=($'Enter public key manually\tmanual')
    while IFS= read -r choice; do
      choices+=("$choice")
    done < <(jq -r '.[] | "\(.title)\t\(.id)"' <<< "$items_json")

    selected=$(gum choose --header "Select Git GPG signing key (1Password SSH key)" "${choices[@]}" || true)
    selected_id="${selected##*$'\t'}"
    [[ "$selected_id" != "manual" && -n "$selected_id" ]] || return 1
  else
    selected_id=$(jq -r '.[0].id // empty' <<< "$items_json")
  fi

  local item_json public_key
  item_json=$(op item get "$selected_id" --format json 2>/dev/null || true)
  public_key=$(jq -r '.fields[]? | select((.label // "" | ascii_downcase) == "public key" or (.id // "") == "public_key") | .value' <<< "$item_json" | head -n 1)

  [[ "$public_key" =~ ^ssh- ]] || return 1
  echo "$public_key"
}

configure_git_local() {
  if [[ -f "$GITCONFIG_LOCAL" ]] && ! confirm "Update existing git + 1Password config at $GITCONFIG_LOCAL?"; then
    log_info "Skipping git local configuration"
    return 0
  fi

  touch "$GITCONFIG_LOCAL"

  local default_name default_email default_key name email signing_key
  default_name=$(current_git_config_value user.name)
  default_email=$(current_git_config_value user.email)
  default_key=$(current_git_config_value user.signingkey)

  [[ -n "$default_name" ]] || default_name="Your Name"
  [[ -n "$default_email" ]] || default_email="you@example.com"

  log_info "Configuring git identity..."
  name=$(read_with_default "Your full name" "$default_name")
  email=$(read_with_default "Your email" "$default_email")

  log_info "Looking for Git GPG signing key in 1Password..."
  # This setup uses Git's SSH signing backend: [gpg] format = ssh,
  # with 1Password's op-ssh-sign as the signing program.
  signing_key=$(detect_ssh_agent_public_key || detect_1password_public_key || true)
  [[ -n "$signing_key" ]] || signing_key="$default_key"
  [[ -n "$signing_key" ]] || signing_key="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA..."
  signing_key=$(read_with_default "Git GPG signing key (SSH public key from 1Password)" "$signing_key")

  git config --file "$GITCONFIG_LOCAL" user.name "$name"
  git config --file "$GITCONFIG_LOCAL" user.email "$email"
  git config --file "$GITCONFIG_LOCAL" user.signingkey "$signing_key"
  git config --file "$GITCONFIG_LOCAL" gpg.format ssh
  git config --file "$GITCONFIG_LOCAL" gpg.ssh.program "$OP_SIGN_PROGRAM"
  git config --file "$GITCONFIG_LOCAL" commit.gpgsign true
  git config --file "$GITCONFIG_LOCAL" tag.gpgsign true

  log_success "Git local config updated: $GITCONFIG_LOCAL"
}

configure_known_hosts() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  if ! ssh-keygen -F github.com >/dev/null 2>&1; then
    log_info "Adding github.com to SSH known_hosts..."
    ssh-keyscan github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null || true
    chmod 600 "$HOME/.ssh/known_hosts" 2>/dev/null || true
  fi
}

default_browser_binaries() {
  local browsers=()
  local browser

  for browser in zen-browser vivaldi-bin vivaldi-stable vivaldi; do
    if command -v "$browser" &>/dev/null; then
      browsers+=("$browser")
    fi
  done

  if [[ ${#browsers[@]} -eq 0 ]]; then
    browsers=(zen-browser)
  fi

  printf '%s ' "${browsers[@]}" | sed 's/ $//'
}

configure_custom_browsers() {
  if ! confirm "Allow custom browsers to connect to 1Password?"; then
    log_info "Skipping 1Password custom browser setup"
    return 0
  fi

  local default_browsers browsers tmp
  if [[ -f "$CUSTOM_ALLOWED_BROWSERS" ]]; then
    default_browsers=$(tr '\n' ' ' < "$CUSTOM_ALLOWED_BROWSERS" | sed 's/[[:space:]]\+/ /g; s/^ //; s/ $//')
  else
    default_browsers=$(default_browser_binaries)
  fi

  browsers=$(read_with_default "Trusted browser binaries (space/comma separated)" "$default_browsers")
  tmp=$(mktemp)

  tr ', ' '\n' <<< "$browsers" \
    | sed '/^[[:space:]]*$/d' \
    | awk '!seen[$0]++' > "$tmp"

  log_info "Writing $CUSTOM_ALLOWED_BROWSERS..."
  sudo mkdir -p /etc/1password
  sudo install -o root -g root -m 0755 "$tmp" "$CUSTOM_ALLOWED_BROWSERS"
  rm -f "$tmp"

  log_success "1Password custom browsers configured: $(tr '\n' ' ' < "$CUSTOM_ALLOWED_BROWSERS" | sed 's/ $//')"

  if confirm "Restart 1Password now so it reads custom browsers?"; then
    if command -v systemctl &>/dev/null && systemctl --user list-unit-files 1password.service &>/dev/null; then
      systemctl --user restart 1password.service || true
    else
      pkill -u "$USER" -x 1password 2>/dev/null || true
      start_1password || true
    fi
  else
    log_info "Restart 1Password later to apply custom browser changes"
  fi
}

log_header "Post Install Setup"

if ! confirm "Setup 1Password for git GPG signing and custom browsers?"; then
  log_info "Skipping post-install 1Password setup"
  exit 0
fi

ensure_1password_agent_config
start_1password || true
export SSH_AUTH_SOCK="$SSH_AGENT_SOCK"

configure_custom_browsers
configure_git_local
configure_known_hosts

if [[ -S "$SSH_AGENT_SOCK" ]]; then
  log_success "1Password SSH agent socket detected: $SSH_AGENT_SOCK"
else
  log_warn "1Password SSH agent socket not found yet. Unlock 1Password and ensure Settings → Developer → SSH Agent is enabled."
fi

log_success "Post install setup complete"
