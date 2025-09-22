#!/bin/bash

# SelfControl CLI LaunchAgent Wrapper
# Ensures proper PATH and environment for LaunchAgent execution

set -euo pipefail

# Set explicit PATH to ensure selfcontrol-cli is found
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:{{USER_HOME}}/.local/bin"
export HOME="{{USER_HOME}}"
export USER="{{USER_NAME}}"

# Execute selfcontrol-cli with proper environment and sudo
exec sudo -n "{{USER_HOME}}/.local/bin/selfcontrol-cli" "$@"