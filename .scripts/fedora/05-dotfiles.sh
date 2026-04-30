#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

setup_1password_ssh_git() {
  log_info "Setting up 1Password SSH agent and Git SSH signing..."

  if command -v 1password &>/dev/null && [[ -f "$HOME/.config/systemd/user/1password.service" ]]; then
    systemctl --user daemon-reload || log_warn "Could not reload user systemd"
    systemctl --user enable --now 1password.service || log_warn "Could not enable/start 1Password user service"
  else
    log_warn "1Password app or user service not found; skipping service setup"
  fi

  mkdir -p "$HOME/.ssh"
  touch "$HOME/.ssh/config"
  chmod 600 "$HOME/.ssh/config"

  if ! grep -Eq '^[[:space:]]*IdentityAgent[[:space:]]+.*\.1password/agent\.sock' "$HOME/.ssh/config"; then
    cat >> "$HOME/.ssh/config" <<'EOF'

Host *
  IdentityAgent ~/.1password/agent.sock
EOF
    log_success "1Password SSH IdentityAgent added to ~/.ssh/config"
  fi

  if [[ ! -x /opt/1Password/op-ssh-sign ]]; then
    log_warn "1Password SSH signer not found at /opt/1Password/op-ssh-sign"
    return 0
  fi

  local signing_key=""
  if [[ -S "$HOME/.1password/agent.sock" ]] && command -v ssh-add &>/dev/null; then
    signing_key="$(SSH_AUTH_SOCK="$HOME/.1password/agent.sock" ssh-add -L 2>/dev/null | awk '/^ssh-/{print $1 " " $2; exit}')"
  fi

  if [[ -z "$signing_key" ]]; then
    log_warn "No SSH public key found from 1Password agent. Unlock 1Password and run this script again."
    return 0
  fi

  touch "$HOME/.gitconfig.local"
  git config --file "$HOME/.gitconfig.local" gpg.ssh.program "/opt/1Password/op-ssh-sign"
  git config --file "$HOME/.gitconfig.local" user.signingkey "$signing_key"
  git config --global gpg.format ssh
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true

  log_success "Git SSH signing configured with 1Password"
}

log_header "Dotfiles Setup"

if confirm "Symlink dotfiles using stow?"; then
  log_info "Creating symlinks..."
  
  cd "$DOTFILES_DIR"
  stow --adopt -v .
  
  log_success "Dotfiles symlinked"
fi

if [[ ! -f "$HOME/.gitconfig.local" ]]; then
  if confirm "Setup git local configuration?"; then
    if [[ -f "$DOTFILES_DIR/.templates/.gitconfig.local.template" ]]; then
      if [[ -t 0 && -t 1 ]]; then
        name=$(read_input "Your full name" "Your Name")
        email=$(read_input "Your email" "you@example.com")
      else
        name="${GIT_USER_NAME:-Your Name}"
        email="${GIT_USER_EMAIL:-you@example.com}"
      fi
      
      sed "s/you@example.com/$email/; s/Your Name/$name/" \
        "$DOTFILES_DIR/.templates/.gitconfig.local.template" > "$HOME/.gitconfig.local"
      
      log_success "Git local config created at $HOME/.gitconfig.local"
    fi
  fi
fi

if confirm "Setup 1Password SSH agent and Git signing?"; then
  setup_1password_ssh_git
fi

log_success "Dotfiles setup complete"
