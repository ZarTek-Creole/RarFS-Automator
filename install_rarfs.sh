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
# shellcheck disable=SC2155
readonly NUM_CORES=$(nproc)
# shellcheck disable=SC2155
readonly WORK_DIR=$(mktemp -d)
readonly RARFS_CONFIGURATION_ARGS="--with-unrar-lib=/usr/local/lib --with-unrar=${WORK_DIR}/unrar"


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
  echo "Installing UnRAR..."
  
  # Téléchargement du source
  wget -q "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" -P "$WORK_DIR" || { echo "Failed to download UnRAR source."; return 1; }
  
  # Extraction du tar.gz
  tar -zxf "$WORK_DIR/unrarsrc-${UNRAR_VERSION}.tar.gz" -C "$WORK_DIR" || { echo "Failed to extract UnRAR source."; return 1; }

  # Changement au dossier de compilation
  pushd "$WORK_DIR/unrar" > /dev/null || { echo "UnRAR source directory does not exist."; return 1; }
  
  # Compilation du programme
  echo "Compiling UnRAR..."
  make -s -j"$NUM_CORES" || { echo "Compilation of unrar failed"; return 1; }
  echo "UnRAR compiled successfully."
  
  # Installation du programme
  sudo make install || { echo "Installation of unrar failed"; return 1; }
  echo "UnRAR installed successfully."
  
  # Compilation et installation de la librairie
    echo "Compiling UnRAR library..."
    make -s lib || { echo "Compilation of library failed"; return 1; }
    sudo make install-lib DESTDIR=/usr/local || { echo "Library installation of unrar failed"; return 1; }
    echo "UnRAR library installed successfully."
  
  popd > /dev/null || return 1
}

# Downloads and installs rar2fs
install_rar2fs() {
  local download_url="$1"
  echo "Installing rar2fs..."
  
  # Téléchargement du fichier tar.gz
  wget -q "$download_url" -P "$WORK_DIR" || { echo "Failed to download rar2fs source."; return 1; }
  
  # Extraction du tar.gz
  local version_dir
  version_dir="$(basename "$download_url" .tar.gz)"
  tar -zxf "$WORK_DIR/$version_dir.tar.gz" -C "$WORK_DIR" || { echo "Failed to extract rar2fs source."; return 1; }
  
  # Changement au dossier de compilation
  pushd "$WORK_DIR/$version_dir" > /dev/null || { echo "rar2fs source directory does not exist."; return 1; }
  
  # Configuration et compilation
  # shellcheck disable=SC2086
  if ! ./configure $RARFS_CONFIGURATION_ARGS > /dev/null; then
    echo "Configuration of rar2fs failed."
    return 1
  fi
  
  if ! make -s -j"$NUM_CORES"; then
    echo "Compilation of rar2fs failed."
    return 1
  fi
  
  # Installation
  if ! sudo make install > /dev/null; then
    echo "Installation of rar2fs failed."
    return 1
  fi
  
  echo "rar2fs installed successfully."
  popd > /dev/null || return 1
}

# Install necessary dependencies
install_dependencies() {
    echo "Installing dependencies..."
    sudo apt-get update -qq \
        && sudo apt-get install -y $DEPENDENCIES > /dev/null \
        || { echo "Failed to install dependencies."; return 1; }
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
  local version download_url

  
  trap 'rm -rf "$WORK_DIR"' EXIT  # Clean up on script exit

  install_dependencies || {
    echo "Failed to install dependencies." >&2
    exit 1
  }

  configure_ccache

  install_unrar || {
    echo "UnRAR installation failed." >&2
    exit 1
  }

  read -r version download_url < <(fetch_latest_version_and_url) || exit 1
  install_rar2fs "$download_url" || {
    echo "rar2fs $version installation failed." >&2
    exit 1
  }
  echo "rar2fs $version installation completed successfully."
}

main
