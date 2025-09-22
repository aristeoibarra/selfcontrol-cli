# Changelog

All notable changes to SelfControl CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0] - 2025-09-21

### 🎯 Major Release: Enhanced User Experience & Diagnostics

#### ✨ New Features

##### **Real-time Monitoring & Diagnostics**

- **`selfcontrol-cli status --live`**: Live status monitoring with automatic refresh every 5 seconds
  - Clear screen updates with real-time status display
  - Graceful exit with Ctrl+C signal handling
  - Shows current SelfControl status, active schedules, and recent LaunchAgent activity
  - Automatic detection of schedule changes and block transitions

- **`selfcontrol-cli debug`**: Comprehensive system diagnostics command
  - Complete system information (macOS version, Bash version, user environment)
  - File paths and permissions validation
  - SelfControl.app integration status and version detection
  - LaunchAgent status and configuration validation
  - Configuration JSON validation with detailed error reporting
  - Sudo permissions testing and troubleshooting
  - Professional diagnostic output with clear status indicators

- **`selfcontrol-cli logs [--follow|-f]`**: Enhanced log management
  - View application logs with configurable line limits (`--lines N`)
  - Follow logs in real-time with `--follow` or `-f` option
  - Intelligent log file detection and validation
  - Professional log display with file information and timestamps
  - Supports both LaunchAgent and application logs

- **`selfcontrol-cli validate`**: Configuration validation system
  - Complete configuration file syntax validation
  - Blocklist file existence and format verification
  - Schedule configuration structure validation
  - Comprehensive error reporting with specific issue identification
  - Summary reporting with error counts and actionable feedback

#### 🔧 Technical Improvements

##### **Enhanced Command Interface**

- **Updated Help System**: All new commands integrated into help documentation with clear descriptions
- **Improved Command Routing**: Enhanced main dispatcher with support for command options and flags
- **Consistent Error Handling**: Standardized error messages and exit codes across all new commands
- **Professional Output Formatting**: Consistent use of emojis, colors, and structured output across all commands

##### **Code Quality & Architecture**

- **Modular Function Design**: All new commands implemented as separate, testable functions
- **Signal Handling**: Proper trap handling for graceful interruption in live monitoring
- **Input Validation**: Comprehensive validation for all command options and parameters
- **Error Recovery**: Intelligent error handling with helpful troubleshooting suggestions

#### 🎨 User Experience Improvements

##### **Better Troubleshooting Workflow**

- **Diagnostic-First Approach**: Users can now quickly identify issues with `selfcontrol-cli debug`
- **Real-time Monitoring**: Immediate visibility into system behavior with live status updates
- **Configuration Validation**: Proactive configuration checking prevents runtime issues
- **Enhanced Log Access**: Easy log viewing and following for better problem diagnosis

##### **Professional CLI Experience**

- **Consistent Visual Design**: Unified emoji usage and output formatting
- **Clear Status Indicators**: ✅ ❌ ⚠️ symbols for immediate status recognition
- **Structured Information Display**: Organized sections with clear headers and separators
- **Responsive Interface**: Live updates and real-time feedback

#### 🔄 Version Management

- **Version Update**: Bumped from v3.0.0 to v3.1.0 across all components
- **Backwards Compatibility**: All existing commands and functionality preserved
- **Non-Breaking Changes**: New features are additive and don't affect existing workflows

#### 📚 Documentation Updates

- **README.md**: Updated with all new v3.1.0 features and commands
- **Command Examples**: New examples showcasing diagnostic and monitoring capabilities
- **Troubleshooting Section**: Enhanced with new diagnostic tools references
- **Use Cases**: Added real-time monitoring and debugging use cases

#### 🐛 Bug Fixes

- **Command Option Parsing**: Improved parsing of command-line options for status command
- **Help Text Consistency**: Standardized help text formatting and command descriptions
- **Error Message Clarity**: Enhanced error messages with more descriptive information

## [2.1.1] - 2025-09-21

### 🗑️ Cron Support Removal

#### ✨ Changes

- **Removed Cron Job Support**: Eliminated all cron-related functionality and migration tools
- **Removed `service migrate` Command**: No longer needed as cron support has been discontinued
- **Simplified Codebase**: Removed cron detection, migration, and cleanup functions
- **Updated Documentation**: Removed all cron-related references from API documentation
- **Streamlined Installation**: Installer no longer checks for or migrates existing cron jobs
- **Cleaner Uninstall**: Uninstaller no longer searches for or removes cron jobs

#### 🔧 Technical Changes

- Removed `detect_existing_cron()`, `get_cron_config()`, `remove_cron_job()`, and `migrate_from_cron()` functions
- Removed cron migration logic from installation and uninstall scripts
- Updated help text to remove migration command references
- Simplified LaunchAgent status display (removed migration status section)

#### 📝 Note

SelfControl CLI now exclusively uses LaunchAgent for automation. Users still using cron-based setups should manually remove their cron jobs before updating.

## [3.0.0] - 2025-09-21

### 🤖 Major Feature: Complete LaunchAgent Migration

#### 🐛 Critical Fixes (2025-09-21 Post-Release)

- **Fixed LaunchAgent Template**: Corrected ProgramArguments to use `_launchagent_check` directly instead of `schedule _launchagent_check`
- **Fixed "command not found" Error**: LaunchAgent now executes the correct internal automation command
- **Enhanced Template Validation**: Improved template processing and validation in installation scripts

#### ✨ New Features

##### **LaunchAgent Automation**

- **Native macOS Integration**: Uses LaunchAgent for scheduled automation
- **Enhanced Persistence**: Better system restart/sleep/wake behavior with native macOS integration
- **Improved Reliability**: Robust error recovery and restart capabilities

##### **Service Management Commands**

- **`selfcontrol-cli service status`**: Comprehensive service status and diagnostics
- **`selfcontrol-cli service start`**: Start (load) LaunchAgent service
- **`selfcontrol-cli service stop`**: Stop (unload) LaunchAgent service
- **`selfcontrol-cli service restart`**: Restart LaunchAgent service
- **`selfcontrol-cli service logs`**: Display LaunchAgent logs with configurable line count

##### **Enhanced Diagnostics**

- **System Health Checks**: Comprehensive validation of sudo permissions, SelfControl.app availability, and configuration

- **Log Management**: Better log file handling and display with size/line information
- **Service Monitoring**: Real-time LaunchAgent status and health monitoring

#### 🔧 Improvements

- **LaunchAgent Installer**: Production installer sets up LaunchAgent automation
- **Simplified Documentation**: Updated README and API documentation to focus on LaunchAgent
- **Enhanced Error Messages**: More helpful error messages for LaunchAgent issues

#### 📁 New Files

- `templates/com.selfcontrol.cli.plist.template`: LaunchAgent plist template
- `scripts/launchagent.sh`: LaunchAgent management functions

#### 🗑️ Removed Features

##### **Streamlined Commands**

- **Removed `schedule setup` command**: No longer needed with automatic LaunchAgent installation
- **Removed `schedule check` command**: Internal automation now handled by LaunchAgent
- **Simplified workflow**: No manual automation setup required

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
