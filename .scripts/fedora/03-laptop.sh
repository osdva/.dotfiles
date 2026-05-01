#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/fedora.sh"

log_header "Laptop Tools Setup"

if ! confirm "Is this a laptop? Install laptop-specific tools?"; then
  log_info "Skipping laptop tools"
  exit 0
fi

packages=(thermald acpi tlp tlp-rdw fwupd)

if confirm "Install CPU microcode package?"; then
  packages+=(microcode_ctl)
fi

setup_fingerprint=false
if confirm "Setup fingerprint reader (fprintd)?"; then
  packages+=(fprintd fprintd-pam)
  setup_fingerprint=true
fi

if rpm -q tuned-ppd &>/dev/null; then
  log_info "Removing tuned-ppd because it conflicts with TLP..."
  sudo dnf remove -y tuned-ppd
fi

if rpm -q power-profiles-daemon &>/dev/null; then
  log_info "Removing power-profiles-daemon because it conflicts with TLP..."
  sudo dnf remove -y power-profiles-daemon
fi

log_info "Installing laptop tools..."
fedora_install_packages "${packages[@]}"

log_info "Enabling services..."
enable_systemd_unit thermald.service
enable_systemd_unit fwupd-refresh.timer
enable_systemd_unit tlp.service
enable_systemd_unit tlp-pd.service

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
  if [[ -f "$SCRIPT_DIR/../../.cp/tlp.conf" ]]; then
    sudo cp "$SCRIPT_DIR/../../.cp/tlp.conf" /etc/tlp.conf
  fi
  log_success "TLP configured"
fi

if confirm "Enable weekly filesystem TRIM? (Recommended for SSDs)"; then
  log_info "Enabling fstrim.timer..."
  enable_systemd_unit fstrim.timer

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
  sudo fprintd-enroll "$USER" || log_warn "Fingerprint enrollment failed"
  sudo fprintd-verify "$USER" || log_warn "Fingerprint verification failed"

  if command -v authselect &>/dev/null; then
    log_info "Enabling Fedora fingerprint auth profile..."
    sudo authselect enable-feature with-fingerprint || log_warn "Could not enable authselect fingerprint feature"
    sudo authselect apply-changes -b || log_warn "Could not apply authselect changes"
  else
    log_warn "authselect not found; configure PAM fingerprint auth manually"
  fi

  log_success "Fingerprint setup complete"
  log_info "Fingerprint auth is enabled through PAM/authselect; greetd uses /etc/pam.d/greetd."
fi
