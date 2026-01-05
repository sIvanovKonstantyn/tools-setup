#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# macOS cleanup script
# Removes:
# - Docker Desktop
# - pgAdmin4
# - Visual Studio Code
# - JDK 21 (Temurin)
# - Python (brew-managed)
# - Homebrew (optional)
# Cleans caches and temp files
# ---------------------------------------------------------------------------

log() { echo -e "\n\033[1;33m[CLEAN]\033[0m $1\n"; }

ARCH="$(uname -m)"
BREW_PREFIX="/usr/local"
[[ "$ARCH" == "arm64" ]] && BREW_PREFIX="/opt/homebrew"

BREW_BIN="${BREW_PREFIX}/bin/brew"

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------
brew_if_exists() {
  if command -v brew >/dev/null 2>&1; then
    brew "$@" || true
  fi
}

# ---------------------------------------------------------------------------
# Docker Desktop
# ---------------------------------------------------------------------------
log "Removing Docker Desktop..."

if [ -d "/Applications/Docker.app" ]; then
  pkill -f Docker || true
  brew_if_exists uninstall --cask docker
  rm -rf ~/Library/Containers/com.docker.docker
  rm -rf ~/Library/Group\ Containers/group.com.docker
  rm -rf ~/Library/Application\ Support/Docker
  rm -rf ~/.docker
fi

# ---------------------------------------------------------------------------
# pgAdmin4
# ---------------------------------------------------------------------------
log "Removing pgAdmin4..."

brew_if_exists uninstall --cask pgadmin4
rm -rf ~/Library/Application\ Support/pgAdmin
rm -rf ~/Library/Preferences/org.pgadmin.pgadmin4.plist
rm -rf ~/Library/Saved\ Application\ State/org.pgadmin.pgadmin4.savedState

# ---------------------------------------------------------------------------
# Visual Studio Code
# ---------------------------------------------------------------------------
log "Removing Visual Studio Code..."

brew_if_exists uninstall --cask visual-studio-code
rm -rf ~/Library/Application\ Support/Code
rm -rf ~/.vscode
rm -rf ~/Library/Preferences/com.microsoft.VSCode.plist
rm -rf ~/Library/Saved\ Application\ State/com.microsoft.VSCode.savedState
rm -f "${BREW_PREFIX}/bin/code"

# ---------------------------------------------------------------------------
# JDK 21 (Temurin)
# ---------------------------------------------------------------------------
log "Removing JDK 21 (Temurin)..."

brew_if_exists uninstall --cask temurin@21

# Remove leftover JVMs if present
sudo rm -rf /Library/Java/JavaVirtualMachines/temurin-21*.jdk || true

# Clean JAVA_HOME exports
sed -i '' '/JAVA_HOME.*21/d' ~/.zprofile 2>/dev/null || true

# ---------------------------------------------------------------------------
# Python (brew-managed)
# ---------------------------------------------------------------------------
log "Removing Homebrew Python..."

brew_if_exists uninstall python

rm -rf ~/Library/Caches/pip
rm -rf ~/Library/Application\ Support/pip

# ---------------------------------------------------------------------------
# Homebrew (OPTIONAL)
# ---------------------------------------------------------------------------
if command -v brew >/dev/null 2>&1; then
  log "Removing Homebrew..."

  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)" || true
fi

# Remove brew leftovers
rm -rf "${BREW_PREFIX}/Cellar"
rm -rf "${BREW_PREFIX}/Caskroom"
rm -rf "${BREW_PREFIX}/Homebrew"
rm -rf "${BREW_PREFIX}/var/homebrew"
rm -rf "${BREW_PREFIX}/etc/homebrew"

# Remove shell env
sed -i '' '/homebrew\/bin\/brew shellenv/d' ~/.zprofile 2>/dev/null || true

# ---------------------------------------------------------------------------
# System & user cleanup
# ---------------------------------------------------------------------------
log "Cleaning caches and temp files..."

# System temp
sudo rm -rf /tmp/* || true
sudo rm -rf /private/var/tmp/* || true

# User caches
rm -rf ~/Library/Caches/* || true
rm -rf ~/.cache/* || true
rm -rf ~/.local/share/Trash/* || true

# ---------------------------------------------------------------------------
log "Cleanup completed!"
log "Restart terminal to fully apply changes."
