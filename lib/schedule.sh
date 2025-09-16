#!/bin/bash

# SelfControl CLI - Schedule Management Library
# Production-ready schedule functions with robust error handling
# Version: 2.0.0

# Source core library
# shellcheck source=lib/core.sh
source "$(dirname "${BASH_SOURCE[0]}")/core.sh"

# =============================================================================
# SCHEDULE CONFIGURATION MANAGEMENT
# =============================================================================

# Load schedule configuration
load_schedule_config() {
    if [[ ! -f "$SCHEDULE_CONFIG" ]]; then
        log_error "Schedule configuration not found: $SCHEDULE_CONFIG"
        return 1
    fi

    if ! validate_json_syntax "$SCHEDULE_CONFIG"; then
        log_error "Invalid JSON syntax in schedule configuration"
        return 1
    fi

    cat "$SCHEDULE_CONFIG"
}

# Get global setting from configuration
get_global_setting() {
    local key="$1"
    local default="${2:-}"
    local config

    if ! config=$(load_schedule_config); then
        echo "$default"
        return 1
    fi

    json_get_value "$config" "$key" "$default"
}

# Get schedule by name
get_schedule_by_name() {
    local schedule_name="$1"
    local config

    if ! config=$(load_schedule_config); then
        return 1
    fi

    # Extract schedules array using python for better JSON parsing
    local schedules
    schedules=$(echo "$config" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    schedules = data.get('schedules', [])
    for schedule in schedules:
        if schedule.get('name') == '$schedule_name':
            print(json.dumps(schedule))
            break
except:
    pass
")

    if [[ -n "$schedules" ]]; then
        echo "$schedules"
        return 0
    fi

    return 1
}

# Update schedule status (enabled/disabled)
update_schedule_status() {
    local schedule_name="$1"
    local enabled="$2"
    local config_file="$SCHEDULE_CONFIG"
    local temp_file
    temp_file=$(mktemp)

    if [[ ! -f "$config_file" ]]; then
        log_error "Configuration file not found: $config_file"
        return 1
    fi

    # Use sed to update the enabled status
    sed "s/\"name\"[[:space:]]*:[[:space:]]*\"$schedule_name\"[^}]*\"enabled\"[[:space:]]*:[[:space:]]*[^,}]*/\"name\": \"$schedule_name\", \"enabled\": $enabled/g" "$config_file" > "$temp_file"

    if validate_json_syntax "$temp_file"; then
        mv "$temp_file" "$config_file"
        log_info "Updated schedule '$schedule_name' enabled status to $enabled"
        return 0
    else
        rm -f "$temp_file"
        log_error "Failed to update schedule status - invalid JSON result"
        return 1
    fi
}

# =============================================================================
# SCHEDULE LOGIC
# =============================================================================

# Check if current day is active for schedule
is_day_active() {
    local schedule_days="$1"
    local current_day
    current_day=$(get_current_day)

    echo "$schedule_days" | grep -q "\"$current_day\""
}

# Check if schedule is currently active
is_schedule_active() {
    local schedule="$1"
    local name enabled start_time end_time days

    name=$(json_get_value "$schedule" "name")
    enabled=$(json_get_value "$schedule" "enabled" "false")

    if [[ "$enabled" != "true" ]]; then
        return 1
    fi

    start_time=$(json_get_value "$schedule" "start_time")
    end_time=$(json_get_value "$schedule" "end_time")
    days=$(json_get_array "$schedule" "days")

    # Check if current day is active
    if ! is_day_active "$days"; then
        return 1
    fi

    # Check if current time is within schedule window
    if is_time_active "$start_time" "$end_time"; then
        return 0
    fi

    return 1
}

# Get currently active schedule
get_active_schedule() {
    local config

    if ! config=$(load_schedule_config); then
        return 1
    fi

    # Extract schedules array using python for better JSON parsing
    local schedules
    schedules=$(echo "$config" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    schedules = data.get('schedules', [])
    for schedule in schedules:
        print(json.dumps(schedule))
except:
    pass
")

    if [[ -z "$schedules" ]]; then
        return 1
    fi

    # Check each schedule
    echo "$schedules" | while read -r schedule; do
        if is_schedule_active "$schedule"; then
            echo "$schedule"
            return 0
        fi
    done

    return 1
}

# =============================================================================
# SCHEDULE EXECUTION
# =============================================================================

# Check and execute schedules
check_and_execute_schedules() {
    local active_schedule

    if ! active_schedule=$(get_active_schedule); then
        log_info "No active schedule found"
        return 0
    fi

    local schedule_name
    schedule_name=$(json_get_value "$active_schedule" "name")

    # Check if SelfControl is already running
    if is_selfcontrol_running; then
        log_info "SelfControl already running, skipping schedule '$schedule_name'"
        return 0
    fi

    # Get schedule details
    local blocklist_file
    blocklist_file=$(json_get_value "$active_schedule" "blocklist_file" "default")
    local end_time
    end_time=$(json_get_value "$active_schedule" "end_time")

    # Calculate remaining time
    local remaining_minutes
    remaining_minutes=$(get_remaining_minutes "$end_time")
    local remaining_hours
    remaining_hours=$(echo "scale=2; $remaining_minutes / 60" | bc)

    # Get blocklist path
    local blocklist_path
    blocklist_path="$SELFCONTROL_ROOT_DIR/config/blocklist.$blocklist_file.selfcontrol"

    if [[ ! -f "$blocklist_path" ]]; then
        blocklist_path="$SELFCONTROL_ROOT_DIR/config/blocklist.selfcontrol"
    fi

    # Start block
    log_info "Starting scheduled block '$schedule_name' for $remaining_hours hours"
    start_selfcontrol_block "$remaining_hours" "$blocklist_path"
}

# =============================================================================
# SCHEDULE TESTING
# =============================================================================

# Test schedule logic
test_schedule_logic() {
    local config

    if ! config=$(load_schedule_config); then
        echo "❌ Failed to load configuration"
        return 1
    fi

    echo "🧪 Testing Schedule Logic"
    echo "========================="
    echo ""

    # Get current time and day
    local current_time current_day
    current_time=$(date '+%H:%M')
    current_day=$(get_current_day)

    echo "Current time: $current_time ($current_day)"
    echo ""

    # Extract schedules array using python for better JSON parsing
    local schedules
    schedules=$(echo "$config" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    schedules = data.get('schedules', [])
    for schedule in schedules:
        print(json.dumps(schedule))
except:
    pass
")

    if [[ -z "$schedules" ]]; then
        echo "No schedules found in configuration"
        return 0
    fi

    # Test each schedule
    echo "$schedules" | while read -r schedule; do
        local name enabled start_time end_time days
        name=$(json_get_value "$schedule" "name")
        enabled=$(json_get_value "$schedule" "enabled" "false")
        start_time=$(json_get_value "$schedule" "start_time")
        end_time=$(json_get_value "$schedule" "end_time")
        days=$(json_get_array "$schedule" "days")

        echo "📅 Schedule: $name"
        echo "   Status: $([ "$enabled" == "true" ] && echo "✅ Enabled" || echo "❌ Disabled")"
        echo "   Time: $start_time - $end_time"
        echo "   Days: $(echo "$days" | tr '\n' ' ')"

        if [[ "$enabled" == "true" ]]; then
            if is_day_active "$days"; then
                echo "   Today: ✅ Active day"
                if is_time_active "$start_time" "$end_time"; then
                    echo "   Now: ✅ Within time window"
                    echo "   Action: 🚀 Would start block"
                else
                    echo "   Now: ❌ Outside time window"
                fi
            else
                echo "   Today: ❌ Inactive day"
            fi
        fi
        echo ""
    done

    # Check for active schedule
    local active_schedule
    if active_schedule=$(get_active_schedule); then
        local active_name
        active_name=$(json_get_value "$active_schedule" "name")
        echo "🎯 Currently active: $active_name"
    else
        echo "🎯 No active schedule"
    fi
}
