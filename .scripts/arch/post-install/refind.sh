#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$SCRIPT_DIR/../../lib/tui.sh"

log_header "rEFInd Setup"

REFIND_DIR="/boot/EFI/refind"
THEMES_DIR="$REFIND_DIR/themes"
REFIND_CONF="$REFIND_DIR/refind.conf"
REFIND_LINUX_CONF="/boot/refind_linux.conf"
MINIMAL_MODDED_REPO="https://github.com/AdityaGarg8/rEFInd-minimal-modded"

if ! confirm "Install rEFInd-minimal-modded theme?"; then
  log_info "Skipping rEFInd theme setup"
  exit 0
fi

if [[ ! -d "$REFIND_DIR" ]]; then
  log_error "rEFInd directory not found at $REFIND_DIR"
  log_info "Is rEFInd installed? Is the ESP mounted at /boot?"
  exit 1
fi

# Create themes directory
sudo mkdir -p "$THEMES_DIR"

# Install rEFInd-minimal-modded into themes/rEFInd-minimal
# (the modded theme's theme.conf hardcodes paths as themes/rEFInd-minimal/...)
if [[ -d "$THEMES_DIR/rEFInd-minimal" ]]; then
  log_info "rEFInd-minimal-modded already installed, pulling latest..."
  sudo git -C "$THEMES_DIR/rEFInd-minimal" pull --ff-only
else
  log_info "Cloning rEFInd-minimal-modded..."
  sudo git clone "$MINIMAL_MODDED_REPO" "$THEMES_DIR/rEFInd-minimal"
fi
log_success "rEFInd-minimal-modded installed"

# Remove any existing theme include and showtools override lines from refind.conf
sudo sed -i '/^include themes\/rEFInd-minimal/d' "$REFIND_CONF"
sudo sed -i '/^showtools shutdown,firmware,hidden_tags/d' "$REFIND_CONF"

# Override theme.conf: showtools and show labels under icons
sudo sed -i 's/^showtools.*/showtools shutdown,firmware,hidden_tags/' "$THEMES_DIR/rEFInd-minimal/theme.conf"
sudo sed -i 's/^hideui singleuser,hints,arrows,label,badges/hideui singleuser,hints,arrows,badges/' "$THEMES_DIR/rEFInd-minimal/theme.conf"

# Add theme include
echo "include themes/rEFInd-minimal/theme.conf" | sudo tee -a "$REFIND_CONF" > /dev/null

# Set timeout to 3 seconds
sudo sed -i 's/^timeout [0-9]*/timeout 3/' "$REFIND_CONF"
log_info "Set rEFInd timeout to 3s"

# Only show manual boot entries
# 'internal' finds auto-detected UKI/systemd-boot duplicates
# 'external'/'optical' can pick up NVRAM tools as extra icons
# firmware reboot tool is still shown via showtools
sudo sed -i 's/^#\?scanfor.*/scanfor manual/' "$REFIND_CONF"

# Skip scanning EFI/Linux (UKI) and EFI/systemd directories
if ! sudo grep -q "^dont_scan_dirs" "$REFIND_CONF" 2>/dev/null; then
  echo "dont_scan_dirs EFI/Linux,EFI/systemd" | sudo tee -a "$REFIND_CONF" > /dev/null
else
  # Replace existing dont_scan_dirs with our version
  sudo sed -i 's/^dont_scan_dirs.*/dont_scan_dirs EFI\/Linux,EFI\/systemd/' "$REFIND_CONF"
fi

# Add manual Arch Linux menuentry with themed icon if not already present
MENUENTRY_MARKER="# BEGIN arch-menuentry"
if ! sudo grep -q "$MENUENTRY_MARKER" "$REFIND_CONF" 2>/dev/null; then
  {
    echo ""
    echo "$MENUENTRY_MARKER"
    echo 'menuentry "Arch Linux" {'
    echo "    icon      EFI/refind/themes/rEFInd-minimal/icons/os_arch.png"
    echo "    loader    /EFI/Linux/arch-linux.efi"
    echo "}"
    echo "# END arch-menuentry"
  } | sudo tee -a "$REFIND_CONF" > /dev/null
  log_success "Added Arch Linux menuentry with themed icon"
else
  log_info "Arch Linux menuentry already present"
fi

log_success "rEFInd setup complete — reboot to see the new theme"