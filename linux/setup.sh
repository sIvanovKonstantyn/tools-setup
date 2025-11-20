#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# Xubuntu bootstrap script
# Installs: Docker + Compose, pgAdmin4 Desktop, VS Code
# Optional: VirtualBox Guest Additions
# ---------------------------------------------------------------------------

log()  { echo -e "\n\033[1;32m[INFO]\033[0m $1\n"; }

log "Updating system..."
sudo apt update -y && sudo apt upgrade -y

log "Installing base packages..."
sudo apt install -y ca-certificates curl gnupg lsb-release software-properties-common

# ---------------------------------------------------------------------------
# Docker + Docker Compose
# ---------------------------------------------------------------------------
log "Installing Docker Engine + Compose plugin..."

sudo apt remove -y docker docker-engine docker.io containerd runc || true

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y

sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker "$USER"

# ---------------------------------------------------------------------------
# pgAdmin 4 (Desktop version)
# ---------------------------------------------------------------------------
log "Installing pgAdmin 4 Desktop..."

curl -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub | \
  sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg

echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] \
https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" \
| sudo tee /etc/apt/sources.list.d/pgadmin4.list > /dev/null

sudo apt update -y
sudo apt install -y pgadmin4-desktop

# ---------------------------------------------------------------------------
# VS Code
# ---------------------------------------------------------------------------
log "Installing Visual Studio Code..."

curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | \
  gpg --dearmor | sudo tee /usr/share/keyrings/ms-packages.gpg > /dev/null

echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ms-packages.gpg] \
https://packages.microsoft.com/repos/code stable main" \
| sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null

sudo apt update -y
sudo apt install -y code

# ---------------------------------------------------------------------------
# OPTIONAL: VirtualBox Guest Additions
# ---------------------------------------------------------------------------
# log "Installing VirtualBox Guest Additions..."
# sudo apt install -y virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11

# ---------------------------------------------------------------------------
log "Setup completed! Log out and back in to apply docker group changes."
