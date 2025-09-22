#!/bin/bash

# SelfControl CLI - Migration Script
# Handles migration from cron to LaunchAgent
# Version: 2.1.0

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_header() { echo -e "${BOLD}${BLUE}$1${NC}"; }
print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# =============================================================================
# MIGRATION FUNCTIONS
# =============================================================================

# Check if this system needs migration
check_migration_needed() {
    print_header "🔍 Checking Migration Status"
    echo ""

    local needs_migration=false

    # Check for existing cron job
    if crontab -l 2>/dev/null | grep -q "selfcontrol-cli schedule check"; then
        print_info "Found existing cron job for SelfControl CLI"
        needs_migration=true
    else
        print_info "No cron job found"
    fi

    # Check for existing LaunchAgent
    local launchagent_plist="$HOME/Library/LaunchAgents/com.selfcontrol.cli.scheduler.plist"
    if [[ -f "$launchagent_plist" ]]; then
        print_info "LaunchAgent already exists"
        if launchctl list com.selfcontrol.cli.scheduler >/dev/null 2>&1; then
            print_info "LaunchAgent is loaded and running"
            if ! $needs_migration; then
                print_success "System is already using LaunchAgent - no migration needed"
                return 1
            fi
        else
            print_warning "LaunchAgent exists but is not loaded"
        fi
    else
        print_info "No LaunchAgent found"
    fi

    echo ""

    if $needs_migration; then
        print_warning "Migration from cron to LaunchAgent is recommended"
        return 0
    else
        print_info "No migration needed - will install fresh LaunchAgent"
        return 2
    fi
}

# Perform automatic migration
perform_migration() {
    print_header "🚀 Performing Migration"
    echo ""

    # Source the LaunchAgent functions
    if [[ -f "$ROOT_DIR/scripts/launchagent.sh" ]]; then
        # shellcheck source=scripts/launchagent.sh
        source "$ROOT_DIR/scripts/launchagent.sh"
    else
        print_error "LaunchAgent script not found: $ROOT_DIR/scripts/launchagent.sh"
        return 1
    fi

    # Source core functions for logging
    if [[ -f "$ROOT_DIR/lib/core.sh" ]]; then
        # shellcheck source=lib/core.sh
        source "$ROOT_DIR/lib/core.sh"
    fi

    # Use the migration function from launchagent.sh
    migrate_from_cron
}

# Migration is one-way only - no rollback to cron supported in v2.1.0+

# Show detailed migration report
show_migration_report() {
    print_header "📊 Migration Report"
    echo ""

    # Current system status
    print_info "Current System Status:"

    # Check cron
    if crontab -l 2>/dev/null | grep -q "selfcontrol-cli schedule check"; then
        echo -e "   Cron Job: ${YELLOW}✓ Active${NC}"
        local cron_line
        cron_line=$(crontab -l 2>/dev/null | grep "selfcontrol-cli schedule check" | head -1)
        echo "   Schedule: $cron_line"
    else
        echo -e "   Cron Job: ${GREEN}✗ Not Active${NC}"
    fi

    # Check LaunchAgent
    local launchagent_plist="$HOME/Library/LaunchAgents/com.selfcontrol.cli.scheduler.plist"
    if [[ -f "$launchagent_plist" ]]; then
        echo -e "   LaunchAgent: ${GREEN}✓ Installed${NC}"

        if launchctl list com.selfcontrol.cli.scheduler >/dev/null 2>&1; then
            echo -e "   LaunchAgent Status: ${GREEN}✓ Running${NC}"
        else
            echo -e "   LaunchAgent Status: ${RED}✗ Not Running${NC}"
        fi
    else
        echo -e "   LaunchAgent: ${RED}✗ Not Installed${NC}"
    fi

    echo ""

    # Migration recommendation
    local status_code
    if check_migration_needed >/dev/null 2>&1; then
        status_code=$?
    else
        status_code=$?
    fi

    case $status_code in
        0)
            print_warning "Recommendation: Run migration to switch from cron to LaunchAgent"
            echo -e "   ${BLUE}Command: $0 migrate${NC}"
            ;;
        1)
            print_success "Recommendation: System is properly configured with LaunchAgent"
            ;;
        2)
            print_info "Recommendation: Install LaunchAgent for better reliability"
            echo -e "   ${BLUE}Command: $0 install${NC}"
            ;;
    esac
}

# =============================================================================
# MAIN FUNCTIONS
# =============================================================================

# Show help information
show_help() {
    cat << 'EOF'
SelfControl CLI - Migration Tool

DESCRIPTION:
    Migrate from cron-based scheduling to LaunchAgent-based scheduling
    for improved reliability and better macOS integration.

USAGE:
    migrate.sh <command>

COMMANDS:
    check       Check if migration is needed
    migrate     Perform automatic migration from cron to LaunchAgent
    install     Install fresh LaunchAgent (no existing cron)
    report      Show detailed system status and recommendations
    help        Show this help message

EXAMPLES:
    ./scripts/migrate.sh check         # Check migration status
    ./scripts/migrate.sh migrate       # Perform migration
    ./scripts/migrate.sh report        # Show detailed report

NOTES:
    - Migration will preserve your current scheduling interval
    - Original cron job is backed up before removal
    - LaunchAgent provides native macOS automation
    - Run 'report' command for personalized recommendations

EOF
}

# Main entry point
main() {
    local command="${1:-check}"

    case "$command" in
        "check")
            if check_migration_needed; then
                exit 0  # Migration needed
            elif [[ $? -eq 1 ]]; then
                exit 1  # No migration needed (already using LaunchAgent)
            else
                exit 2  # No migration needed (fresh install)
            fi
            ;;
        "migrate")
            perform_migration
            ;;
        "install")
            print_header "🚀 Installing Fresh LaunchAgent"
            echo ""

            # Source the LaunchAgent functions
            if [[ -f "$ROOT_DIR/scripts/launchagent.sh" ]]; then
                # shellcheck source=scripts/launchagent.sh
                source "$ROOT_DIR/scripts/launchagent.sh"
            else
                print_error "LaunchAgent script not found"
                exit 1
            fi

            install_launchagent 5
            ;;
        "report")
            show_migration_report
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $command"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
