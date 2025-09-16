# Changelog

All notable changes to SelfControl CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-09-15

### 🎉 Major Release: Automated Scheduled Blocking

#### 🔧 Critical Bug Fixes (2025-09-15)

- **Fixed JSON Array Parsing**: Replaced sed-based JSON parsing with robust Python implementation
- **Fixed Day Detection Logic**: Corrected `is_day_active()` function to properly detect active days
- **Fixed Schedule Dispatcher**: Resolved argument parsing issues in `cmd_schedule()` function
- **Fixed Duration Calculation**: Corrected time calculation to use minutes instead of hours
- **Fixed Production Paths**: Resolved blocklist file path resolution in production environment
- **Fixed Subshell Issues**: Corrected `get_active_schedule()` function to properly return active schedules
- **Enhanced Sudo Integration**: Added support for passwordless sudo execution via cron

#### ✨ New Features

##### **Automated Schedule System**

- **JSON-based Configuration**: Complete schedule configuration with flexible options
- **Cron Integration**: Automatic execution of scheduled blocks with intelligent conflict resolution
- **Multiple Blocklists**: Support for different blocklist files per schedule context
- **Priority-based Scheduling**: Handle overlapping schedules intelligently
- **Midnight Crossover**: Support for schedules that cross midnight (e.g., 23:00-06:00)
- **Flexible Day Configuration**: Any combination of weekdays per schedule
- **Real-time Testing**: Test schedule logic without waiting for execution
- **Comprehensive Logging**: Detailed logs with rotation and structured output
- **Duplicate Prevention**: Avoid conflicts with manual blocks

##### **Enhanced Command Interface**

- **Unified Commands**: All functionality through single `selfcontrol-cli` command
- **Schedule Management**: Complete set of commands for schedule control
- **Intelligent Status**: Enhanced status reporting with schedule information
- **Configuration Validation**: Built-in validation and testing tools

#### 🔧 New Commands

- `selfcontrol-cli schedule list` - Show all configured schedules
- `selfcontrol-cli schedule status` - Show current schedule status
- `selfcontrol-cli schedule enable <name>` - Enable specific schedule
- `selfcontrol-cli schedule disable <name>` - Disable specific schedule
- `selfcontrol-cli schedule reload` - Reload configuration from file
- `selfcontrol-cli schedule test` - Test schedule logic in real-time
- `selfcontrol-cli schedule setup` - Setup automated scheduling with cron
- `selfcontrol-cli init` - Initialize configuration and directories

#### 🛠️ Enhanced Commands

- `selfcontrol-cli status` - Now shows active schedule information
- `selfcontrol-cli help` - Updated with all new schedule commands
- `selfcontrol-cli info` - Better integration with scheduled blocks

#### 📁 Project Structure

- **Modular Architecture**: Clean separation of core and schedule functionality
- **Standardized Locations**: Configuration follows XDG Base Directory specification
- **Professional Layout**: Organized directory structure for maintainability

#### 📁 Configuration System

- **JSON Configuration**: `~/.config/selfcontrol-cli/schedule.json`
- **Multiple Blocklists**: Support for context-specific blocklist files
- **Global Settings**: Centralized configuration for intervals, logging, etc.
- **Advanced Options**: Priority handling, overlap resolution, error recovery
- **Native JSON Parsing**: No external dependencies required

#### 🔒 Technical Improvements

- **Pure Bash Implementation**: Uses only native macOS tools
- **Robust Time Calculation**: Comprehensive timezone and time handling
- **Intelligent Conflict Resolution**: Smart handling of schedule overlaps
- **Log Management**: Automatic rotation and cleanup
- **Comprehensive Error Handling**: Graceful handling of edge cases
- **Security Enhancements**: Input validation and safe defaults

#### 📚 Documentation

- **Complete README**: Comprehensive guide with examples and use cases
- **API Documentation**: Detailed command reference
- **Troubleshooting Guide**: Solutions for common issues
- **Configuration Reference**: Complete configuration options
- **Installation Guide**: Step-by-step setup instructions

#### 🐛 Bug Fixes

- **Improved Error Handling**: Better error messages and recovery
- **Timezone Consistency**: Reliable timezone handling across commands
- **File Path Resolution**: More robust file and directory handling
- **Cron Integration**: Reliable scheduled execution
- **JSON Parsing Robustness**: Replaced fragile sed-based parsing with Python
- **Schedule Detection**: Fixed critical issues preventing automatic schedule detection
- **Production Environment**: Resolved path resolution issues in production installations
- **Sudo Automation**: Added support for passwordless sudo execution

#### 🔄 Backwards Compatibility

- **Legacy Command Support**: Original commands continue to work
- **Configuration Preservation**: Existing blocklist files are preserved
- **Non-Breaking Changes**: All original functionality maintained

---

## [1.0.0] - Previous Version

### Features

- Basic SelfControl CLI integration
- Manual block management
- Status checking
- Simple blocklist support

### Commands

- `selfcontrol-cli start [hours]` - Start manual block
- `selfcontrol-cli status` - Quick status check
- `selfcontrol-cli info` - Detailed block information
- `selfcontrol-cli help` - Help and examples

---

## Support and Resources

- **Documentation**: Complete docs in `docs/` directory
- **Troubleshooting**: `docs/TROUBLESHOOTING.md` for common issues
- **API Reference**: `docs/API.md` for complete command reference
- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For community support and questions

---

**Note**: This project follows semantic versioning. Major version increments indicate significant new features or architectural changes. Minor and patch versions maintain backward compatibility.
