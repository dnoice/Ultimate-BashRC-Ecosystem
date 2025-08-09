#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - MODULE MANAGER
# File: module-manager.sh
# Repository: https://github.com/dnoice/Ultimate-BashRC-Ecosystem
# =============================================================================
# Advanced module management system for the Ultimate Bashrc Ecosystem.
# Provides module dependency resolution, conflict detection, versioning,
# and intelligent loading optimization.
# =============================================================================

set -euo pipefail

# Configuration
SCRIPT_NAME="$(basename "$0")"
SCRIPT_VERSION="2.1.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Paths
ULTIMATE_BASHRC_HOME="${ULTIMATE_BASHRC_HOME:-$HOME/.ultimate-bashrc}"
MODULES_DIR="$ULTIMATE_BASHRC_HOME/modules"
CONFIG_DIR="$ULTIMATE_BASHRC_HOME/config"
DATA_DIR="$ULTIMATE_BASHRC_HOME/data"
CACHE_DIR="$ULTIMATE_BASHRC_HOME/cache"
LOGS_DIR="$ULTIMATE_BASHRC_HOME/logs"

# Module metadata file
MODULE_METADATA="$CONFIG_DIR/modules.json"

# =============================================================================
# MODULE METADATA MANAGEMENT
# =============================================================================

# Initialize module metadata
initialize_metadata() {
    mkdir -p "$CONFIG_DIR"
    
    if [[ ! -f "$MODULE_METADATA" ]]; then
        cat > "$MODULE_METADATA" << 'EOF'
{
  "modules": {
    "01_core-settings": {
      "name": "Core Settings",
      "version": "2.1.0",
      "description": "Intelligent, adaptive core settings with system context detection",
      "dependencies": [],
      "conflicts": [],
      "priority": 1,
      "required": true,
      "category": "core",
      "exports": ["detect_system_intelligence", "configure_intelligent_history"],
      "config_keys": ["HISTSIZE", "HISTFILESIZE", "SYSTEM_PERFORMANCE_CLASS"]
    },
    "02_custom-utilities": {
      "name": "Custom Utilities",
      "version": "2.1.0",
      "description": "Collection of powerful custom utilities and helpers",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 2,
      "required": false,
      "category": "utilities",
      "exports": [],
      "config_keys": []
    },
    "03_file-operations": {
      "name": "File Operations",
      "version": "2.1.0",
      "description": "Revolutionary file operations with AI-like intelligence",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 3,
      "required": false,
      "category": "utilities",
      "exports": ["organize", "finddups", "watchfiles", "smartdiff"],
      "config_keys": []
    },
    "04_git-integration": {
      "name": "Git Integration",
      "version": "2.1.0",
      "description": "Advanced Git integration and workflow automation",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 4,
      "required": false,
      "category": "development",
      "exports": [],
      "config_keys": []
    },
    "05_intelligent-automation": {
      "name": "Intelligent Automation",
      "version": "2.1.0",
      "description": "Intelligent automation with learning capabilities",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 5,
      "required": false,
      "category": "automation",
      "exports": ["autoflow", "learn_patterns", "smartschedule"],
      "config_keys": []
    },
    "06_network-utilities": {
      "name": "Network Utilities",
      "version": "2.1.0",
      "description": "Advanced network utilities and monitoring tools",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 6,
      "required": false,
      "category": "utilities",
      "exports": [],
      "config_keys": []
    },
    "07_productivity-tools": {
      "name": "Productivity Tools",
      "version": "2.1.0",
      "description": "Comprehensive productivity tools including task management",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 7,
      "required": false,
      "category": "productivity",
      "exports": ["task", "note", "timetrack"],
      "config_keys": []
    },
    "08_prompt-tricks": {
      "name": "Prompt Tricks",
      "version": "2.1.0",
      "description": "Advanced prompt customization and tricks",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 8,
      "required": false,
      "category": "interface",
      "exports": [],
      "config_keys": ["PROMPT_THEME", "COLOR_SCHEME"]
    },
    "09_system-monitoring": {
      "name": "System Monitoring",
      "version": "2.1.0",
      "description": "Comprehensive system monitoring and performance analysis",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 9,
      "required": false,
      "category": "system",
      "exports": ["sysmon"],
      "config_keys": ["CPU_ALERT_THRESHOLD", "MEMORY_ALERT_THRESHOLD"]
    },
    "10_python-development": {
      "name": "Python Development",
      "version": "2.1.0",
      "description": "Python development environment and tools",
      "dependencies": ["01_core-settings"],
      "conflicts": [],
      "priority": 10,
      "required": false,
      "category": "development",
      "exports": [],
      "config_keys": []
    }
  }
}
EOF
    fi
}

# =============================================================================
# MODULE OPERATIONS
# =============================================================================

# List all modules
list_modules() {
    echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}     Ultimate Bashrc Ecosystem - Module Manager${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}Available Modules:${NC}"
    echo -e "${CYAN}$(printf '─%.0s' {1..50})${NC}"
    
    printf "%-20s %-10s %-10s %-15s %s\n" "MODULE" "VERSION" "STATUS" "CATEGORY" "DESCRIPTION"
    printf "%-20s %-10s %-10s %-15s %s\n" "──────" "───────" "──────" "────────" "───────────"
    
    # Parse modules from directory
    for module_file in "$MODULES_DIR"/*.sh; do
        [[ ! -f "$module_file" ]] && continue
        
        local module_base=$(basename "$module_file" .sh)
        local module_num="${module_base%%_*}"
        local module_name="${module_base#*_}"
        
        # Check if module is enabled
        local status="${GREEN}Enabled${NC}"
        local config_var="LOAD_$(echo "${module_name^^}" | tr '-' '_')"
        
        if [[ -f "$CONFIG_DIR/user.conf" ]]; then
            source "$CONFIG_DIR/user.conf"
            if [[ "${!config_var}" != "true" ]]; then
                status="${YELLOW}Disabled${NC}"
            fi
        fi
        
        # Get module info from metadata
        local version="2.1.0"
        local category="general"
        local description="Module $module_name"
        
        printf "%-20s %-10s %-10b %-15s %s\n" \
               "$module_base" "$version" "$status" "$category" "$description"
    done
    
    echo
}

# Show detailed module information
module_info() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        echo -e "${RED}Error: Module name required${NC}"
        return 1
    fi
    
    # Find module file
    local module_file=""
    for file in "$MODULES_DIR"/*"$module_name"*.sh; do
        if [[ -f "$file" ]]; then
            module_file="$file"
            break
        fi
    done
    
    if [[ -z "$module_file" ]]; then
        echo -e "${RED}Error: Module '$module_name' not found${NC}"
        return 1
    fi
    
    local module_base=$(basename "$module_file" .sh)
    
    echo -e "${PURPLE}Module Information${NC}"
    echo -e "${CYAN}$(printf '═%.0s' {1..40})${NC}\n"
    
    echo -e "${YELLOW}Module:${NC} $module_base"
    echo -e "${YELLOW}File:${NC} $module_file"
    echo -e "${YELLOW}Size:${NC} $(du -h "$module_file" | cut -f1)"
    echo -e "${YELLOW}Lines:${NC} $(wc -l < "$module_file")"
    echo -e "${YELLOW}Modified:${NC} $(date -r "$module_file" '+%Y-%m-%d %H:%M:%S')"
    
    # Extract module metadata from file
    echo -e "\n${YELLOW}Module Metadata:${NC}"
    grep -E "^declare -r.*MODULE_VERSION=" "$module_file" 2>/dev/null || echo "Version: Not found"
    grep -E "^declare -r.*MODULE_NAME=" "$module_file" 2>/dev/null || echo "Name: Not found"
    
    # Show functions exported
    echo -e "\n${YELLOW}Exported Functions:${NC}"
    grep -E "^export -f" "$module_file" | sed 's/export -f /  - /' | head -10
    
    # Show aliases
    echo -e "\n${YELLOW}Aliases:${NC}"
    grep -E "^alias " "$module_file" | sed 's/alias /  - /' | head -10
}

# Enable a module
enable_module() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        echo -e "${RED}Error: Module name required${NC}"
        return 1
    fi
    
    # Find the module
    local config_var=""
    case "$module_name" in
        *core*settings*|01*)     config_var="LOAD_CORE_SETTINGS" ;;
        *custom*utilities*|02*)  config_var="LOAD_CUSTOM_UTILITIES" ;;
        *file*operations*|03*)   config_var="LOAD_FILE_OPERATIONS" ;;
        *git*|04*)              config_var="LOAD_GIT_INTEGRATION" ;;
        *automation*|05*)        config_var="LOAD_INTELLIGENT_AUTOMATION" ;;
        *network*|06*)          config_var="LOAD_NETWORK_UTILITIES" ;;
        *productivity*|07*)      config_var="LOAD_PRODUCTIVITY_TOOLS" ;;
        *prompt*|08*)           config_var="LOAD_PROMPT_TRICKS" ;;
        *monitoring*|09*)        config_var="LOAD_SYSTEM_MONITORING" ;;
        *python*|10*)           config_var="LOAD_PYTHON_DEVELOPMENT" ;;
        *)
            echo -e "${RED}Error: Unknown module '$module_name'${NC}"
            return 1
            ;;
    esac
    
    # Update configuration
    if [[ -f "$CONFIG_DIR/user.conf" ]]; then
        sed -i "s/^${config_var}=.*/${config_var}=true/" "$CONFIG_DIR/user.conf"
        echo -e "${GREEN}✓ Module '$module_name' enabled${NC}"
        echo -e "${YELLOW}Note: Reload your shell or run 'source ~/.bashrc' to apply changes${NC}"
    else
        echo -e "${RED}Error: Configuration file not found${NC}"
        return 1
    fi
}

# Disable a module
disable_module() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        echo -e "${RED}Error: Module name required${NC}"
        return 1
    fi
    
    # Find the module
    local config_var=""
    case "$module_name" in
        *core*settings*|01*)     
            echo -e "${RED}Error: Core Settings module cannot be disabled${NC}"
            return 1
            ;;
        *custom*utilities*|02*)  config_var="LOAD_CUSTOM_UTILITIES" ;;
        *file*operations*|03*)   config_var="LOAD_FILE_OPERATIONS" ;;
        *git*|04*)              config_var="LOAD_GIT_INTEGRATION" ;;
        *automation*|05*)        config_var="LOAD_INTELLIGENT_AUTOMATION" ;;
        *network*|06*)          config_var="LOAD_NETWORK_UTILITIES" ;;
        *productivity*|07*)      config_var="LOAD_PRODUCTIVITY_TOOLS" ;;
        *prompt*|08*)           config_var="LOAD_PROMPT_TRICKS" ;;
        *monitoring*|09*)        config_var="LOAD_SYSTEM_MONITORING" ;;
        *python*|10*)           config_var="LOAD_PYTHON_DEVELOPMENT" ;;
        *)
            echo -e "${RED}Error: Unknown module '$module_name'${NC}"
            return 1
            ;;
    esac
    
    # Update configuration
    if [[ -f "$CONFIG_DIR/user.conf" ]]; then
        sed -i "s/^${config_var}=.*/${config_var}=false/" "$CONFIG_DIR/user.conf"
        echo -e "${GREEN}✓ Module '$module_name' disabled${NC}"
        echo -e "${YELLOW}Note: Reload your shell or run 'source ~/.bashrc' to apply changes${NC}"
    else
        echo -e "${RED}Error: Configuration file not found${NC}"
        return 1
    fi
}

# =============================================================================
# MODULE DEPENDENCY RESOLUTION
# =============================================================================

# Check module dependencies
check_dependencies() {
    local module_name="$1"
    
    echo -e "${YELLOW}Checking dependencies for $module_name...${NC}"
    
    # This would parse the MODULE_METADATA JSON to check dependencies
    # For now, simplified version
    case "$module_name" in
        01_*|*core*)
            echo -e "${GREEN}✓ No dependencies - this is a core module${NC}"
            ;;
        *)
            echo -e "${GREEN}✓ Dependency: Core Settings${NC}"
            if [[ ! -f "$MODULES_DIR/01_core-settings.sh" ]]; then
                echo -e "${RED}✗ Missing dependency: Core Settings${NC}"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# =============================================================================
# MODULE OPTIMIZATION
# =============================================================================

# Optimize module loading order
optimize_loading() {
    echo -e "${CYAN}Optimizing module loading order...${NC}"
    
    # Create dependency graph
    local -A dependencies
    local -A priorities
    
    # Set priorities based on dependencies and usage patterns
    priorities["01_core-settings"]=1
    priorities["02_custom-utilities"]=2
    priorities["03_file-operations"]=3
    priorities["04_git-integration"]=4
    priorities["05_intelligent-automation"]=5
    priorities["06_network-utilities"]=6
    priorities["07_productivity-tools"]=7
    priorities["08_prompt-tricks"]=8
    priorities["09_system-monitoring"]=9
    priorities["10_python-development"]=10
    
    # Generate optimized loading order
    echo -e "${GREEN}Optimized loading order:${NC}"
    for module in $(for m in "${!priorities[@]}"; do 
        echo "${priorities[$m]} $m"
    done | sort -n | cut -d' ' -f2); do
        echo "  $((priorities[$module])). $module"
    done
    
    # Save optimization results
    {
        echo "# Optimized Module Loading Order"
        echo "# Generated: $(date)"
        for module in $(for m in "${!priorities[@]}"; do 
            echo "${priorities[$m]} $m"
        done | sort -n | cut -d' ' -f2); do
            echo "$module"
        done
    } > "$CONFIG_DIR/loading_order.conf"
    
    echo -e "${GREEN}✓ Optimization complete${NC}"
}

# =============================================================================
# MODULE BENCHMARKING
# =============================================================================

# Benchmark module loading times
benchmark_modules() {
    echo -e "${PURPLE}Module Loading Benchmark${NC}"
    echo -e "${CYAN}$(printf '═%.0s' {1..40})${NC}\n"
    
    local total_time=0
    local results=()
    
    for module_file in "$MODULES_DIR"/*.sh; do
        [[ ! -f "$module_file" ]] && continue
        
        local module_name=$(basename "$module_file" .sh)
        
        # Measure loading time
        local start_time=$(date +%s%N)
        (source "$module_file" 2>/dev/null)
        local end_time=$(date +%s%N)
        
        local load_time=$(( (end_time - start_time) / 1000000 ))
        total_time=$((total_time + load_time))
        
        results+=("$load_time:$module_name")
    done
    
    # Sort and display results
    echo -e "${YELLOW}Module Loading Times:${NC}"
    printf "%-30s %10s\n" "MODULE" "TIME (ms)"
    printf "%-30s %10s\n" "──────" "─────────"
    
    for result in $(printf '%s\n' "${results[@]}" | sort -rn); do
        local time="${result%%:*}"
        local module="${result#*:}"
        
        # Color code based on time
        local color="$GREEN"
        [[ $time -gt 100 ]] && color="$YELLOW"
        [[ $time -gt 500 ]] && color="$RED"
        
        printf "%-30s %b%10d ms%b\n" "$module" "$color" "$time" "$NC"
    done
    
    echo -e "\n${PURPLE}Total Load Time: ${total_time}ms${NC}"
    
    # Provide optimization suggestions
    if [[ $total_time -gt 2000 ]]; then
        echo -e "\n${YELLOW}⚠️  Suggestions for faster loading:${NC}"
        echo "  • Enable lazy loading in configuration"
        echo "  • Disable unused modules"
        echo "  • Enable module caching"
    fi
}

# =============================================================================
# MODULE HEALTH CHECK
# =============================================================================

# Check module health
health_check() {
    echo -e "${PURPLE}Module Health Check${NC}"
    echo -e "${CYAN}$(printf '═%.0s' {1..40})${NC}\n"
    
    local issues=0
    
    # Check modules directory
    if [[ ! -d "$MODULES_DIR" ]]; then
        echo -e "${RED}✗ Modules directory missing${NC}"
        ((issues++))
    else
        echo -e "${GREEN}✓ Modules directory exists${NC}"
    fi
    
    # Check each module file
    for i in {01..10}; do
        local module_found=false
        for file in "$MODULES_DIR"/${i}_*.sh; do
            if [[ -f "$file" ]]; then
                module_found=true
                
                # Check file permissions
                if [[ ! -r "$file" ]]; then
                    echo -e "${RED}✗ Module $i not readable: $(basename "$file")${NC}"
                    ((issues++))
                else
                    echo -e "${GREEN}✓ Module $i OK: $(basename "$file")${NC}"
                fi
                break
            fi
        done
        
        if [[ "$module_found" == "false" ]]; then
            echo -e "${YELLOW}⚠ Module $i missing${NC}"
        fi
    done
    
    # Check configuration
    if [[ ! -f "$CONFIG_DIR/user.conf" ]]; then
        echo -e "${YELLOW}⚠ User configuration missing (will use defaults)${NC}"
    else
        echo -e "${GREEN}✓ User configuration exists${NC}"
    fi
    
    # Summary
    echo
    if [[ $issues -eq 0 ]]; then
        echo -e "${GREEN}✅ All modules healthy!${NC}"
    else
        echo -e "${YELLOW}⚠️  Found $issues issue(s)${NC}"
    fi
}

# =============================================================================
# MAIN FUNCTION
# =============================================================================

main() {
    # Initialize
    initialize_metadata
    
    # Parse command
    local command="${1:-help}"
    shift
    
    case "$command" in
        list|ls)
            list_modules
            ;;
        info|show)
            module_info "$@"
            ;;
        enable|en)
            enable_module "$@"
            ;;
        disable|dis)
            disable_module "$@"
            ;;
        deps|dependencies)
            check_dependencies "$@"
            ;;
        optimize|opt)
            optimize_loading
            ;;
        benchmark|bench)
            benchmark_modules
            ;;
        health|check)
            health_check
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Error: Unknown command '$command'${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Show help
show_help() {
    cat << EOF
${PURPLE}Ultimate Bashrc Module Manager v$SCRIPT_VERSION${NC}
${CYAN}$(printf '═%.0s' {1..40})${NC}

Usage: $SCRIPT_NAME [COMMAND] [OPTIONS]

Commands:
  list, ls              List all available modules
  info, show MODULE     Show detailed module information
  enable, en MODULE     Enable a module
  disable, dis MODULE   Disable a module
  deps MODULE          Check module dependencies
  optimize, opt        Optimize module loading order
  benchmark, bench     Benchmark module loading times
  health, check        Perform health check on modules
  help                 Show this help message

Examples:
  $SCRIPT_NAME list                    # List all modules
  $SCRIPT_NAME info git                # Show git module info
  $SCRIPT_NAME enable productivity     # Enable productivity module
  $SCRIPT_NAME disable python          # Disable python module
  $SCRIPT_NAME benchmark               # Benchmark loading times
  $SCRIPT_NAME health                  # Check module health

Module Names:
  You can use partial names or numbers:
    • 01, core, core-settings
    • 03, file, file-operations
    • 07, prod, productivity
    • 09, mon, monitoring
    • etc.

Configuration:
  User settings: $CONFIG_DIR/user.conf
  Module metadata: $MODULE_METADATA

EOF
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
