#!/bin/bash

# This script is designed to automatically install rar2fs from GitHub releases.
# Filename: install_rar2fs.sh

# Constants for repository and dependencies
# REPO: The GitHub repository for rar2fs
# UNRAR_VERSION: The version of UnRAR to be installed
# API_URL: The URL to fetch the latest release information from GitHub
# DEPENDENCIES: The list of dependencies required to build and install rar2fs
readonly REPO="hasse69/rar2fs"
readonly UNRAR_VERSION="6.2.1"
readonly API_URL="https://api.github.com/repos/$REPO/releases/latest"
readonly DEPENDENCIES="make libfuse-dev g++ unzip"

# Fetches the latest version tag from GitHub
fetch_latest_version() {
  local latest_version
  latest_version=$(curl -s "$API_URL" | jq -r '.tag_name')
  if [[ -z "$latest_version" ]]; then
    echo "Error fetching the latest version." >&2
    exit 1
  fi
  echo "$latest_version"
}

# Constructs the download URL for the specified version
build_download_url() {
  local version="$1"
  echo "https://github.com/$REPO/releases/download/$version/rar2fs-$version.tar.gz"
}

# Downloads and installs UnRAR
install_unrar() {
  local work_dir="$1"
  wget "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" -P "$work_dir" || return 1
  tar -zxvf "$work_dir/unrarsrc-${UNRAR_VERSION}.tar.gz" -C "$work_dir" || return 1
  pushd "$work_dir/unrar" || return 1
  make && sudo make install || return 1
  make lib && sudo make install-lib || return 1
  popd
}

# Downloads and installs rar2fs
install_rar2fs() {
  local work_dir="$1"
  local version="$2"
  local download_url="$3"
  wget "$download_url" -P "$work_dir" || return 1
  tar -zxvf "$work_dir/rar2fs-$version.tar.gz" -C "$work_dir" || return 1
  pushd "$work_dir/rar2fs-$version" || return 1
  ./configure --with-unrar-lib="/usr/lib/" || return 1
  make && sudo make install || return 1
  popd
}

# Manages the installation process
main() {
  local work_dir version download_url

  work_dir=$(mktemp -d)
  trap 'rm -rf "$work_dir"' EXIT  # Clean up on script exit

  sudo apt-get update -qq && sudo apt-get install -y $DEPENDENCIES || {
    echo "Failed to install dependencies." >&2
    exit 1
  }

  install_unrar "$work_dir" || {
    echo "UnRAR installation failed." >&2
    exit 1
  }

  version=$(fetch_latest_version) || exit 1
  download_url=$(build_download_url "$version") || exit 1
  install_rar2fs "$work_dir" "$version" "$download_url" || {
    echo "rar2fs installation failed." >&2
    exit 1
  }
}

main
