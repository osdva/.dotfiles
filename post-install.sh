#!/usr/bin/env bash

# Post-install script for setup that should run after first login/session
# Usage: bash ./post-install.sh <arch|darwin>

set -e

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/.scripts/lib/tui.sh"

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
  if ! command_exists sudo; then
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

  if command_exists gum; then
    local action
    action=$(choose_one "Post-install action" "run all" "choose scripts" "skip" || true)

    case "$action" in
      "run all")
        echo -e "${BLUE}Running all post-install scripts${NC}"
        ;;
      "choose scripts")
        local script_names=()
        local script_name
        for script in "${scripts[@]}"; do
          script_names+=("$(basename "$script")")
        done

        local selected_names=()
        while true; do
          mapfile -t selected_names < <(choose_many "Select post-install scripts (Space to select, Enter to run)" "${script_names[@]}" || true)

          if [[ ${#selected_names[@]} -gt 0 ]]; then
            break
          fi

          echo -e "${YELLOW}No scripts selected. Use Space to select items before pressing Enter.${NC}"
          if ! confirm "Try selecting scripts again?"; then
            return 0
          fi
        done

        echo -e "${BLUE}Selected post-install script(s): ${selected_names[*]}${NC}"

        local selected_scripts=()
        local selected_name
        for selected_name in "${selected_names[@]}"; do
          for script in "${scripts[@]}"; do
            if [[ "$(basename "$script")" == "$selected_name" ]]; then
              selected_scripts+=("$script")
              break
            fi
          done
        done
        scripts=("${selected_scripts[@]}")
        ;;
      *)
        echo -e "${YELLOW}Skipping post-install scripts${NC}"
        return 0
        ;;
    esac
  else
    echo -e "${YELLOW}gum not found; running all post-install scripts${NC}"
  fi

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
    echo -e "${YELLOW}Post-install completed with failed script(s): ${failed_scripts[*]}${NC}" >&2
  fi
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
