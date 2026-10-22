#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../lib/tui.sh"

GITCONFIG_LOCAL="$HOME/.gitconfig.local"
SSH_AGENT_SOCK="$HOME/.ssh/proton-pass-ssh-agent.sock"

current_git_config_value() {
  local key="$1"
  git config --file "$GITCONFIG_LOCAL" --get "$key" 2>/dev/null || true
}

start_proton_pass() {
  if ! command_exists proton-pass; then
    log_warn "Proton Pass desktop is not installed"
    return 1
  fi

  if pgrep -u "$USER" -x "Proton Pass" >/dev/null 2>&1 || pgrep -u "$USER" -x proton-pass >/dev/null 2>&1; then
    return 0
  fi

  log_info "Starting Proton Pass..."
  nohup proton-pass >/dev/null 2>&1 &
}

wait_for_ssh_agent() {
  local attempts="${1:-20}"

  while (( attempts > 0 )); do
    [[ -S "$SSH_AGENT_SOCK" ]] && return 0
    sleep 0.5
    attempts=$((attempts - 1))
  done

  return 1
}

configure_agent_environment() {
  export SSH_AUTH_SOCK="$SSH_AGENT_SOCK"

  if command_exists systemctl; then
    systemctl --user set-environment SSH_AUTH_SOCK="$SSH_AGENT_SOCK" 2>/dev/null || true
  fi

  if command_exists dbus-update-activation-environment; then
    dbus-update-activation-environment --systemd SSH_AUTH_SOCK 2>/dev/null || true
  fi
}

detect_ssh_agent_public_key() {
  command_exists ssh-add || return 1
  [[ -S "$SSH_AGENT_SOCK" ]] || return 1

  local keys=()
  mapfile -t keys < <(SSH_AUTH_SOCK="$SSH_AGENT_SOCK" ssh-add -L 2>/dev/null | sed '/^[[:space:]]*$/d')
  [[ ${#keys[@]} -gt 0 ]] || return 1

  if [[ ${#keys[@]} -eq 1 ]]; then
    echo "${keys[0]}"
  else
    choose_one "Select the Proton Pass key for Git signing" "${keys[@]}"
  fi
}

configure_git_local() {
  if [[ -f "$GITCONFIG_LOCAL" ]] && ! confirm "Update existing Git config at $GITCONFIG_LOCAL?"; then
    log_info "Skipping Git local configuration"
    return 0
  fi

  touch "$GITCONFIG_LOCAL"

  local default_name default_email default_key name email signing_key
  default_name=$(current_git_config_value user.name)
  default_email=$(current_git_config_value user.email)
  default_key=$(current_git_config_value user.signingkey)

  [[ -n "$default_name" ]] || default_name="Your Name"
  [[ -n "$default_email" ]] || default_email="you@example.com"

  name=$(read_input "Your full name" "$default_name")
  email=$(read_input "Your email" "$default_email")
  signing_key=$(detect_ssh_agent_public_key || true)
  [[ -n "$signing_key" ]] || signing_key="$default_key"
  signing_key=$(read_input "Git SSH signing public key" "$signing_key")

  git config --file "$GITCONFIG_LOCAL" user.name "$name"
  git config --file "$GITCONFIG_LOCAL" user.email "$email"
  git config --file "$GITCONFIG_LOCAL" --unset-all gpg.ssh.program 2>/dev/null || true

  if [[ "$signing_key" =~ ^(ssh-|ecdsa-|sk-) ]]; then
    git config --file "$GITCONFIG_LOCAL" user.signingkey "$signing_key"
    git config --file "$GITCONFIG_LOCAL" gpg.format ssh
    git config --file "$GITCONFIG_LOCAL" commit.gpgsign true
    git config --file "$GITCONFIG_LOCAL" tag.gpgsign true
  else
    log_warn "No SSH public key configured; Git signing was left unchanged"
  fi

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

log_header "Proton Pass Setup"

if ! confirm "Set up the Proton Pass SSH agent and Git signing?"; then
  log_info "Skipping Proton Pass setup"
  exit 0
fi

configure_agent_environment
start_proton_pass || true

if ! wait_for_ssh_agent; then
  log_warn "SSH agent socket not found: $SSH_AGENT_SOCK"
  log_warn "Unlock Proton Pass and enable its SSH agent, then rerun this script"
fi

configure_git_local
configure_known_hosts

if [[ -S "$SSH_AGENT_SOCK" ]]; then
  log_success "Proton Pass SSH agent detected: $SSH_AGENT_SOCK"
else
  log_warn "Proton Pass SSH agent is not available yet"
fi

log_success "Post-install setup complete"
