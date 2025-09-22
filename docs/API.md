# SelfControl CLI API Reference

Complete documentation for all SelfControl CLI commands and functionality.

## 📋 Command Overview

SelfControl CLI provides a unified command interface for managing SelfControl.app with **100% automated scheduling capabilities**.

### 🤖 Automation Features

- **Automatic Execution**: Cron job runs every 5 minutes
- **Passwordless Sudo**: Seamless operation without password prompts
- **Schedule Detection**: Intelligent detection of active schedules
- **Conflict Resolution**: Smart handling of overlapping schedules
- **Persistent Operation**: Continues working after computer restart

### Basic Syntax

```bash
selfcontrol-cli <command> [subcommand] [options]
```

## 📊 Status & Information Commands

### `selfcontrol-cli status`

Show current SelfControl and schedule status.

**Usage:**

```bash
selfcontrol-cli status
```

**Output:**

- Current SelfControl block status (ACTIVE/INACTIVE)
- Remaining time if block is active
- Active schedule information if applicable
- Warnings for schedules that should be running

**Examples:**

```bash
$ selfcontrol-cli status
🔒 SelfControl: ACTIVE
⏰ Remaining: 1h 23m
📅 Active schedule: work_hours

$ selfcontrol-cli status
✅ SelfControl: INACTIVE
⚠️  Schedule 'work_hours' should be active!
⏰ Should run until: 17:00 (2h 15m left)
💡 Run 'selfcontrol-cli schedule check' to start scheduled block
```

### `selfcontrol-cli info`

Show detailed system information.

**Usage:**

```bash
selfcontrol-cli info
```

**Output:**

- Version information
- SelfControl.app integration status
- Configuration file status
- Schedule count
- Log file information

### `selfcontrol-cli version`

Show version and system information.

**Usage:**

```bash
selfcontrol-cli version
```

**Output:**

- CLI version
- SelfControl.app availability
- Configuration status
- File paths

## 🚀 Block Management Commands

### `selfcontrol-cli start [hours]`

Start a manual SelfControl block.

**Usage:**

```bash
selfcontrol-cli start [hours]
```

**Parameters:**

- `hours` (optional): Duration in hours (default: 2)
  - Supports decimal values (e.g., 0.5 for 30 minutes)
  - Maximum: 24 hours

**Examples:**

```bash
selfcontrol-cli start          # 2-hour block
selfcontrol-cli start 4        # 4-hour block
selfcontrol-cli start 0.5      # 30-minute block
```

**Behavior:**

- Checks if SelfControl is already running
- Validates blocklist file exists
- Calculates end time
- Starts block using SelfControl CLI
- Logs the action

**Error Conditions:**

- SelfControl already running
- Invalid hours format
- Blocklist file not found
- SelfControl.app not installed

## 🤖 Service Management Commands (v2.1.0)

### `selfcontrol-cli service status`

Show comprehensive LaunchAgent service status and diagnostics.

**Usage:**

```bash
selfcontrol-cli service status
```

**Output:**

- LaunchAgent file existence and location
- LaunchAgent load status (loaded/not loaded)
- LaunchAgent health status (running/not running)
- Detailed LaunchAgent information
- Log file status and recent entries
- System diagnostics (sudo permissions, SelfControl.app, configuration)
- Migration status (cron vs LaunchAgent)

**Example:**

```
📊 SelfControl CLI Service Status
=================================

LaunchAgent File: ✅ Exists (/Users/user/Library/LaunchAgents/com.selfcontrol.cli.scheduler.plist)
LaunchAgent Status: ✅ Loaded
LaunchAgent Health: ✅ Running

📊 LaunchAgent Details:
   Label: com.selfcontrol.cli.scheduler
   Last Exit Status: 0
   Program: /usr/bin/sudo

📋 Log Files:
   Output: ✅ Available (25 lines, 1.2KB)
   Errors: ✅ No errors

🔧 Diagnostics:
   Sudo permissions: ✅ Configured
   SelfControl.app: ✅ Available
   Configuration: ✅ Found

🔄 Migration Status:
   Cron job: ✅ Migrated/Clean
```

### `selfcontrol-cli service start`

Start (load) the LaunchAgent service.

**Usage:**

```bash
selfcontrol-cli service start
```

**Behavior:**

- Loads the LaunchAgent if it exists but is not loaded
- Shows message if already loaded
- Returns error if LaunchAgent plist doesn't exist

### `selfcontrol-cli service stop`

Stop (unload) the LaunchAgent service.

**Usage:**

```bash
selfcontrol-cli service stop
```

**Behavior:**

- Unloads the LaunchAgent if it's currently loaded
- Shows message if not loaded
- Schedules will not run while stopped

### `selfcontrol-cli service restart`

Restart the LaunchAgent service (unload then load).

**Usage:**

```bash
selfcontrol-cli service restart
```

**Behavior:**

- Unloads the LaunchAgent (if loaded)
- Waits briefly
- Loads the LaunchAgent again
- Useful for applying configuration changes

### `selfcontrol-cli service logs`

Display LaunchAgent logs.

**Usage:**

```bash
selfcontrol-cli service logs [lines]
```

**Parameters:**

- `lines` (optional): Number of lines to show (default: 20)

**Output:**

- Recent output log entries
- Recent error log entries (if any)
- Formatted with timestamps and clear separation

**Example:**

```bash
# Show last 20 lines
selfcontrol-cli service logs

# Show last 50 lines
selfcontrol-cli service logs 50
```

### `selfcontrol-cli service migrate`

Migrate from cron-based scheduling to LaunchAgent-based scheduling.

**Usage:**

```bash
selfcontrol-cli service migrate
```

**Behavior:**

- Detects existing cron job configuration
- Preserves current scheduling interval
- Creates and installs LaunchAgent with same settings
- Removes cron job after successful LaunchAgent installation
- Backs up cron configuration before removal
- Shows completion status and next steps

**Migration Process:**

1. Detect existing cron job and extract configuration
2. Create LaunchAgent plist with same interval
3. Install and load LaunchAgent
4. Verify LaunchAgent is working
5. Remove cron job
6. Confirm migration success

**Example Output:**

```
ℹ️  Starting migration from cron to LaunchAgent...

ℹ️  Detected cron interval: 5 minutes
ℹ️  Backed up cron to: ~/.local/share/selfcontrol-cli/cron_backup_20240921_143022.txt
✅ LaunchAgent installed successfully
✅ LaunchAgent is active
✅ Cron job removed successfully
✅ Migration completed successfully!

ℹ️  Your schedules will now run via LaunchAgent instead of cron
ℹ️  Check status with: selfcontrol-cli service status
```

## ⏰ Schedule Management Commands

### `selfcontrol-cli schedule list`

Show all configured schedules.

**Usage:**

```bash
selfcontrol-cli schedule list
```

**Output:**

- Current time and date
- List of all schedules with:
  - Name and description
  - Enabled/disabled status
  - Time range
  - Active days

**Example:**

```
📅 SelfControl Scheduled Blocks

🕐 Current time: Monday, September 15 - 14:04

📋 work_hours
   Description: Deep focus work time
   Status: ✅ Enabled
   Time: 08:00 - 17:00
   Days: monday tuesday wednesday thursday friday

📋 night_block
   Description: Complete digital rest
   Status: ❌ Disabled
   Time: 23:00 - 06:00
   Days: sunday monday tuesday wednesday thursday friday saturday
```

### `selfcontrol-cli schedule status`

Show current schedule status.

**Usage:**

```bash
selfcontrol-cli schedule status
```

**Output:**

- Currently active schedule (if any)
- No active schedule message (if none)

### `selfcontrol-cli schedule enable <name>`

Enable a specific schedule.

**Usage:**

```bash
selfcontrol-cli schedule enable <name>
```

**Parameters:**

- `name`: Schedule name to enable

**Examples:**

```bash
selfcontrol-cli schedule enable work_hours
selfcontrol-cli schedule enable night_block
```

**Behavior:**

- Updates schedule configuration file
- Sets `enabled` field to `true`
- Validates JSON syntax after update
- Logs the action

### `selfcontrol-cli schedule disable <name>`

Disable a specific schedule.

**Usage:**

```bash
selfcontrol-cli schedule disable <name>
```

**Parameters:**

- `name`: Schedule name to disable

**Examples:**

```bash
selfcontrol-cli schedule disable work_hours
selfcontrol-cli schedule disable night_block
```

### `selfcontrol-cli schedule reload`

Reload configuration from file.

**Usage:**

```bash
selfcontrol-cli schedule reload
```

**Behavior:**

- Validates configuration file syntax
- Reloads schedule settings
- Useful after manual configuration edits

### `selfcontrol-cli schedule test`

Test schedule logic in real-time.

**Usage:**

```bash
selfcontrol-cli schedule test
```

**Output:**

- Current time and day
- Test results for each schedule:
  - Enabled/disabled status
  - Day activation status
  - Time window status
  - Action that would be taken
- Currently active schedule

**Example:**

```
🧪 Testing Schedule Logic
=========================

Current time: 14:30 (monday)

📅 Schedule: work_hours
   Status: ✅ Enabled
   Time: 08:00 - 17:00
   Days: monday tuesday wednesday thursday friday
   Today: ✅ Active day
   Now: ✅ Within time window
   Action: 🚀 Would start block

🎯 Currently active: work_hours
```

### `selfcontrol-cli schedule setup`

Setup automated scheduling with cron.

**Usage:**

```bash
selfcontrol-cli schedule setup
```

**Behavior:**

- Adds cron job to check schedules every 5 minutes
- Checks for existing cron jobs
- Configures: `*/5 * * * * selfcontrol-cli schedule check`

**Cron Job:**

```bash
*/5 * * * * /path/to/selfcontrol-cli schedule check >/dev/null 2>&1
```

### `selfcontrol-cli schedule check`

Internal command called by cron.

**Usage:**

```bash
selfcontrol-cli schedule check
```

**Behavior:**

- Checks for active schedules
- Starts blocks if needed
- Prevents duplicate blocks
- Logs all actions

## 🔧 Utility Commands

### `selfcontrol-cli init`

Initialize configuration and directories.

**Usage:**

```bash
selfcontrol-cli init
```

**Behavior:**

- Creates default configuration file
- Creates default blocklist
- Sets up directory structure
- Provides next steps guidance

**Created Files:**

- `~/.config/selfcontrol-cli/schedule.json`
- `~/.config/selfcontrol-cli/blocklist.selfcontrol`

### `selfcontrol-cli help`

Show comprehensive help information.

**Usage:**

```bash
selfcontrol-cli help
```

**Output:**

- Command overview
- Usage examples
- Available commands
- Project information

## 📁 Configuration

### Schedule Configuration (`schedule.json`)

**Location:** `~/.config/selfcontrol-cli/schedule.json`

**Structure:**

```json
{
  "global_settings": {
    "check_interval": 5,
    "timezone": "auto",
    "prevent_duplicates": true,
    "log_level": "info"
  },
  "schedules": [
    {
      "name": "work_hours",
      "description": "Deep focus work time",
      "start_time": "08:00",
      "end_time": "17:00",
      "days": ["monday", "tuesday", "wednesday", "thursday", "friday"],
      "enabled": true,
      "blocklist_file": "work",
      "priority": 1
    }
  ],
  "blocklists": {
    "default": "blocklist.selfcontrol",
    "work": "blocklist.work.selfcontrol"
  },
  "logging": {
    "enabled": true,
    "max_size_mb": 10,
    "keep_days": 30
  }
}
```

### Schedule Properties

| Property         | Type    | Description                | Example                  |
| ---------------- | ------- | -------------------------- | ------------------------ |
| `name`           | string  | Unique schedule identifier | `"work_hours"`           |
| `description`    | string  | Human-readable description | `"Deep focus work time"` |
| `start_time`     | string  | Start time (HH:MM)         | `"08:00"`                |
| `end_time`       | string  | End time (HH:MM)           | `"17:00"`                |
| `days`           | array   | Active days of week        | `["monday", "friday"]`   |
| `enabled`        | boolean | Schedule enabled status    | `true`                   |
| `blocklist_file` | string  | Blocklist to use           | `"work"`                 |
| `priority`       | number  | Priority for overlaps      | `1`                      |

### Blocklist Files

**Location:** `~/.config/selfcontrol-cli/`

**Format:** XML plist format (SelfControl.app format)

**Example:**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <string>facebook.com</string>
    <string>twitter.com</string>
    <string>instagram.com</string>
</array>
</plist>
```

## 🔍 Error Handling

### Common Error Messages

| Error                          | Cause                         | Solution                                |
| ------------------------------ | ----------------------------- | --------------------------------------- |
| `SelfControl.app not found`    | SelfControl.app not installed | Install from https://selfcontrolapp.com |
| `Blocklist file not found`     | Missing blocklist file        | Run `selfcontrol-cli init`              |
| `Invalid hours format`         | Invalid duration parameter    | Use numeric format (e.g., 2, 0.5)       |
| `SelfControl already running`  | Block already active          | Wait for current block to end           |
| `Failed to load configuration` | Invalid JSON syntax           | Check `schedule.json` syntax            |

### Exit Codes

| Code | Meaning               |
| ---- | --------------------- |
| 0    | Success               |
| 1    | General error         |
| 2    | Configuration error   |
| 3    | SelfControl.app error |

## 🔧 Advanced Usage

### Environment Variables

| Variable                     | Description               | Default                          |
| ---------------------------- | ------------------------- | -------------------------------- |
| `SELFCONTROL_CLI_CONFIG_DIR` | Override config directory | `~/.config/selfcontrol-cli`      |
| `SELFCONTROL_CLI_DATA_DIR`   | Override data directory   | `~/.local/share/selfcontrol-cli` |
| `SELFCONTROL_CLI_DEBUG`      | Enable debug mode         | `0`                              |

### Debug Mode

Enable detailed logging:

```bash
export SELFCONTROL_CLI_DEBUG=1
selfcontrol-cli schedule test
```

### Custom Blocklists

Create specialized blocklists:

```bash
# Copy example
cp ~/.config/selfcontrol-cli/blocklist.example.selfcontrol \
   ~/.config/selfcontrol-cli/blocklist.study.selfcontrol

# Edit for study context
# Add to schedule.json:
"blocklists": {
  "study": "blocklist.study.selfcontrol"
}
```

### Automation Integration

Manual cron setup:

```bash
# Add to crontab
crontab -e

# Add line:
*/5 * * * * /path/to/selfcontrol-cli schedule check >/dev/null 2>&1
```

## 📚 Examples

### Basic Workflow

```bash
# 1. Initialize
selfcontrol-cli init

# 2. Configure schedules
# Edit ~/.config/selfcontrol-cli/schedule.json

# 3. Test configuration
selfcontrol-cli schedule test

# 4. Enable automation
selfcontrol-cli schedule setup

# 5. Monitor status
selfcontrol-cli status
```

### Manual Blocking

```bash
# Quick 30-minute focus
selfcontrol-cli start 0.5

# Extended 4-hour deep work
selfcontrol-cli start 4

# Check remaining time
selfcontrol-cli status
```

### Schedule Management

```bash
# List all schedules
selfcontrol-cli schedule list

# Enable work schedule
selfcontrol-cli schedule enable work_hours

# Test schedule logic
selfcontrol-cli schedule test

# Disable for vacation
selfcontrol-cli schedule disable work_hours
```

---

For more information, see:

- [README.md](../README.md) - Installation and quick start
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues and solutions
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Development guidelines
