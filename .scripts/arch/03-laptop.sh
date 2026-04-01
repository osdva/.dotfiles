#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"

log_header "Laptop Tools Setup"

if ! confirm "Is this a laptop? Install laptop-specific tools?"; then
  log_info "Skipping laptop tools"
  exit 0
fi

packages=(thermald acpi tlp tlp-pd tlp-rdw fwupd)

install_intel_microcode=false
if confirm "Install Intel microcode?"; then
  packages+=(intel-ucode)
  install_intel_microcode=true
fi

setup_fingerprint=false
if confirm "Setup fingerprint reader (fprintd)?"; then
  packages+=(fprintd)
  setup_fingerprint=true
fi

log_info "Installing laptop tools..."
paru -S --needed --noconfirm "${packages[@]}"

log_info "Enabling services..."
sudo systemctl enable --now thermald.service
sudo systemctl enable --now fwupd-refresh.timer
sudo systemctl enable --now tlp.service
sudo systemctl enable --now tlp-pd.service

if confirm "Configure lid management?"; then
  if [[ -d "$SCRIPT_DIR/../../.cp/systemd/logind.conf.d" ]]; then
    sudo cp -r "$SCRIPT_DIR/../../.cp/systemd/logind.conf.d/" /etc/systemd/
  fi
  if [[ -d "$SCRIPT_DIR/../../.cp/systemd/sleep.conf.d" ]]; then
    sudo cp -r "$SCRIPT_DIR/../../.cp/systemd/sleep.conf.d/" /etc/systemd/
  fi
  log_success "Lid management configured"
fi

if confirm "Configure TLP?"; then
  if [[ -d "$SCRIPT_DIR/../../.cp/tlp.conf" ]]; then
    sudo cp -r "$SCRIPT_DIR/../../.cp/tlp.conf" /etc/
  fi
  log_success "TLP configured"
fi

if confirm "Enable weekly filesystem TRIM? (Recommended for SSDs)"; then
  log_info "Enabling fstrim.timer..."
  sudo systemctl enable --now fstrim.timer
  log_success "fstrim.timer enabled (runs weekly)"

  log_info "Running initial TRIM on all mounted filesystems..."
  sudo fstrim -av
  log_success "Initial TRIM complete"
fi

log_success "Laptop tools installed and configured"
log_info "Run 'fwupdmgr update' to update firmware"

if [[ "$setup_fingerprint" == "true" ]]; then
  echo
  log_header "Fingerprint Enrollment"
  log_info "Starting fingerprint enrollment..."
  fprintd-enroll
  fprintd-verify

  if [[ -d "$SCRIPT_DIR/../../.cp/pam.d" ]]; then
    sudo cp -r "$SCRIPT_DIR/../../.cp/pam.d/system-local-login" /etc/pam.d/system-local-login
    sudo cp -r "$SCRIPT_DIR/../../.cp/pam.d/polkit-1" /etc/pam.d/polkit-1
  fi
  if [[ -f "$SCRIPT_DIR/../../.cp/systemd/system/kill-fprintd.service" ]]; then
    sudo cp -r "$SCRIPT_DIR/../../.cp/systemd/system/kill-fprintd.service" /etc/systemd/system/
  fi
  log_success "PAM configuration updated"

  log_success "Fingerprint setup complete"
fi
