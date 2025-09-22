#!/bin/bash

# SelfControl CLI - Core Library
# Production-ready core functions with robust error handling
# Version: 2.0.0

set -euo pipefail  # Strict error handling

# Prevent multiple sourcing
if [[ -n "${SELFCONTROL_CORE_LOADED:-}" ]]; then
    return 0
fi
readonly SELFCONTROL_CORE_LOADED=1

# =============================================================================
# CONSTANTS AND CONFIGURATION
# =============================================================================

readonly SELFCONTROL_CLI_VERSION="3.1.0"
readonly SELFCONTROL_APP_PATH="/Applications/SelfControl.app"
readonly SELFCONTROL_CLI_PATH="$SELFCONTROL_APP_PATH/Contents/MacOS/SelfControl-CLI"

# Directory resolution - more robust
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    readonly SELFCONTROL_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    readonly SELFCONTROL_ROOT_DIR="$(cd "$SELFCONTROL_LIB_DIR/.." && pwd)"
else
    readonly SELFCONTROL_LIB_DIR="$(pwd)/lib"
    readonly SELFCONTROL_ROOT_DIR="$(pwd)"
fi

# Configuration paths - support both development and production
if [[ -d "$SELFCONTROL_ROOT_DIR/config" ]]; then
    # Development mode
    readonly SCHEDULE_CONFIG="$SELFCONTROL_ROOT_DIR/config/schedule.json"
    readonly SCHEDULE_LOG="$SELFCONTROL_ROOT_DIR/logs/schedule.log"
else
    # Production mode
    readonly SCHEDULE_CONFIG="$HOME/.config/selfcontrol-cli/schedule.json"
    readonly SCHEDULE_LOG="$HOME/.local/share/selfcontrol-cli/logs/schedule.log"
fi

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Print error message and exit
die() {
    echo "❌ Error: $1" >&2
    exit 1
}

# Print warning message
warn() {
    echo "⚠️  Warning: $1" >&2
}

# Print info message
info() {
    echo "ℹ️  $1"
}

# Print success message
success() {
    echo "✅ $1"
}

# Log message to schedule log
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    if [[ -n "${SCHEDULE_LOG:-}" ]]; then
        echo "[$timestamp] [$level] $message" >> "$SCHEDULE_LOG"
    fi
}

# Log info message
log_info() {
    log_message "INFO" "$1"
}

# Log warning message
log_warning() {
    log_message "WARN" "$1"
}

# Log error message
log_error() {
    log_message "ERROR" "$1"
}

# =============================================================================
# TIME UTILITIES
# =============================================================================

# Get current time in minutes since midnight
get_current_time_minutes() {
    date '+%H:%M' | awk -F: '{print $1 * 60 + $2}'
}

# Convert time string (HH:MM) to minutes since midnight
time_to_minutes() {
    local time_str="$1"
    echo "$time_str" | awk -F: '{print $1 * 60 + $2}'
}

# Convert minutes since midnight to time string (HH:MM)
minutes_to_time() {
    local minutes="$1"
    local hours=$((minutes / 60))
    local mins=$((minutes % 60))
    printf "%02d:%02d" "$hours" "$mins"
}

# Get current day of week (lowercase)
get_current_day() {
    date '+%A' | tr '[:upper:]' '[:lower:]'
}

# Check if current time is within schedule window
is_time_active() {
    local start_time="$1"
    local end_time="$2"
    local current_minutes
    current_minutes=$(get_current_time_minutes)
    local start_minutes
    start_minutes=$(time_to_minutes "$start_time")
    local end_minutes
    end_minutes=$(time_to_minutes "$end_time")

    # Handle midnight crossover
    if [[ $start_minutes -gt $end_minutes ]]; then
        # Schedule crosses midnight
        if [[ $current_minutes -ge $start_minutes || $current_minutes -lt $end_minutes ]]; then
            return 0
        fi
    else
        # Same day schedule
        if [[ $current_minutes -ge $start_minutes && $current_minutes -lt $end_minutes ]]; then
            return 0
        fi
    fi

    return 1
}

# Get remaining minutes until end time
get_remaining_minutes() {
    local end_time="$1"
    local current_minutes
    current_minutes=$(get_current_time_minutes)
    local end_minutes
    end_minutes=$(time_to_minutes "$end_time")

    if [[ $current_minutes -lt $end_minutes ]]; then
        echo $((end_minutes - current_minutes))
    else
        echo $((1440 - current_minutes + end_minutes))  # Next day
    fi
}

# =============================================================================
# JSON UTILITIES
# =============================================================================

# Get value from JSON object
json_get_value() {
    local json="$1"
    local key="$2"
    local default="${3:-}"

    # Try to extract quoted string values first
    local value
    value=$(echo "$json" | sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p")

    # If no quoted value found, try boolean/number values
    if [[ -z "$value" ]]; then
        value=$(echo "$json" | sed -n "s/.*\"$key\"[[:space:]]*:[[:space:]]*\([^,}]*\).*/\1/p" | tr -d ' ')
    fi

    if [[ -n "$value" ]]; then
        echo "$value"
    else
        echo "$default"
    fi
}

# Get array from JSON object
json_get_array() {
    local json="$1"
    local key="$2"

    echo "$json" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    array = data.get('$key', [])
    for item in array:
        print(item)
except:
    pass
"
}
# Validate JSON syntax
validate_json_syntax() {
    local json_file="$1"

    if [[ ! -f "$json_file" ]]; then
        return 1
    fi

    # Use python to validate JSON
    python3 -m json.tool "$json_file" >/dev/null 2>&1
}

# =============================================================================
# SELFCONTROL INTEGRATION
# =============================================================================

# Check if SelfControl is currently running
is_selfcontrol_running() {
    if [[ ! -x "$SELFCONTROL_CLI_PATH" ]]; then
        return 1
    fi

    # Use grep to check for presence of YES (output goes to stderr)
    if sudo "$SELFCONTROL_CLI_PATH" is-running 2>&1 | grep -q "YES"; then
        return 0
    else
        return 1
    fi
}

# Get SelfControl settings
get_selfcontrol_settings() {
    if [[ ! -x "$SELFCONTROL_CLI_PATH" ]]; then
        return 1
    fi

    sudo "$SELFCONTROL_CLI_PATH" settings 2>/dev/null
}

# Validate and convert blocklist to proper format
validate_and_convert_blocklist() {
    local input_file="$1"
    local output_file="$2"
    local duration_minutes="${3:-60}"

    # Try to read the input file
    if ! plutil -lint "$input_file" >/dev/null 2>&1; then
        log_error "Invalid plist format: $input_file"
        return 1
    fi

    # Read the domains from the input file
    local domains
    domains=$(plutil -extract 0 raw "$input_file" 2>/dev/null || plutil -p "$input_file" | grep '=>' | sed 's/.*=> "\(.*\)"/\1/')

    # Create a proper SelfControl block format
    cat > "$output_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>BlockDuration</key>
    <integer>$duration_minutes</integer>
    <key>HostBlacklist</key>
    <array>
EOF

    # Add all domains from the original file
    if [[ -n "$domains" ]]; then
        # If we got a single domain from plutil -extract
        if [[ "$domains" != *$'\n'* ]]; then
            echo "        <string>$domains</string>" >> "$output_file"
        else
            # Multiple domains
            echo "$domains" | while read -r domain; do
                if [[ -n "$domain" ]]; then
                    echo "        <string>$domain</string>" >> "$output_file"
                fi
            done
        fi
    else
        # Fallback: parse the plist manually
        plutil -p "$input_file" | grep '=>' | sed 's/.*=> "\(.*\)"/\1/' | while read -r domain; do
            if [[ -n "$domain" ]]; then
                echo "        <string>$domain</string>" >> "$output_file"
            fi
        done
    fi

    cat >> "$output_file" << EOF
    </array>
    <key>WhitelistEnabled</key>
    <false/>
    <key>BlockAsWhitelist</key>
    <false/>
</dict>
</plist>
EOF

    chmod 644 "$output_file"

    # Final validation of created file
    if ! plutil -lint "$output_file" >/dev/null 2>&1; then
        log_error "Failed to create valid blocklist file"
        rm -f "$output_file"
        return 1
    fi

    return 0
}

# Read sites from blocklist for display
read_blocklist_sites() {
    local blocklist_file="$1"

    if [[ ! -f "$blocklist_file" ]]; then
        echo "(no sites)"
        return 1
    fi

    # Check if this is the new format (has HostBlacklist key)
    if plutil -p "$blocklist_file" 2>/dev/null | grep -q "HostBlacklist"; then
        # Extract domains from HostBlacklist array in new format
        # Look for numbered array entries and extract the quoted strings
        plutil -p "$blocklist_file" 2>/dev/null | sed -n '/HostBlacklist/,/\]/p' | grep -E '[0-9]+ =>' | sed 's/.*=> "\(.*\)"/\1/' | tr '\n' ' ' | sed 's/ $//'
    else
        # Fallback to old format (simple array)
        plutil -p "$blocklist_file" 2>/dev/null | grep '=>' | sed 's/.*=> "\(.*\)"/\1/' | tr '\n' ' ' | sed 's/ $//'
    fi
}

# Start SelfControl block
start_selfcontrol_block() {
    local minutes="$1"
    local blocklist_file="$2"

    local selfcontrol_cli="/Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli"

    if [[ ! -x "$selfcontrol_cli" ]]; then
        die "SelfControl CLI not found at $selfcontrol_cli"
    fi

    if [[ ! -f "$blocklist_file" ]]; then
        die "Blocklist file not found: $blocklist_file"
    fi

    # Calculate duration in minutes first
    local int_minutes
    int_minutes=$(echo "$minutes" | awk '{print int($1)}')
    if [[ $int_minutes -eq 0 ]]; then
        int_minutes=1  # Minimum 1 minute
    fi

    # Create a temporary blocklist in the format SelfControl CLI expects
    local temp_blocklist="/tmp/selfcontrol-temp-blocklist-$$.selfcontrol"

    # Validate and convert blocklist format
    if ! validate_and_convert_blocklist "$blocklist_file" "$temp_blocklist" "$int_minutes"; then
        die "Failed to process blocklist: $blocklist_file"
    fi

    # Calculate end time in ISO8601 format
    local end_date

    if command -v gdate >/dev/null 2>&1; then
        end_date=$(gdate -d "+${int_minutes} minutes" -Iseconds)
    else
        end_date=$(date -v+"${int_minutes}"M "+%Y-%m-%dT%H:%M:%S%z")
    fi

    # Display what we're about to do
    echo "🚀 Starting SelfControl block..."
    echo "   Duration: $int_minutes minutes"
    echo "   End time: $end_date"

    # Read and display sites from the converted blocklist
    local sites_list
    sites_list=$(read_blocklist_sites "$temp_blocklist")
    echo "   Sites to block: $sites_list"
    echo ""

    echo "🔒 Initiating block with CLI tool..."
    echo "💡 Using CLI automation (no interactive authorization needed)"

    # Try to start the block with proper error handling
    local result=0
    if sudo "$selfcontrol_cli" --uid "$(id -u)" start --blocklist "$temp_blocklist" --enddate "$end_date"; then
        echo "✅ Block started successfully!"
        echo "🚫 Sites are now blocked for $int_minutes minutes"
        result=0
    else
        echo "❌ Failed to start SelfControl block"
        echo "💡 Make sure you have administrator privileges"
        echo "💡 You may need to enter your password when prompted"
        result=1
    fi

    # Clean up temporary file
    rm -f "$temp_blocklist"

    if [[ $result -eq 0 ]]; then
        log_info "Started SelfControl block for $int_minutes minutes"
    else
        log_error "Failed to start SelfControl block"
    fi

    return $result
}

# =============================================================================
# INPUT VALIDATION
# =============================================================================

# Sanitize input to prevent command injection
sanitize_input() {
    local input="$1"
    # Remove dangerous characters
    echo "$input" | sed 's/[;&|`$(){}[\]<>]//g'
}

# Validate schedule name
validate_schedule_name() {
    local name="$1"

    # Check if name contains only valid characters
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 1
    fi

    # Check length
    if [[ ${#name} -lt 1 || ${#name} -gt 50 ]]; then
        return 1
    fi

    return 0
}

# Validate time format (HH:MM)
validate_time_format() {
    local time="$1"

    if [[ ! "$time" =~ ^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$ ]]; then
        return 1
    fi

    return 0
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize SelfControl CLI
init_selfcontrol_cli() {
    # Check if SelfControl.app is installed
    if [[ ! -d "$SELFCONTROL_APP_PATH" ]]; then
        die "SelfControl.app not found. Please install from https://selfcontrolapp.com"
    fi

    # Check if CLI is available
    if [[ ! -x "$SELFCONTROL_CLI_PATH" ]]; then
        die "SelfControl CLI not found at $SELFCONTROL_CLI_PATH"
    fi

    # Create logs directory
    if [[ -n "${SCHEDULE_LOG:-}" ]]; then
        local log_dir
        log_dir=$(dirname "$SCHEDULE_LOG")
        mkdir -p "$log_dir"
    fi

    return 0
}
