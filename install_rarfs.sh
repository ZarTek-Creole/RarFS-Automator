#!/bin/bash
#######################################################################
# Nom du script : install_rar2fs.sh
# Auteur : ZarTek-Creole
# URL : https://github.com/ZarTek-Creole/install_rarfs
# Description :
#   Ce script est conçu pour installer automatiquement rar2fs depuis
#   les releases GitHub. Il gère l'installation de toutes les dépendances
#   nécessaires, configure et compile rar2fs et UnRAR depuis les sources.
#
# Utilisation :
#   Exécutez ce script sans arguments. Assurez-vous d'avoir les droits
#   administratifs (sudo) nécessaires pour l'installation des paquets.
#
# Dépendances : make, gcc, g++, libfuse-dev, unzip, ccache
#
#######################################################################

# Configuration des constantes pour le dépôt et les dépendances
readonly REPO="hasse69/rar2fs"
readonly UNRAR_VERSION="6.2.1"
readonly API_URL="https://api.github.com/repos/$REPO/releases/latest"
readonly DEPENDENCIES="make gcc g++ libfuse-dev unzip ccache"
# shellcheck disable=SC2155
readonly WORK_DIR=$(mktemp -d)
readonly RARFS_CONFIGURATION_ARGS="--with-unrar-lib=/usr/local/lib --with-unrar=${WORK_DIR}/unrar"
# shellcheck disable=SC2155
readonly NUM_CORES=$(nproc)


# Fetches the latest version tag and download URL from GitHub
fetch_latest_version_and_url() {
  local response
  response=$(curl -s "$API_URL")
  local latest_version
  latest_version=$(echo "$response" | jq -r '.tag_name')
  local download_url
  download_url=$(echo "$response" | jq -r '.assets[0].browser_download_url')

  if [[ -z "$latest_version" || -z "$download_url" ]]; then
    echo -e "\033[0;31mError\033[0m: Fetching the latest version or download URL failed." >&2
    exit 1
  fi
  echo "$latest_version" "$download_url"
}

display_header() {
    clear
    echo -e "\033[1;34mInstalling rar2fs from GitHub\033[0m"
    echo "Description : Ce script installe automatiquement la derniere version de rar2fs depuis les releases GitHub et unrar $UNRAR_VERSION."
    echo "Author: ZarTek-Creole"
    echo "URL: https://github.com/ZarTek-Creole/install_rarfs"
    echo "Press any key to continue..."
    read -n1 -r -p " "
}
# Downloads and installs UnRAR
install_unrar() {
  echo -e "\033[0;34mInstalling UnRAR...\033[0m"

  # Téléchargement du source
  wget -q "https://www.rarlab.com/rar/unrarsrc-${UNRAR_VERSION}.tar.gz" -P "$WORK_DIR" || { echo -e "\033[0;31mError\033[0m: Failed to download UnRAR source."; return 1; }

  # Extraction du tar.gz
  tar -zxf "$WORK_DIR/unrarsrc-${UNRAR_VERSION}.tar.gz" -C "$WORK_DIR" || { echo -e "\033[0;31mError\033[0m: Failed to extract UnRAR source."; return 1; }

  # Changement au dossier de compilation
  pushd "$WORK_DIR/unrar" > /dev/null || { echo -e "\033[0;31mError\033[0m: UnRAR source directory does not exist."; return 1; }

  # Compilation du programme
  echo -e "\033[0;34mCompiling UnRAR...\033[0m"
  make -s -j"$NUM_CORES" || { echo -e "\033[0;31mError\033[0m: Compilation of unrar failed"; return 1; }
  echo -e "\033[0;32mUnRAR compiled successfully.\033[0m"

  # Installation du programme
  sudo make install > /dev/null || { echo -e "\033[0;31mError\033[0m: Installation of unrar failed"; return 1; }
  echo -e "\033[0;32mUnRAR installed successfully.\033[0m"

  # Compilation et installation de la librairie
    echo -e "\033[0;34mCompiling UnRAR library...\033[0m"
    make -s lib || { echo -e "\033[0;31mError\033[0m: Compilation of library failed"; return 1; }
    sudo make install-lib DESTDIR=/usr/local  > /dev/null || { echo -e "\033[0;31mError\033[0m: Library installation of unrar failed"; return 1; }
    echo -e "\033[0;32mUnRAR library installed successfully.\033[0m"

  popd > /dev/null || return 1
}

# Downloads and installs rar2fs
install_rar2fs() {
  local download_url="$1"
  echo -e "\033[0;34mInstalling rar2fs...\033[0m"

  # Téléchargement du fichier tar.gz
  wget -q "$download_url" -P "$WORK_DIR" || { echo -e "\033[0;31mError\033[0m: Failed to download rar2fs source."; return 1; }

  # Extraction du tar.gz
  local version_dir
  version_dir="$(basename "$download_url" .tar.gz)"
  tar -zxf "$WORK_DIR/$version_dir.tar.gz" -C "$WORK_DIR" || { echo -e "\033[0;31mError\033[0m: Failed to extract rar2fs source."; return 1; }

  # Changement au dossier de compilation
  pushd "$WORK_DIR/$version_dir" > /dev/null || { echo -e "\033[0;31mError\033[0m: rar2fs source directory does not exist."; return 1; }

  # Configuration et compilation
  # shellcheck disable=SC2086
  if ! ./configure $RARFS_CONFIGURATION_ARGS > /dev/null; then
    echo -e "\033[0;31mError\033[0m: Configuration of rar2fs failed."
    return 1
  fi

  if ! make -s -j"$NUM_CORES"; then
    echo -e "\033[0;31mError\033[0m: Compilation of rar2fs failed."
    return 1
  fi

  # Installation
  if ! sudo make install  > /dev/null ; then
    echo -e "\033[0;31mError\033[0m: Installation of rar2fs failed."
    return 1
  fi

  echo -e "\033[0;32mrar2fs installed successfully.\033[0m"
  popd > /dev/null || return 1
}

# Install necessary dependencies
install_dependencies() {
    echo -e "\033[0;34mInstalling dependencies...\033[0m"
    sudo apt-get update -qq \
        && sudo apt-get install -y $DEPENDENCIES > /dev/null \
        || { echo -e "\033[0;31mError\033[0m: Failed to install dependencies."; return 1; }
    echo -e "\033[0;32mDependencies installed.\033[0m"
}

# Configure ccache for faster recompilation
configure_ccache() {
    echo -e "\033[0;34mConfiguring ccache...\033[0m"
    export CC="ccache gcc"
    export CXX="ccache g++"
    ccache --max-size=5G > /dev/null  # Set the maximum cache size to 5GB
    echo -e "\033[0;32mccache configured.\033[0m"
}

# Manages the installation process
main() {
  local version download_url
  display_header
  trap 'rm -rf "$WORK_DIR"' EXIT  # Clean up on script exit

  install_dependencies || {
    echo -e "\033[0;31mError\033[0m: Failed to install dependencies." >&2
    exit 1
  }

  configure_ccache

  install_unrar || {
    echo -e "\033[0;31mError\033[0m: UnRAR installation failed." >&2
    exit 1
  }

  read -r version download_url < <(fetch_latest_version_and_url) || exit 1
  install_rar2fs "$download_url" || {
    echo -e "\033[0;31mError\033[0m: rar2fs $version installation failed." >&2
    exit 1
  }
  echo -e "\033[0;32mrar2fs $version installation completed successfully.\033[0m"
}

main