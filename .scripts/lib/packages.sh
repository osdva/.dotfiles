#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/commands.sh"

read_package_list() {
  local file="$1"

  while IFS= read -r pkg; do
    [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue
    printf '%s\n' "$pkg"
  done < "$file"
}

package_installed() {
  local pkg="$1"

  if command_exists pacman; then
    pacman -Qi "$pkg" &>/dev/null
  elif command_exists brew; then
    brew list --formula "$pkg" &>/dev/null || brew list --cask "$pkg" &>/dev/null
  else
    command_exists "$pkg"
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
