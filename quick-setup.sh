#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - QUICK SETUP
# File: quick-setup.sh
# Repository: https://github.com/dnoice/Ultimate-BashRC-Ecosystem
# =============================================================================
# One-liner installation: 
# curl -sL https://raw.githubusercontent.com/dnoice/Ultimate-BashRC-Ecosystem/main/quick-setup.sh | bash
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/dnoice/Ultimate-BashRC-Ecosystem.git"
INSTALL_DIR="$HOME/.ultimate-bashrc"
TEMP_DIR="/tmp/ultimate-bashrc-install-$$"

# Print header
echo
echo -e "${PURPLE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║     ${BOLD}ULTIMATE BASHRC ECOSYSTEM - QUICK SETUP${NC}${PURPLE}       ║${NC}"
echo -e "${PURPLE}║        github.com/dnoice/Ultimate-BashRC-Ecosystem    ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════╝${NC}"
echo

# Check requirements
echo -e "${CYAN}Checking requirements...${NC}"

# Check bash version
BASH_VERSION_MAJOR="${BASH_VERSION%%.*}"
if [[ $BASH_VERSION_MAJOR -lt 4 ]]; then
    echo -e "${RED}✗ Bash 4.0+ required (found: $BASH_VERSION)${NC}"
    echo -e "${YELLOW}Please upgrade Bash and try again.${NC}"
    exit 1
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${RED}✗ Git is required but not installed${NC}"
    echo -e "${YELLOW}Please install git and try again.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All requirements met${NC}"

# Check for existing installation
if [[ -d "$INSTALL_DIR" ]]; then
    echo
    echo -e "${YELLOW}⚠ Existing installation found at: $INSTALL_DIR${NC}"
    echo -n "Do you want to backup and reinstall? [y/N]: "
    read -n 1 -r response
    echo
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Installation cancelled${NC}"
        exit 0
    fi
    
    # Backup existing installation
    BACKUP_NAME="ultimate-bashrc-backup-$(date +%Y%m%d-%H%M%S)"
    echo -e "${CYAN}Creating backup: ~/$BACKUP_NAME.tar.gz${NC}"
    tar -czf "$HOME/$BACKUP_NAME.tar.gz" -C "$HOME" ".ultimate-bashrc" 2>/dev/null
    rm -rf "$INSTALL_DIR"
fi

# Clone repository
echo
echo -e "${CYAN}Downloading Ultimate Bashrc Ecosystem...${NC}"
git clone --depth 1 "$REPO_URL" "$TEMP_DIR" 2>/dev/null || {
    echo -e "${RED}✗ Failed to download repository${NC}"
    echo -e "${YELLOW}Please check your internet connection and try again.${NC}"
    exit 1
}

# Install
echo -e "${CYAN}Installing...${NC}"

# Create directory structure
mkdir -p "$INSTALL_DIR"/{modules,config,data,cache,logs,bin}

# Copy files
cp "$TEMP_DIR"/*.sh "$INSTALL_DIR/modules/" 2>/dev/null || true
cp "$TEMP_DIR"/.easter_eggs.sh "$INSTALL_DIR/" 2>/dev/null || true  # Silent easter eggs
cp "$TEMP_DIR"/install.sh "$INSTALL_DIR/bin/" 2>/dev/null || true
cp "$TEMP_DIR"/module-manager.sh "$INSTALL_DIR/bin/" 2>/dev/null || true
cp "$TEMP_DIR"/config-manager.sh "$INSTALL_DIR/bin/" 2>/dev/null || true
cp "$TEMP_DIR"/README.md "$INSTALL_DIR/" 2>/dev/null || true
cp "$TEMP_DIR"/LICENSE "$INSTALL_DIR/" 2>/dev/null || true

# Create main bashrc loader
cat > "$INSTALL_DIR/.bashrc" << 'EOF'
#!/bin/bash
# Ultimate Bashrc Ecosystem Loader
export ULTIMATE_BASHRC_HOME="$(dirname "${BASH_SOURCE[0]}")"

# Source modules directory .bashrc if it exists (for backward compatibility)
if [[ -f "$ULTIMATE_BASHRC_HOME/modules/.bashrc" ]]; then
    source "$ULTIMATE_BASHRC_HOME/modules/.bashrc"
# Otherwise source the appropriate main file
elif [[ -f "$ULTIMATE_BASHRC_HOME/modules/01_core-settings.sh" ]]; then
    # Create a temporary main loader
    for module in "$ULTIMATE_BASHRC_HOME/modules"/*.sh; do
        [[ -f "$module" ]] && source "$module"
    done
fi
EOF

# Create default configuration
cat > "$INSTALL_DIR/config/user.conf" << 'EOF'
# Ultimate Bashrc User Configuration
LOAD_CORE_SETTINGS=true
LOAD_CUSTOM_UTILITIES=true
LOAD_FILE_OPERATIONS=true
LOAD_GIT_INTEGRATION=true
LOAD_INTELLIGENT_AUTOMATION=true
LOAD_NETWORK_UTILITIES=true
LOAD_PRODUCTIVITY_TOOLS=true
LOAD_PROMPT_TRICKS=true
LOAD_SYSTEM_MONITORING=true
LOAD_PYTHON_DEVELOPMENT=true

ENABLE_LAZY_LOADING=false
ENABLE_MODULE_CACHING=true
SHOW_WELCOME_MESSAGE=true
PROMPT_THEME="powerline"
COLOR_SCHEME="vibrant"
EOF

# Set permissions
chmod 755 "$INSTALL_DIR/modules"/*.sh 2>/dev/null || true
chmod 755 "$INSTALL_DIR/bin"/*.sh 2>/dev/null || true

# Add to .bashrc if not already present
BASHRC_FILE="$HOME/.bashrc"
INTEGRATION_MARKER="# Ultimate Bashrc Ecosystem"

if ! grep -q "$INTEGRATION_MARKER" "$BASHRC_FILE" 2>/dev/null; then
    echo -e "${CYAN}Adding to ~/.bashrc...${NC}"
    cat >> "$BASHRC_FILE" << EOF

# Ultimate Bashrc Ecosystem
if [[ -f "$INSTALL_DIR/.bashrc" ]]; then
    source "$INSTALL_DIR/.bashrc"
fi
EOF
else
    echo -e "${YELLOW}Already integrated with ~/.bashrc${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR"

# Success message
echo
echo -e "${GREEN}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          🎉 INSTALLATION SUCCESSFUL! 🎉             ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${CYAN}Installation Details:${NC}"
echo -e "  • Location: $INSTALL_DIR"
echo -e "  • Modules: 10 installed"
echo -e "  • Config: $INSTALL_DIR/config/user.conf"
echo
echo -e "${YELLOW}Next Steps:${NC}"
echo -e "  1. Reload your shell:"
echo -e "     ${CYAN}source ~/.bashrc${NC}"
echo
echo -e "  2. Or start a new terminal"
echo
echo -e "  3. Explore the features:"
echo -e "     ${CYAN}ultimate help${NC}     - Show help"
echo -e "     ${CYAN}ultimate status${NC}   - Check status"
echo -e "     ${CYAN}task help${NC}         - Task management"
echo -e "     ${CYAN}sysmon${NC}            - System monitor"
echo
echo -e "${PURPLE}Thank you for installing Ultimate Bashrc Ecosystem!${NC}"
echo -e "${PURPLE}Star us on GitHub: ${CYAN}https://github.com/dnoice/Ultimate-BashRC-Ecosystem${NC}"
echo
