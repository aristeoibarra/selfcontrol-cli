# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SelfControl CLI is a Bash-based command-line interface for SelfControl.app on macOS. The project provides automated scheduled blocking with LaunchAgent integration, manual block management, and comprehensive schedule configuration. This is a **production-ready** macOS automation tool with ~95% test coverage.

**Current Version**: v3.1.0 (includes enhanced UX and diagnostic tools)

## Core Architecture

### Main Components

- **`bin/selfcontrol-cli`** - Main executable that routes commands and sources libraries
- **`lib/core.sh`** - Core functionality library with SelfControl.app integration, file operations, and error handling
- **`lib/schedule.sh`** - Schedule management library with JSON configuration parsing and time logic
- **`scripts/launchagent.sh`** - LaunchAgent automation system for automatic schedule execution
- **`scripts/install-production.sh`** - Production installer with full environment setup
- **`scripts/uninstall.sh`** - Complete uninstallation with cleanup

### Configuration System

The project follows XDG Base Directory specification:

- **Configuration**: `~/.config/selfcontrol-cli/schedule.json` (main config), `*.selfcontrol` (blocklists)
- **Data/Logs**: `~/.local/share/selfcontrol-cli/logs/`
- **Executables**: `~/.local/bin/selfcontrol-cli` (production install)

### Schedule Configuration Format

JSON-based with features including:
- Midnight crossover support (`"start_time": "23:00", "end_time": "06:00"`)
- Priority-based overlapping schedule resolution
- Multiple blocklist support (work, study, minimal contexts)
- Automatic duplicate prevention
- LaunchAgent integration every 5 minutes

## Development Commands

### Testing

```bash
# Run all tests
./tests/test_runner.sh

# Run specific test suites
./tests/test_runner.sh basic      # Basic functionality
./tests/test_runner.sh config     # Configuration validation
./tests/test_runner.sh schedule   # Schedule functionality
./tests/test_runner.sh syntax     # Script syntax validation
./tests/test_runner.sh install    # Installation system
```

### Development Workflow

```bash
# Test before changes
./tests/test_runner.sh

# Development testing with current working directory
./bin/selfcontrol-cli status
./bin/selfcontrol-cli schedule test

# Production installation (creates ~/.local/bin/selfcontrol-cli)
./scripts/install-production.sh

# Clean uninstall
./scripts/uninstall.sh
```

## Code Standards

### Bash Best Practices

- **Strict mode**: All scripts use `set -euo pipefail`
- **Error handling**: Comprehensive validation and recovery
- **Input sanitization**: All user inputs validated
- **Shellcheck compliance**: Code follows shellcheck recommendations
- **Function documentation**: All functions have purpose, parameters, and return value docs

### File Organization

- **Functions**: Use `snake_case` (e.g., `cmd_schedule_list`)
- **Variables**: `UPPER_CASE` for constants, `lower_case` for locals
- **Library loading**: Conditional sourcing based on development vs production paths
- **Source prevention**: Libraries use guards to prevent multiple sourcing

### Security Considerations

- **Path validation**: Prevent directory traversal attacks
- **Command injection prevention**: Proper input escaping
- **File permissions**: Appropriate permissions for config and log files
- **Sudo integration**: Passwordless sudo setup for automation

## Key Architectural Patterns

### Library System

The main executable uses conditional library loading:

```bash
# Development mode (when lib/ exists relative to script)
if [[ -d "$ROOT_DIR/lib" && -f "$ROOT_DIR/lib/core.sh" ]]; then
    readonly LIB_DIR="$ROOT_DIR/lib"
else
    # Production mode
    readonly LIB_DIR="$HOME/.local/lib/selfcontrol-cli"
fi
```

### Command Routing

Commands are routed through a case statement in the main executable with validation and help integration.

### Schedule Logic

Time-based schedule activation uses:
- Current day-of-week detection
- Time range validation with midnight crossover support
- Priority-based conflict resolution for overlapping schedules
- JSON configuration parsing with error recovery

### LaunchAgent Integration

- **Automation**: Native macOS LaunchAgent runs every 5 minutes
- **Persistence**: Survives computer restarts and user sessions
- **Passwordless operation**: Configured sudo integration
- **Migration**: Automatic migration from legacy cron systems

## Integration Points

### SelfControl.app Dependencies

- **Required**: SelfControl.app must be installed at `/Applications/SelfControl.app`
- **CLI tool**: Uses SelfControl's built-in CLI at `/Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli`
- **Blocklist format**: XML plist format compatible with SelfControl.app

### macOS System Integration

- **LaunchAgent**: Native macOS service for automation
- **File locations**: Follows macOS standards (XDG spec)
- **Permissions**: Integrates with macOS security model

## Common Development Tasks

### Adding New Commands

1. Add command case in `bin/selfcontrol-cli` main dispatcher
2. Implement function in appropriate library (`lib/core.sh` or `lib/schedule.sh`)
3. Add help documentation to `cmd_help()` function
4. Update API documentation in `docs/API.md`
5. Add examples and troubleshooting in `docs/TROUBLESHOOTING.md`

#### Example: New Command Implementation (v3.1.0 Pattern)

```bash
# In bin/selfcontrol-cli - Command function
cmd_new_feature() {
    if ! init_selfcontrol_cli; then
        die "Failed to initialize SelfControl CLI"
    fi

    echo "🔧 New Feature Implementation"
    echo "=========================="
    # Implementation logic here
}

# In main dispatcher
"new-feature")
    cmd_new_feature "$@"
    ;;

# In help section
🔧 Utility:
    new-feature         Description of new feature
```

### New Commands Added in v3.1.0

The following diagnostic and monitoring commands were added:

1. **`status --live`** - Real-time status monitoring with auto-refresh
2. **`debug`** - Comprehensive system diagnostics
3. **`logs [--follow|-f]`** - Enhanced log management with following
4. **`validate`** - Configuration validation system

#### Implementation Pattern for v3.1.0 Commands

- **Consistent Error Handling**: All new commands use `init_selfcontrol_cli` validation
- **Professional Output**: Unified emoji usage and structured display
- **Signal Handling**: Proper trap handling for graceful interruption (live monitoring)
- **Input Validation**: Comprehensive validation for options and parameters
- **Help Integration**: All commands documented in help text with examples

### Modifying Schedule Logic

1. Edit functions in `lib/schedule.sh`
2. Test with `./bin/selfcontrol-cli schedule test`
3. Validate JSON config parsing
4. Run schedule test suite: `./tests/test_runner.sh schedule`

### Debugging

#### New Diagnostic Tools (v3.1.0)

Use the enhanced diagnostic commands for troubleshooting:

```bash
# Comprehensive system diagnostics
./bin/selfcontrol-cli debug

# Configuration validation
./bin/selfcontrol-cli validate

# Real-time monitoring
./bin/selfcontrol-cli status --live

# Follow logs in real-time
./bin/selfcontrol-cli logs --follow
```

#### Legacy Debug Mode

Enable debug mode for detailed logging:

```bash
export SELFCONTROL_CLI_DEBUG=1
./bin/selfcontrol-cli schedule test
```

Log files are located at `~/.local/share/selfcontrol-cli/logs/schedule.log`.

## v3.1.0 Development Patterns

### New Command Implementation Patterns

#### 1. Real-time Monitoring Pattern (`status --live`)

```bash
cmd_status_live() {
    # Initialization and validation
    if ! init_selfcontrol_cli; then
        die "Failed to initialize SelfControl CLI"
    fi

    # Signal handling for graceful exit
    trap 'echo -e "\n👋 Live monitoring stopped"; exit 0' INT

    # Main loop with clear screen and auto-refresh
    while true; do
        clear
        echo "🔴 Live Status Monitor - SelfControl CLI v$SELFCONTROL_CLI_VERSION"
        echo "⏰ Refresh: 5s | Press Ctrl+C to exit"
        echo "============================================================"

        # Display content
        show_current_status

        # Wait and refresh
        echo ""
        echo "🔄 Next update in 5s..."
        sleep 5
    done
}
```

#### 2. Diagnostic Command Pattern (`debug`)

```bash
cmd_debug() {
    if ! init_selfcontrol_cli; then
        die "Failed to initialize SelfControl CLI"
    fi

    echo "🐛 SelfControl CLI Debug Information"
    echo "====================================="
    echo ""

    # System Information Section
    echo "🖥️  System Information:"
    echo "   macOS Version: $(sw_vers -productVersion)"
    echo "   Bash Version: $BASH_VERSION"
    echo ""

    # File Validation Section
    echo "📁 File Paths & Permissions:"
    check_file_with_status "$SCHEDULE_CONFIG"
    check_file_with_status "$LOG_FILE"
    echo ""

    # Integration Testing Section
    echo "🔗 SelfControl.app Integration:"
    if [[ -x "$SELFCONTROL_CLI_PATH" ]]; then
        echo "   ✅ SelfControl CLI available"
    else
        echo "   ❌ SelfControl CLI not found"
    fi
    echo ""
}
```

#### 3. Option Parsing Pattern (`logs`)

```bash
cmd_logs() {
    local follow=false
    local lines=20

    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --follow|-f)
                follow=true
                shift
                ;;
            --lines|-n)
                lines="$2"
                shift 2
                ;;
            *)
                lines="$1"
                shift
                ;;
        esac
    done

    # Input validation
    if ! [[ "$lines" =~ ^[0-9]+$ ]]; then
        die "Invalid lines number: $lines"
    fi

    # Implementation based on options
    if [[ "$follow" == true ]]; then
        tail -f "$LOG_FILE"
    else
        tail -n "$lines" "$LOG_FILE"
    fi
}
```

#### 4. Validation Pattern (`validate`)

```bash
cmd_validate() {
    if ! init_selfcontrol_cli; then
        die "Failed to initialize SelfControl CLI"
    fi

    local errors=0

    echo "✅ SelfControl CLI Configuration Validation"
    echo "==========================================="
    echo ""

    # Configuration File Validation
    echo "📄 Configuration File:"
    if [[ -f "$SCHEDULE_CONFIG" ]]; then
        echo "   ✅ File exists: $SCHEDULE_CONFIG"

        if validate_json_syntax "$SCHEDULE_CONFIG"; then
            echo "   ✅ JSON syntax is valid"
        else
            echo "   ❌ JSON syntax error"
            ((errors++))
        fi
    else
        echo "   ❌ Configuration file not found"
        ((errors++))
    fi

    # Summary
    echo ""
    echo "📊 Validation Summary:"
    if [[ $errors -eq 0 ]]; then
        echo "   ✅ All checks passed successfully."
    else
        echo "   ❌ Found $errors error(s). Please fix the issues above."
    fi
}
```

### Key Development Guidelines for v3.1.0

1. **Consistent Initialization**: Always use `init_selfcontrol_cli` for validation
2. **Professional Output**: Use structured sections with emojis and clear headers
3. **Error Counting**: Track and report error counts in validation commands
4. **Signal Handling**: Implement graceful exits for interactive commands
5. **Option Parsing**: Support both long and short options where applicable
6. **Input Validation**: Validate all user inputs with helpful error messages
7. **Help Integration**: Document all new commands in help text with examples

### Testing New Commands

```bash
# Test new commands individually
./bin/selfcontrol-cli debug
./bin/selfcontrol-cli validate
./bin/selfcontrol-cli status --live  # Press Ctrl+C to exit
./bin/selfcontrol-cli logs --follow  # Press Ctrl+C to exit

# Run full test suite
./tests/test_runner.sh
```