#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/fedora.sh"

log_header "Installing Packages"

if [[ ! -f /etc/yum.repos.d/1password.repo ]]; then
  if confirm "Enable 1Password repository?"; then
    log_info "Adding 1Password repository..."
    sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
    sudo tee /etc/yum.repos.d/1password.repo >/dev/null <<'EOF'
[1password]
name=1Password Stable Channel
baseurl=https://downloads.1password.com/linux/rpm/stable/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://downloads.1password.com/linux/keys/1password.asc
EOF
  fi
fi

if ! dnf repolist --enabled | grep -q 'copr:copr.fedorainfracloud.org:jdxcode:mise'; then
  if confirm "Enable mise COPR repository?"; then
    log_info "Enabling mise COPR repository..."
    sudo dnf copr enable -y jdxcode/mise
  fi
fi

if ! rpm -q terra-release &>/dev/null; then
  if confirm "Enable Terra repository?"; then
    log_info "Enabling Terra repository..."
    sudo dnf install -y --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' --setopt='terra.gpgkey=https://repos.fyralabs.com/terra$releasever/key.asc' terra-release
  fi
fi

if rpm -q terra-release &>/dev/null; then
  fedora_version="$(rpm -E %fedora)"
  terra_key_url="https://repos.fyralabs.com/terra${fedora_version}/key.asc"
  terra_key_file="/etc/pki/rpm-gpg/RPM-GPG-KEY-terra${fedora_version}"
  log_info "Importing Terra GPG key..."
  sudo rpm --import "$terra_key_url"
  if [[ -f "$terra_key_file" ]]; then
    sudo rpm --import "$terra_key_file"
  fi
fi

if [[ ! -f /etc/yum.repos.d/tailscale.repo ]]; then
  if confirm "Enable Tailscale repository?"; then
    log_info "Enabling Tailscale repository..."
    sudo dnf config-manager addrepo --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo
  fi
fi

if [[ -f /etc/yum.repos.d/tailscale.repo ]]; then
  log_info "Importing Tailscale GPG key..."
  sudo rpm --import https://pkgs.tailscale.com/stable/fedora/repo.gpg
fi

sudo dnf makecache -y

fedora_install_package_file "$SCRIPT_DIR/../packages/fedora/packages"

if command -v flatpak &>/dev/null; then
  if ! flatpak remotes --columns=name | grep -qx flathub; then
    if confirm "Enable Flathub remote?"; then
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      log_success "Flathub enabled"
    fi
  fi
else
  log_warn "flatpak is not installed; skipping Flathub setup"
fi

log_success "Package installation complete"
