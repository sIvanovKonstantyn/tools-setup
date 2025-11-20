#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Cleanup script for Xubuntu bootstrap tools
# Removes: Docker, Compose, pgAdmin4 Desktop, VS Code
# Optional: VirtualBox Guest Additions
# Also cleans apt cache + system temp files
# ---------------------------------------------------------------------------

log() { echo -e "\n\033[1;33m[CLEAN]\033[0m $1\n"; }

# ---------------------------------------------------------------------------
# Remove Docker + Docker Compose
# ---------------------------------------------------------------------------
log "Removing Docker Engine + Compose plugin..."

sudo systemctl stop docker || true

sudo apt remove -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true
sudo apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin || true

# Delete Docker data
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd

# Remove Docker repo + GPG key
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg

# ---------------------------------------------------------------------------
# Remove pgAdmin4 Desktop
# ---------------------------------------------------------------------------
log "Removing pgAdmin4 Desktop..."

sudo apt remove -y pgadmin4-desktop || true
sudo apt purge -y pgadmin4-desktop || true

# Remove repo + key
sudo rm -f /etc/apt/sources.list.d/pgadmin4.list
sudo rm -f /usr/share/keyrings/packages-pgadmin-org.gpg

# Remove user configs
rm -rf ~/.pgadmin || true

# ---------------------------------------------------------------------------
# Remove VS Code
# ---------------------------------------------------------------------------
log "Removing Visual Studio Code..."

sudo apt remove -y code || true
sudo apt purge -y code || true

# Remove repo + key
sudo rm -f /etc/apt/sources.list.d/vscode.list
sudo rm -f /usr/share/keyrings/ms-packages.gpg

# User config & cache
rm -rf ~/.config/Code || true
rm -rf ~/.vscode || true

# ---------------------------------------------------------------------------
# OPTIONAL: VirtualBox Guest Additions
# ---------------------------------------------------------------------------
# log "Removing VirtualBox Guest Additions..."
# sudo apt remove -y virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 || true
# sudo apt purge -y virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 || true

# ---------------------------------------------------------------------------
# System cleanup
# ---------------------------------------------------------------------------
log "Cleaning apt cache and system temp files..."

# Clean apt
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean -y

# Clean temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clean user temp dirs
rm -rf ~/.cache/* || true
rm -rf ~/.local/share/Trash/* || true

log "Cleanup finished!"
