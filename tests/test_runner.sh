#!/bin/bash

# SelfControl CLI - Test Runner (Fixed Version)
# Comprehensive test suite for production validation
# Version: 3.0.0

set -euo pipefail

# =============================================================================
# TEST FRAMEWORK SETUP
# =============================================================================

readonly TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR="$(cd "$TEST_DIR/.." && pwd)"
readonly LIB_DIR="$ROOT_DIR/lib"

# Test configuration
readonly TEST_CONFIG_DIR="$TEST_DIR/fixtures"
readonly TEST_LOG_DIR="$TEST_DIR/logs"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# =============================================================================
# TEST UTILITIES
# =============================================================================

# Print colored test output
print_test_result() {
    local status="$1"
    local test_name="$2"
    local message="${3:-}"

    case "$status" in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC} $test_name"
            ((TESTS_PASSED++))
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC} $test_name"
            if [[ -n "$message" ]]; then
                echo -e "${RED}   Error: $message${NC}"
            fi
            ((TESTS_FAILED++))
            ;;
        "SKIP")
            echo -e "${YELLOW}⏭️  SKIP${NC} $test_name - $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC} $test_name - $message"
            ;;
    esac
    ((TESTS_RUN++))
}

# Assert function for tests
assert() {
    local condition="$1"
    local test_name="$2"
    local error_message="${3:-Assertion failed}"

    if eval "$condition"; then
        print_test_result "PASS" "$test_name"
        return 0
    else
        print_test_result "FAIL" "$test_name" "$error_message"
        return 1
    fi
}

# Setup test environment
setup_test_env() {
    # Create test directories
    mkdir -p "$TEST_CONFIG_DIR" "$TEST_LOG_DIR"

    # Create test configuration
    cat > "$TEST_CONFIG_DIR/test_schedule.json" << 'EOF'
{
  "global_settings": {
    "check_interval": 1,
    "timezone": "auto",
    "prevent_duplicates": true,
    "log_level": "debug"
  },
  "schedules": [
    {
      "name": "test_schedule",
      "description": "Test schedule for validation",
      "start_time": "09:00",
      "end_time": "17:00",
      "days": ["monday", "tuesday", "wednesday", "thursday", "friday"],
      "enabled": true,
      "duration_hours": 8,
      "blocklist_file": "default",
      "priority": 1
    }
  ],
  "blocklists": {
    "default": "blocklist.test.selfcontrol"
  },
  "logging": {
    "enabled": true,
    "max_size_mb": 1,
    "keep_days": 7
  }
}
EOF

    # Create test blocklist
    cat > "$TEST_CONFIG_DIR/blocklist.test.selfcontrol" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
    <string>example.com</string>
    <string>test.com</string>
</array>
</plist>
EOF
}

# Cleanup test environment
cleanup_test_env() {
    rm -rf "$TEST_CONFIG_DIR" "$TEST_LOG_DIR"
}

# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================

test_basic_functionality() {
    echo ""
    echo "🧪 Testing Basic Functionality"
    echo "=============================="

    local cli_binary="$ROOT_DIR/bin/selfcontrol-cli"

    # Test binary exists and is executable
    if [[ -x "$cli_binary" ]]; then
        print_test_result "PASS" "CLI binary executable"
    else
        print_test_result "FAIL" "CLI binary executable" "Binary not found or not executable: $cli_binary"
        return 1
    fi

    # Test help command
    if "$cli_binary" help >/dev/null 2>&1; then
        print_test_result "PASS" "CLI help command"
    else
        print_test_result "FAIL" "CLI help command"
    fi

    # Test version command
    if "$cli_binary" version >/dev/null 2>&1; then
        print_test_result "PASS" "CLI version command"
    else
        print_test_result "FAIL" "CLI version command"
    fi

    # Test status command (should work even without SelfControl running)
    if "$cli_binary" status >/dev/null 2>&1; then
        print_test_result "PASS" "CLI status command"
    else
        print_test_result "FAIL" "CLI status command"
    fi

    # Test invalid command handling - should return exit code != 0
    if "$cli_binary" invalid_command >/dev/null 2>&1; then
        print_test_result "FAIL" "CLI invalid command handling" "Should return error for invalid commands"
    else
        print_test_result "PASS" "CLI invalid command handling"
    fi
}

# =============================================================================
# CONFIGURATION TESTS
# =============================================================================

test_configuration() {
    echo ""
    echo "🧪 Testing Configuration Files"
    echo "=============================="

    # Test JSON syntax validation
    for json_file in "$ROOT_DIR/config"/*.json; do
        if [[ -f "$json_file" ]]; then
            local filename=$(basename "$json_file")
            if python3 -m json.tool "$json_file" >/dev/null 2>&1; then
                print_test_result "PASS" "JSON syntax validation: $filename"
            else
                print_test_result "FAIL" "JSON syntax validation: $filename"
            fi
        fi
    done

    # Test XML blocklist validation
    for xml_file in "$ROOT_DIR/config"/*.selfcontrol; do
        if [[ -f "$xml_file" ]]; then
            local filename=$(basename "$xml_file")
            if command -v xmllint >/dev/null 2>&1; then
                if xmllint --noout "$xml_file" 2>/dev/null; then
                    print_test_result "PASS" "XML syntax validation: $filename"
                else
                    print_test_result "FAIL" "XML syntax validation: $filename"
                fi
            else
                print_test_result "SKIP" "XML syntax validation: $filename" "xmllint not available"
            fi
        fi
    done
}

# =============================================================================
# SCHEDULE TESTS
# =============================================================================

test_schedule_functionality() {
    echo ""
    echo "🧪 Testing Schedule Functionality"
    echo "================================="

    local cli_binary="$ROOT_DIR/bin/selfcontrol-cli"

    # Test schedule list command (allow exit code 1 if no schedules configured)
    "$cli_binary" schedule list >/dev/null 2>&1
    local exit_code=$?
    if [[ $exit_code -eq 0 || $exit_code -eq 1 ]]; then
        print_test_result "PASS" "Schedule list command"
    else
        print_test_result "FAIL" "Schedule list command" "Unexpected exit code: $exit_code"
    fi

    # Test schedule status command
    if "$cli_binary" schedule status >/dev/null 2>&1; then
        print_test_result "PASS" "Schedule status command"
    else
        print_test_result "FAIL" "Schedule status command"
    fi

    # Test schedule test command
    if "$cli_binary" schedule test >/dev/null 2>&1; then
        print_test_result "PASS" "Schedule test command"
    else
        print_test_result "FAIL" "Schedule test command"
    fi
}

# =============================================================================
# SCRIPT SYNTAX TESTS
# =============================================================================

test_script_syntax() {
    echo ""
    echo "🧪 Testing Script Syntax"
    echo "========================"

    # Test main binary syntax
    if bash -n "$ROOT_DIR/bin/selfcontrol-cli"; then
        print_test_result "PASS" "Main binary syntax"
    else
        print_test_result "FAIL" "Main binary syntax"
    fi

    # Test library scripts syntax
    for lib_file in "$ROOT_DIR/lib"/*.sh; do
        if [[ -f "$lib_file" ]]; then
            local filename=$(basename "$lib_file")
            if bash -n "$lib_file"; then
                print_test_result "PASS" "Library syntax: $filename"
            else
                print_test_result "FAIL" "Library syntax: $filename"
            fi
        fi
    done

    # Test script files syntax
    for script_file in "$ROOT_DIR/scripts"/*.sh; do
        if [[ -f "$script_file" ]]; then
            local filename=$(basename "$script_file")
            if bash -n "$script_file"; then
                print_test_result "PASS" "Script syntax: $filename"
            else
                print_test_result "FAIL" "Script syntax: $filename"
            fi
        fi
    done
}

# =============================================================================
# INSTALLATION TESTS
# =============================================================================

test_installation() {
    echo ""
    echo "🧪 Testing Installation"
    echo "======================="

    local installer="$ROOT_DIR/scripts/install-production.sh"

    # Test installer exists and is executable
    if [[ -x "$installer" ]]; then
        print_test_result "PASS" "Installer executable"
    else
        print_test_result "FAIL" "Installer executable" "Installer not found or not executable"
        return 1
    fi

    # Test installer help
    if "$installer" --help >/dev/null 2>&1; then
        print_test_result "PASS" "Installer help command"
    else
        print_test_result "FAIL" "Installer help command"
    fi

    # Test installer syntax
    if bash -n "$installer"; then
        print_test_result "PASS" "Installer script syntax"
    else
        print_test_result "FAIL" "Installer script syntax"
    fi
}

# =============================================================================
# MAIN TEST RUNNER
# =============================================================================

run_all_tests() {
    echo "🚀 SelfControl CLI Test Suite (Fixed)"
    echo "====================================="
    echo "Starting comprehensive test run..."

    # Setup test environment
    setup_test_env

    # Run test suites (in order of importance)
    test_script_syntax || true
    test_basic_functionality || true
    test_configuration || true
    test_schedule_functionality || true
    test_installation || true

    # Cleanup test environment
    cleanup_test_env

    # Print summary
    echo ""
    echo "📊 Test Results Summary"
    echo "======================="
    echo "Tests run: $TESTS_RUN"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 All tests passed!${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some tests failed.${NC}"
        exit 1
    fi
}

# Run specific test suite
run_specific_test() {
    local test_name="$1"

    setup_test_env

    case "$test_name" in
        "basic")
            test_basic_functionality
            ;;
        "config")
            test_configuration
            ;;
        "schedule")
            test_schedule_functionality
            ;;
        "syntax")
            test_script_syntax
            ;;
        "install")
            test_installation
            ;;
        *)
            echo "Unknown test suite: $test_name"
            echo "Available test suites: basic, config, schedule, syntax, install"
            exit 1
            ;;
    esac

    cleanup_test_env
}

# Main entry point
main() {
    case "${1:-all}" in
        "all")
            run_all_tests
            ;;
        *)
            run_specific_test "$1"
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
