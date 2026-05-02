#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/packages.sh"

sudo pacman -S --needed --noconfirm gum

log_header "Installing Essential Packages"

log_info "Updating package database..."
sudo pacman -Sy --noconfirm

mapfile -t packages < <(read_package_list "$SCRIPT_DIR/../packages/arch/essential")

log_info "Installing essential packages..."
sudo pacman -S --needed --noconfirm "${packages[@]}"

if ! command_exists rustc; then
  log_info "Installing Rust toolchain..."
  sudo pacman -S --needed --noconfirm rustup
  rustup default stable
fi

if ! command_exists paru; then
  log_info "Installing paru (AUR helper)..."
  
  tmpdir=$(mktemp -d)
  git clone https://aur.archlinux.org/paru-git.git "$tmpdir/paru"
  (cd "$tmpdir/paru" && makepkg -si --noconfirm)
  rm -rf "$tmpdir"
  
  log_success "paru installed"
fi

log_success "Essential packages installed"
