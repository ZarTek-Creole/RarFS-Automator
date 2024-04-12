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
readonly DEPENDENCIES="make gcc g++ libfuse-dev unzip ccache"
readonly NUM_CORES=$(nproc)  # Automatically determines the number of cores

# Fetches the latest version tag and download URL from GitHub
fetch_latest_version_and_url() {
  local response
  response=$(curl -s "$API_URL")
  local latest_version
  latest_version=$(echo "$response" | jq -r '.tag_name')
  local download_url
  download_url=$(echo "$response" | jq -r '.assets[0].browser_download_url')

  if [[ -z "$latest_version" || -z "$download_url" ]]; then
    echo "Error fetching the latest version or download URL." >&2
    exit 1
  fi
  echo "$latest_version" "$download_url"
}

# Downloads and installs UnRAR
install_unrar() {
  local work_dir="$1"
  echo "Installing UnRAR..."
  wget -q "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" -P "$work_dir" || return 1
  tar -zxf "$work_dir/unrarsrc-${UNRAR_VERSION}.tar.gz" -C "$work_dir" || return 1
  pushd "$work_dir/unrar" > /dev/null || return 1
  make -s -j"$NUM_CORES" || { echo "Compilation of unrar failed" >&2; return 1; }
  sudo make install || { echo "Installation of unrar failed" >&2; return 1; }
  make -s lib || { echo "Compilation of library failed" >&2; return 1; }
  sudo make install-lib || { echo "Library installation of unrar failed" >&2; return 1; }
  popd > /dev/null
}

# Downloads and installs rar2fs
install_rar2fs() {
  local work_dir="$1"
  local download_url="$2"
  echo "Installing rar2fs..."
  wget -q "$download_url" -P "$work_dir" || return 1
  local version_dir
  version_dir=$(basename "$download_url" .tar.gz)
  tar -zxf "$work_dir/$version_dir.tar.gz" -C "$work_dir" || return 1
  pushd "$work_dir/$version_dir" > /dev/null || return 1
  ./configure --with-unrar-lib="/usr/lib/" > /dev/null 2>&1 && make -s -j"$NUM_CORES" && sudo make install > /dev/null 2>&1 || { echo "Installation failed" >&2; return 1; }
  popd > /dev/null
}

# Install necessary dependencies
install_dependencies() {
    echo "Installing dependencies..."
    sudo apt-get update -qq && sudo apt-get install -y $DEPENDENCIES > /dev/null || return 1
    echo "Dependencies installed."
}

# Configure ccache for faster recompilation
configure_ccache() {
    echo "Configuring ccache..."
    export CC="ccache gcc"
    export CXX="ccache g++"
    ccache --max-size=5G > /dev/null  # Set the maximum cache size to 5GB
    echo "ccache configured."
}

# Manages the installation process
main() {
  local work_dir version download_url

  work_dir=$(mktemp -d)
  trap 'rm -rf "$work_dir"' EXIT  # Clean up on script exit

  install_dependencies || {
    echo "Failed to install dependencies." >&2
    exit 1
  }

  configure_ccache

  install_unrar "$work_dir" || {
    echo "UnRAR installation failed." >&2
    exit 1
  }

  read version download_url < <(fetch_latest_version_and_url) || exit 1
  install_rar2fs "$work_dir" "$download_url" || {
    echo "rar2fs installation failed." >&2
    exit 1
  }
  echo "rar2fs installation completed successfully."
}

main
