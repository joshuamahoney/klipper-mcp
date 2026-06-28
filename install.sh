#!/bin/bash
# Klipper MCP Server Installation Script
# Run this from inside the cloned repository:  bash install.sh
# Compatible with Python 3.7+ (runs on the system Python of older SBC images).
#
# The service runs FROM the cloned repo directory, so `git pull` updates the
# running server. Paths and the systemd user are derived from where this script
# lives and who runs it — nothing is copied to a second location.

set -e

echo "=========================================="
echo "Klipper MCP Server Installer"
echo "=========================================="

# Resolve the repo directory (where this script lives) and the running user.
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_USER="$(whoami)"
INSTALL_GROUP="$(id -gn)"
VENV_DIR="$INSTALL_DIR/venv"
SERVICE_NAME="klipper-mcp"

# Check Python version
PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo "Python version:  $PYTHON_VERSION"
echo "Install dir:     $INSTALL_DIR"
echo "Service user:    $INSTALL_USER ($INSTALL_GROUP)"

# Prompt for printer name
echo ""
echo "Enter a name for this printer (e.g. elegoo1, elegoo2)"
echo "Note: each printer needs a unique name when connecting multiple printers to the same MCP client."
read -p "Printer name [my-printer]: " PRINTER_NAME
PRINTER_NAME=${PRINTER_NAME:-my-printer}
PRINTER_NAME=$(echo "$PRINTER_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
echo "Using printer name: $PRINTER_NAME"

# Runtime directories (gitignored, created in place)
echo "Creating runtime directories..."
mkdir -p "$INSTALL_DIR/data" "$INSTALL_DIR/backups"

# Create config from the template on first install; never clobber an existing one
if [ ! -f "$INSTALL_DIR/config.py" ]; then
    echo "Creating config.py from config.example.py..."
    cp "$INSTALL_DIR/config.example.py" "$INSTALL_DIR/config.py"
    # Seed the printer name; leave the rest for the user to edit
    sed -i "s/^PRINTER_NAME = .*/PRINTER_NAME = \"$PRINTER_NAME\"/" "$INSTALL_DIR/config.py"
else
    echo "Keeping existing config.py (not overwritten)."
fi

# Create / refresh the virtual environment
echo "Setting up Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r "$INSTALL_DIR/requirements.txt"

# Generate the systemd unit pointing at THIS directory and user.
echo "Installing systemd service..."
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null << EOF
[Unit]
Description=Klipper MCP Server
After=network.target moonraker.service
Wants=moonraker.service

[Service]
Type=simple
User=${INSTALL_USER}
Group=${INSTALL_GROUP}
WorkingDirectory=${INSTALL_DIR}
Environment="PATH=${VENV_DIR}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=${VENV_DIR}/bin/python server.py
Restart=always
RestartSec=10

# Logging
StandardOutput=append:/var/log/klipper-mcp.log
StandardError=append:/var/log/klipper-mcp.log

[Install]
WantedBy=multi-user.target
EOF

# Log file
sudo touch /var/log/klipper-mcp.log
sudo chown "$INSTALL_USER:$INSTALL_GROUP" /var/log/klipper-mcp.log

# Enable and (re)start
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl restart "$SERVICE_NAME"

IP=$(hostname -I | awk '{print $1}')

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "Service runs from: $INSTALL_DIR  (git pull here updates it)"
echo ""
echo "Next steps:"
echo "1. Edit the configuration file:"
echo "   nano $INSTALL_DIR/config.py"
echo "   - set a strong API_KEY"
echo "   - set ARMED=True when ready to enable dangerous commands"
echo "   then: sudo systemctl restart $SERVICE_NAME"
echo ""
echo "2. Check service status:"
echo "   sudo systemctl status $SERVICE_NAME"
echo ""
echo "3. View logs:"
echo "   tail -f /var/log/klipper-mcp.log"
echo ""
echo "MCP server will be available at:"
echo "   http://$IP:8000/mcp"
echo ""
echo "To connect this printer to your MCP client:"
echo ""
echo "Claude Code:"
echo "  claude mcp add --transport http $PRINTER_NAME http://$IP:8000/mcp --header \"X-API-Key: YOUR_API_KEY\""
echo ""
echo "OpenAI Codex (~/.codex/config.toml):"
echo "  [mcp_servers.$PRINTER_NAME]"
echo "  url = \"http://$IP:8000/mcp\""
echo "  http_headers = { \"X-API-Key\" = \"YOUR_API_KEY\" }"
echo ""
echo "OpenCode (opencode.jsonc):"
echo "  \"$PRINTER_NAME\": {"
echo "    \"type\": \"remote\","
echo "    \"url\": \"http://$IP:8000/mcp\","
echo "    \"headers\": { \"X-API-Key\": \"YOUR_API_KEY\" }"
echo "  }"
echo ""
echo "VS Code (settings.json or .vscode/mcp.json):"
echo "  \"$PRINTER_NAME\": {"
echo "    \"type\": \"http\","
echo "    \"url\": \"http://$IP:8000/mcp\","
echo "    \"headers\": { \"X-API-Key\": \"YOUR_API_KEY\" }"
echo "  }"
echo ""
echo "Replace YOUR_API_KEY with the value set in config.py"
echo ""
