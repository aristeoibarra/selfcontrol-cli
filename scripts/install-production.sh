#!/bin/bash

# SelfControl CLI - Production Installer
# Robust installation script with comprehensive validation
# Version: 2.0.0

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

readonly INSTALLER_VERSION="2.0.0"
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
# VALIDATION FUNCTIONS
# =============================================================================

validate_system() {
    print_header "🔍 System Validation"
    
    # Check macOS version
    local macos_version
    macos_version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$macos_version" | cut -d. -f1)
    
    if [[ $major_version -lt 12 ]]; then
        print_error "macOS 12.0 or later required. Current: $macos_version"
        exit 1
    fi
    
    print_success "macOS version: $macos_version"
    
    # Check bash version
    local bash_version
    bash_version=$(bash --version | head -n1 | cut -d' ' -f4)
    print_success "Bash version: $bash_version"
}

validate_dependencies() {
    print_header "📦 Dependency Validation"
    
    # Check for SelfControl.app
    if [[ ! -d "/Applications/SelfControl.app" ]]; then
        print_error "SelfControl.app not found"
        print_status "Please install from: https://selfcontrolapp.com"
        exit 1
    fi
    
    print_success "SelfControl.app found"
    
    # Check for SelfControl CLI
    if [[ ! -x "/Applications/SelfControl.app/Contents/MacOS/SelfControl-CLI" ]]; then
        print_error "SelfControl CLI not found"
        print_status "Please ensure SelfControl.app is properly installed"
        exit 1
    fi
    
    print_success "SelfControl CLI found"
    
    # Check for required tools
    local required_tools=("date" "bc" "crontab" "python3")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" >/dev/null 2>&1; then
            print_error "Required tool not found: $tool"
            exit 1
        fi
        print_success "Tool available: $tool"
    done
}

validate_permissions() {
    print_header "🔐 Permission Validation"
    print_status "Checking installation permissions..."
    
    # Check write permissions
    if [[ ! -w "$HOME" ]]; then
        print_error "No write permission to home directory"
        exit 1
    fi
    
    # Check if directories can be created
    local test_dir
    test_dir=$(mktemp -d)
    if [[ ! -w "$test_dir" ]]; then
        print_error "Cannot create directories"
        exit 1
    fi
    rm -rf "$test_dir"
    
    print_success "Permission validation completed"
}

# =============================================================================
# INSTALLATION FUNCTIONS
# =============================================================================

install_files() {
    print_header "📦 Installing Files"
    print_status "Installing SelfControl CLI files..."
    
    # Create directories
    mkdir -p "$INSTALL_DIR" "$LIB_DIR" "$CONFIG_DIR" "$DATA_DIR/logs"
    
    # Install main executable
    cp "bin/selfcontrol-cli" "$INSTALL_DIR/"
    chmod +x "$INSTALL_DIR/selfcontrol-cli"
    print_success "Installed main executable"
    
    # Install libraries
    cp lib/*.sh "$LIB_DIR/"
    chmod +x "$LIB_DIR"/*.sh
    print_success "Installed libraries"
    
    # Create default configuration
    if [[ ! -f "$CONFIG_DIR/schedule.json" ]]; then
        cp "config/schedule.json" "$CONFIG_DIR/"
        print_success "Created default configuration"
    fi
    
    # Create default blocklist
    if [[ ! -f "$CONFIG_DIR/blocklist.selfcontrol" ]]; then
        cp "config/blocklist.selfcontrol" "$CONFIG_DIR/"
        print_success "Created default blocklist"
    fi
    
    print_success "File installation completed"
}

setup_shell_integration() {
    print_header "🐚 Shell Integration"
    print_status "Setting up shell integration..."
    
    # Determine shell profile
    local profile_file
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        profile_file="$HOME/.zshrc"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        profile_file="$HOME/.bashrc"
    else
        profile_file="$HOME/.profile"
    fi
    
    # Add to PATH if not already present
    local path_line
    path_line="export PATH=\"\$PATH:$INSTALL_DIR\""
    
    if ! grep -q "$INSTALL_DIR" "$profile_file" 2>/dev/null; then
        echo "" >> "$profile_file"
        echo "# SelfControl CLI" >> "$profile_file"
        echo "$path_line" >> "$profile_file"
        print_success "Added to PATH in $profile_file"
    fi
    
    # No legacy command compatibility needed for new installation

    print_success "Shell integration completed"
}

setup_automation() {
    print_header "🤖 Automation Setup"
    print_status "Setting up automated scheduling..."
    
    if [[ "${BATCH_MODE:-false}" != "true" ]]; then
        echo ""
        echo "Would you like to enable automatic scheduled blocks? (Y/n)"
        read -r response
        
        if [[ "$response" =~ ^[Nn]$ ]]; then
            print_status "Automated scheduling skipped"
            return 0
        fi
    fi
    
    # Check if cron job already exists
    if crontab -l 2>/dev/null | grep -q "selfcontrol-cli schedule check"; then
        print_warning "Cron job already exists"
        return 0
    fi
    
    # Add cron job
    local cron_entry
    cron_entry="*/5 * * * * $INSTALL_DIR/selfcontrol-cli schedule check >/dev/null 2>&1"
    
    (crontab -l 2>/dev/null; echo "$cron_entry") | crontab -
    print_success "Added cron job for automated scheduling"
}

run_post_install_tests() {
    print_header "🧪 Post-Installation Tests"
    print_status "Running installation validation tests..."
    
    local cli_path="$INSTALL_DIR/selfcontrol-cli"
    
    # Test CLI executable
    if [[ ! -x "$cli_path" ]]; then
        print_error "CLI executable not found or not executable: $cli_path"
        return 1
    fi
    
    # Test basic commands
    if ! "$cli_path" version >/dev/null 2>&1; then
        print_error "CLI version command failed"
        return 1
    fi
    
    if ! "$cli_path" help >/dev/null 2>&1; then
        print_error "CLI help command failed"
        return 1
    fi
    
    print_success "Post-installation tests passed"
}

show_completion_info() {
    print_header "🎉 Installation Complete"
    echo ""
    echo "SelfControl CLI has been successfully installed!"
    echo ""
    echo "Installation locations:"
    echo "  Executable: $INSTALL_DIR/selfcontrol-cli"
    echo "  Libraries:  $LIB_DIR/"
    echo "  Config:     $CONFIG_DIR/"
    echo "  Data:       $DATA_DIR/"
    echo ""
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.zshrc"
    echo "2. Test installation: selfcontrol-cli version"
    echo "3. Initialize configuration: selfcontrol-cli init"
    echo "4. Test schedules: selfcontrol-cli schedule test"
    echo ""
    echo "For help, run: selfcontrol-cli help"
}

# =============================================================================
# UNINSTALLATION
# =============================================================================

uninstall() {
    print_header "🗑️  Uninstalling SelfControl CLI"
    
    # Remove executable
    if [[ -f "$INSTALL_DIR/selfcontrol-cli" ]]; then
        rm "$INSTALL_DIR/selfcontrol-cli"
        print_success "Removed executable"
    fi
    
    # Remove libraries
    if [[ -d "$LIB_DIR" ]]; then
        rm -rf "$LIB_DIR"
        print_success "Removed libraries"
    fi
    
    # Remove from PATH
    local profile_files=("$HOME/.zshrc" "$HOME/.bashrc" "$HOME/.profile")
    for profile_file in "${profile_files[@]}"; do
        if [[ -f "$profile_file" ]]; then
            # Remove SelfControl CLI lines
            sed -i '' '/# SelfControl CLI/,+2d' "$profile_file" 2>/dev/null || true
            sed -i '' "/$INSTALL_DIR/d" "$profile_file" 2>/dev/null || true
        fi
    done
    print_success "Removed from PATH"
    
    # Remove cron jobs
    if crontab -l 2>/dev/null | grep -q "selfcontrol-cli"; then
        crontab -l 2>/dev/null | grep -v "selfcontrol-cli" | crontab -
        print_success "Removed cron jobs"
    fi
    
    # No legacy symlinks to remove for new installation

    # Ask about configuration and data
    if [[ "${BATCH_MODE:-false}" != "true" ]]; then
        echo ""
        echo "Remove configuration and data files? (y/N)"
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            rm -rf "$CONFIG_DIR" "$DATA_DIR"
            print_success "Configuration and data removed"
        else
            print_status "Configuration and data preserved"
        fi
    fi
    
    print_success "Uninstallation completed"
}

# =============================================================================
# MAIN INSTALLATION
# =============================================================================

install() {
    print_header "🚀 SelfControl CLI Production Installer"
    echo "Version: $INSTALLER_VERSION"
    echo ""
    
    # Check if already installed
    if [[ -x "$INSTALL_DIR/selfcontrol-cli" ]]; then
        print_warning "SelfControl CLI is already installed"
        echo "Use --force to reinstall or --uninstall to remove"
        exit 1
    fi
    
    # Run installation steps
    validate_system
    validate_dependencies
    validate_permissions
    
    install_files
    setup_shell_integration
    setup_automation
    
    run_post_install_tests
    show_completion_info
}

# =============================================================================
# COMMAND LINE PARSING
# =============================================================================

show_help() {
    cat << 'EOF'
SelfControl CLI Production Installer

USAGE:
    install-production.sh [OPTIONS]

OPTIONS:
    --help, -h              Show this help message
    --version, -v           Show installer version
    --force                 Force installation over existing
    --skip-deps             Skip dependency checks
    --verbose               Enable verbose logging
    --batch                 Run in batch mode (no prompts)
    --uninstall             Remove SelfControl CLI

EXAMPLES:
    ./install-production.sh                    # Interactive installation
    ./install-production.sh --batch --force    # Automated installation
    ./install-production.sh --uninstall        # Remove installation

INSTALLATION PATHS:
    Executable:     ~/.local/bin/selfcontrol-cli
    Libraries:      ~/.local/lib/selfcontrol-cli/
    Configuration:  ~/.config/selfcontrol-cli/
    Data & Logs:    ~/.local/share/selfcontrol-cli/

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
                echo "SelfControl CLI Installer v$INSTALLER_VERSION"
                exit 0
                ;;
            --force)
                FORCE=true
                ;;
            --skip-deps)
                SKIP_DEPS=true
                ;;
            --verbose)
                VERBOSE=true
                ;;
            --batch)
                BATCH_MODE=true
                ;;
            --uninstall)
                uninstall
                exit 0
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
    install
}

# Run main function if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
