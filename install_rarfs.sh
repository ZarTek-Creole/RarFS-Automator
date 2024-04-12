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

# fetch_latest_version
# Fetches the latest version tag from GitHub using curl and jq
fetch_latest_version() {
  local latest_version
  latest_version=$(curl -s "$API_URL" | jq -r '.tag_name')
  echo "$latest_version"
}

# build_download_url
# Constructs the download URL for the specified version
build_download_url() {
  local version="$1"
  echo "https://github.com/$REPO/releases/download/$version/rar2fs-$version.tar.gz"
}

# install_unrar
# Downloads and installs UnRAR from the official source
install_unrar() {
  local work_dir="$1"
  wget "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" -P "$work_dir"
  tar -zxvf "$work_dir/unrarsrc-${UNRAR_VERSION}.tar.gz" -C "$work_dir"
  pushd "$work_dir/unrar"
  make && sudo make install
  make lib && sudo make install-lib
  popd
}

# install_rar2fs
# Downloads and installs rar2fs using the provided URL
install_rar2fs() {
  local work_dir="$1"
  local version="$2"
  local download_url="$3"
  wget "$download_url" -P "$work_dir"
  tar -zxvf "$work_dir/rar2fs-$version.tar.gz" -C "$work_dir"
  pushd "$work_dir/rar2fs-$version"
  ./configure --with-unrar-lib="/usr/lib/"
  make && sudo make install
  popd
}

# main
# Manages the installation process
main() {
  local work_dir version download_url

  # Setup temporary directory for installation
  work_dir=$(mktemp -d)
  trap 'rm -rf "$work_dir"' EXIT  # Ensure cleanup on script exit

  # Install dependencies
  sudo apt-get update -qq && sudo apt-get install -y $DEPENDENCIES

  # Installation steps
  install_unrar "$work_dir"
  version=$(fetch_latest_version)
  download_url=$(build_download_url "$version")
  install_rar2fs "$work_dir" "$version" "$download_url"
}

# Execute the main function
main