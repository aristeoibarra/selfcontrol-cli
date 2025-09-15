# SelfControl CLI

A command-line interface for SelfControl.app with enhanced features for macOS.

## Features

- 🚀 Quick status checks with remaining time
- 📊 Detailed block information
- 🔒 Easy block management
- 📋 Customizable blocklist support
- 💡 Helpful command suggestions

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/aristeoibarra/selfcontrol-cli.git
   cd selfcontrol-cli
   ```

2. Add to your shell configuration (e.g. `.zshrc` or `.bashrc`):
   ```bash
   source ~/selfcontrol-cli/selfcontrol_functions
   ```

3. Create your blocklist:
   ```bash
   cp blocklist.selfcontrol.example blocklist.selfcontrol
   ```
   Then edit `blocklist.selfcontrol` with your sites.

## Usage

Available commands:

### 📊 Status & Information
- `sc-status` - Quick status and time remaining
- `sc-info` - Detailed information about active block

### 🚀 Block Management
- `sc-start [hours]` - Start a new block (default: 2 hours)
  Example: `sc-start 4` - Block for 4 hours

### 🔧 Utility
- `sc-help` - Show help and examples
- `sc` - Direct access to SelfControl CLI

## Configuration

- Blocklist file: `~/selfcontrol-cli/blocklist.selfcontrol`
- Functions file: `~/selfcontrol-cli/selfcontrol_functions`

## Requirements

- macOS
- [SelfControl.app](https://selfcontrolapp.com) installed

## License

MIT License - see LICENSE file for details