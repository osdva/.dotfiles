#!/usr/bin/env bash

command_exists() {
  command -v "$1" &>/dev/null
}

command_path() {
  command -v "$1"
}
