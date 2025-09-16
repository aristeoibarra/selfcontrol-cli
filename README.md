# SelfControl CLI

A powerful command-line interface for SelfControl.app with **automated scheduled blocking** for macOS.

## 🌟 Features

### Core Features

- 🚀 **Unified command interface** - All functionality through single `selfcontrol-cli` command
- 📊 **Intelligent status reporting** with detailed block and schedule information
- 🔒 **Easy manual block management** with flexible duration options
- 📋 **Multiple blocklist support** for different contexts (work, study, minimal)
- 💡 **Helpful command suggestions** with contextual guidance

### 🆕 Advanced Scheduling System

- ⏰ **Fully customizable scheduled blocks** with JSON configuration
- 🤖 **Automatic execution** via cron integration with smart conflict resolution
- 📅 **Flexible time ranges** including midnight crossover support (e.g., 23:00-06:00)
- 🎯 **Priority-based scheduling** for overlapping time slots
- 🔍 **Real-time schedule testing** and debugging tools
- 📊 **Comprehensive logging** with rotation and structured output
- 🛡️ **Duplicate prevention** to avoid conflicts with manual blocks
- 🔐 **Passwordless sudo integration** for seamless automation
- 🚀 **100% automated operation** - no manual intervention required

### 🔧 Production-Ready Features

- 📁 **Standardized configuration** following XDG Base Directory specification
- 🧪 **Comprehensive testing** with validation and error recovery
- 🔒 **Enhanced security** with input validation and safe defaults
- 📖 **Complete documentation** with troubleshooting guides

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/aristeoibarra/selfcontrol-cli.git
cd selfcontrol-cli

# Run the installer
./scripts/install-production.sh
```

The installer will:

- ✅ Check prerequisites and validate environment
- 📁 Install files to standardized locations (`~/.local/bin`, `~/.config`, etc.)
- 🔗 Setup PATH and shell integration automatically
- ⚙️ Configure initial schedules and automation
- 🤖 Setup cron job for automatic execution every 5 minutes
- 🔐 Configure passwordless sudo for seamless automation
- 🎯 Guide you through customization options

## 📋 Command Reference

### 📊 Status & Information

- `selfcontrol-cli status` - Quick status with schedule info
- `selfcontrol-cli info` - Detailed block information
- `selfcontrol-cli version` - Version and system information

### 🚀 Block Management

- `selfcontrol-cli start [hours]` - Start manual block (default: 2 hours)
- `selfcontrol-cli help` - Show comprehensive help

### ⏰ Schedule Management

- `selfcontrol-cli schedule list` - Show all configured schedules
- `selfcontrol-cli schedule status` - Show current schedule status
- `selfcontrol-cli schedule enable <name>` - Enable specific schedule
- `selfcontrol-cli schedule disable <name>` - Disable specific schedule
- `selfcontrol-cli schedule reload` - Reload configuration from file
- `selfcontrol-cli schedule test` - Test schedule logic in real-time
- `selfcontrol-cli schedule setup` - Setup automated scheduling with cron

### 🔧 Utility Commands

- `selfcontrol-cli init` - Initialize configuration and directories

## ⚙️ Configuration

### Configuration Locations

SelfControl CLI follows XDG Base Directory specification:

```bash
# Configuration files
~/.config/selfcontrol-cli/schedule.json        # Main schedule configuration
~/.config/selfcontrol-cli/blocklist.selfcontrol # Default blocklist
~/.config/selfcontrol-cli/*.selfcontrol         # Additional blocklists

# Data and logs
~/.local/share/selfcontrol-cli/logs/schedule.log # Execution logs

# Executable
~/.local/bin/selfcontrol-cli                    # Main executable
```

### Schedule Configuration

Complete example with all features:

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
    },
    {
      "name": "digital_sunset",
      "description": "Evening wind-down",
      "start_time": "21:00",
      "end_time": "23:00",
      "days": ["sunday", "monday", "tuesday", "wednesday", "thursday"],
      "enabled": true,
      "blocklist_file": "minimal",
      "priority": 2
    },
    {
      "name": "night_block",
      "description": "Complete digital rest",
      "start_time": "23:00",
      "end_time": "06:00",
      "days": [
        "sunday",
        "monday",
        "tuesday",
        "wednesday",
        "thursday",
        "friday",
        "saturday"
      ],
      "enabled": false,
      "blocklist_file": "work",
      "priority": 1
    }
  ],

  "blocklists": {
    "default": "blocklist.selfcontrol",
    "work": "blocklist.work.selfcontrol",
    "minimal": "blocklist.minimal.selfcontrol"
  },

  "logging": {
    "enabled": true,
    "max_size_mb": 10,
    "keep_days": 30
  }
}
```

### Configuration Features

- **Midnight crossover**: `"start_time": "23:00", "end_time": "06:00"`
- **Flexible days**: Any combination of weekdays
- **Priority system**: Lower numbers = higher priority for overlaps
- **Multiple blocklists**: Different contexts (work, study, minimal)
- **Smart logging**: Automatic rotation and cleanup

## 🤖 Complete Automation Setup

### Automatic Operation (No Manual Intervention Required)

Once installed and configured, SelfControl CLI operates **100% automatically**:

#### ✅ What Happens Automatically:

- **Every 5 minutes**: Cron checks for active schedules
- **Work hours (Mon-Fri 08:00-19:00)**: Automatically starts blocking
- **Night hours (Daily 23:00-06:00)**: Automatically starts night blocking
- **Schedule transitions**: Seamlessly switches between different blocklists
- **After computer restart**: Continues working automatically
- **No password prompts**: Uses passwordless sudo configuration

#### 🔧 Setup for Complete Automation:

```bash
# 1. Install with automation
./scripts/install-production.sh

# 2. Configure passwordless sudo (one-time setup)
sudo tee /etc/sudoers.d/selfcontrol-cli << 'EOF'
# SelfControl CLI - Allow without password
aristeoibarra ALL=(ALL) NOPASSWD: /Users/aristeoibarra/.local/bin/selfcontrol-cli schedule check
EOF

# 3. Update cron job to use sudo
(crontab -l 2>/dev/null | grep -v "selfcontrol-cli"; echo "*/5 * * * * sudo /Users/aristeoibarra/.local/bin/selfcontrol-cli schedule check >/dev/null 2>&1") | crontab -

# 4. Verify automation is working
selfcontrol-cli schedule test
```

#### 📊 Monitoring Automation:

```bash
# Check if automation is working
selfcontrol-cli status

# View automation logs
tail -f ~/.local/share/selfcontrol-cli/logs/schedule.log

# Verify cron job
crontab -l | grep selfcontrol-cli
```

## 🎯 Use Cases & Examples

### 1. Work Schedule

```bash
# Enable deep focus during work hours
selfcontrol-cli schedule enable work_hours

# Check if currently in work hours
selfcontrol-cli schedule status

# Test work schedule logic
selfcontrol-cli schedule test
```

### 2. Digital Wellness Routine

```bash
# Setup evening wind-down
selfcontrol-cli schedule enable digital_sunset

# Enable complete night rest
selfcontrol-cli schedule enable night_block

# Check overall schedule status
selfcontrol-cli schedule list
```

### 3. Manual Blocking

```bash
# Quick 2-hour focus session
selfcontrol-cli start

# Extended 4-hour deep work
selfcontrol-cli start 4

# Short 30-minute break from distractions
selfcontrol-cli start 0.5
```

### 4. Schedule Management

```bash
# Disable all schedules for vacation
selfcontrol-cli schedule disable work_hours
selfcontrol-cli schedule disable digital_sunset

# Re-enable after vacation
selfcontrol-cli schedule enable work_hours
selfcontrol-cli schedule enable digital_sunset
```

## 🔧 Advanced Configuration

### Custom Blocklists

Create specialized blocklists for different contexts:

```bash
# Copy example blocklist
cp ~/.config/selfcontrol-cli/blocklist.example.selfcontrol ~/.config/selfcontrol-cli/blocklist.study.selfcontrol

# Edit for study context
# Add to schedule.json:
"blocklists": {
  "study": "blocklist.study.selfcontrol"
}
```

### Environment Variables

```bash
# Override configuration directory
export SELFCONTROL_CLI_CONFIG_DIR="/custom/path"

# Override data directory
export SELFCONTROL_CLI_DATA_DIR="/custom/data/path"

# Enable debug mode
export SELFCONTROL_CLI_DEBUG=1
```

### Automation Integration

```bash
# Enable work schedule on weekdays at 8 AM
0 8 * * 1-5 selfcontrol-cli schedule enable work_hours

# Disable all schedules on Friday evening
0 18 * * 5 selfcontrol-cli schedule disable work_hours
```

## 🔧 Troubleshooting

### Common Issues

**❌ "Command not found: selfcontrol-cli"**

```bash
# Solution: Ensure PATH includes ~/.local/bin
export PATH="$PATH:$HOME/.local/bin"
# Add to shell profile permanently
```

**❌ "No configuration found"**

```bash
# Solution: Initialize configuration
selfcontrol-cli init
```

**❌ "Schedules not working"**

```bash
# Solution: Setup automated scheduling
selfcontrol-cli schedule setup

# Test schedule logic
selfcontrol-cli schedule test

# Check if cron is running
crontab -l | grep selfcontrol-cli

# Verify sudo configuration
sudo /Users/aristeoibarra/.local/bin/selfcontrol-cli schedule check
```

### Debug Mode

Enable detailed logging for troubleshooting:

```bash
# Enable debug mode
export SELFCONTROL_CLI_DEBUG=1

# Run commands with verbose output
selfcontrol-cli schedule test

# Check logs
tail -f ~/.local/share/selfcontrol-cli/logs/schedule.log
```

For comprehensive troubleshooting, see [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## 📚 Documentation

- **[API Reference](docs/API.md)** - Complete command documentation
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Contributing](CONTRIBUTING.md)** - Development and contribution guidelines
- **[Changelog](CHANGELOG.md)** - Version history and changes

## 📋 Requirements

- **macOS 12.0** or later
- **[SelfControl.app](https://selfcontrolapp.com)** installed
- **Bash 4.0** or later (default on macOS)

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Development setup and guidelines
- Code standards and testing
- Pull request process
- Issue reporting guidelines

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🆘 Support

### Documentation & Self-Help

- **Troubleshooting**: [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **API Reference**: [docs/API.md](docs/API.md)

### Community Support

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and community support

---

**Happy focused working!** 🎯

_SelfControl CLI - Professional digital wellness automation for macOS_
