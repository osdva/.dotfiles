#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/commands.sh"

log_info() {
  if command_exists gum; then
    gum log --level info "$*"
  else
    echo "INFO $*"
  fi
}

log_success() {
  if command_exists gum; then
    gum log --level info --prefix "✓" "$*"
  else
    echo "INFO ✓ $*"
  fi
}

log_error() {
  if command_exists gum; then
    gum log --level error "$*" >&2
  else
    echo "ERROR $*" >&2
  fi
}

log_warn() {
  if command_exists gum; then
    gum log --level warn "$*"
  else
    echo "WARN $*"
  fi
}

log_step() {
  if command_exists gum; then
    gum style --foreground 212 "==> $*"
  else
    echo "==> $*"
  fi
  echo
}

log_header() {
  echo
  echo "================================================"
  echo "  $*"
  echo "================================================"
  echo
}

confirm() {
  if [[ "${ASSUME_YES:-}" == "1" || "${ASSUME_YES:-}" == "true" ]]; then
    log_info "$* yes"
    return 0
  fi

  if command_exists gum; then
    gum confirm "$*"
    return $?
  fi

  local answer
  read -r -p "$* [y/N]: " answer
  [[ "$answer" =~ ^[Yy]$ ]]
}

read_input() {
  local prompt="$1"
  local default="$2"
  local value

  if command_exists gum; then
    gum input --value "$default" --prompt "$prompt: "
    return $?
  fi

  read -r -p "$prompt [$default]: " value
  echo "${value:-$default}"
}

choose_one() {
  local header="$1"
  shift

  if command_exists gum; then
    gum choose --header "$header" "$@"
    return $?
  fi

  local choices=("$@")
  local index=1 selected
  echo "$header" >&2
  for choice in "${choices[@]}"; do
    echo "  $index) $choice" >&2
    index=$((index + 1))
  done

  read -r -p "Choose [1]: " selected
  selected="${selected:-1}"
  [[ "$selected" =~ ^[0-9]+$ ]] || return 1
  (( selected >= 1 && selected <= ${#choices[@]} )) || return 1
  echo "${choices[$((selected - 1))]}"
}

choose_many() {
  local header="$1"
  shift

  if command_exists gum; then
    gum choose --no-limit --header "$header" "$@" | sed '/^[[:space:]]*$/d'
    return ${PIPESTATUS[0]}
  fi

  local choices=("$@")
  local selected
  echo "Available choices: ${choices[*]}" >&2
  read -r -p "Select values (space/comma separated): " selected
  tr ', ' '\n' <<< "$selected" | sed '/^[[:space:]]*$/d'
}
