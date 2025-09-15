#!/bin/bash

# SelfControl CLI - Standalone Uninstaller
# Complete removal script for SelfControl CLI
# Version: 1.0.0

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

readonly UNINSTALLER_VERSION="1.0.0"
readonly INSTALL_DIR="$HOME/.local/bin"
readonly LIB_DIR="$HOME/.local/lib/selfcontrol-cli"
readonly CONFIG_DIR="$HOME/.config/selfcontrol-cli"
readonly DATA_DIR="$HOME/.local/share/selfcontrol-cli"

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
print_status() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# =============================================================================
# UNINSTALLATION FUNCTIONS
# =============================================================================

check_installation() {
    print_header "🔍 Checking Installation"

    local found=false

    # Check executable
    if [[ -f "$INSTALL_DIR/selfcontrol-cli" ]]; then
        print_status "Found executable: $INSTALL_DIR/selfcontrol-cli"
        found=true
    fi

    # Check libraries
    if [[ -d "$LIB_DIR" ]]; then
        print_status "Found libraries: $LIB_DIR"
        found=true
    fi

    # Check configuration
    if [[ -d "$CONFIG_DIR" ]]; then
        print_status "Found configuration: $CONFIG_DIR"
        found=true
    fi

    # Check data directory
    if [[ -d "$DATA_DIR" ]]; then
        print_status "Found data directory: $DATA_DIR"
        found=true
    fi

    # Check PATH entries
    local profile_files=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile")
    for profile_file in "${profile_files[@]}"; do
        if [[ -f "$profile_file" ]] && grep -q "selfcontrol-cli" "$profile_file" 2>/dev/null; then
            print_status "Found PATH entry in: $profile_file"
            found=true
        fi
    done

    # Check cron jobs
    if crontab -l 2>/dev/null | grep -q "selfcontrol-cli"; then
        print_status "Found cron jobs"
        found=true
    fi

    if [[ "$found" == "false" ]]; then
        print_warning "No SelfControl CLI installation found"
        exit 0
    fi

    print_success "Installation detected"
}

remove_executable() {
    print_header "🗑️  Removing Executable"

    if [[ -f "$INSTALL_DIR/selfcontrol-cli" ]]; then
        rm "$INSTALL_DIR/selfcontrol-cli"
        print_success "Removed executable"
    else
        print_status "Executable not found"
    fi
}

remove_libraries() {
    print_header "📚 Removing Libraries"

    if [[ -d "$LIB_DIR" ]]; then
        rm -rf "$LIB_DIR"
        print_success "Removed libraries"
    else
        print_status "Libraries not found"
    fi
}

remove_from_path() {
    print_header "🐚 Removing from PATH"

    local profile_files=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile")
    local removed=false

    for profile_file in "${profile_files[@]}"; do
        if [[ -f "$profile_file" ]]; then
            # Create backup
            cp "$profile_file" "$profile_file.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true

            # Remove SelfControl CLI lines
            if grep -q "selfcontrol-cli" "$profile_file" 2>/dev/null; then
                # Remove the entire SelfControl CLI section
                sed -i '' '/# SelfControl CLI/,+2d' "$profile_file" 2>/dev/null || true
                # Remove any remaining lines with the install directory
                sed -i '' "/$INSTALL_DIR/d" "$profile_file" 2>/dev/null || true
                print_success "Removed from $profile_file"
                removed=true
            fi
        fi
    done

    if [[ "$removed" == "false" ]]; then
        print_status "No PATH entries found"
    fi
}

remove_cron_jobs() {
    print_header "⏰ Removing Cron Jobs"

    if crontab -l 2>/dev/null | grep -q "selfcontrol-cli"; then
        # Create backup of current crontab
        crontab -l > "$HOME/crontab.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true

        # Remove selfcontrol-cli entries
        crontab -l 2>/dev/null | grep -v "selfcontrol-cli" | crontab -
        print_success "Removed cron jobs"
    else
        print_status "No cron jobs found"
    fi
}

remove_configuration() {
    print_header "⚙️  Removing Configuration"

    local removed=false

    if [[ -d "$CONFIG_DIR" ]]; then
        rm -rf "$CONFIG_DIR"
        print_success "Removed configuration directory"
        removed=true
    fi

    if [[ -d "$DATA_DIR" ]]; then
        rm -rf "$DATA_DIR"
        print_success "Removed data directory"
        removed=true
    fi

    # Also check for any remaining config in lib directory
    if [[ -d "$HOME/.local/lib/config" ]] && [[ -f "$HOME/.local/lib/config/schedule.json" ]]; then
        rm -rf "$HOME/.local/lib/config"
        print_success "Removed legacy configuration"
        removed=true
    fi

    if [[ "$removed" == "false" ]]; then
        print_status "No configuration found"
    fi
}

cleanup_empty_directories() {
    print_header "🧹 Cleaning Up Empty Directories"

    # Remove empty directories if they exist
    [[ -d "$HOME/.local/lib" ]] && rmdir "$HOME/.local/lib" 2>/dev/null || true
    [[ -d "$HOME/.local/bin" ]] && rmdir "$HOME/.local/bin" 2>/dev/null || true
    [[ -d "$HOME/.local" ]] && rmdir "$HOME/.local" 2>/dev/null || true

    print_success "Cleanup completed"
}

show_completion_info() {
    print_header "🎉 Uninstallation Complete"
    echo ""
    echo "SelfControl CLI has been completely removed from your system."
    echo ""
    echo "Removed components:"
    echo "  ✅ Executable"
    echo "  ✅ Libraries"
    echo "  ✅ Configuration files"
    echo "  ✅ Data files"
    echo "  ✅ PATH entries"
    echo "  ✅ Cron jobs"
    echo ""
    echo "Backup files created:"
    echo "  📁 Shell profile backups: ~/.zshrc.backup.*, ~/.bashrc.backup.*"
    echo "  📁 Crontab backup: ~/crontab.backup.*"
    echo ""
    echo "To reinstall, run: ./scripts/install-production.sh"
    echo ""
    echo "Thank you for using SelfControl CLI! 👋"
}

# =============================================================================
# INTERACTIVE CONFIRMATION
# =============================================================================

confirm_uninstall() {
    if [[ "${BATCH_MODE:-false}" == "true" ]]; then
        return 0
    fi

    echo ""
    print_warning "This will completely remove SelfControl CLI from your system."
    echo ""
    echo "The following will be removed:"
    echo "  • Executable: $INSTALL_DIR/selfcontrol-cli"
    echo "  • Libraries: $LIB_DIR/"
    echo "  • Configuration: $CONFIG_DIR/"
    echo "  • Data files: $DATA_DIR/"
    echo "  • PATH entries from shell profiles"
    echo "  • Cron jobs"
    echo ""
    echo "Backup files will be created before removal."
    echo ""

    while true; do
        read -p "Are you sure you want to continue? (y/N): " -r response
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0
                ;;
            [Nn]|[Nn][Oo]|"")
                print_status "Uninstallation cancelled"
                exit 0
                ;;
            *)
                echo "Please answer yes (y) or no (n)."
                ;;
        esac
    done
}

# =============================================================================
# MAIN UNINSTALLATION
# =============================================================================

uninstall() {
    print_header "🗑️  SelfControl CLI Uninstaller"
    echo "Version: $UNINSTALLER_VERSION"
    echo ""

    check_installation
    confirm_uninstall

    remove_executable
    remove_libraries
    remove_from_path
    remove_cron_jobs
    remove_configuration
    cleanup_empty_directories

    show_completion_info
}

# =============================================================================
# COMMAND LINE PARSING
# =============================================================================

show_help() {
    cat << 'EOF'
SelfControl CLI Standalone Uninstaller

USAGE:
    uninstall.sh [OPTIONS]

OPTIONS:
    --help, -h              Show this help message
    --version, -v           Show uninstaller version
    --batch                 Run in batch mode (no prompts)
    --force                 Force uninstallation without confirmation

EXAMPLES:
    ./uninstall.sh                    # Interactive uninstallation
    ./uninstall.sh --batch --force    # Automated uninstallation

This script will completely remove SelfControl CLI from your system,
including all configuration files, data, and system integrations.

For more information, visit:
https://github.com/aristeoibarra/selfcontrol-cli
EOF
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --version|-v)
                echo "SelfControl CLI Uninstaller v$UNINSTALLER_VERSION"
                exit 0
                ;;
            --batch)
                BATCH_MODE=true
                ;;
            --force)
                FORCE=true
                BATCH_MODE=true
                ;;
            *)
                print_error "Unknown option: $1"
                print_status "Use --help for usage information"
                exit 1
                ;;
        esac
        shift
    done
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    parse_args "$@"
    uninstall
}

# Run main function if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
