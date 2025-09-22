#!/bin/bash

# SelfControl CLI - LaunchAgent Management
# Handles LaunchAgent installation, migration, and management
# Version: 3.0.0

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

readonly LAUNCHAGENT_LABEL="com.selfcontrol.cli.scheduler"
readonly LAUNCHAGENT_DIR="$HOME/Library/LaunchAgents"
readonly LAUNCHAGENT_PLIST="$LAUNCHAGENT_DIR/$LAUNCHAGENT_LABEL.plist"
readonly LAUNCHAGENT_TEMPLATE="$ROOT_DIR/templates/com.selfcontrol.cli.plist.template"
readonly DEFAULT_INTERVAL_MINUTES=5
readonly LOG_DIR="$HOME/.local/share/selfcontrol-cli/logs"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_launchagent_status() {
    echo -e "${BLUE}📊 SelfControl CLI Service Status${NC}"
    echo "================================="
    echo ""
}

print_launchagent_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_launchagent_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_launchagent_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_launchagent_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# =============================================================================
# LAUNCHAGENT DETECTION FUNCTIONS
# =============================================================================

# Check if LaunchAgent plist exists
launchagent_plist_exists() {
    [[ -f "$LAUNCHAGENT_PLIST" ]]
}

# Check if LaunchAgent is loaded
launchagent_is_loaded() {
    launchctl list | grep -q "$LAUNCHAGENT_LABEL" 2>/dev/null
}

# Check if LaunchAgent is running (actually executing)
launchagent_is_running() {
    if launchctl list "$LAUNCHAGENT_LABEL" >/dev/null 2>&1; then
        local status
        status=$(launchctl list "$LAUNCHAGENT_LABEL" 2>/dev/null | grep -E "PID|LastExitStatus" || true)

        # If it has a PID, it's currently running
        if echo "$status" | grep -q "PID.*[0-9]"; then
            return 0
        fi

        # If LastExitStatus is 0, it ran successfully recently
        if echo "$status" | grep -q "LastExitStatus.*=.*0"; then
            return 0
        fi
    fi
    return 1
}

# Get LaunchAgent status information
get_launchagent_info() {
    if launchctl list "$LAUNCHAGENT_LABEL" >/dev/null 2>&1; then
        launchctl list "$LAUNCHAGENT_LABEL"
    else
        echo "LaunchAgent not loaded"
    fi
}

# =============================================================================
# LAUNCHAGENT GENERATION FUNCTIONS
# =============================================================================

# Generate LaunchAgent plist from template
generate_launchagent_plist() {
    local interval_minutes="${1:-$DEFAULT_INTERVAL_MINUTES}"
    local interval_seconds=$((interval_minutes * 60))

    if [[ ! -f "$LAUNCHAGENT_TEMPLATE" ]]; then
        print_launchagent_error "LaunchAgent template not found: $LAUNCHAGENT_TEMPLATE"
        return 1
    fi

    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$LAUNCHAGENT_DIR"
    mkdir -p "$LOG_DIR"

    # Replace template variables
    sed -e "s|{{USER_HOME}}|$HOME|g" \
        -e "s|{{USER_NAME}}|$(whoami)|g" \
        -e "s|{{INTERVAL_SECONDS}}|$interval_seconds|g" \
        "$LAUNCHAGENT_TEMPLATE" > "$LAUNCHAGENT_PLIST"

    # Validate generated plist
    if ! plutil -lint "$LAUNCHAGENT_PLIST" >/dev/null 2>&1; then
        print_launchagent_error "Generated plist is invalid"
        rm -f "$LAUNCHAGENT_PLIST"
        return 1
    fi

    print_launchagent_success "Generated LaunchAgent plist (interval: ${interval_minutes}m)"
    return 0
}

# =============================================================================
# LAUNCHAGENT INSTALLATION FUNCTIONS
# =============================================================================

# Install LaunchAgent
install_launchagent() {
    local interval_minutes="${1:-$DEFAULT_INTERVAL_MINUTES}"

    print_launchagent_info "Installing LaunchAgent..."

    # Generate plist
    if ! generate_launchagent_plist "$interval_minutes"; then
        return 1
    fi

    # Unload existing LaunchAgent if loaded
    if launchagent_is_loaded; then
        print_launchagent_info "Unloading existing LaunchAgent..."
        launchctl unload "$LAUNCHAGENT_PLIST" 2>/dev/null || true
    fi

    # Load LaunchAgent
    if launchctl load "$LAUNCHAGENT_PLIST"; then
        print_launchagent_success "LaunchAgent installed and loaded"

        # Wait a moment and check if it loaded properly
        sleep 2
        if launchagent_is_loaded; then
            print_launchagent_success "LaunchAgent is running"
        else
            print_launchagent_warning "LaunchAgent loaded but may not be running properly"
        fi

        return 0
    else
        print_launchagent_error "Failed to load LaunchAgent"
        return 1
    fi
}

# Uninstall LaunchAgent
uninstall_launchagent() {
    print_launchagent_info "Uninstalling LaunchAgent..."

    local success=true

    # Unload LaunchAgent
    if launchagent_is_loaded; then
        if launchctl unload "$LAUNCHAGENT_PLIST" 2>/dev/null; then
            print_launchagent_success "LaunchAgent unloaded"
        else
            print_launchagent_warning "Failed to unload LaunchAgent"
            success=false
        fi
    else
        print_launchagent_info "LaunchAgent was not loaded"
    fi

    # Remove plist file
    if launchagent_plist_exists; then
        if rm -f "$LAUNCHAGENT_PLIST"; then
            print_launchagent_success "LaunchAgent plist removed"
        else
            print_launchagent_error "Failed to remove LaunchAgent plist"
            success=false
        fi
    else
        print_launchagent_info "LaunchAgent plist was not installed"
    fi

    if $success; then
        print_launchagent_success "LaunchAgent uninstalled successfully"
        return 0
    else
        return 1
    fi
}

# =============================================================================
# LAUNCHAGENT CONTROL FUNCTIONS
# =============================================================================

# Load LaunchAgent
load_launchagent() {
    if ! launchagent_plist_exists; then
        print_launchagent_error "LaunchAgent plist not found. Run 'install' first."
        return 1
    fi

    if launchagent_is_loaded; then
        print_launchagent_info "LaunchAgent is already loaded"
        return 0
    fi

    print_launchagent_info "Loading LaunchAgent..."
    if launchctl load "$LAUNCHAGENT_PLIST"; then
        print_launchagent_success "LaunchAgent loaded successfully"
        return 0
    else
        print_launchagent_error "Failed to load LaunchAgent"
        return 1
    fi
}

# Unload LaunchAgent
unload_launchagent() {
    if ! launchagent_is_loaded; then
        print_launchagent_info "LaunchAgent is not loaded"
        return 0
    fi

    print_launchagent_info "Unloading LaunchAgent..."
    if launchctl unload "$LAUNCHAGENT_PLIST"; then
        print_launchagent_success "LaunchAgent unloaded successfully"
        return 0
    else
        print_launchagent_error "Failed to unload LaunchAgent"
        return 1
    fi
}

# Restart LaunchAgent
restart_launchagent() {
    print_launchagent_info "Restarting LaunchAgent..."

    # Unload first
    if launchagent_is_loaded; then
        unload_launchagent || return 1
    fi

    # Wait a moment
    sleep 1

    # Load again
    load_launchagent || return 1

    print_launchagent_success "LaunchAgent restarted successfully"
}

# =============================================================================
# STATUS AND DIAGNOSTIC FUNCTIONS
# =============================================================================

# Show comprehensive LaunchAgent status
show_launchagent_status() {
    print_launchagent_status

    local plist_exists=false
    local is_loaded=false
    local is_running=false

    # Check plist existence
    if launchagent_plist_exists; then
        plist_exists=true
        echo -e "LaunchAgent File: ${GREEN}✅ Exists${NC} ($LAUNCHAGENT_PLIST)"
    else
        echo -e "LaunchAgent File: ${RED}❌ Not Found${NC}"
    fi

    # Check if loaded
    if launchagent_is_loaded; then
        is_loaded=true
        echo -e "LaunchAgent Status: ${GREEN}✅ Loaded${NC}"

        # Check if running
        if launchagent_is_running; then
            is_running=true
            echo -e "LaunchAgent Health: ${GREEN}✅ Running${NC}"
        else
            echo -e "LaunchAgent Health: ${YELLOW}⚠️  Loaded but not active${NC}"
        fi
    else
        echo -e "LaunchAgent Status: ${RED}❌ Not Loaded${NC}"
    fi

    echo ""

    # Show detailed info if loaded
    if $is_loaded; then
        echo "📊 LaunchAgent Details:"
        get_launchagent_info | while read -r line; do
            echo "   $line"
        done
        echo ""
    fi

    # Show log information
    echo "📋 Log Files:"
    local stdout_log="$LOG_DIR/launchd.log"
    local stderr_log="$LOG_DIR/launchd.error.log"

    if [[ -f "$stdout_log" ]]; then
        local log_size
        log_size=$(stat -f%z "$stdout_log" 2>/dev/null || echo "0")
        local log_lines
        log_lines=$(wc -l < "$stdout_log" 2>/dev/null || echo "0")
        echo -e "   Output: ${GREEN}✅ Available${NC} ($log_lines lines, $(numfmt --to=iec "$log_size"))"

        # Show last few lines if log exists and has content
        if [[ $log_lines -gt 0 ]]; then
            echo "   Last entries:"
            tail -3 "$stdout_log" | sed 's/^/     /'
        fi
    else
        echo -e "   Output: ${YELLOW}⚠️  No log file${NC}"
    fi

    if [[ -f "$stderr_log" ]]; then
        local error_size
        error_size=$(stat -f%z "$stderr_log" 2>/dev/null || echo "0")
        if [[ $error_size -gt 0 ]]; then
            echo -e "   Errors: ${RED}⚠️  Has errors${NC} ($(numfmt --to=iec "$error_size"))"
        else
            echo -e "   Errors: ${GREEN}✅ No errors${NC}"
        fi
    else
        echo -e "   Errors: ${GREEN}✅ No error log${NC}"
    fi

    echo ""

    # Show diagnostics
    echo "🔧 Diagnostics:"

    # Check sudo permissions
    if sudo -n true 2>/dev/null; then
        echo -e "   Sudo permissions: ${GREEN}✅ Configured${NC}"
    else
        echo -e "   Sudo permissions: ${RED}❌ Not configured${NC}"
        echo -e "   ${YELLOW}Run: sudo visudo${NC}"
        echo -e "   ${YELLOW}Add: $(whoami) ALL=(ALL) NOPASSWD: $(which selfcontrol-cli || echo '/usr/local/bin/selfcontrol-cli')${NC}"
    fi

    # Check SelfControl.app
    if [[ -x "/Applications/SelfControl.app/Contents/MacOS/SelfControl" ]]; then
        echo -e "   SelfControl.app: ${GREEN}✅ Available${NC}"
    else
        echo -e "   SelfControl.app: ${RED}❌ Not found${NC}"
    fi

    # Check configuration
    local config_file="$HOME/.config/selfcontrol-cli/schedule.json"
    if [[ -f "$config_file" ]]; then
        echo -e "   Configuration: ${GREEN}✅ Found${NC} ($config_file)"
    else
        echo -e "   Configuration: ${RED}❌ Not found${NC}"
    fi


}

# Show LaunchAgent logs
show_launchagent_logs() {
    local lines="${1:-20}"
    local stdout_log="$LOG_DIR/launchd.log"
    local stderr_log="$LOG_DIR/launchd.error.log"

    echo -e "${BLUE}📋 LaunchAgent Logs (last $lines lines)${NC}"
    echo "================================================"
    echo ""

    if [[ -f "$stdout_log" ]]; then
        echo -e "${GREEN}📤 Output Log:${NC}"
        tail -n "$lines" "$stdout_log" | sed 's/^/  /'
        echo ""
    else
        echo -e "${YELLOW}📤 No output log found${NC}"
        echo ""
    fi

    if [[ -f "$stderr_log" ]] && [[ -s "$stderr_log" ]]; then
        echo -e "${RED}📥 Error Log:${NC}"
        tail -n "$lines" "$stderr_log" | sed 's/^/  /'
        echo ""
    else
        echo -e "${GREEN}📥 No errors in log${NC}"
        echo ""
    fi
}



# =============================================================================
# EXPORTED FUNCTIONS
# =============================================================================

# These functions are available when this script is sourced
# They follow the naming convention: launchagent_*

# Main service management entry point
launchagent_main() {
    local command="$1"
    shift || true

    case "$command" in
        "status")
            show_launchagent_status
            ;;
        "start"|"load")
            load_launchagent
            ;;
        "stop"|"unload")
            unload_launchagent
            ;;
        "restart")
            restart_launchagent
            ;;
        "install")
            local interval="${1:-$DEFAULT_INTERVAL_MINUTES}"
            install_launchagent "$interval"
            ;;
        "uninstall")
            uninstall_launchagent
            ;;
        "logs")
            local lines="${1:-20}"
            show_launchagent_logs "$lines"
            ;;
        *)
            echo "❌ Unknown service command: $command"
            echo "Available commands: status, start, stop, restart, install, uninstall, logs"
            return 1
            ;;
    esac
}
