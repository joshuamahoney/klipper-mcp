#!/bin/bash
# Spoolman Installation Script for Klipper SBCs (CB1 / Raspberry Pi / Orange Pi, etc.)
#
# Run this as your normal printer user (NOT with sudo) — it calls sudo itself
# where root is required. Paths and the systemd service user are derived from
# whoever runs it.

set -eo pipefail

SPOOLMAN_USER="$(whoami)"
SPOOLMAN_DIR="${HOME}/spoolman"
SPOOLMAN_VERSION="0.19.3"
DOWNLOAD_URL="https://github.com/Donkie/Spoolman/releases/download/v${SPOOLMAN_VERSION}/spoolman.zip"

if [ "$(id -u)" -eq 0 ]; then
    echo "Please run this script as your normal user, not as root/sudo." >&2
    echo "It will prompt for sudo only when needed." >&2
    exit 1
fi

echo "=== Installing Spoolman v${SPOOLMAN_VERSION} ==="
echo "User:      ${SPOOLMAN_USER}"
echo "Directory: ${SPOOLMAN_DIR}"

# Install dependencies (unzip is required to extract the release archive)
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv unzip

# Create directory
echo "Creating Spoolman directory..."
rm -rf "${SPOOLMAN_DIR}"
mkdir -p "${SPOOLMAN_DIR}"
cd "${SPOOLMAN_DIR}"

# Download latest release. The Spoolman release ships a .zip (not .tar.gz).
# -f makes curl exit non-zero on HTTP errors (e.g. 404) instead of silently
# writing the error page to the output file.
echo "Downloading Spoolman..."
curl -fSL "${DOWNLOAD_URL}" -o spoolman.zip
unzip -q spoolman.zip
rm spoolman.zip

# Create virtual environment and install dependencies
echo "Setting up Python environment..."
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -e .

# Create .env file
echo "Creating configuration..."
cat > .env << 'EOF'
# Spoolman Configuration
SPOOLMAN_DB_TYPE=sqlite
SPOOLMAN_HOST=0.0.0.0
SPOOLMAN_PORT=7912
SPOOLMAN_LOGGING_LEVEL=info
EOF

# Create systemd service
echo "Creating systemd service..."
sudo tee /etc/systemd/system/spoolman.service > /dev/null << EOF
[Unit]
Description=Spoolman - Filament Spool Manager
After=network.target

[Service]
Type=simple
User=${SPOOLMAN_USER}
WorkingDirectory=${SPOOLMAN_DIR}
ExecStart=${SPOOLMAN_DIR}/.venv/bin/uvicorn spoolman.main:app --host 0.0.0.0 --port 7912
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start service
echo "Starting Spoolman service..."
sudo systemctl daemon-reload
sudo systemctl enable spoolman
sudo systemctl start spoolman

# Wait and check status
sleep 3
sudo systemctl status spoolman --no-pager

echo ""
echo "=== Spoolman Installation Complete ==="
echo "Web UI: http://$(hostname -I | awk '{print $1}'):7912"
echo ""
echo "Next steps:"
echo "1. Add to Moonraker config:"
echo "   [spoolman]"
echo "   server: http://localhost:7912"
echo ""
echo "2. Enable in Klipper MCP:"
echo "   Set SPOOLMAN_ENABLED=true"
