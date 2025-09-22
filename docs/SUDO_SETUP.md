# Sudo Configuration Guide for SelfControl CLI

This guide explains how to configure passwordless sudo for SelfControl CLI automation.

## Overview

SelfControl CLI requires sudo privileges to interact with SelfControl.app for blocking functionality. To enable seamless automation via LaunchAgent, we need to configure passwordless sudo execution for specific commands.

## Prerequisites

- SelfControl CLI v3.1.0 installed
- Administrator access to your macOS system
- Basic familiarity with terminal commands

## Configuration Steps

### 1. Open Sudoers File

```bash
sudo visudo
```

**Important**: Always use `visudo` instead of editing `/etc/sudoers` directly. This command validates syntax before saving, preventing system lockout.

### 2. Add SelfControl CLI Rules

Add the following lines at the **end** of the sudoers file:

```bash
# SelfControl CLI - Allow passwordless execution with PATH preservation
aristeoibarra ALL=(ALL) NOPASSWD: /Users/aristeoibarra/.local/bin/selfcontrol-cli
aristeoibarra ALL=(ALL) NOPASSWD: /Users/aristeoibarra/.local/lib/selfcontrol-cli/launchagent-wrapper.sh
Defaults!/Users/aristeoibarra/.local/bin/selfcontrol-cli env_keep += "PATH HOME USER"
Defaults!/Users/aristeoibarra/.local/lib/selfcontrol-cli/launchagent-wrapper.sh env_keep += "PATH HOME USER"
Defaults!/Users/aristeoibarra/.local/bin/selfcontrol-cli !secure_path
Defaults!/Users/aristeoibarra/.local/lib/selfcontrol-cli/launchagent-wrapper.sh !secure_path
```

**Note**: Replace `aristeoibarra` with your actual username. You can check your username with `whoami`.

### 3. Save and Exit

- **In nano**: Press `Ctrl+X`, then `Y`, then `Enter`
- **In vi/vim**: Press `Esc`, type `:wq`, press `Enter`

The editor will validate the syntax before saving. If there are errors, it will prompt you to fix them.

## What These Rules Do

| Rule | Purpose |
|------|---------|
| `NOPASSWD: /path/to/selfcontrol-cli` | Allows passwordless execution of SelfControl CLI |
| `NOPASSWD: /path/to/launchagent-wrapper.sh` | Allows passwordless execution of LaunchAgent wrapper |
| `env_keep += "PATH HOME USER"` | Preserves environment variables needed for execution |
| `!secure_path` | Disables secure_path for these specific commands |

## Verification

After configuration, verify the setup:

```bash
# Test passwordless sudo
sudo -n selfcontrol-cli version

# Run comprehensive diagnostics
selfcontrol-cli debug
```

You should see:
- No password prompts
- "✅ Sudo permissions: Configured" in debug output

## Troubleshooting

### Common Issues

1. **Syntax Errors**: Always use `visudo` and check syntax carefully
2. **Wrong Username**: Ensure you use your actual username (check with `whoami`)
3. **Wrong Paths**: Verify file paths match your installation

### Test Commands

```bash
# Test if sudo works without password
sudo -n true && echo "Sudo configured correctly" || echo "Sudo requires password"

# Test SelfControl CLI specifically
sudo -n selfcontrol-cli version

# Full system diagnostics
selfcontrol-cli debug
```

### Reset Configuration

If you need to remove the configuration:

```bash
sudo visudo
# Remove the SelfControl CLI lines
# Save and exit
```

## Security Considerations

- These rules only apply to specific SelfControl CLI commands
- No other sudo privileges are affected
- Environment variable preservation is limited to necessary variables
- Paths are absolute to prevent command substitution attacks

## Automation Benefits

Once configured, you get:

- **Seamless LaunchAgent Operation**: Schedules execute without user intervention
- **No Password Prompts**: Automatic blocks start/stop as scheduled
- **System Restart Persistence**: Configuration survives reboots
- **Background Operation**: Works even when user is not logged in

## Alternative: Manual Automation

If you prefer not to configure passwordless sudo, you can:

- Use manual block commands: `selfcontrol-cli start [duration]`
- Monitor schedules: `selfcontrol-cli schedule test`
- Enable schedules when needed: `selfcontrol-cli schedule enable <name>`

However, full automation requires passwordless sudo configuration.

---

**Next Steps**: After configuration, test the automation with `selfcontrol-cli debug` and `selfcontrol-cli validate`.