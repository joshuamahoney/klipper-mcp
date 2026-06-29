# Klipper MCP Server

A Model Context Protocol (MCP) server for controlling Klipper 3D printers via
Moonraker API. Enables AI coding assistants to interact with your printer
through any MCP-compatible client.

Compatible with any Klipper-based printer — Elegoo, Voron, RatRig, and more.

---

## Features

> 🔒 marks a **write tool** — one that changes printer or system state. Write
> tools are never registered when `READ_ONLY=true` (see [Security](#security)),
> and most also require `ARMED=true` and/or the admin PIN at call time.

### 🖨️ Core Printer Control

| Tool | Description |
|---|---|
| `get_printer_status` | Full status including temps, position, state |
| `get_temperatures` | Current temperatures for all heaters |
| `get_server_info` | Moonraker server info and version |
| `set_temperature` 🔒 | Set a heater (hotend/bed) target temp |
| `run_gcode` 🔒 | Execute any G-code command |
| `home_printer` 🔒 | Home X/Y/Z or all axes |
| `start_print` 🔒 | Start a print job |
| `pause_print` / `resume_print` 🔒 | Print flow control |
| `cancel_print` 🔒 | Cancel current print |
| `restart_klipper` 🔒 | Firmware restart |
| `emergency_stop` 🔒 | Immediate halt (requires admin PIN) |

### 🔧 StealthChanger / Toolchanger Support

| Tool | Description |
|---|---|
| `get_active_tool` | Current tool status |
| `get_tool_offsets` | Tool offset values |
| `get_dock_positions` | Configured dock positions |
| `select_tool` 🔒 | Activate a tool (T0–TN) |
| `pickup_tool` / `dropoff_tool` 🔒 | Pick up / return tool to dock |
| `initialize_toolchanger` 🔒 | Run init sequence |
| `tool_align_start` / `tool_align_test` / `tool_align_done` 🔒 | Alignment workflow |
| `start_crash_detection` / `stop_crash_detection` 🔒 | Crash detection control |
| `set_tool_temperature` 🔒 | Set a tool's extruder temp |
| `quad_gantry_level` 🔒 | Run QGL procedure |

### ⚡ TMC Stepper Driver Control

| Tool | Description |
|---|---|
| `get_tmc_status` | Driver status, currents, temps |
| `dump_tmc_registers` | Register diagnostics |
| `get_tmc_field` | Read a register field |
| `get_autotune_status` | TMC Autotune configuration |
| `list_tmc_steppers` | All TMC-equipped steppers |
| `set_tmc_current` 🔒 | Adjust run/hold current |
| `set_tmc_field` 🔒 | Write a register field |

### 💡 LED Effects (klipper-led_effect)

| Tool | Description |
|---|---|
| `list_led_effects` | Common effect names |
| `list_led_scenes` | Preset scenes |
| `set_led_effect` 🔒 | Activate an effect |
| `stop_led_effect` / `stop_all_led_effects` 🔒 | Stop effects |
| `set_led_direct` 🔒 | Direct RGB/RGBW control |
| `set_led_scene` 🔒 | Apply a scene preset |

### 📁 File Operations

| Tool | Description |
|---|---|
| `list_files` | List any printer directory |
| `list_gcode_files` | Browse G-code files |
| `list_config_files` | Klipper config files |
| `read_file` | Read file contents (config/logs/etc.) |
| `get_gcode_metadata` | Slicer settings, thumbnails |
| `search_in_file` | Search file contents |
| `write_file` 🔒 | Write a file (requires admin PIN) |
| `delete_file` 🔒 | Delete a file (requires admin PIN) |

### 📷 Camera & Timelapse

| Tool | Description |
|---|---|
| `capture_snapshot` | Capture current frame (base64) |
| `get_camera_stream_url` | MJPEG stream URL |
| `get_timelapse_settings` | Current timelapse config |
| `list_timelapses` | Rendered timelapse videos |
| `set_timelapse_enabled` 🔒 | Enable/disable timelapse |
| `configure_timelapse` 🔒 | Adjust settings |
| `take_timelapse_frame` 🔒 | Manual frame capture |
| `render_timelapse` 🔒 | Trigger video render |

### 📊 Print Statistics

| Tool | Description |
|---|---|
| `get_print_history` | Past prints with filtering |
| `get_print_totals` | Cumulative statistics |
| `get_job_details` | Details of a single job |
| `get_filament_usage_summary` | Filament usage summary |
| `get_recent_prints` | Prints in the last N hours |
| `get_average_print_stats` | Average metrics |

### 🔍 Diagnostics & Troubleshooting

| Tool | Description |
|---|---|
| `parse_klippy_log` | Analyze log for issues |
| `get_recent_errors` | Recent errors with context |
| `get_log_summary` | Log activity overview |
| `get_log_files` | List log files with sizes |
| `check_common_issues` | Config/state problem detection |
| `get_mcu_status` | MCU info and timing |
| `get_gcode_history` | Recent G-code responses |
| `diagnose_problem` | Symptom-based troubleshooting |
| `clear_old_logs` 🔒 | Delete old log files |
| `truncate_log` 🔒 | Truncate a log file |

### 🌡️ Temperature & Bed Mesh

| Tool | Description |
|---|---|
| `get_temperature_history` | Historical temp data |
| `detect_temperature_anomalies` | Anomaly detection |
| `get_bed_mesh` | Current mesh and statistics |
| `get_bed_mesh_profiles` | List saved meshes |
| `get_heater_pid_params` | PID parameters for a heater |
| `load_bed_mesh_profile` 🔒 | Load a mesh profile |
| `calibrate_bed_mesh` 🔒 | Run bed mesh calibration |
| `save_bed_mesh_profile` 🔒 | Save current mesh |
| `clear_bed_mesh` 🔒 | Clear active mesh |

### 🧵 Spoolman Integration

| Tool | Description |
|---|---|
| `list_spools` | All tracked spools |
| `get_spool_details` | Full spool info |
| `get_active_spool` | Currently loaded spool |
| `get_filament_vendors` | Filament vendors |
| `get_low_filament_spools` | Low filament warnings |
| `get_filament_usage_by_material` | Material usage statistics |
| `set_active_spool` 🔒 | Set the active spool |
| `clear_active_spool` 🔒 | Clear the active spool |

### 🔔 Notifications

| Tool | Description |
|---|---|
| `get_notification_config` | Current notification config |
| `send_notification` 🔒 | Multi-channel notify (Discord/Slack/Pushover/Moonraker) |
| `announce_tts` 🔒 | Text-to-speech announcement |
| `notify_print_complete` 🔒 | Print completion alert |
| `notify_temperature_alert` 🔒 | Temperature alert |
| `console_message` 🔒 | Post to Mainsail/Fluidd console |
| `test_notifications` 🔒 | Test all channels |

### 💾 Backup & Maintenance

| Tool | Description |
|---|---|
| `list_backups` | Available backups |
| `check_maintenance_due` | Maintenance alerts |
| `get_maintenance_history` | Maintenance log |
| `get_audit_log` | Security audit trail |
| `backup_config` 🔒 | Backup all configs |
| `restore_config` 🔒 | Restore from backup (requires admin PIN) |
| `log_maintenance` 🔒 | Record a maintenance action |
| `export_printer_data` 🔒 | Full data export to JSON |

### 📝 G-code Analysis

| Tool | Description |
|---|---|
| `analyze_gcode_file` | Full file analysis |
| `validate_gcode` | Check for common issues |
| `extract_gcode_comments` | Slicer comments |
| `get_gcode_move_stats` | Movement statistics |
| `get_layer_gcode` | Extract a specific layer |
| `find_gcode_section` | Find text within a file |

### 🖥️ System Management

| Tool | Description |
|---|---|
| `get_system_info` | CPU, memory, disk, temp |
| `get_network_info` | IP addresses, WiFi |
| `check_updates` | Available updates |
| `get_service_status` | Service states |
| `get_moonraker_config` | Moonraker info |
| `get_printer_objects` | Available Klipper objects |
| `update_component` 🔒 | Update Klipper/Moonraker/etc. |
| `refresh_update_status` 🔒 | Refresh update status from repos |
| `restart_service` 🔒 | Restart a service |
| `reboot_system` 🔒 | System reboot (requires ARMED) |
| `shutdown_system` 🔒 | System shutdown (requires ARMED) |

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
| `READ_ONLY` | Block all write tools at startup (monitoring-only) | `false` |
| `ARMED` | Enable dangerous operations | `false` |
| `ADMIN_PIN` | PIN for destructive ops | `123456` |

**Optional integrations:**

| Setting | Description |
|---|---|
| `SPOOLMAN_ENABLED` | Enable Spoolman filament tracking |
| `SPOOLMAN_URL` | Spoolman base URL (local or shared instance) |
| `SPOOLMAN_SYNC_ENABLED` | Track usage via klipper-mcp (vendor builds without native `[spoolman]`) |
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

The server has three independent safety layers, from broadest to narrowest:
`READ_ONLY` (what tools exist at all) → `ARMED` (whether dangerous tools act) →
`ADMIN_PIN` (per-call authorization for destructive tools).

### READ_ONLY Mode

When `READ_ONLY=True`, every write tool (marked 🔒 above) is **never registered**
at startup — it does not appear in `tools/list` and cannot be called. This is a
hard, server-side guarantee that holds regardless of `ARMED` or the admin PIN,
making it safe to expose a monitoring-only connection. On startup the log shows
how many read tools were registered and how many write tools were blocked.

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
READ_ONLY = False                   # True = block all write tools at startup
ARMED = False                       # Set True to enable dangerous ops
ADMIN_PIN = "123456"                # For destructive operations

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
SPOOLMAN_URL = "http://localhost:7912"   # local, or a shared instance e.g. http://10.8.10.50:7912
```

#### Automatic filament-usage tracking

Standard Moonraker tracks filament usage itself via its native `[spoolman]`
component, deducting from the active spool as each print runs. Some vendor
Moonraker builds (e.g. Elegoo) ship **without** that component, so usage is
never recorded.

For those printers, klipper-mcp can do the tracking instead. Enable
`SPOOLMAN_SYNC_ENABLED` (the installer offers this as a prompt) to run a small
monitor service that watches finished print jobs and deducts the filament each
one used — including partial usage on cancelled prints — from the active spool:

```python
SPOOLMAN_ENABLED = True
SPOOLMAN_URL = "http://10.8.10.50:7912"
SPOOLMAN_SYNC_ENABLED = True   # ONLY if Moonraker lacks native [spoolman] support
```

> ⚠️ Do **not** enable this on a printer whose Moonraker already has native
> `[spoolman]` tracking — both would deduct the same filament and double-count
> it. The monitor detects the native integration and refuses to start as a
> safety net.

Set which spool to charge with the `set_active_spool` tool; every subsequent
print is charged to it until you change it. This works the same whether you
run a per-printer Spoolman or a single shared instance for the whole fleet.

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
│   ├── __init__.py      # Registers all tool modules
│   ├── _util.py         # Shared helpers (duration formatting)
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