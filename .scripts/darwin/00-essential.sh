#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/packages.sh"

log_header "Installing Essential Packages"

if ! command_exists brew; then
  log_info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  
  log_success "Homebrew installed"
fi

log_info "Updating Homebrew..."
brew update

mapfile -t packages < <(read_package_list "$SCRIPT_DIR/../packages/darwin/essential")

log_info "Installing essential packages..."
brew install "${packages[@]}"

log_success "Essential packages installed"
