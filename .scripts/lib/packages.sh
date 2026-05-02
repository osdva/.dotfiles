#!/usr/bin/env bash

package_installed() {
  local pkg="$1"

  if command -v pacman &>/dev/null; then
    pacman -Qi "$pkg" &>/dev/null
  elif command -v brew &>/dev/null; then
    brew list --formula "$pkg" &>/dev/null || brew list --cask "$pkg" &>/dev/null
  else
    command -v "$pkg" &>/dev/null
  fi
}

installed_packages() {
  local pkg

  for pkg in "$@"; do
    if package_installed "$pkg"; then
      printf '%s\n' "$pkg"
    fi
  done
}

missing_packages() {
  local pkg

  for pkg in "$@"; do
    if ! package_installed "$pkg"; then
      printf '%s\n' "$pkg"
    fi
  done
}
