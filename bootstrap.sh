#!/usr/bin/env bash

# Bootstrap script for fresh system installation
# Usage: sh ./bootstrap.sh <arch|darwin>

set -e

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.scripts/lib/commands.sh"

print_usage() {
  echo "Usage: $0 <arch|darwin>"
  echo ""
  echo "Bootstrap a fresh system installation"
  echo ""
  echo "Arguments:"
  echo "  arch    - Bootstrap Arch Linux system"
  echo "  darwin  - Bootstrap macOS (Darwin) system"
  exit 1
}

print_header() {
  echo -e "${BLUE}================================================${NC}"
  echo -e "${BLUE}  Dotfiles Bootstrap${NC}"
  echo -e "${BLUE}================================================${NC}"
  echo ""
}

keep_sudo_alive() {
  if ! command_exists sudo; then
    return 0
  fi

  echo -e "${BLUE}Requesting sudo once for bootstrap...${NC}"
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
  local scripts_dir=".scripts/$system"
  
  if [[ ! -d "$scripts_dir" ]]; then
    echo -e "${RED}Error: Scripts directory not found: $scripts_dir${NC}" >&2
    exit 1
  fi
  
  # Find all .sh files and sort them
  local scripts=()
  while IFS= read -r -d '' script; do
    scripts+=("$script")
  done < <(find "$scripts_dir" -maxdepth 1 -name "*.sh" -type f -print0 | sort -z)
  
  if [[ ${#scripts[@]} -eq 0 ]]; then
    echo -e "${RED}Error: No scripts found in $scripts_dir${NC}" >&2
    exit 1
  fi
  
  echo -e "${BLUE}Found ${#scripts[@]} setup script(s)${NC}"
  echo ""
  
  # Execute each script in order. Keep going if one step fails so the rest of
  # the machine can still be bootstrapped.
  local failed_scripts=()

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
      echo -e "${RED}✗ $script_name failed; continuing${NC}" >&2
      echo ""
      failed_scripts+=("$script_name")
    fi
  done

  if [[ ${#failed_scripts[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Bootstrap completed with failed script(s): ${failed_scripts[*]}${NC}" >&2
  fi
}

main() {
  # Check arguments
  if [[ $# -ne 1 ]]; then
    print_usage
  fi
  
  local system="$1"
  
  # Validate system argument
  if [[ "$system" != "arch" && "$system" != "darwin" ]]; then
    echo -e "${RED}Error: Invalid system '$system'${NC}" >&2
    echo ""
    print_usage
  fi
  
  print_header
  
  echo -e "${BLUE}System: $system${NC}"
  echo ""

  # Ask for sudo once and keep the timestamp fresh while scripts run.
  keep_sudo_alive
  
  # Run the setup scripts
  run_scripts "$system"
  
  echo ""
  echo -e "${GREEN}================================================${NC}"
  echo -e "${GREEN}  Bootstrap Complete!${NC}"
  echo -e "${GREEN}================================================${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Restart your shell or run: exec bash"
  echo "  2. Run post-install scripts as needed: bash post-install.sh $system"
  echo "  3. Open tmux and press Ctrl+A + I to install plugins"
  echo "  4. Run 'nvim' to let plugins install automatically"
  echo ""
}

main "$@"
