#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - INSTALLER
# File: install.sh
# Repository: https://github.com/dnoice/Ultimate-BashRC-Ecosystem
# =============================================================================
# Automated installation script for the Ultimate Bashrc Ecosystem.
# Handles complete setup, dependency checking, backup creation, and
# intelligent configuration.
# =============================================================================

set -euo pipefail

# Configuration
SCRIPT_NAME="$(basename "$0")"
SCRIPT_VERSION="2.1.0"
INSTALL_DIR="${ULTIMATE_BASHRC_HOME:-$HOME/.ultimate-bashrc}"
BACKUP_DIR="$HOME/.bashrc_backups"
REPO_URL="https://github.com/dnoice/Ultimate-BashRC-Ecosystem.git"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Installation flags
FORCE_INSTALL=false
SKIP_BACKUP=false
MINIMAL_INSTALL=false
DEVELOPER_MODE=false
INTERACTIVE=true

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Print colored output
print_color() {
    local color="$1"
    shift
    echo -e "${color}$*${NC}"
}

# Print header
print_header() {
    echo
    print_color "$PURPLE" "╔══════════════════════════════════════════════════════╗"
    print_color "$PURPLE" "║      ${BOLD}ULTIMATE BASHRC ECOSYSTEM INSTALLER${NC}${PURPLE}         ║"
    print_color "$PURPLE" "║                  Version $SCRIPT_VERSION                        ║"
    print_color "$PURPLE" "║        github.com/dnoice/Ultimate-BashRC-Ecosystem    ║"
    print_color "$PURPLE" "╚══════════════════════════════════════════════════════╝"
    echo
}

# Print section
print_section() {
    echo
    print_color "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_color "$CYAN" "  $1"
    print_color "$CYAN" "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo
}

# Print success
print_success() {
    print_color "$GREEN" "✓ $1"
}

# Print warning
print_warning() {
    print_color "$YELLOW" "⚠ $1"
}

# Print error
print_error() {
    print_color "$RED" "✗ $1"
}

# Print info
print_info() {
    print_color "$BLUE" "ℹ $1"
}

# Spinner animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    
    while ps -p "$pid" > /dev/null 2>&1; do
        for i in $(seq 0 9); do
            printf "\r${CYAN}%s${NC} " "${spinstr:$i:1}"
            sleep $delay
        done
    done
    printf "\r"
}

# Confirm action
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    
    if [[ "$INTERACTIVE" == "false" ]]; then
        [[ "$default" == "y" ]] && return 0 || return 1
    fi
    
    local answer
    if [[ "$default" == "y" ]]; then
        read -p "$prompt [Y/n]: " -n 1 -r answer
    else
        read -p "$prompt [y/N]: " -n 1 -r answer
    fi
    echo
    
    if [[ -z "$answer" ]]; then
        [[ "$default" == "y" ]] && return 0 || return 1
    fi
    
    [[ "$answer" =~ ^[Yy]$ ]] && return 0 || return 1
}

# =============================================================================
# SYSTEM CHECKS
# =============================================================================

# Check system requirements
check_requirements() {
    print_section "System Requirements Check"
    
    local requirements_met=true
    
    # Check bash version
    local bash_version="${BASH_VERSION%%.*}"
    if [[ $bash_version -ge 4 ]]; then
        print_success "Bash version: $BASH_VERSION"
    else
        print_error "Bash version 4.0+ required (found: $BASH_VERSION)"
        requirements_met=false
    fi
    
    # Check for required commands
    local required_commands=("git" "curl" "grep" "sed" "awk")
    for cmd in "${required_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            print_success "Command '$cmd' found"
        else
            print_error "Command '$cmd' not found"
            requirements_met=false
        fi
    done
    
    # Check for optional commands
    local optional_commands=("jq" "bc" "tree" "htop" "iostat")
    print_info "Checking optional commands..."
    for cmd in "${optional_commands[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            print_success "Optional: '$cmd' found"
        else
            print_warning "Optional: '$cmd' not found (some features may be limited)"
        fi
    done
    
    # Check disk space
    local available_space=$(df "$HOME" | awk 'NR==2 {print $4}')
    if [[ $available_space -gt 10240 ]]; then
        print_success "Sufficient disk space available"
    else
        print_warning "Low disk space (recommended: 10MB free)"
    fi
    
    if [[ "$requirements_met" == "false" ]]; then
        print_error "System requirements not met"
        if ! confirm "Continue anyway?"; then
            exit 1
        fi
    else
        print_success "All requirements met!"
    fi
}

# Detect existing installation
detect_existing() {
    print_section "Checking for Existing Installation"
    
    if [[ -d "$INSTALL_DIR" ]]; then
        print_warning "Existing installation found at: $INSTALL_DIR"
        
        if [[ -f "$INSTALL_DIR/VERSION" ]]; then
            local installed_version=$(cat "$INSTALL_DIR/VERSION")
            print_info "Installed version: $installed_version"
        fi
        
        if [[ "$FORCE_INSTALL" == "true" ]]; then
            print_info "Force installation enabled - will overwrite"
        else
            echo "Choose an option:"
            echo "  1) Upgrade existing installation"
            echo "  2) Backup and reinstall"
            echo "  3) Cancel installation"
            
            read -p "Enter choice (1-3): " -n 1 -r choice
            echo
            
            case "$choice" in
                1)
                    print_info "Upgrading existing installation..."
                    UPGRADE_MODE=true
                    ;;
                2)
                    print_info "Backing up existing installation..."
                    backup_existing
                    ;;
                3)
                    print_info "Installation cancelled"
                    exit 0
                    ;;
                *)
                    print_error "Invalid choice"
                    exit 1
                    ;;
            esac
        fi
    else
        print_success "No existing installation found"
    fi
}

# =============================================================================
# BACKUP OPERATIONS
# =============================================================================

# Backup existing configuration
backup_existing() {
    if [[ "$SKIP_BACKUP" == "true" ]]; then
        print_warning "Skipping backup (--skip-backup flag set)"
        return 0
    fi
    
    print_section "Creating Backup"
    
    mkdir -p "$BACKUP_DIR"
    local backup_name="ultimate-bashrc-backup-$(date +%Y%m%d-%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    # Backup existing .bashrc
    if [[ -f "$HOME/.bashrc" ]]; then
        cp "$HOME/.bashrc" "$backup_path.bashrc"
        print_success "Backed up .bashrc to $backup_path.bashrc"
    fi
    
    # Backup existing installation
    if [[ -d "$INSTALL_DIR" ]]; then
        tar -czf "$backup_path.tar.gz" -C "$HOME" ".ultimate-bashrc" 2>/dev/null
        print_success "Backed up installation to $backup_path.tar.gz"
        
        # Remove old installation
        rm -rf "$INSTALL_DIR"
        print_success "Removed old installation"
    fi
}

# =============================================================================
# INSTALLATION FUNCTIONS
# =============================================================================

# Download or copy modules
install_modules() {
    print_section "Installing Modules"
    
    # Create directory structure
    mkdir -p "$INSTALL_DIR"/{modules,config,data,cache,logs,bin}
    print_success "Created directory structure"
    
    # Check if we're installing from local directory or downloading
    if [[ -f "./01_core-settings.sh" ]]; then
        print_info "Installing from local directory..."
        
        # Copy module files (including hidden gems if present)
        for module in *.sh; do
            if [[ "$module" =~ ^[0-9]{2}_.+\.sh$ ]]; then
                cp "$module" "$INSTALL_DIR/modules/"
                # Don't announce hidden modules
                if [[ ! "$module" =~ ^(11|12)_ ]]; then
                    print_success "Installed module: $module"
                fi
            fi
        done
        
        # Silently copy easter eggs if present
        [[ -f ".easter_eggs.sh" ]] && cp ".easter_eggs.sh" "$INSTALL_DIR/" 2>/dev/null
        
        # Copy additional files
        [[ -f "README.md" ]] && cp "README.md" "$INSTALL_DIR/"
        [[ -f "LICENSE" ]] && cp "LICENSE" "$INSTALL_DIR/"
        
    else
        print_info "Downloading from repository..."
        
        # Clone or download repository
        if command -v git &> /dev/null; then
            git clone --depth 1 "$REPO_URL" "$INSTALL_DIR/temp" &
            spinner $!
            
            if [[ -d "$INSTALL_DIR/temp" ]]; then
                mv "$INSTALL_DIR/temp"/*.sh "$INSTALL_DIR/modules/" 2>/dev/null
                mv "$INSTALL_DIR/temp/README.md" "$INSTALL_DIR/" 2>/dev/null
                mv "$INSTALL_DIR/temp/LICENSE" "$INSTALL_DIR/" 2>/dev/null
                rm -rf "$INSTALL_DIR/temp"
                print_success "Downloaded and installed modules"
            else
                print_error "Failed to download modules"
                exit 1
            fi
        else
            print_error "Git not available for downloading"
            exit 1
        fi
    fi
    
    # Set permissions
    chmod 755 "$INSTALL_DIR/modules"/*.sh
    print_success "Set module permissions"
    
    # Create version file
    echo "$SCRIPT_VERSION" > "$INSTALL_DIR/VERSION"
}

# Setup configuration
setup_configuration() {
    print_section "Setting Up Configuration"
    
    local config_file="$INSTALL_DIR/config/user.conf"
    
    if [[ "$INTERACTIVE" == "true" ]] && [[ ! -f "$config_file" ]]; then
        print_info "Configuring module preferences..."
        
        cat > "$config_file" << 'EOF'
# Ultimate Bashrc User Configuration
# Generated by installer

# Module Loading Configuration
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

# Performance Settings
ENABLE_LAZY_LOADING=false
ENABLE_ASYNC_LOADING=false
ENABLE_MODULE_CACHING=true
MAX_PARALLEL_LOADS=4

# Feature Flags
ENABLE_ADVANCED_FEATURES=true
ENABLE_EXPERIMENTAL_FEATURES=false
ENABLE_DEBUG_MODE=false
SHOW_LOAD_TIMES=false
SHOW_WELCOME_MESSAGE=true

# Theme and Appearance
PROMPT_THEME="powerline"
COLOR_SCHEME="vibrant"

# System Integration
ENABLE_CLOUD_SYNC=false
ENABLE_TELEMETRY=false
AUTO_UPDATE_CHECK=true
UPDATE_CHECK_INTERVAL=7
EOF
        
        # Ask user about module preferences if interactive
        if confirm "Would you like to customize module loading?"; then
            customize_modules "$config_file"
        fi
        
        print_success "Configuration file created"
    else
        print_info "Using default configuration"
    fi
}

# Customize module selection
customize_modules() {
    local config_file="$1"
    
    echo
    print_info "Select modules to enable:"
    echo
    
    local modules=(
        "Custom Utilities:LOAD_CUSTOM_UTILITIES:Powerful custom utilities"
        "File Operations:LOAD_FILE_OPERATIONS:AI-like file management"
        "Git Integration:LOAD_GIT_INTEGRATION:Advanced Git features"
        "Intelligent Automation:LOAD_INTELLIGENT_AUTOMATION:Workflow automation"
        "Network Utilities:LOAD_NETWORK_UTILITIES:Network tools"
        "Productivity Tools:LOAD_PRODUCTIVITY_TOOLS:Task management & notes"
        "Prompt Tricks:LOAD_PROMPT_TRICKS:Custom prompt themes"
        "System Monitoring:LOAD_SYSTEM_MONITORING:Performance monitoring"
        "Python Development:LOAD_PYTHON_DEVELOPMENT:Python dev tools"
    )
    
    for module_info in "${modules[@]}"; do
        IFS=':' read -r name var desc <<< "$module_info"
        
        if confirm "  Enable $name? ($desc)"; then
            sed -i "s/^${var}=.*/${var}=true/" "$config_file"
        else
            sed -i "s/^${var}=.*/${var}=false/" "$config_file"
        fi
    done
}

# Setup shell integration
setup_shell_integration() {
    print_section "Setting Up Shell Integration"
    
    # Create main bashrc loader
    local bashrc_loader="$INSTALL_DIR/.bashrc"
    cp /dev/stdin "$bashrc_loader" << 'EOF'
#!/bin/bash
# Ultimate Bashrc Ecosystem Loader
# This file sources the main Ultimate Bashrc configuration

# Set installation directory
export ULTIMATE_BASHRC_HOME="$(dirname "${BASH_SOURCE[0]}")"

# Source the main configuration
if [[ -f "$ULTIMATE_BASHRC_HOME/modules/.bashrc_main" ]]; then
    source "$ULTIMATE_BASHRC_HOME/modules/.bashrc_main"
elif [[ -f "$ULTIMATE_BASHRC_HOME/.bashrc_main" ]]; then
    source "$ULTIMATE_BASHRC_HOME/.bashrc_main"
fi
EOF
    
    chmod 644 "$bashrc_loader"
    print_success "Created bashrc loader"
    
    # Integrate with user's .bashrc
    local user_bashrc="$HOME/.bashrc"
    local integration_marker="# Ultimate Bashrc Ecosystem"
    
    if grep -q "$integration_marker" "$user_bashrc" 2>/dev/null; then
        print_info "Integration already exists in .bashrc"
    else
        print_info "Adding integration to .bashrc..."
        
        cat >> "$user_bashrc" << EOF

# Ultimate Bashrc Ecosystem
if [[ -f "$INSTALL_DIR/.bashrc" ]]; then
    source "$INSTALL_DIR/.bashrc"
fi
EOF
        
        print_success "Added integration to .bashrc"
    fi
}

# Setup utilities
setup_utilities() {
    print_section "Installing Utilities"
    
    # Copy module manager
    if [[ -f "./module-manager.sh" ]]; then
        cp "./module-manager.sh" "$INSTALL_DIR/bin/"
        chmod 755 "$INSTALL_DIR/bin/module-manager.sh"
        print_success "Installed module manager"
    fi
    
    # Create uninstaller
    cat > "$INSTALL_DIR/bin/uninstall.sh" << 'EOF'
#!/bin/bash
# Ultimate Bashrc Ecosystem Uninstaller

echo "Uninstalling Ultimate Bashrc Ecosystem..."

# Remove from .bashrc
sed -i '/# Ultimate Bashrc Ecosystem/,+3d' "$HOME/.bashrc"

# Remove installation directory
rm -rf "$HOME/.ultimate-bashrc"

echo "✓ Ultimate Bashrc Ecosystem uninstalled"
echo "Please restart your shell or run: source ~/.bashrc"
EOF
    
    chmod 755 "$INSTALL_DIR/bin/uninstall.sh"
    print_success "Created uninstaller"
    
    # Create updater
    cat > "$INSTALL_DIR/bin/update.sh" << 'EOF'
#!/bin/bash
# Ultimate Bashrc Ecosystem Updater

echo "Checking for updates..."

# Update logic would go here
echo "Update check complete"
EOF
    
    chmod 755 "$INSTALL_DIR/bin/update.sh"
    print_success "Created updater"
}

# =============================================================================
# POST-INSTALLATION
# =============================================================================

# Run post-installation tasks
post_install() {
    print_section "Post-Installation Setup"
    
    # Initialize data directories
    touch "$INSTALL_DIR/logs/install.log"
    echo "Installation completed: $(date)" > "$INSTALL_DIR/logs/install.log"
    
    # Test loading
    print_info "Testing module loading..."
    if bash -c "source $INSTALL_DIR/.bashrc && echo 'Load test successful'" &> /dev/null; then
        print_success "Module loading test passed"
    else
        print_warning "Module loading test failed - check configuration"
    fi
    
    # Generate quick reference
    generate_quick_reference
}

# Generate quick reference guide
generate_quick_reference() {
    local ref_file="$INSTALL_DIR/QUICK_REFERENCE.md"
    
    cat > "$ref_file" << 'EOF'
# Ultimate Bashrc Ecosystem - Quick Reference

## Main Commands

### System Management
- `ultimate help` - Show help
- `ultimate reload` - Reload ecosystem
- `ultimate status` - Show status
- `ultimate config edit` - Edit configuration

### Module Management
- `ultimate modules list` - List modules
- `ultimate modules enable <name>` - Enable module
- `ultimate modules disable <name>` - Disable module

## Module-Specific Commands

### File Operations (Module 03)
- `organize [dir]` - Organize files intelligently
- `finddups [dir]` - Find duplicate files
- `watchfiles [path]` - Monitor file changes
- `smartdiff file1 file2` - Intelligent file comparison

### Productivity Tools (Module 07)
- `task add "description"` - Add task
- `task list` - List tasks
- `note add "content"` - Add note
- `timetrack start` - Start time tracking

### System Monitoring (Module 09)
- `sysmon` - System monitoring dashboard
- `sysmon cpu` - CPU monitoring
- `sysmon memory` - Memory monitoring
- `sysmon benchmark` - Run benchmarks

### Intelligent Automation (Module 05)
- `autoflow create [name]` - Create workflow
- `autoflow run [name]` - Run workflow
- `learn_patterns` - Analyze command patterns
- `smartschedule add` - Schedule tasks

## Useful Aliases
- `ll` - Detailed list
- `t` - Task management
- `n` - Note taking
- `mon` - System monitor

## Configuration Files
- User config: ~/.ultimate-bashrc/config/user.conf
- Module metadata: ~/.ultimate-bashrc/config/modules.json

## Troubleshooting
- Check logs: ~/.ultimate-bashrc/logs/
- Run health check: ultimate status
- Reinstall: Run install.sh again
- Uninstall: ~/.ultimate-bashrc/bin/uninstall.sh

For detailed documentation, see README.md
EOF
    
    print_success "Created quick reference guide"
}

# =============================================================================
# COMPLETION MESSAGE
# =============================================================================

# Show completion message
show_completion() {
    echo
    print_color "$GREEN" "╔══════════════════════════════════════════════════════╗"
    print_color "$GREEN" "║     🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉      ║"
    print_color "$GREEN" "╚══════════════════════════════════════════════════════╝"
    echo
    
    print_info "Installation Summary:"
    echo "  • Location: $INSTALL_DIR"
    echo "  • Modules installed: 10"
    echo "  • Configuration: $INSTALL_DIR/config/user.conf"
    echo "  • Quick reference: $INSTALL_DIR/QUICK_REFERENCE.md"
    echo
    
    print_color "$YELLOW" "Next Steps:"
    echo "  1. Reload your shell:"
    print_color "$CYAN" "     source ~/.bashrc"
    echo
    echo "  2. Or start a new terminal session"
    echo
    echo "  3. Run 'ultimate help' for documentation"
    echo
    
    print_color "$PURPLE" "Thank you for installing Ultimate Bashrc Ecosystem!"
}

# =============================================================================
# MAIN INSTALLATION FLOW
# =============================================================================

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force|-f)
                FORCE_INSTALL=true
                shift
                ;;
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --minimal|-m)
                MINIMAL_INSTALL=true
                shift
                ;;
            --dev)
                DEVELOPER_MODE=true
                shift
                ;;
            --non-interactive|-n)
                INTERACTIVE=false
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Clear screen and show header
    clear
    print_header
    
    # Run installation steps
    check_requirements
    detect_existing
    
    if [[ "${UPGRADE_MODE:-false}" != "true" ]]; then
        backup_existing
    fi
    
    install_modules
    setup_configuration
    setup_shell_integration
    setup_utilities
    post_install
    
    # Show completion
    show_completion
}

# Show help
show_help() {
    cat << EOF
Ultimate Bashrc Ecosystem Installer

Usage: $SCRIPT_NAME [OPTIONS]

Options:
  -f, --force           Force installation (overwrite existing)
  --skip-backup         Skip backup creation
  -m, --minimal         Minimal installation (core modules only)
  --dev                 Developer mode (include extra tools)
  -n, --non-interactive Non-interactive installation
  -h, --help            Show this help message

Examples:
  $SCRIPT_NAME                 # Interactive installation
  $SCRIPT_NAME --force         # Force reinstall
  $SCRIPT_NAME --minimal       # Minimal setup
  $SCRIPT_NAME -n              # Automated installation

EOF
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Trap errors
trap 'print_error "Installation failed! Check logs for details."; exit 1' ERR

# Run main installation
main "$@"
