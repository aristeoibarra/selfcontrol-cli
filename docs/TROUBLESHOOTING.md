# Troubleshooting Guide

Common issues and solutions for SelfControl CLI.

## 🚨 Quick Fixes (Updated for v3.1.0)

### Automation Not Working

**Problem:** Schedules are not executing automatically

**Diagnosis (NEW v3.1.0 - Enhanced Tools):**

```bash
# 1. Run comprehensive diagnostics (NEW v3.1.0)
selfcontrol-cli debug

# 2. Validate all configuration (NEW v3.1.0)
selfcontrol-cli validate

# 3. Monitor system in real-time (NEW v3.1.0)
selfcontrol-cli status --live

# 4. Follow logs for detailed information (NEW v3.1.0)
selfcontrol-cli logs --follow

# Legacy diagnostic tools
selfcontrol-cli service status
selfcontrol-cli schedule test
```

**Solutions:**

```bash
# 1. Configure passwordless sudo
sudo tee /etc/sudoers.d/selfcontrol-cli << 'EOF'
# SelfControl CLI - Allow without password
# LaunchAgent handles automation - no sudo configuration needed
EOF

# 2. Restart LaunchAgent service
selfcontrol-cli service restart

# 3. Test automation
# Check LaunchAgent functionality
selfcontrol-cli service logs
```

### Schedule Detection Issues

**Problem:** System shows "No active schedule found" when it should be active

**Common Causes:**

- JSON parsing issues (fixed in v2.0.0)
- Day detection problems (fixed in v2.0.0)
- Path resolution issues (fixed in v2.0.0)

**Solution:**

```bash
# Reinstall with latest fixes
./scripts/install-production.sh --force

# Test schedule detection
selfcontrol-cli schedule test
```

### Command Not Found

**Error:** `command not found: selfcontrol-cli`

**Solution:**

```bash
# Add to PATH
export PATH="$PATH:$HOME/.local/bin"

# Add permanently to shell profile
echo 'export PATH="$PATH:$HOME/.local/bin"' >> ~/.zshrc
source ~/.zshrc
```

### SelfControl.app Not Found

**Error:** `SelfControl.app not found`

**Solution:**

```bash
# Install SelfControl.app
# Download from: https://selfcontrolapp.com

# Or with Homebrew:
brew install --cask selfcontrol
```

### Configuration Not Found

**Error:** `No configuration found`

**Solution (Enhanced v3.1.0):**

```bash
# Initialize configuration
selfcontrol-cli init

# Validate configuration after setup (NEW v3.1.0)
selfcontrol-cli validate

# Run diagnostics to verify everything (NEW v3.1.0)
selfcontrol-cli debug
```

## 🔧 Installation Issues

### Permission Denied

**Error:** `Permission denied` during installation

**Solution:**

```bash
# Make installer executable
chmod +x scripts/install-production.sh

# Run installer
./scripts/install-production.sh
```

### PATH Not Updated

**Error:** Command works in project directory but not globally

**Solution:**

```bash
# Check current PATH
echo $PATH

# Verify installation
ls -la ~/.local/bin/selfcontrol-cli

# Restart terminal or reload shell
source ~/.zshrc
```

### LaunchAgent Not Working

**Error:** Schedules not executing automatically

**Solution:**

```bash
# Check LaunchAgent status
selfcontrol-cli service status

# Restart LaunchAgent
selfcontrol-cli service restart

# Check logs for errors
selfcontrol-cli service logs
```

## ⚙️ Configuration Issues

### Invalid JSON Syntax

**Error:** `Invalid JSON syntax in schedule configuration`

**Solution:**

```bash
# Validate JSON
python3 -m json.tool ~/.config/selfcontrol-cli/schedule.json

# Fix common issues:
# - Missing commas between objects
# - Trailing commas
# - Unescaped quotes
```

### Schedule Not Working

**Error:** Schedule enabled but not starting blocks

**Solution:**

```bash
# Test schedule logic
selfcontrol-cli schedule test

# Check current time vs schedule
selfcontrol-cli schedule status

# Check LaunchAgent logs
selfcontrol-cli service logs
```

### Blocklist Not Found

**Error:** `Blocklist file not found`

**Solution:**

```bash
# Check blocklist files
ls -la ~/.config/selfcontrol-cli/*.selfcontrol

# Create default blocklist
selfcontrol-cli init

# Verify blocklist format
xmllint --noout ~/.config/selfcontrol-cli/blocklist.selfcontrol
```

## 🚀 Runtime Issues

### SelfControl Already Running

**Error:** `SelfControl is already running`

**Solution:**

```bash
# Check current status
selfcontrol-cli status

# Wait for current block to end
# Or cancel from SelfControl.app GUI
```

### Block Not Starting

**Error:** Block command succeeds but no block starts

**Solution:**

```bash
# Check SelfControl.app installation
ls -la /Applications/SelfControl.app/Contents/MacOS/SelfControl-CLI

# Test SelfControl CLI directly
sudo /Applications/SelfControl.app/Contents/MacOS/SelfControl-CLI is-running

# Check blocklist format
xmllint --noout ~/.config/selfcontrol-cli/blocklist.selfcontrol
```

### Schedule Overlap Issues

**Error:** Multiple schedules active simultaneously

**Solution:**

```bash
# Check schedule priorities
selfcontrol-cli schedule list

# Adjust priorities in configuration
# Lower numbers = higher priority

# Test schedule logic
selfcontrol-cli schedule test
```

## 📊 Debugging

### Enable Debug Mode

```bash
# Set debug environment variable
export SELFCONTROL_CLI_DEBUG=1

# Run commands with verbose output
selfcontrol-cli schedule test
```

### Check Logs

```bash
# View schedule logs
tail -f ~/.local/share/selfcontrol-cli/logs/schedule.log

# Check LaunchAgent logs
selfcontrol-cli service logs 50
```

### Validate Installation

```bash
# Run test suite
./tests/test_runner.sh

# Test specific components
./tests/test_runner.sh basic
./tests/test_runner.sh config
./tests/test_runner.sh schedule
```

## 🔍 Advanced Troubleshooting

### Time Zone Issues

**Problem:** Schedules not matching local time

**Solution:**

```bash
# Check system timezone
date

# Verify timezone in configuration
grep timezone ~/.config/selfcontrol-cli/schedule.json

# Set explicit timezone if needed
# Edit schedule.json: "timezone": "America/New_York"
```

### Midnight Crossover Issues

**Problem:** Schedules crossing midnight not working

**Solution:**

```bash
# Test midnight crossover logic
selfcontrol-cli schedule test

# Verify schedule configuration
# Example: "start_time": "23:00", "end_time": "06:00"
```

### Performance Issues

**Problem:** Slow command execution

**Solution:**

```bash
# Check system resources
top -l 1

# Optimize configuration
# Reduce check_interval in schedule.json

# Check log file size
ls -lh ~/.local/share/selfcontrol-cli/logs/schedule.log
```

## 🆕 New Diagnostic Tools (v3.1.0)

### Enhanced Troubleshooting Workflow

SelfControl CLI v3.1.0 introduces powerful new diagnostic tools that make troubleshooting much easier:

#### 1. Comprehensive System Diagnostics

```bash
# Run full system diagnosis (NEW v3.1.0)
selfcontrol-cli debug
```

**What it checks:**
- System information (macOS version, Bash version, user environment)
- File paths and permissions for all critical files
- SelfControl.app integration and version detection
- LaunchAgent status and configuration validation
- Configuration JSON syntax and structure
- Sudo permissions testing

#### 2. Configuration Validation

```bash
# Validate all configuration files (NEW v3.1.0)
selfcontrol-cli validate
```

**What it validates:**
- JSON syntax in schedule.json
- All referenced blocklist files exist and are valid
- Schedule configuration structure and time formats
- File permissions and accessibility

#### 3. Real-time Status Monitoring

```bash
# Monitor system in real-time (NEW v3.1.0)
selfcontrol-cli status --live
```

**Features:**
- Auto-refresh every 5 seconds
- Real-time SelfControl status updates
- Active schedule information
- Recent LaunchAgent activity
- Graceful exit with Ctrl+C

#### 4. Enhanced Log Management

```bash
# Follow logs in real-time (NEW v3.1.0)
selfcontrol-cli logs --follow

# Show specific number of log lines (NEW v3.1.0)
selfcontrol-cli logs --lines 50
```

**Capabilities:**
- Real-time log following like `tail -f`
- Configurable line limits
- Professional log formatting
- Intelligent file detection

### Recommended Troubleshooting Steps (v3.1.0)

When experiencing issues, follow this enhanced workflow:

```bash
# 1. Quick diagnostics overview
selfcontrol-cli debug

# 2. Validate configuration
selfcontrol-cli validate

# 3. Check service status
selfcontrol-cli service status

# 4. Monitor in real-time
selfcontrol-cli status --live

# 5. Follow logs for detailed information
selfcontrol-cli logs --follow
```

This new approach provides comprehensive system analysis and real-time monitoring capabilities that make identifying and resolving issues much more efficient.

## 🛠️ Recovery Procedures

### Reset Configuration

```bash
# Backup current configuration
cp ~/.config/selfcontrol-cli/schedule.json ~/.config/selfcontrol-cli/schedule.json.backup

# Reset to defaults
selfcontrol-cli init

# Validate new configuration (NEW v3.1.0)
selfcontrol-cli validate

# Run diagnostics to verify (NEW v3.1.0)
selfcontrol-cli debug
```

### Reinstall

```bash
# Uninstall
./scripts/install-production.sh --uninstall

# Clean reinstall
./scripts/install-production.sh
```

### Fix Corrupted Installation

```bash
# Remove installation
rm -rf ~/.local/bin/selfcontrol-cli
rm -rf ~/.local/lib/selfcontrol-cli

# Reinstall
./scripts/install-production.sh
```

## 📞 Getting Help

### Self-Diagnosis

```bash
# System information
selfcontrol-cli info

# Test all functionality
./tests/test_runner.sh

# Check configuration
selfcontrol-cli schedule test
```

### Collect Debug Information

```bash
# Create debug report
{
  echo "=== System Information ==="
  uname -a
  sw_vers
  echo ""
  echo "=== SelfControl CLI Info ==="
  selfcontrol-cli info
  echo ""
  echo "=== Configuration ==="
  cat ~/.config/selfcontrol-cli/schedule.json
  echo ""
  echo "=== Recent Logs ==="
  tail -20 ~/.local/share/selfcontrol-cli/logs/schedule.log
} > debug-report.txt
```

### Community Support

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and community support
- **Documentation**: Check API.md for detailed command reference

## 🔧 Common Configuration Fixes

### Fix Schedule JSON

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
      "description": "Work time",
      "start_time": "09:00",
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
  }
}
```

### Fix Blocklist XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <string>facebook.com</string>
    <string>twitter.com</string>
</array>
</plist>
```

---

**Still having issues?** Create a GitHub issue with your debug report and system information.
