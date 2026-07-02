"""
Klipper MCP Server Configuration
Copy this file to config.py and customize for your printer.

  cp config.example.py config.py
  nano config.py
"""
import os

# Internal helper: directory where this file lives (used for relative defaults)
_MCP_DIR = os.path.dirname(os.path.abspath(__file__))

# =============================================================================
# MOONRAKER CONNECTION
# =============================================================================
# URL to your Moonraker instance (usually localhost if running on same machine)
MOONRAKER_URL = os.getenv("MOONRAKER_URL", "http://localhost:7125")

# Optional Moonraker API key (required if Moonraker has auth enabled)
# Generate in Moonraker settings or leave empty for trusted local connections
MOONRAKER_API_KEY = os.getenv("MOONRAKER_API_KEY", "")

# Display name for your printer
PRINTER_NAME = "my-printer"  # Set during install, or change to match your printer

# =============================================================================
# MCP SERVER SETTINGS
# =============================================================================
# Host: 0.0.0.0 = listen on all interfaces (required for remote access)
#       127.0.0.1 = localhost only
MCP_HOST = "0.0.0.0"
MCP_PORT = int(os.getenv("MCP_PORT", "8000"))

# =============================================================================
# SECURITY - IMPORTANT: Change these values!
# =============================================================================
# API key for authenticating MCP clients
# Generate a strong random key: python3 -c "import secrets; print(secrets.token_urlsafe(32))"
API_KEY = os.getenv("API_KEY", "CHANGE-ME-TO-A-SECURE-KEY")

# Armed mode - when False, dangerous commands (gcode, temp changes) are blocked
# Set to True once you've verified everything works
ARMED = os.getenv("ARMED", "false").lower() == "true"

# Read-only mode — when True, all write tools are blocked at registration time,
# independent of ARMED/ADMIN_PIN. Safe for monitoring-only MCP connections.
READ_ONLY = os.getenv("READ_ONLY", "false").lower() == "true"

# Admin PIN for destructive operations (delete files, restore config, reboot)
ADMIN_PIN = os.getenv("ADMIN_PIN", "123456")

# =============================================================================
# FILE PATHS
# Adjust these paths for your setup (default: BTT CB1 with printer_data)
# =============================================================================
PRINTER_DATA_PATH = os.getenv("PRINTER_DATA_PATH", os.path.expanduser("~/printer_data"))
CONFIG_PATH = f"{PRINTER_DATA_PATH}/config"
GCODES_PATH = f"{PRINTER_DATA_PATH}/gcodes"
LOGS_PATH = f"{PRINTER_DATA_PATH}/logs"
BACKUP_PATH = f"{PRINTER_DATA_PATH}/backups"

# Security: Only allow file operations in these directories
ALLOWED_PATHS = [
    CONFIG_PATH,
    GCODES_PATH,
    LOGS_PATH,
    BACKUP_PATH,
]

# =============================================================================
# CAMERA SETTINGS
# =============================================================================
# Crowsnest/mjpg-streamer URLs
CAMERA_SNAPSHOT_URL = os.getenv("CAMERA_SNAPSHOT_URL", "http://localhost/webcam/?action=snapshot")
CAMERA_STREAM_URL = os.getenv("CAMERA_STREAM_URL", "http://localhost/webcam/?action=stream")

# =============================================================================
# SPOOLMAN SETTINGS (optional filament tracking)
# https://github.com/Donkie/Spoolman
# =============================================================================
SPOOLMAN_ENABLED = os.getenv("SPOOLMAN_ENABLED", "false").lower() == "true"
SPOOLMAN_URL = os.getenv("SPOOLMAN_URL", "http://localhost:7912")

# --- Local filament-usage sync ---------------------------------------------
# For printers WITHOUT native Moonraker [spoolman] support (e.g. Elegoo and
# other vendor Moonraker builds). When True, a separate monitor service
# (spoolman_sync.py) watches finished print jobs and deducts the filament each
# one used from the active spool in Spoolman.
#
# IMPORTANT: Leave this False if your Moonraker has the native [spoolman]
# component (standard Moonraker). Enabling both would double-count every
# print's filament usage. The monitor also refuses to start if it detects the
# native integration, as a safety net.
SPOOLMAN_SYNC_ENABLED = os.getenv("SPOOLMAN_SYNC_ENABLED", "false").lower() == "true"

# How often (seconds) the monitor polls Moonraker for finished prints.
SPOOLMAN_SYNC_POLL_INTERVAL = int(os.getenv("SPOOLMAN_SYNC_POLL_INTERVAL", "30"))

# State files for the monitor. The active-spool file is also read/written by
# the set_active_spool / clear_active_spool MCP tools when sync mode is on.
SPOOLMAN_ACTIVE_SPOOL_FILE = os.getenv(
    "SPOOLMAN_ACTIVE_SPOOL_FILE", os.path.join(_MCP_DIR, "data", "active_spool.json"))
SPOOLMAN_SYNC_STATE_FILE = os.getenv(
    "SPOOLMAN_SYNC_STATE_FILE", os.path.join(_MCP_DIR, "data", "spoolman_sync_state.json"))

# =============================================================================
# NOTIFICATION SETTINGS (all optional)
# =============================================================================
# ntfy.sh - free, self-hostable push notifications
NTFY_ENABLED = os.getenv("NTFY_ENABLED", "false").lower() == "true"
NTFY_URL = os.getenv("NTFY_URL", "https://ntfy.sh")
NTFY_TOPIC = os.getenv("NTFY_TOPIC", PRINTER_NAME.lower().replace(" ", "-"))

# Discord webhook
DISCORD_ENABLED = os.getenv("DISCORD_ENABLED", "false").lower() == "true"
DISCORD_WEBHOOK_URL = os.getenv("DISCORD_WEBHOOK_URL", "")

# Slack webhook
SLACK_WEBHOOK_URL = os.getenv("SLACK_WEBHOOK_URL", "")

# Pushover
PUSHOVER_USER_KEY = os.getenv("PUSHOVER_USER_KEY", "")
PUSHOVER_API_TOKEN = os.getenv("PUSHOVER_API_TOKEN", "")

# Text-to-Speech (plays on CB1/Pi speaker if available)
TTS_ENABLED = os.getenv("TTS_ENABLED", "false").lower() == "true"
TTS_RATE = int(os.getenv("TTS_RATE", "150"))
TTS_VOLUME = float(os.getenv("TTS_VOLUME", "0.8"))

# =============================================================================
# TOOLCHANGER / STEALTHCHANGER SETTINGS
# =============================================================================
# Number of tools configured (T0, T1, T2, etc.)
TOOL_COUNT = int(os.getenv("TOOL_COUNT", "1"))

# Tool display names (optional)
TOOL_NAMES = {
    0: "T0",
    1: "T1",
    2: "T2",
    3: "T3",
}

# =============================================================================
# MAINTENANCE TRACKING
# =============================================================================
# Path to store maintenance data
MAINTENANCE_DATA_FILE = os.getenv("MAINTENANCE_DATA_FILE", os.path.join(_MCP_DIR, "data", "maintenance.json"))
AUDIT_LOG_FILE = os.getenv("AUDIT_LOG_FILE", os.path.join(_MCP_DIR, "data", "audit.log"))

# Maintenance intervals (in print hours)
MAINTENANCE_INTERVALS = {
    "nozzle_change": 500,
    "belt_tension": 200,
    "lubrication": 100,
    "pom_nut_check": 300,
    "filter_change": 200,
    "hotend_clean": 50,
}

# =============================================================================
# LED SCENES
# =============================================================================
LED_SCENES_FILE = os.getenv("LED_SCENES_FILE", os.path.join(_MCP_DIR, "scenes", "led_scenes.json"))

# Aliases for backward compatibility
MAINTENANCE_LOG_PATH = MAINTENANCE_DATA_FILE
AUDIT_LOG_PATH = AUDIT_LOG_FILE
