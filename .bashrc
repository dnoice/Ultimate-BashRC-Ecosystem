#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - MAIN CONFIGURATION
# File: .bashrc
# Repository: https://github.com/dnoice/Ultimate-BashRC-Ecosystem
# =============================================================================
# This is the main bashrc file that orchestrates the entire Ultimate Bashrc
# Ecosystem. It handles module loading, environment setup, and provides
# intelligent initialization with performance optimization.
# =============================================================================

# Prevent duplicate sourcing
[[ -n "$ULTIMATE_BASHRC_LOADED" ]] && return
export ULTIMATE_BASHRC_LOADED=true

# =============================================================================
# CORE CONFIGURATION & PATHS
# =============================================================================

# Ultimate Bashrc installation directory
export ULTIMATE_BASHRC_HOME="${ULTIMATE_BASHRC_HOME:-$HOME/.ultimate-bashrc}"
export ULTIMATE_BASHRC_VERSION="2.1.0"
export ULTIMATE_BASHRC_MODULES_DIR="$ULTIMATE_BASHRC_HOME/modules"
export ULTIMATE_BASHRC_CONFIG_DIR="$ULTIMATE_BASHRC_HOME/config"
export ULTIMATE_BASHRC_DATA_DIR="$ULTIMATE_BASHRC_HOME/data"
export ULTIMATE_BASHRC_CACHE_DIR="$ULTIMATE_BASHRC_HOME/cache"
export ULTIMATE_BASHRC_LOGS_DIR="$ULTIMATE_BASHRC_HOME/logs"

# Color definitions for consistent output
export BASHRC_RED='\033[0;31m'
export BASHRC_GREEN='\033[0;32m'
export BASHRC_YELLOW='\033[0;33m'
export BASHRC_BLUE='\033[0;34m'
export BASHRC_PURPLE='\033[0;35m'
export BASHRC_CYAN='\033[0;36m'
export BASHRC_WHITE='\033[0;37m'
export BASHRC_NC='\033[0m' # No Color

# =============================================================================
# PERFORMANCE MONITORING
# =============================================================================

# Track initialization time
ULTIMATE_BASHRC_START_TIME=$(date +%s%N)

# Function to calculate elapsed time
calculate_load_time() {
    local end_time=$(date +%s%N)
    local elapsed=$((($end_time - $ULTIMATE_BASHRC_START_TIME) / 1000000))
    echo "${elapsed}ms"
}

# =============================================================================
# ERROR HANDLING
# =============================================================================

# Enhanced error handling
set -o errtrace
trap 'echo -e "${BASHRC_RED}Error loading Ultimate Bashrc: Check $ULTIMATE_BASHRC_LOGS_DIR/error.log${BASHRC_NC}"' ERR

# Create necessary directories
mkdir -p "$ULTIMATE_BASHRC_CONFIG_DIR" "$ULTIMATE_BASHRC_DATA_DIR" \
         "$ULTIMATE_BASHRC_CACHE_DIR" "$ULTIMATE_BASHRC_LOGS_DIR" 2>/dev/null

# =============================================================================
# CONFIGURATION LOADING
# =============================================================================

# Load user configuration
load_user_configuration() {
    local config_file="$ULTIMATE_BASHRC_CONFIG_DIR/user.conf"
    
    # Create default configuration if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << 'EOF'
# Ultimate Bashrc User Configuration
# Edit this file to customize your experience

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
SHOW_LOAD_TIMES=true
SHOW_WELCOME_MESSAGE=true

# Theme and Appearance
PROMPT_THEME="powerline"  # options: minimal, powerline, advanced, custom
COLOR_SCHEME="vibrant"    # options: vibrant, pastel, monochrome, custom

# System Integration
ENABLE_CLOUD_SYNC=false
ENABLE_TELEMETRY=false
AUTO_UPDATE_CHECK=true
UPDATE_CHECK_INTERVAL=7  # days
EOF
    fi
    
    # Source the configuration
    source "$config_file"
}

# =============================================================================
# MODULE LOADER
# =============================================================================

# Intelligent module loading system
load_module() {
    local module_name="$1"
    local module_file="$2"
    local load_var="$3"
    
    # Check if module should be loaded
    if [[ "${!load_var}" != "true" ]]; then
        [[ "$ENABLE_DEBUG_MODE" == "true" ]] && echo -e "${BASHRC_YELLOW}⏭️  Skipping $module_name${BASHRC_NC}"
        return 0
    fi
    
    # Check if module file exists
    if [[ ! -f "$module_file" ]]; then
        echo -e "${BASHRC_RED}❌ Module not found: $module_name${BASHRC_NC}"
        echo "$(date -Iseconds) - Module not found: $module_file" >> "$ULTIMATE_BASHRC_LOGS_DIR/error.log"
        return 1
    fi
    
    # Load module with timing
    local module_start=$(date +%s%N)
    
    # Check cache if enabled
    local cache_file="$ULTIMATE_BASHRC_CACHE_DIR/${module_name}.cache"
    if [[ "$ENABLE_MODULE_CACHING" == "true" && -f "$cache_file" && "$cache_file" -nt "$module_file" ]]; then
        source "$cache_file"
        local load_method="cached"
    else
        source "$module_file"
        local load_method="fresh"
        
        # Update cache if enabled
        if [[ "$ENABLE_MODULE_CACHING" == "true" ]]; then
            cp "$module_file" "$cache_file" 2>/dev/null
        fi
    fi
    
    local module_end=$(date +%s%N)
    local module_time=$((($module_end - $module_start) / 1000000))
    
    # Show load time if enabled
    if [[ "$SHOW_LOAD_TIMES" == "true" ]]; then
        echo -e "${BASHRC_GREEN}✓${BASHRC_NC} $module_name loaded (${module_time}ms) [$load_method]"
    fi
    
    # Log module loading
    echo "$(date -Iseconds) - Loaded: $module_name (${module_time}ms)" >> "$ULTIMATE_BASHRC_LOGS_DIR/modules.log"
    
    return 0
}

# Load all modules
load_all_modules() {
    echo -e "\n${BASHRC_CYAN}🚀 Loading Ultimate Bashrc Ecosystem v$ULTIMATE_BASHRC_VERSION${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    # Module definitions (name, filename, config_variable)
    local modules=(
        "Core Settings:01_core-settings.sh:LOAD_CORE_SETTINGS"
        "Custom Utilities:02_custom-utilities.sh:LOAD_CUSTOM_UTILITIES"
        "File Operations:03_file-operations.sh:LOAD_FILE_OPERATIONS"
        "Git Integration:04_git-integration.sh:LOAD_GIT_INTEGRATION"
        "Intelligent Automation:05_intelligent-automation.sh:LOAD_INTELLIGENT_AUTOMATION"
        "Network Utilities:06_network-utilities.sh:LOAD_NETWORK_UTILITIES"
        "Productivity Tools:07_productivity-tools.sh:LOAD_PRODUCTIVITY_TOOLS"
        "Prompt Tricks:08_prompt-tricks.sh:LOAD_PROMPT_TRICKS"
        "System Monitoring:09_system-monitoring.sh:LOAD_SYSTEM_MONITORING"
        "Python Development:10_python-development.sh:LOAD_PYTHON_DEVELOPMENT"
    )
    
    # 🤫 Check for hidden gems (silent loading)
    if [[ -f "$ULTIMATE_BASHRC_MODULES_DIR/11_secret-assistant.sh" ]]; then
        # Only load if discovered or explicitly enabled
        if [[ -f "$HOME/.ultimate-bashrc/.assistant_discovered" ]] || [[ "$LOAD_SECRET_ASSISTANT" == "true" ]]; then
            modules+=("Secret Assistant:11_secret-assistant.sh:LOAD_SECRET_ASSISTANT")
        fi
    fi
    
    if [[ -f "$ULTIMATE_BASHRC_MODULES_DIR/12_stealth-mode.sh" ]]; then
        # Only load if discovered or explicitly enabled  
        if [[ -f "$HOME/.ultimate-bashrc/.stealth_discovered" ]] || [[ "$LOAD_STEALTH_MODE" == "true" ]]; then
            modules+=("Stealth Mode:12_stealth-mode.sh:LOAD_STEALTH_MODE")
        fi
    }
    
    # Load modules based on configuration
    local loaded_count=0
    local failed_count=0
    
    for module_info in "${modules[@]}"; do
        IFS=':' read -r module_name module_file config_var <<< "$module_info"
        
        if load_module "$module_name" "$ULTIMATE_BASHRC_MODULES_DIR/$module_file" "$config_var"; then
            ((loaded_count++))
        else
            ((failed_count++))
        fi
    done
    
    echo -e "\n${BASHRC_PURPLE}📊 Module Loading Summary${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
    echo -e "✅ Loaded: $loaded_count modules"
    [[ $failed_count -gt 0 ]] && echo -e "❌ Failed: $failed_count modules"
    
    return 0
}

# =============================================================================
# LAZY LOADING SUPPORT
# =============================================================================

# Setup lazy loading for heavy modules
setup_lazy_loading() {
    if [[ "$ENABLE_LAZY_LOADING" != "true" ]]; then
        return 0
    fi
    
    echo -e "${BASHRC_CYAN}⚡ Lazy loading enabled${BASHRC_NC}"
    
    # Define lazy-loaded commands
    declare -A lazy_commands=(
        ["git"]="04_git-integration.sh"
        ["task"]="07_productivity-tools.sh"
        ["sysmon"]="09_system-monitoring.sh"
        ["pyenv"]="10_python-development.sh"
    )
    
    # Create wrapper functions
    for cmd in "${!lazy_commands[@]}"; do
        local module="${lazy_commands[$cmd]}"
        eval "
        $cmd() {
            if [[ ! -f \"$ULTIMATE_BASHRC_CACHE_DIR/.loaded_$module\" ]]; then
                echo -e \"${BASHRC_CYAN}⚡ Lazy loading ${module}...${BASHRC_NC}\"
                source \"$ULTIMATE_BASHRC_MODULES_DIR/$module\"
                touch \"$ULTIMATE_BASHRC_CACHE_DIR/.loaded_$module\"
            fi
            command $cmd \"\$@\"
        }
        "
    done
}

# =============================================================================
# SYSTEM HEALTH CHECK
# =============================================================================

# Perform system health check
system_health_check() {
    local issues=()
    
    # Check disk space
    local home_usage=$(df "$HOME" 2>/dev/null | awk 'NR==2 {print int($5)}')
    [[ $home_usage -gt 90 ]] && issues+=("⚠️  Home directory ${home_usage}% full")
    
    # Check memory
    local mem_usage=$(free 2>/dev/null | awk '/^Mem:/ {printf "%d", $3*100/$2}')
    [[ $mem_usage -gt 85 ]] && issues+=("⚠️  Memory usage high: ${mem_usage}%")
    
    # Check for updates if enabled
    if [[ "$AUTO_UPDATE_CHECK" == "true" ]]; then
        check_for_updates
    fi
    
    # Display issues if any
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo -e "\n${BASHRC_YELLOW}⚠️  System Health Warnings:${BASHRC_NC}"
        for issue in "${issues[@]}"; do
            echo -e "  $issue"
        done
    fi
}

# Check for updates
check_for_updates() {
    local last_check_file="$ULTIMATE_BASHRC_DATA_DIR/.last_update_check"
    local current_time=$(date +%s)
    local check_interval=$((UPDATE_CHECK_INTERVAL * 86400))
    
    # Check if enough time has passed
    if [[ -f "$last_check_file" ]]; then
        local last_check=$(cat "$last_check_file")
        local time_diff=$((current_time - last_check))
        [[ $time_diff -lt $check_interval ]] && return 0
    fi
    
    # Update last check time
    echo "$current_time" > "$last_check_file"
    
    # Check for updates (placeholder - implement actual update check)
    # This would typically check a remote repository or update server
    [[ "$ENABLE_DEBUG_MODE" == "true" ]] && echo -e "${BASHRC_CYAN}📦 Checking for updates...${BASHRC_NC}"
}

# =============================================================================
# WELCOME MESSAGE
# =============================================================================

# Display welcome message
show_welcome_message() {
    if [[ "$SHOW_WELCOME_MESSAGE" != "true" ]]; then
        return 0
    fi
    
    local load_time=$(calculate_load_time)
    
    echo -e "\n${BASHRC_PURPLE}╔══════════════════════════════════════════════════╗${BASHRC_NC}"
    echo -e "${BASHRC_PURPLE}║${BASHRC_NC}  🚀 ${BASHRC_CYAN}Ultimate Bashrc Ecosystem Initialized${BASHRC_NC}    ${BASHRC_PURPLE}║${BASHRC_NC}"
    echo -e "${BASHRC_PURPLE}╠══════════════════════════════════════════════════╣${BASHRC_NC}"
    echo -e "${BASHRC_PURPLE}║${BASHRC_NC}  📂 Version: ${BASHRC_GREEN}$ULTIMATE_BASHRC_VERSION${BASHRC_NC}                          ${BASHRC_PURPLE}║${BASHRC_NC}"
    echo -e "${BASHRC_PURPLE}║${BASHRC_NC}  ⏱️  Load Time: ${BASHRC_YELLOW}$load_time${BASHRC_NC}                         ${BASHRC_PURPLE}║${BASHRC_NC}"
    echo -e "${BASHRC_PURPLE}║${BASHRC_NC}  💡 Type 'ultimate help' for documentation      ${BASHRC_PURPLE}║${BASHRC_NC}"
    echo -e "${BASHRC_PURPLE}╚══════════════════════════════════════════════════╝${BASHRC_NC}\n"
}

# =============================================================================
# MAIN COMMAND
# =============================================================================

# Ultimate command for ecosystem management
ultimate() {
    local command="${1:-help}"
    shift
    
    case "$command" in
        help)
            ultimate_help
            ;;
        reload)
            ultimate_reload
            ;;
        update)
            ultimate_update
            ;;
        config)
            ultimate_config "$@"
            ;;
        modules)
            ultimate_modules "$@"
            ;;
        status)
            ultimate_status
            ;;
        benchmark)
            ultimate_benchmark
            ;;
        repair)
            ultimate_repair
            ;;
        *)
            echo "Unknown command: $command"
            ultimate_help
            ;;
    esac
}

# Show help
ultimate_help() {
    cat << EOF
${BASHRC_PURPLE}Ultimate Bashrc Ecosystem - Command Center${BASHRC_NC}
${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}

Usage: ultimate [COMMAND] [OPTIONS]

Commands:
  help        Show this help message
  reload      Reload the entire ecosystem
  update      Check and install updates
  config      Manage configuration
  modules     Manage modules
  status      Show system status
  benchmark   Run performance benchmark
  repair      Repair installation

Module Commands:
  ultimate modules list       List all modules
  ultimate modules enable     Enable a module
  ultimate modules disable    Disable a module
  ultimate modules info       Show module information

Configuration:
  ultimate config edit        Edit user configuration
  ultimate config reset       Reset to defaults
  ultimate config show        Show current configuration

Examples:
  ultimate reload             # Reload all modules
  ultimate modules list       # List available modules
  ultimate config edit        # Edit configuration
  ultimate status            # Show system status

For module-specific help, use:
  task help                  # Task management help
  note help                  # Note-taking help
  sysmon help               # System monitoring help
  ... and more

${BASHRC_YELLOW}💡 Hint: This ecosystem rewards exploration...${BASHRC_NC}
${BASHRC_YELLOW}   Some features are hidden until discovered.${BASHRC_NC}
${BASHRC_YELLOW}   Try using 'ultimate' frequently! 🥚${BASHRC_NC}

EOF
}

# Reload ecosystem
ultimate_reload() {
    echo -e "${BASHRC_CYAN}🔄 Reloading Ultimate Bashrc Ecosystem...${BASHRC_NC}"
    
    # Clear module cache if exists
    [[ -d "$ULTIMATE_BASHRC_CACHE_DIR" ]] && rm -f "$ULTIMATE_BASHRC_CACHE_DIR"/*.cache
    
    # Unset loaded flag
    unset ULTIMATE_BASHRC_LOADED
    
    # Re-source this file
    source "${BASH_SOURCE[0]}"
}

# Show status
ultimate_status() {
    echo -e "${BASHRC_PURPLE}Ultimate Bashrc Ecosystem Status${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
    
    echo -e "📂 Version: ${BASHRC_GREEN}$ULTIMATE_BASHRC_VERSION${BASHRC_NC}"
    echo -e "🏠 Home: $ULTIMATE_BASHRC_HOME"
    echo -e "📦 Modules Directory: $ULTIMATE_BASHRC_MODULES_DIR"
    echo -e "⚙️  Configuration: $ULTIMATE_BASHRC_CONFIG_DIR/user.conf"
    
    # Count loaded modules
    local module_count=$(ls "$ULTIMATE_BASHRC_MODULES_DIR"/*.sh 2>/dev/null | wc -l)
    echo -e "📚 Available Modules: $module_count"
    
    # Show cache status
    if [[ "$ENABLE_MODULE_CACHING" == "true" ]]; then
        local cache_count=$(ls "$ULTIMATE_BASHRC_CACHE_DIR"/*.cache 2>/dev/null | wc -l)
        echo -e "💾 Cached Modules: $cache_count"
    fi
    
    # Show disk usage
    local ecosystem_size=$(du -sh "$ULTIMATE_BASHRC_HOME" 2>/dev/null | cut -f1)
    echo -e "💿 Disk Usage: $ecosystem_size"
    
    # System info
    echo -e "\n${BASHRC_YELLOW}System Information:${BASHRC_NC}"
    echo -e "🖥️  Hostname: $(hostname)"
    echo -e "👤 User: $(whoami)"
    echo -e "🐚 Shell: $SHELL"
    echo -e "📍 PWD: $(pwd)"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Main initialization sequence
initialize_ultimate_bashrc() {
    # Load user configuration
    load_user_configuration
    
    # Setup lazy loading if enabled
    setup_lazy_loading
    
    # Load all modules
    load_all_modules
    
    # Perform system health check
    system_health_check
    
    # Show welcome message
    show_welcome_message
    
    # Set up command completion
    complete -W "help reload update config modules status benchmark repair" ultimate
    
    # Export main command
    export -f ultimate ultimate_help ultimate_reload ultimate_status
    
    # 🥚 Load easter eggs system if present (silent)
    if [[ -f "$ULTIMATE_BASHRC_HOME/.easter_eggs.sh" ]]; then
        source "$ULTIMATE_BASHRC_HOME/.easter_eggs.sh" 2>/dev/null
    fi
}

# Run initialization
initialize_ultimate_bashrc

# Clean up
unset ULTIMATE_BASHRC_START_TIME
unset -f calculate_load_time load_user_configuration load_module load_all_modules
unset -f setup_lazy_loading system_health_check check_for_updates show_welcome_message
unset -f initialize_ultimate_bashrc
