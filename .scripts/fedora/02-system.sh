#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/tui.sh"
source "$SCRIPT_DIR/../lib/fedora.sh"

log_header "Setting up system packages"

log_info "Installing desktop/session packages..."
fedora_install_packages niri greetd tuigreet kitty matugen pam-u2f swaybg xwayland-satellite NetworkManager

log_info "Configuring greetd to use tuigreet..."
sudo install -d -m 0755 /etc/greetd

# Fedora's tuigreet stores --remember state in /var/lib/greetd/tuigreet-*.
# Run the greeter as the greetd user so it can persist the last username.
tuigreet_user="greetd"
tuigreet_group="greetd"
login_user="${SUDO_USER:-${USER:-}}"
if [[ -z "$login_user" || "$login_user" == "root" ]]; then
  login_user="$(logname 2>/dev/null || true)"
fi

if getent passwd "$tuigreet_user" &>/dev/null; then
  tuigreet_group="$(id -gn "$tuigreet_user")"
  sudo install -d -o "$tuigreet_user" -g "$tuigreet_group" -m 0750 /var/lib/greetd
  # Keep the upstream cache path valid too, in case the package changes back.
  sudo install -d -o "$tuigreet_user" -g "$tuigreet_group" -m 0755 /var/cache/tuigreet
  if [[ -n "$login_user" && "$login_user" != "root" ]]; then
    printf '%s\n' "$login_user" | sudo tee /var/lib/greetd/tuigreet-lastuser >/dev/null
    sudo chown "$tuigreet_user:$tuigreet_group" /var/lib/greetd/tuigreet-lastuser
    sudo chmod 0644 /var/lib/greetd/tuigreet-lastuser
  fi
else
  log_warn "$tuigreet_user user not found; tuigreet --remember may not be able to persist state"
  sudo install -d -m 0750 /var/lib/greetd
  sudo install -d -m 0755 /var/cache/tuigreet
fi

sudo tee /etc/greetd/config.toml >/dev/null <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-user-session --asterisks --cmd niri-session"
user = "$tuigreet_user"
EOF

log_info "Installing Noctalia shell from Terra..."
fedora_install_packages noctalia-shell

log_info "Enabling Vicinae COPR repository..."
sudo dnf copr enable -y quadratech188/vicinae

log_info "Installing Vicinae from COPR..."
fedora_install_packages vicinae

log_info "Enabling network manager..."
enable_systemd_unit NetworkManager.service

log_success "System packages installed"
