#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v dnf &>/dev/null; then
  echo "Error: dnf not found. This script is intended for Fedora." >&2
  exit 1
fi

if ! command -v gum &>/dev/null; then
  echo "Installing gum..."
  sudo dnf install -y gum
fi

source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/fedora.sh"

log_header "Installing Essential Packages"

log_info "Updating package metadata..."
sudo dnf makecache -y

log_info "Installing essential packages..."
mapfile -t packages < <(read_package_file "$SCRIPT_DIR/../packages/fedora/essential")
sudo dnf install -y "${packages[@]}"

if ! rpm -q rpmfusion-free-release &>/dev/null || ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
  if confirm "Enable RPM Fusion repositories? (recommended for ffmpeg/media packages)"; then
    fedora_version=$(rpm -E %fedora)
    sudo dnf install -y \
      "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${fedora_version}.noarch.rpm" \
      "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${fedora_version}.noarch.rpm"
    sudo dnf makecache -y
    log_success "RPM Fusion enabled"
  fi
fi

log_success "Essential packages installed"
