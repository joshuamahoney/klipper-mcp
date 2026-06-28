# Klipper MCP Server

A Model Context Protocol (MCP) server for controlling Klipper 3D printers via
Moonraker API. Enables AI coding assistants to interact with your printer
through any MCP-compatible client.

Compatible with any Klipper-based printer — Elegoo, Voron, RatRig, and more.

---

## Features

### 🖨️ Core Printer Control

| Tool | Description |
|---|---|
| `get_printer_status` | Full status including temps, position, state |
| `run_gcode` | Execute any G-code command |
| `start_print` | Start a print job |
| `pause_print` / `resume_print` | Print flow control |
| `cancel_print` | Cancel current print |
| `home_axes` | Home X/Y/Z or all axes |
| `emergency_stop` | Immediate halt |
| `restart_klipper` | Firmware restart |
| `quad_gantry_level` | Run QGL procedure |
| `set_heater_temperature` | Set hotend/bed temps |

### 🔧 StealthChanger / Toolchanger Support

| Tool | Description |
|---|---|
| `get_active_tool` | Current tool status |
| `select_tool` | Pick up tool (T0-T5) |
| `drop_tool` | Return tool to dock |
| `initialize_toolchanger` | Run init sequence |
| `get_tool_offsets` | Tool offset values |
| `start_tool_alignment` | Alignment workflow |
| `test_dock_undock` | Test docking operations |
| `disable_crash_detection` | Disable during testing |

### ⚡ TMC Stepper Driver Control

| Tool | Description |
|---|---|
| `get_tmc_status` | Driver status, currents, temps |
| `set_tmc_current` | Adjust run/hold current |
| `dump_tmc_registers` | Register diagnostics |
| `get_tmc_field` / `set_tmc_field` | Direct register access |
| `get_autotune_status` | TMC Autotune configuration |
| `list_tmc_steppers` | All TMC-equipped steppers |

### 💡 LED Effects (klipper-led_effect)

| Tool | Description |
|---|---|
| `list_led_effects` | Available effects |
| `set_led_effect` | Activate an effect |
| `stop_led_effect` / `stop_all_effects` | Stop effects |
| `set_led_color` | Direct RGB/RGBW control |
| `list_led_scenes` | Preset scenes |
| `activate_led_scene` | Apply scene preset |

### 📁 File Operations

| Tool | Description |
|---|---|
| `list_gcode_files` | Browse G-code files |
| `get_file_metadata` | Slicer settings, thumbnails |
| `read_gcode_file` | Read file contents |
| `upload_gcode_file` | Upload new files |
| `delete_gcode_file` | Remove files |
| `search_in_file` | Search file contents |
| `list_config_files` | Klipper config files |
| `read_config_file` | Read printer.cfg etc. |

### 📷 Camera & Timelapse

| Tool | Description |
|---|---|
| `get_camera_snapshot` | Capture current frame |
| `get_camera_stream_url` | MJPEG stream URL |
| `get_timelapse_settings` | Current timelapse config |
| `set_timelapse_enabled` | Enable/disable timelapse |
| `capture_timelapse_frame` | Manual frame capture |
| `render_timelapse` | Trigger video render |
| `configure_timelapse` | Adjust settings |

### 📊 Print Statistics

| Tool | Description |
|---|---|
| `get_print_history` | Past prints with filtering |
| `get_print_stats` | Cumulative statistics |
| `get_filament_usage_by_material` | Usage breakdown |
| `get_recent_prints` | Last N prints summary |
| `get_average_print_stats` | Average metrics |
| `export_printer_data` | Export all data to JSON |

### 🔍 Diagnostics & Troubleshooting

| Tool | Description |
|---|---|
| `parse_klippy_log` | Analyze log for issues |
| `get_recent_errors` | Recent errors with context |
| `get_log_summary` | Log overview |
| `check_common_issues` | Config problem detection |
| `get_mcu_status` | MCU info and timing |
| `get_gcode_history` | Recent G-code commands |
| `get_troubleshooting_guide` | Problem-specific help |
| `analyze_print_failure` | Failure diagnosis |
| `check_config_issues` | Configuration validation |
| `get_system_performance` | CPU, memory, disk stats |

### 🌡️ Temperature & Bed Mesh

| Tool | Description |
|---|---|
| `get_temperatures` | All heater temperatures |
| `get_temperature_history` | Historical temp data |
| `analyze_temperature_data` | Anomaly detection |
| `set_temperature_alert` | Threshold alerts |
| `run_bed_mesh_calibrate` | Run bed mesh |
| `get_bed_mesh_profiles` | List saved meshes |
| `load_bed_mesh` | Load a mesh profile |
| `save_bed_mesh` | Save current mesh |
| `clear_bed_mesh` | Remove active mesh |

### 🧵 Spoolman Integration

| Tool | Description |
|---|---|
| `list_spools` | All tracked spools |
| `get_active_spool` | Currently loaded spool |
| `set_active_spool` | Set spool for tool |
| `get_spool_details` | Full spool info |
| `check_low_filament` | Low filament warnings |
| `get_filament_usage_by_material` | Material statistics |
| `list_vendors` | Filament vendors |
| `list_filaments` | Filament database |

### 🔔 Notifications

| Tool | Description |
|---|---|
| `send_notification` | Multi-channel notify |
| `send_discord_notification` | Discord webhook |
| `send_slack_notification` | Slack webhook |
| `send_pushover_notification` | Pushover push |
| `announce_tts` | Text-to-speech |
| `test_notifications` | Test all channels |
| `get_notification_settings` | Current config |

### 💾 Backup & Maintenance

| Tool | Description |
|---|---|
| `backup_config` | Backup all configs |
| `list_backups` | Available backups |
| `restore_config` | Restore from backup |
| `check_maintenance_due` | Maintenance alerts |
| `log_maintenance` | Record maintenance |
| `get_maintenance_history` | Maintenance log |
| `get_audit_log` | Security audit trail |
| `export_printer_data` | Full data export |

### 📝 G-code Analysis

| Tool | Description |
|---|---|
| `analyze_gcode_file` | Full file analysis |
| `validate_gcode` | Check for issues |
| `extract_gcode_comments` | Slicer comments |
| `get_gcode_moves` | Movement statistics |
| `extract_layer` | Get specific layer |
| `compare_gcode_files` | Diff two files |

### 🖥️ System Management

| Tool | Description |
|---|---|
| `get_system_info` | CPU, memory, disk, temp |
| `get_network_info` | IP addresses, WiFi |
| `check_updates` | Available updates |
| `update_component` | Update Klipper/Moonraker |
| `refresh_update_status` | Check repos |
| `get_service_status` | Service states |
| `restart_service` | Restart services |
| `reboot_system` | System reboot |
| `shutdown_system` | System shutdown |
| `get_moonraker_config` | Moonraker info |
| `get_printer_objects` | Available Klipper objects |

---

## Installation

### Prerequisites

- Klipper + Moonraker running on your printer
- Python 3.9+ on your SBC (Raspberry Pi, CB1, Orange Pi, etc.)
- Network access between your machine and the printer

### Quick Start

```bash
# 1. SSH into your printer
ssh your-user@192.168.x.x

# 2. Clone the repository
cd ~
git clone https://github.com/joshuamahoney/klipper-mcp.git
cd klipper-mcp

# 3. Create and edit config
cp config.example.py config.py
nano config.py

# 4. Run the installer
# The installer detects your user automatically and prompts for a printer
# name. Use a unique name for each printer if connecting multiple printers
# to the same MCP client.
bash install.sh
```

The installer will:

- Set up a Python virtual environment and install dependencies
- Prompt you for a printer name
- Install and start the systemd service automatically
- Print connection commands for your MCP client

### Verify Installation

```bash
# Check the service is running
sudo systemctl status klipper-mcp

# Test the API
curl -H "X-API-Key: your-api-key" http://localhost:8000/health

# View logs
journalctl -u klipper-mcp -f
```

---

## Configuration

Copy `config.example.py` to `config.py` and customize:

```bash
nano ~/klipper-mcp/config.py
```

**Required settings:**

| Setting | Description | Example |
|---|---|---|
| `API_KEY` | Secure authentication key | `python3 -c "import secrets; print(secrets.token_urlsafe(32))"` |
| `MOONRAKER_URL` | Your Moonraker address | `http://localhost:7125` |
| `PRINTER_NAME` | Display name | `elegoo-giga-1` |

**Security settings:**

| Setting | Description | Default |
|---|---|---|
| `ARMED` | Enable dangerous operations | `false` |
| `ADMIN_PIN` | PIN for destructive ops | `123456` |

**Optional integrations:**

| Setting | Description |
|---|---|
| `SPOOLMAN_ENABLED` | Enable Spoolman filament tracking |
| `TOOL_COUNT` | Number of toolchanger tools |
| `DISCORD_WEBHOOK_URL` | Discord notifications |

---

## Connecting to Your MCP Client

The installer prints these commands automatically at the end of setup.
Replace `YOUR_API_KEY` with the value set in `config.py`, and
`192.168.x.x` with your printer's IP address.

> **Note:** If connecting multiple printers to the same MCP client, each
> printer must be given a unique name.

### Claude Code

```bash
claude mcp add --transport http my-printer http://192.168.x.x:8000/mcp \
  --header "X-API-Key: YOUR_API_KEY"
```

### OpenAI Codex

Add to `~/.codex/config.toml`:

```toml
[mcp_servers.my-printer]
url = "http://192.168.x.x:8000/mcp"
http_headers = { "X-API-Key" = "YOUR_API_KEY" }
```

### OpenCode

Add to `opencode.jsonc`:

```json
{
  "mcp": {
    "my-printer": {
      "type": "remote",
      "url": "http://192.168.x.x:8000/mcp",
      "headers": { "X-API-Key": "YOUR_API_KEY" }
    }
  }
}
```

### VS Code

Add to `settings.json` (`Ctrl+Shift+P` → "Preferences: Open User Settings (JSON)"):

```json
{
  "mcp": {
    "servers": {
      "my-printer": {
        "type": "http",
        "url": "http://192.168.x.x:8000/mcp",
        "headers": { "X-API-Key": "YOUR_API_KEY" }
      }
    }
  }
}
```

Or create `.vscode/mcp.json` in your project for workspace-scoped config.

### Multiple Printers

Each printer needs a unique name. Example with two printers:

**Claude Code:**

```bash
claude mcp add --transport http elegoo-giga-1 http://192.168.1.100:8000/mcp \
  --header "X-API-Key: KEY_FOR_PRINTER_1"

claude mcp add --transport http elegoo-giga-2 http://192.168.1.101:8000/mcp \
  --header "X-API-Key: KEY_FOR_PRINTER_2"
```

**OpenCode / VS Code:** add a separate named entry per printer under `mcp`.

---

## Security

### ARMED Flag

Dangerous operations (G-code execution, temperature changes) require
`ARMED=True` in `config.py`.

### Admin PIN

Destructive operations (file deletion, config restore, system reboot)
require the admin PIN.

### API Key

All requests must include a valid `X-API-Key` header matching your config.
Generate a key with:

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Audit Log

All operations are logged to `data/audit.log`.

---

## Configuration Reference

```python
# config.py

# Moonraker connection
MOONRAKER_URL = "http://localhost:7125"
PRINTER_NAME = "my-printer"

# MCP Server
MCP_HOST = "0.0.0.0"
MCP_PORT = 8000
MCP_TRANSPORT = "http"

# Security
API_KEY = "your-secret-key"        # Required for all API calls
ARMED = False                       # Set True to enable dangerous ops
ADMIN_PIN = "1234"                  # For destructive operations

# Camera
CAMERA_SNAPSHOT_URL = "http://localhost/webcam/?action=snapshot"
CAMERA_STREAM_URL = "http://localhost/webcam/?action=stream"

# Spoolman (optional)
SPOOLMAN_ENABLED = True
SPOOLMAN_URL = "http://localhost:7912"

# Notifications (optional)
DISCORD_WEBHOOK_URL = ""
SLACK_WEBHOOK_URL = ""
PUSHOVER_USER_KEY = ""
PUSHOVER_API_TOKEN = ""

# Text-to-Speech (optional)
TTS_ENABLED = False
TTS_RATE = 150
TTS_VOLUME = 1.0

# Maintenance intervals (print hours)
MAINTENANCE_INTERVALS = {
    "nozzle": 200,
    "belts": 500,
    "linear_rails": 1000,
    "filters": 100
}

# StealthChanger / Toolchanger
TOOL_COUNT = 4  # Number of tools (T0-T3)
```

---

## Troubleshooting

### Service won't start

```bash
# Check logs
journalctl -u klipper-mcp -n 50

# Verify config is valid
python3 -c "import config; print(config.MOONRAKER_URL)"

# Check Moonraker is running
systemctl status moonraker
```

### Can't connect from your machine

- Verify the printer IP is reachable: `ping 192.168.x.x`
- Check port 8000 is open: `sudo ufw allow 8000`
- Verify the API key matches exactly in your client config and `config.py`
- Test directly: `curl -H "X-API-Key: your-key" http://192.168.x.x:8000/health`

### Operations failing

- Check `ARMED=True` is set in `config.py` for dangerous operations
- Verify Klipper is running: `systemctl status klipper`
- Check klippy log: `tail -f ~/printer_data/logs/klippy.log`

---

## Optional Integrations

### Spoolman

```bash
cd ~/klipper-mcp/scripts
chmod +x install_spoolman.sh
./install_spoolman.sh
```

Then update `config.py`:

```python
SPOOLMAN_ENABLED = True
SPOOLMAN_URL = "http://localhost:7912"
```

### TMC Autotune

Install [klipper_tmc_autotune](https://github.com/andrewmcgr/klipper_tmc_autotune).

### LED Effects

Install [klipper-led_effect](https://github.com/julianschill/klipper-led_effect).

---

## Project Structure

```
klipper-mcp/
├── server.py            # Main MCP server
├── moonraker.py         # Moonraker API client
├── config.py            # Configuration (gitignored)
├── config.example.py    # Configuration template
├── requirements.txt     # Python dependencies
├── install.sh           # Installation script
├── klipper-mcp.service  # Systemd service template
├── tools/               # MCP tool implementations
│   ├── printer.py
│   ├── toolchanger.py
│   ├── tmc.py
│   ├── led_effects.py
│   ├── filesystem.py
│   ├── camera.py
│   ├── statistics.py
│   ├── diagnostics.py
│   ├── temperature.py
│   ├── spoolman.py
│   ├── notifications.py
│   ├── backup.py
│   ├── gcode_analysis.py
│   └── system.py
├── data/
│   ├── audit.log
│   └── maintenance.json
├── backups/
├── scenes/
│   └── led_scenes.json
└── docs/
```

---

## Contributing

Contributions welcome. Please:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

---

## Acknowledgments

- [Klipper](https://www.klipper3d.org/) — 3D printer firmware
- [Moonraker](https://moonraker.readthedocs.io/) — Klipper API server
- [Model Context Protocol](https://modelcontextprotocol.io/) — AI tool protocol
- [StealthChanger](https://github.com/DraftShift/StealthChanger) — Toolchanger system
- [Spoolman](https://github.com/Donkie/Spoolman) — Filament management

---

## License

MIT License — see LICENSE file for details.