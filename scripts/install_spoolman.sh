#!/bin/bash
# Spoolman Installation Script for Klipper SBCs (CB1 / Raspberry Pi / Orange Pi, etc.)
#
# Run this as your normal printer user (NOT with sudo) — it calls sudo itself
# where root is required. Paths and the systemd service user are derived from
# whoever runs it.
#
# Spoolman requires Python 3.9+. On older OS images (e.g. Debian Buster, which
# ships Python 3.7) this script builds an isolated Python via pyenv and uses it
# ONLY for Spoolman's virtualenv — the system Python is left untouched so
# Klipper and Moonraker keep running on it.

set -eo pipefail

SPOOLMAN_USER="$(whoami)"
SPOOLMAN_DIR="${HOME}/spoolman"
SPOOLMAN_VERSION="0.19.3"
DOWNLOAD_URL="https://github.com/Donkie/Spoolman/releases/download/v${SPOOLMAN_VERSION}/spoolman.zip"

# Python to build via pyenv when the system Python is too old (< 3.9).
PYTHON_VERSION="3.11.9"

if [ "$(id -u)" -eq 0 ]; then
    echo "Please run this script as your normal user, not as root/sudo." >&2
    echo "It will prompt for sudo only when needed." >&2
    exit 1
fi

echo "=== Installing Spoolman v${SPOOLMAN_VERSION} ==="
echo "User:      ${SPOOLMAN_USER}"
echo "Directory: ${SPOOLMAN_DIR}"

# Install base dependencies (unzip is required to extract the release archive)
echo "Installing dependencies..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv unzip curl

# Create directory
echo "Creating Spoolman directory..."
rm -rf "${SPOOLMAN_DIR}"
mkdir -p "${SPOOLMAN_DIR}"
cd "${SPOOLMAN_DIR}"

# Download the release. The Spoolman release ships a .zip (not .tar.gz).
# -f makes curl exit non-zero on HTTP errors (e.g. 404) instead of silently
# writing the error page to the output file.
echo "Downloading Spoolman..."
curl -fSL "${DOWNLOAD_URL}" -o spoolman.zip
unzip -q spoolman.zip
rm spoolman.zip

# --- Ensure a Python >= 3.9 is available -----------------------------------
# Use the system python3 if it is new enough; otherwise build an isolated
# interpreter with pyenv. We never replace the system Python.
echo "Checking Python version..."
if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 9) else 1)' 2>/dev/null; then
    PYTHON_BIN="$(command -v python3)"
    echo "System python3 ($(${PYTHON_BIN} -V 2>&1)) is new enough."
else
    echo "System python3 is older than 3.9 — Spoolman needs 3.9+."
    echo "Building an isolated Python ${PYTHON_VERSION} via pyenv."
    echo "NOTE: this compiles CPython from source and can take 15-30 minutes on an SBC."

    # Build dependencies for compiling CPython
    sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev git

    export PYENV_ROOT="${HOME}/.pyenv"
    if [ ! -d "${PYENV_ROOT}" ]; then
        echo "Installing pyenv..."
        curl -fsSL https://pyenv.run | bash
    fi
    export PATH="${PYENV_ROOT}/bin:${PATH}"
    eval "$(pyenv init -)"

    if ! pyenv versions --bare | grep -qx "${PYTHON_VERSION}"; then
        echo "Compiling Python ${PYTHON_VERSION}..."
        pyenv install "${PYTHON_VERSION}"
    else
        echo "Python ${PYTHON_VERSION} already built by pyenv."
    fi
    PYTHON_BIN="${PYENV_ROOT}/versions/${PYTHON_VERSION}/bin/python"
fi

echo "Using Python: ${PYTHON_BIN} ($(${PYTHON_BIN} -V 2>&1))"

# Create virtual environment and install dependencies
echo "Setting up Python environment..."
"${PYTHON_BIN}" -m venv .venv
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

# Create systemd service. The service runs uvicorn from the venv, so it uses
# whichever Python the venv was built with (system or pyenv-provided).
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
