#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# macOS bootstrap script
# Installs:
# - Homebrew
# - Docker Desktop
# - pgAdmin4
# - Visual Studio Code
# - JDK 21 (Temurin)
# - Python (brew-managed)
# ---------------------------------------------------------------------------

log() { echo -e "\n\033[1;32m[INFO]\033[0m $1\n"; }

ARCH="$(uname -m)"
BREW_PREFIX="/usr/local"
[[ "$ARCH" == "arm64" ]] && BREW_PREFIX="/opt/homebrew"

# ---------------------------------------------------------------------------
# Xcode Command Line Tools
# ---------------------------------------------------------------------------
log "Ensuring Xcode Command Line Tools are installed..."

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "⚠️  Please finish Xcode CLI tools installation, then re-run the script."
  exit 1
fi

# ---------------------------------------------------------------------------
# Homebrew
# ---------------------------------------------------------------------------
log "Installing Homebrew (if missing)..."

if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  echo "eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\"" >> ~/.zprofile
  eval "$(${BREW_PREFIX}/bin/brew shellenv)"
else
  log "Homebrew already installed"
fi

brew update

# ---------------------------------------------------------------------------
# Docker Desktop
# ---------------------------------------------------------------------------
log "Installing Docker Desktop..."

brew install --cask docker

# Start Docker automatically
open -a Docker || true

# ---------------------------------------------------------------------------
# pgAdmin 4
# ---------------------------------------------------------------------------
log "Installing pgAdmin4..."

brew install --cask pgadmin4

# ---------------------------------------------------------------------------
# Visual Studio Code
# ---------------------------------------------------------------------------
log "Installing Visual Studio Code..."

brew install --cask visual-studio-code

# Enable `code` CLI
if ! command -v code >/dev/null 2>&1; then
  ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" \
        "${BREW_PREFIX}/bin/code" || true
fi

# ---------------------------------------------------------------------------
# JDK 21
# ---------------------------------------------------------------------------
log "Installing JDK 21 (Temurin)..."

brew install --cask temurin@21

# Set JAVA_HOME
JAVA_21_HOME=$(/usr/libexec/java_home -v 21)
if ! grep -q "JAVA_HOME.*21" ~/.zprofile 2>/dev/null; then
  echo "export JAVA_HOME=${JAVA_21_HOME}" >> ~/.zprofile
  echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zprofile
fi

# ---------------------------------------------------------------------------
# Python
# ---------------------------------------------------------------------------
log "Installing Python..."

brew install python

# Ensure pip & venv are usable
python3 -m pip install --upgrade pip setuptools wheel

# ---------------------------------------------------------------------------
log "Setup completed!"
log "Restart terminal to apply environment changes."
log "Start Docker Desktop once before using docker CLI."
