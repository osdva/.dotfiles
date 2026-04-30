#!/usr/bin/env bash

log_info() {
  if command -v gum &>/dev/null; then
    gum log --level info "$*"
  else
    echo "INFO $*"
  fi
}

log_success() {
  if command -v gum &>/dev/null; then
    gum log --level info --prefix "✓" "$*"
  else
    echo "INFO ✓ $*"
  fi
}

log_error() {
  if command -v gum &>/dev/null; then
    gum log --level error "$*" >&2
  else
    echo "ERROR $*" >&2
  fi
}

log_warn() {
  if command -v gum &>/dev/null; then
    gum log --level warn "$*"
  else
    echo "WARN $*"
  fi
}

log_step() {
  if command -v gum &>/dev/null; then
    gum style --foreground 212 "==> $*"
  else
    echo "==> $*"
  fi
  echo
}

log_header() {
  echo
  if command -v gum &>/dev/null; then
    gum style \
      --border double \
      --align center \
      --width 50 \
      --margin "1 2" \
      --padding "1 4" \
      "$*"
  else
    echo "================================================"
    echo "  $*"
    echo "================================================"
  fi
  echo
}

confirm() {
  if [[ "${ASSUME_YES:-}" == "1" || "${ASSUME_YES:-}" == "true" ]]; then
    log_info "$* yes"
    return 0
  fi

  gum confirm "$*"
}

read_input() {
  local prompt="$1"
  local default="$2"
  gum input --placeholder "$default" --prompt "$prompt: "
}
