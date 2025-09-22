#!/bin/bash

# SelfControl CLI - Sudo Configuration Setup
# This script helps configure passwordless sudo for SelfControl CLI automation

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Get current user
readonly USERNAME=$(whoami)
readonly SELFCONTROL_CLI_PATH="$HOME/.local/bin/selfcontrol-cli"
readonly WRAPPER_PATH="$HOME/.local/lib/selfcontrol-cli/launchagent-wrapper.sh"

echo -e "${BLUE}🔐 SelfControl CLI - Sudo Configuration Setup${NC}"
echo "=============================================="
echo ""

# Check if files exist
echo -e "${BLUE}📋 Checking Prerequisites${NC}"

if [[ ! -f "$SELFCONTROL_CLI_PATH" ]]; then
    echo -e "${RED}❌ SelfControl CLI not found at: $SELFCONTROL_CLI_PATH${NC}"
    echo "Please install SelfControl CLI first."
    exit 1
fi

if [[ ! -f "$WRAPPER_PATH" ]]; then
    echo -e "${RED}❌ LaunchAgent wrapper not found at: $WRAPPER_PATH${NC}"
    echo "Please install SelfControl CLI first."
    exit 1
fi

echo -e "${GREEN}✅ SelfControl CLI found${NC}"
echo -e "${GREEN}✅ LaunchAgent wrapper found${NC}"
echo ""

# Generate sudoers content
echo -e "${BLUE}📝 Generating Sudoers Configuration${NC}"

SUDOERS_CONTENT="# SelfControl CLI - Allow passwordless execution with PATH preservation
$USERNAME ALL=(ALL) NOPASSWD: $SELFCONTROL_CLI_PATH
$USERNAME ALL=(ALL) NOPASSWD: $WRAPPER_PATH
Defaults!$SELFCONTROL_CLI_PATH env_keep += \"PATH HOME USER\"
Defaults!$WRAPPER_PATH env_keep += \"PATH HOME USER\"
Defaults!$SELFCONTROL_CLI_PATH !secure_path
Defaults!$WRAPPER_PATH !secure_path"

# Create temporary sudoers file
TEMP_SUDOERS="/tmp/selfcontrol-sudoers-$(date +%s).txt"
echo "$SUDOERS_CONTENT" > "$TEMP_SUDOERS"

echo -e "${GREEN}✅ Configuration generated at: $TEMP_SUDOERS${NC}"
echo ""

# Show the configuration
echo -e "${BLUE}📄 Configuration to be added:${NC}"
echo "---"
cat "$TEMP_SUDOERS"
echo "---"
echo ""

# Check current sudo status
echo -e "${BLUE}🔍 Checking Current Sudo Status${NC}"
if sudo -n true 2>/dev/null; then
    echo -e "${GREEN}✅ Sudo access available${NC}"
else
    echo -e "${YELLOW}⚠️  Sudo requires password${NC}"
fi
echo ""

# Instructions
echo -e "${BLUE}📋 Next Steps:${NC}"
echo ""
echo "1. Copy the configuration above"
echo "2. Run: ${YELLOW}sudo visudo${NC}"
echo "3. Go to the end of the file"
echo "4. Paste the configuration"
echo "5. Save and exit:"
echo "   - nano: Ctrl+X, Y, Enter"
echo "   - vi/vim: Esc, :wq, Enter"
echo ""

echo -e "${BLUE}🔧 Alternative: Automatic Configuration${NC}"
echo ""
echo "To automatically add the configuration (requires password):"
echo ""
echo "${YELLOW}echo '$SUDOERS_CONTENT' | sudo tee /etc/sudoers.d/selfcontrol-cli${NC}"
echo ""

# Offer to do automatic configuration
read -p "Would you like to automatically configure sudo now? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🔧 Configuring sudo automatically...${NC}"

    # Create sudoers.d file
    if echo "$SUDOERS_CONTENT" | sudo tee /etc/sudoers.d/selfcontrol-cli > /dev/null; then
        echo -e "${GREEN}✅ Sudo configuration created at /etc/sudoers.d/selfcontrol-cli${NC}"

        # Test the configuration
        echo -e "${BLUE}🧪 Testing configuration...${NC}"
        if sudo -n true 2>/dev/null; then
            echo -e "${GREEN}✅ Passwordless sudo configured successfully!${NC}"
        else
            echo -e "${YELLOW}⚠️  Configuration applied, but may need shell restart${NC}"
        fi
    else
        echo -e "${RED}❌ Failed to create sudo configuration${NC}"
        echo "Please configure manually using the instructions above."
        exit 1
    fi
else
    echo -e "${BLUE}📖 Manual Configuration Instructions${NC}"
    echo ""
    echo "1. Run: sudo visudo"
    echo "2. Add the configuration shown above"
    echo "3. Save and exit"
    echo ""
    echo "Or copy the configuration from: $TEMP_SUDOERS"
fi

echo ""
echo -e "${BLUE}🔍 Verification Commands${NC}"
echo ""
echo "After configuration, verify with:"
echo "  ${YELLOW}selfcontrol-cli debug${NC}     # Should show sudo configured"
echo "  ${YELLOW}sudo -n selfcontrol-cli version${NC}  # Should work without password"
echo ""

echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo "For detailed documentation, see: docs/SUDO_SETUP.md"

# Clean up
rm -f "$TEMP_SUDOERS"