#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/fedora.sh"

log_header "Fedora Cleanup"

if ! confirm "Remove unused Fedora/GNOME packages before installing dotfiles packages?"; then
  log_info "Skipping Fedora cleanup"
  exit 0
fi

# Mark the GNOME pieces we still want to keep as user-installed so autoremove
# does not prune the display manager, file manager, settings, or auth/keyring bits.
keep_packages=(
  gdm
  nautilus
  gnome-shell
  gnome-session
  gnome-session-wayland-session
  gnome-control-center
  gnome-settings-daemon
  gnome-keyring
  gnome-keyring-pam
  gnome-online-accounts
  xdg-desktop-portal-gnome
)

installed_keep=()
for pkg in "${keep_packages[@]}"; do
  if rpm -q "$pkg" &>/dev/null; then
    installed_keep+=("$pkg")
  fi
done

if [[ ${#installed_keep[@]} -gt 0 ]]; then
  log_info "Marking essential GNOME packages to keep..."
  sudo dnf -y mark user "${installed_keep[@]}" || log_warn "Could not mark some packages as user-installed"
fi

cleanup_packages=(
  baobab
  cheese
  evince
  evince-djvu
  file-roller
  gnome-boxes
  gnome-browser-connector
  gnome-calculator
  gnome-calendar
  gnome-characters
  gnome-classic-session
  gnome-clocks
  gnome-color-manager
  gnome-connections
  gnome-contacts
  gnome-disk-utility
  gnome-font-viewer
  gnome-initial-setup
  gnome-logs
  gnome-maps
  gnome-photos
  gnome-remote-desktop
  gnome-software
  gnome-software-fedora-langpacks
  gnome-system-monitor
  gnome-text-editor
  gnome-tour
  gnome-user-docs
  gnome-user-share
  gnome-weather
  loupe
  malcontent-control
  mediawriter
  orca
  rhythmbox
  simple-scan
  snapshot
  totem
  yelp
)

installed_cleanup=()
for pkg in "${cleanup_packages[@]}"; do
  if rpm -q "$pkg" &>/dev/null; then
    installed_cleanup+=("$pkg")
  fi
done

while IFS= read -r pkg; do
  [[ -n "$pkg" ]] && installed_cleanup+=("$pkg")
done < <(rpm -qa 'libreoffice-*' --qf '%{NAME}\n' 2>/dev/null | sort -u)

if [[ ${#installed_cleanup[@]} -eq 0 ]]; then
  log_info "No cleanup packages are installed"
else
  log_info "Removing ${#installed_cleanup[@]} unused package(s)..."
  sudo dnf remove -y "${installed_cleanup[@]}"
fi

if [[ "${RUN_DNF_AUTOREMOVE:-}" == "1" || "${RUN_DNF_AUTOREMOVE:-}" == "true" ]]; then
  log_info "Running dnf autoremove..."
  sudo dnf autoremove -y
else
  log_info "Skipping dnf autoremove (set RUN_DNF_AUTOREMOVE=1 to enable)"
fi

log_success "Fedora cleanup complete"
