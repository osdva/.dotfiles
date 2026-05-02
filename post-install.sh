#!/usr/bin/env bash

# Post-install script for setup that should run after first login/session
# Usage: bash ./post-install.sh <arch|darwin>

set -e

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

print_usage() {
  echo "Usage: $0 <arch|darwin>"
  echo ""
  echo "Run post-install scripts after bootstrap has completed"
  echo ""
  echo "Arguments:"
  echo "  arch    - Run Arch Linux post-install scripts"
  echo "  darwin  - Run macOS (Darwin) post-install scripts"
  exit 1
}

print_header() {
  echo -e "${BLUE}================================================${NC}"
  echo -e "${BLUE}  Dotfiles Post Install${NC}"
  echo -e "${BLUE}================================================${NC}"
  echo ""
}

keep_sudo_alive() {
  if ! command -v sudo &>/dev/null; then
    return 0
  fi

  echo -e "${BLUE}Requesting sudo once for post-install...${NC}"
  sudo -v

  (
    while true; do
      sudo -n -v 2>/dev/null || exit
      sleep 60
    done
  ) &
  SUDO_KEEPALIVE_PID=$!
  trap '[[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
}

run_scripts() {
  local system="$1"
  local scripts_dir=".scripts/$system/post-install"

  if [[ ! -d "$scripts_dir" ]]; then
    echo -e "${YELLOW}No post-install directory found: $scripts_dir${NC}"
    return 0
  fi

  local scripts=()
  while IFS= read -r -d '' script; do
    scripts+=("$script")
  done < <(find "$scripts_dir" -maxdepth 1 -name "*.sh" -type f -print0 | sort -z)

  if [[ ${#scripts[@]} -eq 0 ]]; then
    echo -e "${YELLOW}No post-install scripts found in $scripts_dir${NC}"
    return 0
  fi

  echo -e "${BLUE}Found ${#scripts[@]} post-install script(s)${NC}"
  echo ""

  for script in "${scripts[@]}"; do
    local script_name
    script_name=$(basename "$script")
    echo -e "${BLUE}▶ Running: $script_name${NC}"
    echo ""

    if bash "$script"; then
      echo ""
      echo -e "${GREEN}✓ $script_name completed${NC}"
      echo ""
    else
      echo ""
      echo -e "${RED}✗ $script_name failed${NC}" >&2
      exit 1
    fi
  done
}

main() {
  if [[ $# -ne 1 ]]; then
    print_usage
  fi

  local system="$1"

  if [[ "$system" != "arch" && "$system" != "darwin" ]]; then
    echo -e "${RED}Error: Invalid system '$system'${NC}" >&2
    echo ""
    print_usage
  fi

  print_header

  echo -e "${BLUE}System: $system${NC}"
  echo ""

  keep_sudo_alive
  run_scripts "$system"

  echo ""
  echo -e "${GREEN}================================================${NC}"
  echo -e "${GREEN}  Post Install Complete!${NC}"
  echo -e "${GREEN}================================================${NC}"
  echo ""
}

main "$@"
