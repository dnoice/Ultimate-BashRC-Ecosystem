#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - CONFIGURATION MANAGER
# File: config-manager.sh
# Repository: https://github.com/dnoice/Ultimate-BashRC-Ecosystem
# =============================================================================
# Advanced configuration management system for the Ultimate Bashrc Ecosystem.
# Provides GUI-like interface for settings, profiles, themes, and preferences.
# =============================================================================

set -euo pipefail

# Configuration
SCRIPT_NAME="$(basename "$0")"
SCRIPT_VERSION="2.1.0"

# Paths
ULTIMATE_BASHRC_HOME="${ULTIMATE_BASHRC_HOME:-$HOME/.ultimate-bashrc}"
CONFIG_DIR="$ULTIMATE_BASHRC_HOME/config"
PROFILES_DIR="$CONFIG_DIR/profiles"
THEMES_DIR="$CONFIG_DIR/themes"
BACKUPS_DIR="$CONFIG_DIR/backups"

# Configuration files
USER_CONFIG="$CONFIG_DIR/user.conf"
DEFAULTS_CONFIG="$CONFIG_DIR/defaults.conf"
ACTIVE_PROFILE="$CONFIG_DIR/.active_profile"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize configuration system
initialize() {
    # Create directory structure
    mkdir -p "$CONFIG_DIR" "$PROFILES_DIR" "$THEMES_DIR" "$BACKUPS_DIR"
    
    # Create default configuration if not exists
    if [[ ! -f "$DEFAULTS_CONFIG" ]]; then
        create_defaults_config
    fi
    
    # Create user configuration if not exists
    if [[ ! -f "$USER_CONFIG" ]]; then
        cp "$DEFAULTS_CONFIG" "$USER_CONFIG"
    fi
    
    # Create default profile
    if [[ ! -f "$PROFILES_DIR/default.conf" ]]; then
        cp "$USER_CONFIG" "$PROFILES_DIR/default.conf"
    fi
    
    # Set active profile
    if [[ ! -f "$ACTIVE_PROFILE" ]]; then
        echo "default" > "$ACTIVE_PROFILE"
    fi
    
    # Create default themes
    create_default_themes
}

# Create default configuration
create_defaults_config() {
    cat > "$DEFAULTS_CONFIG" << 'EOF'
# ═══════════════════════════════════════════════════════════════════════════
# ULTIMATE BASHRC ECOSYSTEM - DEFAULT CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

# ┌─────────────────────────────────────────────────────────────────────────┐
# │ MODULE LOADING CONFIGURATION                                           │
# └─────────────────────────────────────────────────────────────────────────┘

# Core module (always loaded)
LOAD_CORE_SETTINGS=true

# Utility modules
LOAD_CUSTOM_UTILITIES=true
LOAD_FILE_OPERATIONS=true
LOAD_NETWORK_UTILITIES=true

# Development modules
LOAD_GIT_INTEGRATION=true
LOAD_PYTHON_DEVELOPMENT=true

# Productivity modules
LOAD_INTELLIGENT_AUTOMATION=true
LOAD_PRODUCTIVITY_TOOLS=true

# Interface modules
LOAD_PROMPT_TRICKS=true

# System modules
LOAD_SYSTEM_MONITORING=true

# ┌─────────────────────────────────────────────────────────────────────────┐
# │ PERFORMANCE SETTINGS                                                   │
# └─────────────────────────────────────────────────────────────────────────┘

# Loading optimization
ENABLE_LAZY_LOADING=false          # Load modules only when needed
ENABLE_ASYNC_LOADING=false         # Load modules in parallel
ENABLE_MODULE_CACHING=true         # Cache compiled modules
MAX_PARALLEL_LOADS=4               # Maximum parallel module loads

# Resource limits
MAX_HISTORY_SIZE=100000            # Maximum history entries
MAX_CACHE_SIZE_MB=50               # Maximum cache size in MB
BACKGROUND_JOBS_LIMIT=10           # Maximum background jobs

# ┌─────────────────────────────────────────────────────────────────────────┐
# │ FEATURE FLAGS                                                          │
# └─────────────────────────────────────────────────────────────────────────┘

# Core features
ENABLE_ADVANCED_FEATURES=true      # Enable advanced functionality
ENABLE_EXPERIMENTAL_FEATURES=false # Enable experimental features
ENABLE_DEBUG_MODE=false           # Enable debug output
ENABLE_VERBOSE_MODE=false         # Enable verbose output

# User interface
SHOW_LOAD_TIMES=false             # Show module load times
SHOW_WELCOME_MESSAGE=true         # Show welcome message
SHOW_TIPS=true                    # Show helpful tips
ENABLE_NOTIFICATIONS=true         # Enable system notifications

# ┌─────────────────────────────────────────────────────────────────────────┐
# │ THEME AND APPEARANCE                                                   │
# └─────────────────────────────────────────────────────────────────────────┘

# Prompt configuration
PROMPT_THEME="powerline"          # Options: minimal, powerline, advanced, custom
PROMPT_SHOW_GIT=true              # Show git information in prompt
PROMPT_SHOW_TIME=false            # Show time in prompt
PROMPT_SHOW_EXIT_CODE=true        # Show last command exit code
PROMPT_SHOW_JOBS=true             # Show background jobs count

# Color scheme
COLOR_SCHEME="vibrant"            # Options: vibrant, pastel, monochrome, custom
ENABLE_256_COLORS=true            # Use 256 color palette
ENABLE_TRUECOLOR=false           # Use 24-bit true color

# Interface settings
TERMINAL_TITLE_FORMAT="dynamic"   # Options: static, dynamic, custom
ENABLE_UNICODE=true              # Enable Unicode characters
ENABLE_EMOJI=true                # Enable emoji support

# ┌─────────────────────────────────────────────────────────────────────────┐
# │ SYSTEM INTEGRATION                                                     │
# └─────────────────────────────────────────────────────────────────────────┘

# Cloud and sync
ENABLE_CLOUD_SYNC=false          # Sync settings to cloud
CLOUD_PROVIDER=""                # Options: dropbox, gdrive, onedrive
SYNC_INTERVAL_HOURS=24           # Sync interval in hours

# Updates and telemetry
AUTO_UPDATE_CHECK=true           # Check for updates automatically
UPDATE_CHECK_INTERVAL=7          # Days between update checks
ENABLE_TELEMETRY=false          # Send anonymous usage statistics
ENABLE_CRASH_REPORTS=false      # Send crash reports

# Security
ENABLE_COMMAND_LOGGING=false    # Log all commands
ENABLE_AUDIT_MODE=false         # Enhanced security auditing
MASK_SENSITIVE_DATA=true        # Mask passwords in history

# ┌─────────────────────────────────────────────────────────────────────────┐
# │ MODULE-SPECIFIC SETTINGS                                               │
# └─────────────────────────────────────────────────────────────────────────┘

# File Operations Module
FILE_OPS_AI_MODE=true            # Enable AI-like intelligence
FILE_OPS_LEARN_PATTERNS=true    # Learn from usage patterns
FILE_OPS_AUTO_ORGANIZE=false    # Auto-organize downloads

# Git Integration Module
GIT_AUTO_FETCH=false            # Auto-fetch in git repos
GIT_SHOW_STATS=true            # Show commit statistics
GIT_ENHANCED_DIFF=true         # Use enhanced diff viewer

# Productivity Tools Module
TASK_DEFAULT_PRIORITY="medium"  # Default task priority
TASK_REMINDER_ENABLED=true     # Enable task reminders
NOTE_DEFAULT_FORMAT="markdown" # Default note format

# System Monitoring Module
MONITOR_CPU_THRESHOLD=80       # CPU alert threshold (%)
MONITOR_MEM_THRESHOLD=85       # Memory alert threshold (%)
MONITOR_DISK_THRESHOLD=90      # Disk alert threshold (%)
MONITOR_TEMP_THRESHOLD=75      # Temperature threshold (°C)

# ┌─────────────────────────────────────────────────────────────────────────┐
# │ ADVANCED SETTINGS                                                      │
# └─────────────────────────────────────────────────────────────────────────┘

# Development
DEV_MODE_ENABLED=false         # Enable development mode
DEV_SHOW_TIMINGS=false        # Show detailed timings
DEV_SHOW_TRACES=false         # Show stack traces

# Experimental
EXPERIMENTAL_AI_ASSIST=false  # AI command assistance
EXPERIMENTAL_VOICE=false      # Voice command support
EXPERIMENTAL_GESTURES=false   # Gesture support

# Custom hooks
PRE_INIT_HOOK=""              # Script to run before init
POST_INIT_HOOK=""             # Script to run after init
PRE_COMMAND_HOOK=""           # Script to run before commands
POST_COMMAND_HOOK=""          # Script to run after commands
EOF
}

# Create default themes
create_default_themes() {
    # Vibrant theme
    cat > "$THEMES_DIR/vibrant.theme" << 'EOF'
# Vibrant Color Theme
COLOR_PRIMARY="\033[1;36m"       # Bright Cyan
COLOR_SECONDARY="\033[1;35m"     # Bright Magenta
COLOR_SUCCESS="\033[1;32m"       # Bright Green
COLOR_WARNING="\033[1;33m"       # Bright Yellow
COLOR_ERROR="\033[1;31m"         # Bright Red
COLOR_INFO="\033[1;34m"          # Bright Blue
COLOR_ACCENT="\033[1;95m"        # Bright Light Magenta
EOF
    
    # Pastel theme
    cat > "$THEMES_DIR/pastel.theme" << 'EOF'
# Pastel Color Theme
COLOR_PRIMARY="\033[38;5;117m"   # Light Blue
COLOR_SECONDARY="\033[38;5;183m" # Light Purple
COLOR_SUCCESS="\033[38;5;120m"   # Light Green
COLOR_WARNING="\033[38;5;222m"   # Light Yellow
COLOR_ERROR="\033[38;5;210m"     # Light Red
COLOR_INFO="\033[38;5;153m"      # Pale Blue
COLOR_ACCENT="\033[38;5;225m"    # Light Pink
EOF
    
    # Monochrome theme
    cat > "$THEMES_DIR/monochrome.theme" << 'EOF'
# Monochrome Theme
COLOR_PRIMARY="\033[1;37m"       # Bright White
COLOR_SECONDARY="\033[0;37m"     # White
COLOR_SUCCESS="\033[1;37m"       # Bright White
COLOR_WARNING="\033[0;37m"       # White
COLOR_ERROR="\033[1;37m"         # Bright White
COLOR_INFO="\033[2;37m"          # Dim White
COLOR_ACCENT="\033[4;37m"        # Underlined White
EOF
}

# =============================================================================
# INTERACTIVE MENU SYSTEM
# =============================================================================

# Main menu
main_menu() {
    while true; do
        clear
        echo -e "${PURPLE}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║   ${BOLD}ULTIMATE BASHRC CONFIGURATION MANAGER${NC}${PURPLE}          ║${NC}"
        echo -e "${PURPLE}║                 Version $SCRIPT_VERSION                      ║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════╝${NC}"
        echo
        echo -e "${CYAN}Main Menu:${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        echo "  1) 📦 Module Management"
        echo "  2) 🎨 Theme & Appearance"
        echo "  3) ⚡ Performance Settings"
        echo "  4) 🔧 Advanced Configuration"
        echo "  5) 👤 Profile Management"
        echo "  6) 💾 Backup & Restore"
        echo "  7) 📊 Configuration Report"
        echo "  8) 🔄 Apply Changes"
        echo "  9) ❓ Help"
        echo "  0) 🚪 Exit"
        echo
        echo -n "Enter your choice [0-9]: "
        
        read -n 1 -r choice
        echo
        
        case "$choice" in
            1) module_management_menu ;;
            2) theme_appearance_menu ;;
            3) performance_settings_menu ;;
            4) advanced_configuration_menu ;;
            5) profile_management_menu ;;
            6) backup_restore_menu ;;
            7) show_configuration_report ;;
            8) apply_changes ;;
            9) show_help ;;
            0) exit 0 ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# Module management menu
module_management_menu() {
    while true; do
        clear
        echo -e "${CYAN}Module Management${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        
        # Show module status
        show_module_status
        
        echo
        echo "  1) Enable module"
        echo "  2) Disable module"
        echo "  3) Configure module"
        echo "  4) Module information"
        echo "  5) Module dependencies"
        echo "  0) Back to main menu"
        echo
        echo -n "Enter your choice [0-5]: "
        
        read -n 1 -r choice
        echo
        
        case "$choice" in
            1) enable_module_interactive ;;
            2) disable_module_interactive ;;
            3) configure_module_interactive ;;
            4) show_module_info ;;
            5) show_module_dependencies ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# Show module status
show_module_status() {
    source "$USER_CONFIG"
    
    echo "Current Module Status:"
    echo
    printf "%-25s %-10s %-15s\n" "MODULE" "STATUS" "LOAD ORDER"
    printf "%-25s %-10s %-15s\n" "────────────────────────" "──────────" "───────────────"
    
    local modules=(
        "Core Settings:LOAD_CORE_SETTINGS:1"
        "Custom Utilities:LOAD_CUSTOM_UTILITIES:2"
        "File Operations:LOAD_FILE_OPERATIONS:3"
        "Git Integration:LOAD_GIT_INTEGRATION:4"
        "Intelligent Automation:LOAD_INTELLIGENT_AUTOMATION:5"
        "Network Utilities:LOAD_NETWORK_UTILITIES:6"
        "Productivity Tools:LOAD_PRODUCTIVITY_TOOLS:7"
        "Prompt Tricks:LOAD_PROMPT_TRICKS:8"
        "System Monitoring:LOAD_SYSTEM_MONITORING:9"
        "Python Development:LOAD_PYTHON_DEVELOPMENT:10"
    )
    
    for module_info in "${modules[@]}"; do
        IFS=':' read -r name var order <<< "$module_info"
        
        local status
        if [[ "${!var}" == "true" ]]; then
            status="${GREEN}Enabled${NC}"
        else
            status="${YELLOW}Disabled${NC}"
        fi
        
        printf "%-25s %-20b %-15s\n" "$name" "$status" "$order"
    done
}

# Theme and appearance menu
theme_appearance_menu() {
    while true; do
        clear
        echo -e "${CYAN}Theme & Appearance${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        
        source "$USER_CONFIG"
        
        echo "Current Settings:"
        echo "  Prompt Theme: $PROMPT_THEME"
        echo "  Color Scheme: $COLOR_SCHEME"
        echo "  256 Colors: $ENABLE_256_COLORS"
        echo "  Unicode: $ENABLE_UNICODE"
        echo "  Emoji: $ENABLE_EMOJI"
        echo
        echo "  1) Change prompt theme"
        echo "  2) Change color scheme"
        echo "  3) Toggle 256 colors"
        echo "  4) Toggle Unicode support"
        echo "  5) Toggle emoji support"
        echo "  6) Preview themes"
        echo "  0) Back to main menu"
        echo
        echo -n "Enter your choice [0-6]: "
        
        read -n 1 -r choice
        echo
        
        case "$choice" in
            1) change_prompt_theme ;;
            2) change_color_scheme ;;
            3) toggle_setting "ENABLE_256_COLORS" ;;
            4) toggle_setting "ENABLE_UNICODE" ;;
            5) toggle_setting "ENABLE_EMOJI" ;;
            6) preview_themes ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# =============================================================================
# CONFIGURATION OPERATIONS
# =============================================================================

# Get configuration value
get_config() {
    local key="$1"
    local file="${2:-$USER_CONFIG}"
    
    grep "^${key}=" "$file" 2>/dev/null | cut -d'=' -f2 | tr -d '"'
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"
    local file="${3:-$USER_CONFIG}"
    
    if grep -q "^${key}=" "$file" 2>/dev/null; then
        sed -i "s/^${key}=.*/${key}=${value}/" "$file"
    else
        echo "${key}=${value}" >> "$file"
    fi
}

# Toggle boolean setting
toggle_setting() {
    local key="$1"
    local current=$(get_config "$key")
    
    if [[ "$current" == "true" ]]; then
        set_config "$key" "false"
        echo -e "${GREEN}$key set to false${NC}"
    else
        set_config "$key" "true"
        echo -e "${GREEN}$key set to true${NC}"
    fi
    
    sleep 1
}

# =============================================================================
# PROFILE MANAGEMENT
# =============================================================================

# Profile management menu
profile_management_menu() {
    while true; do
        clear
        echo -e "${CYAN}Profile Management${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        
        local current_profile=$(cat "$ACTIVE_PROFILE" 2>/dev/null || echo "default")
        echo "Current Profile: ${GREEN}$current_profile${NC}"
        echo
        
        echo "Available Profiles:"
        for profile in "$PROFILES_DIR"/*.conf; do
            [[ -f "$profile" ]] || continue
            local name=$(basename "$profile" .conf)
            if [[ "$name" == "$current_profile" ]]; then
                echo "  * ${GREEN}$name${NC} (active)"
            else
                echo "    $name"
            fi
        done
        
        echo
        echo "  1) Switch profile"
        echo "  2) Create new profile"
        echo "  3) Copy profile"
        echo "  4) Delete profile"
        echo "  5) Export profile"
        echo "  6) Import profile"
        echo "  0) Back to main menu"
        echo
        echo -n "Enter your choice [0-6]: "
        
        read -n 1 -r choice
        echo
        
        case "$choice" in
            1) switch_profile ;;
            2) create_profile ;;
            3) copy_profile ;;
            4) delete_profile ;;
            5) export_profile ;;
            6) import_profile ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# Switch profile
switch_profile() {
    echo
    echo "Available profiles:"
    local profiles=()
    for profile in "$PROFILES_DIR"/*.conf; do
        [[ -f "$profile" ]] || continue
        local name=$(basename "$profile" .conf)
        profiles+=("$name")
        echo "  ${#profiles[@]}) $name"
    done
    
    echo
    echo -n "Select profile number: "
    read -r choice
    
    if [[ "$choice" -ge 1 && "$choice" -le ${#profiles[@]} ]]; then
        local selected="${profiles[$((choice-1))]}"
        echo "$selected" > "$ACTIVE_PROFILE"
        cp "$PROFILES_DIR/$selected.conf" "$USER_CONFIG"
        echo -e "${GREEN}Switched to profile: $selected${NC}"
    else
        echo -e "${RED}Invalid selection${NC}"
    fi
    
    sleep 2
}

# Create new profile
create_profile() {
    echo
    echo -n "Enter new profile name: "
    read -r name
    
    if [[ -z "$name" ]]; then
        echo -e "${RED}Profile name cannot be empty${NC}"
        sleep 2
        return
    fi
    
    if [[ -f "$PROFILES_DIR/$name.conf" ]]; then
        echo -e "${RED}Profile already exists${NC}"
        sleep 2
        return
    fi
    
    cp "$USER_CONFIG" "$PROFILES_DIR/$name.conf"
    echo -e "${GREEN}Profile '$name' created${NC}"
    sleep 2
}

# =============================================================================
# BACKUP AND RESTORE
# =============================================================================

# Backup restore menu
backup_restore_menu() {
    while true; do
        clear
        echo -e "${CYAN}Backup & Restore${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo
        
        echo "Available Backups:"
        local backups=()
        for backup in "$BACKUPS_DIR"/*.tar.gz; do
            [[ -f "$backup" ]] || continue
            backups+=("$(basename "$backup")")
        done
        
        if [[ ${#backups[@]} -eq 0 ]]; then
            echo "  No backups found"
        else
            for backup in "${backups[@]}"; do
                echo "  • $backup"
            done
        fi
        
        echo
        echo "  1) Create backup"
        echo "  2) Restore backup"
        echo "  3) Delete backup"
        echo "  4) Export all settings"
        echo "  5) Import settings"
        echo "  0) Back to main menu"
        echo
        echo -n "Enter your choice [0-5]: "
        
        read -n 1 -r choice
        echo
        
        case "$choice" in
            1) create_backup ;;
            2) restore_backup ;;
            3) delete_backup ;;
            4) export_settings ;;
            5) import_settings ;;
            0) return ;;
            *) echo -e "${RED}Invalid choice${NC}"; sleep 1 ;;
        esac
    done
}

# Create backup
create_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="backup_${timestamp}.tar.gz"
    local backup_path="$BACKUPS_DIR/$backup_name"
    
    echo
    echo "Creating backup..."
    
    tar -czf "$backup_path" \
        -C "$CONFIG_DIR" \
        user.conf \
        $(ls "$PROFILES_DIR"/*.conf 2>/dev/null | xargs -n1 basename) \
        $(ls "$THEMES_DIR"/*.theme 2>/dev/null | xargs -n1 basename) \
        2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}Backup created: $backup_name${NC}"
    else
        echo -e "${RED}Backup failed${NC}"
    fi
    
    sleep 2
}

# =============================================================================
# CONFIGURATION REPORT
# =============================================================================

# Show configuration report
show_configuration_report() {
    clear
    echo -e "${PURPLE}Configuration Report${NC}"
    echo -e "${CYAN}$(printf '═%.0s' {1..50})${NC}"
    echo
    
    source "$USER_CONFIG"
    
    # System information
    echo -e "${YELLOW}System Information:${NC}"
    echo "  Hostname: $(hostname)"
    echo "  User: $(whoami)"
    echo "  Shell: $SHELL"
    echo "  Bash Version: ${BASH_VERSION}"
    echo
    
    # Module statistics
    echo -e "${YELLOW}Module Statistics:${NC}"
    local enabled_count=0
    local disabled_count=0
    
    for var in $(grep "^LOAD_" "$USER_CONFIG" | cut -d'=' -f1); do
        if [[ "$(get_config "$var")" == "true" ]]; then
            ((enabled_count++))
        else
            ((disabled_count++))
        fi
    done
    
    echo "  Enabled Modules: $enabled_count"
    echo "  Disabled Modules: $disabled_count"
    echo
    
    # Performance settings
    echo -e "${YELLOW}Performance Settings:${NC}"
    echo "  Lazy Loading: $ENABLE_LAZY_LOADING"
    echo "  Module Caching: $ENABLE_MODULE_CACHING"
    echo "  Max Parallel Loads: $MAX_PARALLEL_LOADS"
    echo
    
    # Theme settings
    echo -e "${YELLOW}Theme Settings:${NC}"
    echo "  Prompt Theme: $PROMPT_THEME"
    echo "  Color Scheme: $COLOR_SCHEME"
    echo "  256 Colors: $ENABLE_256_COLORS"
    echo
    
    # Storage usage
    echo -e "${YELLOW}Storage Usage:${NC}"
    local total_size=$(du -sh "$ULTIMATE_BASHRC_HOME" 2>/dev/null | cut -f1)
    echo "  Total Size: $total_size"
    echo "  Config Directory: $(du -sh "$CONFIG_DIR" 2>/dev/null | cut -f1)"
    echo "  Cache Directory: $(du -sh "$ULTIMATE_BASHRC_HOME/cache" 2>/dev/null | cut -f1)"
    echo
    
    echo -n "Press any key to continue..."
    read -n 1 -r
}

# =============================================================================
# APPLY CHANGES
# =============================================================================

# Apply configuration changes
apply_changes() {
    clear
    echo -e "${CYAN}Applying Configuration Changes${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    
    echo "This will reload your shell configuration."
    echo -n "Continue? [y/N]: "
    read -n 1 -r response
    echo
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Applying changes..."
        
        # Clear cache if needed
        if [[ -d "$ULTIMATE_BASHRC_HOME/cache" ]]; then
            rm -f "$ULTIMATE_BASHRC_HOME/cache"/*.cache
            echo "  • Cleared module cache"
        fi
        
        # Reload configuration
        if [[ -f "$HOME/.bashrc" ]]; then
            source "$HOME/.bashrc"
            echo "  • Reloaded .bashrc"
        fi
        
        echo
        echo -e "${GREEN}Changes applied successfully!${NC}"
        echo -e "${YELLOW}Note: Some changes may require a new shell session.${NC}"
    else
        echo "Cancelled"
    fi
    
    echo
    echo -n "Press any key to continue..."
    read -n 1 -r
}

# =============================================================================
# HELP SYSTEM
# =============================================================================

# Show help
show_help() {
    clear
    echo -e "${PURPLE}Configuration Manager Help${NC}"
    echo -e "${CYAN}$(printf '═%.0s' {1..50})${NC}"
    echo
    
    cat << 'EOF'
OVERVIEW
--------
The Configuration Manager provides a comprehensive interface for managing
all aspects of the Ultimate Bashrc Ecosystem.

KEY FEATURES
-----------
• Module Management - Enable/disable and configure individual modules
• Theme System - Customize appearance and color schemes
• Performance Tuning - Optimize loading and resource usage
• Profile Support - Save and switch between configurations
• Backup/Restore - Protect your settings
• Interactive Menus - Easy navigation and configuration

CONFIGURATION FILES
------------------
• User Config: ~/.ultimate-bashrc/config/user.conf
• Profiles: ~/.ultimate-bashrc/config/profiles/
• Themes: ~/.ultimate-bashrc/config/themes/
• Backups: ~/.ultimate-bashrc/config/backups/

KEYBOARD SHORTCUTS
-----------------
• Numbers (0-9): Select menu options
• Enter: Confirm selection
• Ctrl+C: Exit at any time

TIPS
----
1. Create profiles for different environments (work, home, server)
2. Backup your configuration before major changes
3. Use lazy loading for faster shell startup
4. Disable unused modules to improve performance
5. Experiment with different themes and prompts

For more information, see the documentation at:
~/.ultimate-bashrc/README.md

EOF
    
    echo -n "Press any key to continue..."
    read -n 1 -r
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Initialize configuration system
    initialize
    
    # Parse command line arguments
    case "${1:-}" in
        --edit|-e)
            ${EDITOR:-nano} "$USER_CONFIG"
            ;;
        --show|-s)
            cat "$USER_CONFIG"
            ;;
        --reset)
            cp "$DEFAULTS_CONFIG" "$USER_CONFIG"
            echo "Configuration reset to defaults"
            ;;
        --help|-h)
            show_help
            ;;
        *)
            # Launch interactive menu
            main_menu
            ;;
    esac
}

# Run main function
main "$@"
