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

# Filament-usage sync (for printers WITHOUT native Moonraker [spoolman] support).
# Standard Moonraker tracks filament itself via its [spoolman] component; vendor
# builds (e.g. Elegoo) often lack it. Installing the sync monitor on a printer that
# ALSO has native tracking would double-count usage, so this is strictly opt-in.
echo ""
echo "Filament-usage sync to Spoolman"
echo "  Standard Moonraker tracks filament usage itself (the [spoolman] component)."
echo "  Enable this ONLY if your Moonraker lacks native Spoolman support (e.g. an"
echo "  Elegoo/vendor build). Enabling it alongside native tracking double-counts usage."
read -p "Enable klipper-mcp filament-usage sync? [y/N]: " ENABLE_SYNC
ENABLE_SYNC=$(echo "${ENABLE_SYNC:-n}" | tr '[:upper:]' '[:lower:]')
if [ "$ENABLE_SYNC" = "y" ] || [ "$ENABLE_SYNC" = "yes" ]; then
    INSTALL_SYNC=1
    # Flip the flag in config.py so the monitor and MCP tools use local-sync mode.
    # On configs predating this option the line is absent — append it instead.
    if grep -q "^SPOOLMAN_SYNC_ENABLED" "$INSTALL_DIR/config.py"; then
        sed -i 's/^SPOOLMAN_SYNC_ENABLED = .*/SPOOLMAN_SYNC_ENABLED = os.getenv("SPOOLMAN_SYNC_ENABLED", "true").lower() == "true"/' "$INSTALL_DIR/config.py"
    else
        printf '\n# Filament-usage sync (added by installer)\nSPOOLMAN_SYNC_ENABLED = os.getenv("SPOOLMAN_SYNC_ENABLED", "true").lower() == "true"\n' >> "$INSTALL_DIR/config.py"
    fi
    echo "Filament-usage sync ENABLED. Set SPOOLMAN_ENABLED=true and SPOOLMAN_URL in config.py."
else
    INSTALL_SYNC=0
    echo "Filament-usage sync not enabled (use native Moonraker [spoolman] if available)."
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

# Optional filament-usage sync monitor (separate long-running service).
SYNC_SERVICE_NAME="${SERVICE_NAME}-spoolman-sync"
if [ "${INSTALL_SYNC:-0}" = "1" ]; then
    echo "Installing filament-usage sync service..."
    sudo tee /etc/systemd/system/${SYNC_SERVICE_NAME}.service > /dev/null << EOF
[Unit]
Description=Klipper MCP Spoolman Filament-Usage Sync
After=network.target moonraker.service ${SERVICE_NAME}.service
Wants=moonraker.service

[Service]
Type=simple
User=${INSTALL_USER}
Group=${INSTALL_GROUP}
WorkingDirectory=${INSTALL_DIR}
Environment="PATH=${VENV_DIR}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=${VENV_DIR}/bin/python spoolman_sync.py
Restart=always
RestartSec=10

# Logging
StandardOutput=append:/var/log/${SYNC_SERVICE_NAME}.log
StandardError=append:/var/log/${SYNC_SERVICE_NAME}.log

[Install]
WantedBy=multi-user.target
EOF

    sudo touch /var/log/${SYNC_SERVICE_NAME}.log
    sudo chown "$INSTALL_USER:$INSTALL_GROUP" /var/log/${SYNC_SERVICE_NAME}.log

    sudo systemctl daemon-reload
    sudo systemctl enable "$SYNC_SERVICE_NAME"
    sudo systemctl restart "$SYNC_SERVICE_NAME"
else
    # If a previous install enabled it but this run did not, leave it alone —
    # we never silently remove a service the user may rely on.
    :
fi

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
if [ "${INSTALL_SYNC:-0}" = "1" ]; then
    echo "Filament-usage sync is enabled (service: $SYNC_SERVICE_NAME)."
    echo "   - Ensure SPOOLMAN_ENABLED=true and SPOOLMAN_URL are set in config.py,"
    echo "     then: sudo systemctl restart $SYNC_SERVICE_NAME"
    echo "   - Set the active spool (charges all prints until changed) via your MCP"
    echo "     client's set_active_spool tool, e.g. set_active_spool(spool_id=1)"
    echo "   - Sync logs: tail -f /var/log/$SYNC_SERVICE_NAME.log"
    echo ""
fi
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
