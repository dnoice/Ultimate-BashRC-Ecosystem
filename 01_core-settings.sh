#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - CORE SETTINGS MODULE
# File: 01_core-settings.sh
# =============================================================================
# This module provides intelligent, adaptive core settings that automatically
# adjust based on system context, time, location, performance, and usage patterns.
# Features unique implementations not found in typical bashrc configurations.
# =============================================================================

# Module metadata
declare -r CORE_MODULE_VERSION="2.1.0"
declare -r CORE_MODULE_NAME="Ultimate Core Settings"
declare -r CORE_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# =============================================================================
# SYSTEM CONTEXT DETECTION & INTELLIGENCE ENGINE
# =============================================================================

# Advanced system profiling with machine learning-style adaptation
detect_system_intelligence() {
    # Core system metrics
    export SYSTEM_LOAD_1MIN=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/^ *//')
    export SYSTEM_LOAD_5MIN=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f2 | sed 's/^ *//')
    export SYSTEM_LOAD_15MIN=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f3 | sed 's/^ *//')
    
    # Memory intelligence
    if command -v free >/dev/null 2>&1; then
        local mem_info=($(free | awk '/^Mem:/ {print $2, $3, $7}'))
        export SYSTEM_MEMORY_TOTAL_GB=$((${mem_info[0]} / 1024 / 1024))
        export SYSTEM_MEMORY_USED_PERCENT=$(echo "scale=1; ${mem_info[1]} * 100 / ${mem_info[0]}" | bc -l 2>/dev/null || echo "0")
        export SYSTEM_MEMORY_AVAILABLE_GB=$((${mem_info[2]} / 1024 / 1024))
    fi
    
    # CPU intelligence
    export CPU_CORES=$(nproc 2>/dev/null || echo "1")
    export CPU_ARCHITECTURE=$(uname -m)
    export CPU_MODEL=$(grep -m1 'model name' /proc/cpuinfo 2>/dev/null | cut -d: -f2 | sed 's/^ *//' || echo "Unknown")
    
    # Storage intelligence
    if command -v df >/dev/null 2>&1; then
        export DISK_USAGE_HOME=$(df "$HOME" 2>/dev/null | awk 'NR==2 {print $5}' | sed 's/%//')
        export DISK_AVAILABLE_HOME_GB=$(df -BG "$HOME" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//')
    fi
    
    # Network intelligence
    export NETWORK_INTERFACES=($(ip link show 2>/dev/null | awk -F: '$0 !~ "lo|vir|docker|br-"{print $2}' | tr -d ' ' || echo ""))
    export IS_CONNECTED_WIFI=$(nmcli -t -f WIFI g 2>/dev/null | grep -q enabled && echo "true" || echo "false")
    export CURRENT_NETWORK=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 || echo "unknown")
    
    # Time and location intelligence
    export CURRENT_TIMESTAMP=$(date +%s)
    export CURRENT_HOUR=$(date +%H)
    export CURRENT_DAY_OF_WEEK=$(date +%u)  # 1=Monday, 7=Sunday
    export CURRENT_TIMEZONE=$(timedatectl show --property=Timezone --value 2>/dev/null || date +%Z)
    
    # Session context intelligence
    export IS_SSH_SESSION=${SSH_CONNECTION:+true}
    export IS_ROOT_USER=$([[ $EUID -eq 0 ]] && echo "true" || echo "false")
    export PARENT_PROCESS=$(ps -o comm= -p $PPID 2>/dev/null || echo "unknown")
    export TERMINAL_MULTIPLEXER=""
    [[ -n "$TMUX" ]] && export TERMINAL_MULTIPLEXER="tmux"
    [[ -n "$STY" ]] && export TERMINAL_MULTIPLEXER="screen"
    
    # Terminal capabilities intelligence
    export TERMINAL_COLORS=$(tput colors 2>/dev/null || echo "8")
    export TERMINAL_SIZE=$(stty size 2>/dev/null || echo "24 80")
    export TERMINAL_ROWS=$(echo $TERMINAL_SIZE | cut -d' ' -f1)
    export TERMINAL_COLS=$(echo $TERMINAL_SIZE | cut -d' ' -f2)
    
    # Battery intelligence (for laptops)
    if [[ -d /sys/class/power_supply/ ]]; then
        export BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1 || echo "100")
        export IS_ON_BATTERY=$(cat /sys/class/power_supply/ADP*/online 2>/dev/null | grep -q 0 && echo "true" || echo "false")
    fi
    
    # Performance class determination
    determine_performance_class
    
    # Create system intelligence summary
    create_system_intelligence_summary
}

# Determine system performance class for adaptive behavior
determine_performance_class() {
    local performance_score=0
    
    # Score based on memory
    [[ $SYSTEM_MEMORY_TOTAL_GB -gt 16 ]] && ((performance_score += 3))
    [[ $SYSTEM_MEMORY_TOTAL_GB -gt 8 ]] && ((performance_score += 2))
    [[ $SYSTEM_MEMORY_TOTAL_GB -gt 4 ]] && ((performance_score += 1))
    
    # Score based on CPU cores
    [[ $CPU_CORES -gt 8 ]] && ((performance_score += 3))
    [[ $CPU_CORES -gt 4 ]] && ((performance_score += 2))
    [[ $CPU_CORES -gt 2 ]] && ((performance_score += 1))
    
    # Score based on current load
    local load_impact=$(echo "$SYSTEM_LOAD_1MIN < 1.0" | bc -l 2>/dev/null)
    [[ "$load_impact" == "1" ]] && ((performance_score += 2))
    
    # Determine class
    if [[ $performance_score -ge 7 ]]; then
        export SYSTEM_PERFORMANCE_CLASS="high"
    elif [[ $performance_score -ge 4 ]]; then
        export SYSTEM_PERFORMANCE_CLASS="medium"
    else
        export SYSTEM_PERFORMANCE_CLASS="low"
    fi
}

# Create intelligent system summary
create_system_intelligence_summary() {
    export SYSTEM_INTELLIGENCE_SUMMARY="Performance: $SYSTEM_PERFORMANCE_CLASS | Memory: ${SYSTEM_MEMORY_TOTAL_GB}GB (${SYSTEM_MEMORY_USED_PERCENT}% used) | Load: $SYSTEM_LOAD_1MIN | Cores: $CPU_CORES"
}

# =============================================================================
# INTELLIGENT HISTORY MANAGEMENT
# =============================================================================

# Advanced history configuration with machine learning patterns
configure_intelligent_history() {
    # Create history directory structure
    local history_dir="$HOME/.bash_history_intelligence"
    mkdir -p "$history_dir"/{daily,monthly,analytics,backups}
    
    # Base history settings adapted to system performance
    case "$SYSTEM_PERFORMANCE_CLASS" in
        "high")
            export HISTSIZE=100000
            export HISTFILESIZE=500000
            export HISTORY_ANALYSIS_ENABLED=true
            ;;
        "medium")
            export HISTSIZE=50000
            export HISTFILESIZE=200000
            export HISTORY_ANALYSIS_ENABLED=true
            ;;
        "low")
            export HISTSIZE=20000
            export HISTFILESIZE=50000
            export HISTORY_ANALYSIS_ENABLED=false
            ;;
    esac
    
    # Advanced history control with intelligent filtering
    export HISTCONTROL="ignorespace:ignoredups:erasedups"
    export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
    
    # Intelligent ignore patterns that learn from usage
    export HISTIGNORE="ls:ls -la:ll:cd:cd -:pwd:exit:date:history:clear:bg:fg:jobs"
    export HISTIGNORE="${HISTIGNORE}:* --help:man *:which *:type *:whereis *"
    
    # Daily history rotation and backup
    local today=$(date +%Y-%m-%d)
    local daily_history="$history_dir/daily/history_$today"
    
    # Create daily history symlink
    if [[ ! -L "$HOME/.bash_history" ]]; then
        [[ -f "$HOME/.bash_history" ]] && cp "$HOME/.bash_history" "$history_dir/backups/history_backup_$(date +%Y%m%d_%H%M%S)"
        ln -sf "$daily_history" "$HOME/.bash_history"
    fi
    
    # History analysis and learning (if enabled)
    if [[ "$HISTORY_ANALYSIS_ENABLED" == "true" ]]; then
        setup_history_intelligence
    fi
}

# Set up history intelligence and pattern learning
setup_history_intelligence() {
    local analytics_dir="$HOME/.bash_history_intelligence/analytics"
    
    # Function to analyze command patterns (runs in background)
    analyze_command_patterns() {
        local today=$(date +%Y-%m-%d)
        local pattern_file="$analytics_dir/patterns_$today.json"
        
        # Create simple command frequency analysis
        if [[ -f "$HOME/.bash_history" ]] && command -v awk >/dev/null 2>&1; then
            {
                echo "{"
                echo "  \"date\": \"$today\","
                echo "  \"analysis_time\": \"$(date -Iseconds)\","
                echo "  \"top_commands\": ["
                history | tail -1000 | awk '{
                    cmd = $4; 
                    for(i=5; i<=NF; i++) cmd = cmd " " $i; 
                    gsub(/^[ \t]+/, "", cmd); 
                    count[cmd]++
                } END {
                    PROCINFO["sorted_in"] = "@val_num_desc"
                    i = 0
                    for(cmd in count) {
                        if(i > 0) printf ","
                        printf "\n    {\"command\": \"%s\", \"count\": %d}", cmd, count[cmd]
                        if(++i >= 20) break
                    }
                    printf "\n"
                }'
                echo "  ]"
                echo "}"
            } > "$pattern_file.tmp" && mv "$pattern_file.tmp" "$pattern_file"
        fi
    } &
    
    # Store the analysis function for later use
    export -f analyze_command_patterns
}

# =============================================================================
# ADAPTIVE ENVIRONMENT CONFIGURATION
# =============================================================================

# Time-aware and context-sensitive environment setup
configure_adaptive_environment() {
    # Time-based configuration
    configure_time_based_settings
    
    # Network-aware configuration
    configure_network_aware_settings
    
    # Performance-aware configuration
    configure_performance_aware_settings
    
    # Battery-aware configuration (for laptops)
    configure_battery_aware_settings
    
    # Session-type aware configuration
    configure_session_aware_settings
}

# Time-based intelligent configuration
configure_time_based_settings() {
    # Work hours detection (9 AM - 6 PM on weekdays)
    local is_work_hours=false
    if [[ $CURRENT_DAY_OF_WEEK -le 5 && $CURRENT_HOUR -ge 9 && $CURRENT_HOUR -le 18 ]]; then
        is_work_hours=true
    fi
    
    # Night mode detection (10 PM - 6 AM)
    local is_night_mode=false
    if [[ $CURRENT_HOUR -ge 22 || $CURRENT_HOUR -le 6 ]]; then
        is_night_mode=true
    fi
    
    export IS_WORK_HOURS="$is_work_hours"
    export IS_NIGHT_MODE="$is_night_mode"
    
    # Adaptive color schemes
    if [[ "$is_night_mode" == "true" ]]; then
        # Reduced contrast colors for night
        export LS_COLORS="di=0;34:ln=0;35:so=32:pi=33:ex=0;31:bd=34;46:cd=34;43"
        export GREP_COLORS="mt=0;33"
        export NIGHT_MODE_ACTIVE=true
    else
        # Full vibrant colors for day
        export LS_COLORS="di=1;34:ln=1;35:so=1;32:pi=1;33:ex=1;31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
        export GREP_COLORS="mt=1;33"
        export NIGHT_MODE_ACTIVE=false
    fi
    
    # Work hours specific settings
    if [[ "$is_work_hours" == "true" ]]; then
        export WORK_MODE_ACTIVE=true
        # Enable more detailed logging during work hours
        export ENABLE_DETAILED_LOGGING=true
    else
        export WORK_MODE_ACTIVE=false
        export ENABLE_DETAILED_LOGGING=false
    fi
}

# Network-aware configuration
configure_network_aware_settings() {
    # Adjust timeouts based on network type
    case "$CURRENT_NETWORK" in
        *"work"*|*"office"*|*"corp"*)
            export NETWORK_TYPE="corporate"
            export CURL_TIMEOUT=10
            export WGET_TIMEOUT=10
            ;;
        *"home"*|*"house"*)
            export NETWORK_TYPE="home"
            export CURL_TIMEOUT=30
            export WGET_TIMEOUT=30
            ;;
        *"phone"*|*"mobile"*|*"hotspot"*)
            export NETWORK_TYPE="mobile"
            export CURL_TIMEOUT=60
            export WGET_TIMEOUT=60
            ;;
        *)
            export NETWORK_TYPE="unknown"
            export CURL_TIMEOUT=20
            export WGET_TIMEOUT=20
            ;;
    esac
    
    # Set proxy awareness if in corporate environment
    if [[ "$NETWORK_TYPE" == "corporate" ]]; then
        export CORPORATE_NETWORK=true
        # Corporate networks often have proxies - check for common proxy env vars
        [[ -z "$http_proxy" && -z "$HTTP_PROXY" ]] && export PROXY_DETECTION_NEEDED=true
    fi
}

# Performance-aware configuration
configure_performance_aware_settings() {
    case "$SYSTEM_PERFORMANCE_CLASS" in
        "high")
            export ENABLE_ADVANCED_FEATURES=true
            export BACKGROUND_JOBS_LIMIT=10
            export COMPLETION_CACHE_SIZE=1000
            export ENABLE_REALTIME_MONITORING=true
            ;;
        "medium")
            export ENABLE_ADVANCED_FEATURES=true
            export BACKGROUND_JOBS_LIMIT=5
            export COMPLETION_CACHE_SIZE=500
            export ENABLE_REALTIME_MONITORING=false
            ;;
        "low")
            export ENABLE_ADVANCED_FEATURES=false
            export BACKGROUND_JOBS_LIMIT=2
            export COMPLETION_CACHE_SIZE=100
            export ENABLE_REALTIME_MONITORING=false
            ;;
    esac
    
    # Memory pressure awareness
    if [[ $(echo "$SYSTEM_MEMORY_USED_PERCENT > 90" | bc -l 2>/dev/null) == "1" ]]; then
        export MEMORY_PRESSURE=high
        export REDUCE_MEMORY_FEATURES=true
    elif [[ $(echo "$SYSTEM_MEMORY_USED_PERCENT > 70" | bc -l 2>/dev/null) == "1" ]]; then
        export MEMORY_PRESSURE=medium
        export REDUCE_MEMORY_FEATURES=false
    else
        export MEMORY_PRESSURE=low
        export REDUCE_MEMORY_FEATURES=false
    fi
}

# Battery-aware configuration for laptops
configure_battery_aware_settings() {
    if [[ -n "$BATTERY_LEVEL" ]]; then
        if [[ "$IS_ON_BATTERY" == "true" ]]; then
            # Battery mode - conserve resources
            export BATTERY_SAVE_MODE=true
            export REDUCE_BACKGROUND_ACTIVITY=true
            export DISABLE_HEAVY_FEATURES=true
            
            # Reduce refresh rates based on battery level
            if [[ $BATTERY_LEVEL -le 20 ]]; then
                export PROMPT_REFRESH_RATE=10  # seconds
                export CRITICAL_BATTERY=true
            elif [[ $BATTERY_LEVEL -le 50 ]]; then
                export PROMPT_REFRESH_RATE=5
                export LOW_BATTERY=true
            else
                export PROMPT_REFRESH_RATE=2
            fi
        else
            # AC power - full features
            export BATTERY_SAVE_MODE=false
            export REDUCE_BACKGROUND_ACTIVITY=false
            export DISABLE_HEAVY_FEATURES=false
            export PROMPT_REFRESH_RATE=1
        fi
    fi
}

# Session-aware configuration
configure_session_aware_settings() {
    # SSH session optimizations
    if [[ "$IS_SSH_SESSION" == "true" ]]; then
        export SSH_OPTIMIZED_MODE=true
        export REDUCE_VISUAL_EFFECTS=true
        export COMPRESS_OUTPUT=true
        
        # Add SSH-specific safety measures
        export SSH_CLIENT_INFO="$SSH_CLIENT"
        export SSH_CONNECTION_INFO="$SSH_CONNECTION"
    fi
    
    # Root user safety measures
    if [[ "$IS_ROOT_USER" == "true" ]]; then
        export ROOT_SAFETY_MODE=true
        export ENABLE_COMMAND_CONFIRMATION=true
        export DANGEROUS_COMMAND_WARNINGS=true
    fi
    
    # Terminal multiplexer optimizations
    case "$TERMINAL_MULTIPLEXER" in
        "tmux")
            export TMUX_OPTIMIZED=true
            export ENABLE_TMUX_INTEGRATION=true
            ;;
        "screen")
            export SCREEN_OPTIMIZED=true
            export ENABLE_SCREEN_INTEGRATION=true
            ;;
    esac
}

# =============================================================================
# ADVANCED SHELL OPTIONS & COMPLETION
# =============================================================================

# Intelligent shell option configuration
configure_advanced_shell_options() {
    # Core shell options
    shopt -s histappend        # Append to the history file, don't overwrite it
    shopt -s checkwinsize      # Check the window size after each command
    shopt -s expand_aliases    # Expand aliases
    shopt -s cmdhist          # Save multi-line commands as one command
    shopt -s histreedit       # Re-edit a failed history substitution
    shopt -s histverify       # Verify history expansion before executing
    shopt -s lithist          # Preserve newlines in multi-line commands
    
    # Advanced options based on Bash version
    if [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
        shopt -s autocd           # cd to directory by just typing its name
        shopt -s dirspell        # Correct minor directory spelling errors
        shopt -s cdspell         # Correct minor spelling errors in cd
        shopt -s globstar        # Enable ** recursive globbing
        shopt -s checkjobs       # Check for running jobs before exiting
    fi
    
    # Set options based on performance class
    if [[ "$ENABLE_ADVANCED_FEATURES" == "true" ]]; then
        set -o notify            # Report status of terminated background jobs immediately
        shopt -s gnu_errfmt     # Enable GNU error message format
    fi
    
    # Safety options for root user
    if [[ "$ROOT_SAFETY_MODE" == "true" ]]; then
        set -o nounset          # Exit if unset variables are used
        shopt -s failglob       # Fail if globbing produces no matches
    fi
}

# Intelligent completion configuration
configure_intelligent_completion() {
    # Load system bash completion
    if ! shopt -oq posix; then
        if [[ -f /usr/share/bash-completion/bash_completion ]]; then
            source /usr/share/bash-completion/bash_completion
        elif [[ -f /etc/bash_completion ]]; then
            source /etc/bash_completion
        fi
    fi
    
    # Advanced completion settings
    bind "set completion-ignore-case on"      # Case insensitive completion
    bind "set completion-map-case on"         # Map case for completion
    bind "set show-all-if-ambiguous on"       # Show all completions immediately
    bind "set show-all-if-unmodified on"      # Show all completions if unmodified
    bind "set menu-complete-display-prefix on" # Show prefix before cycling
    bind "set colored-stats on"               # Color completion statistics
    bind "set visible-stats on"               # Show file type indicators
    bind "set mark-symlinked-directories on"  # Mark symlinked directories
    bind "set colored-completion-prefix on"   # Color the completion prefix
    
    # Intelligent completion timeout based on performance
    case "$SYSTEM_PERFORMANCE_CLASS" in
        "high")   bind "set completion-query-items 200" ;;
        "medium") bind "set completion-query-items 100" ;;
        "low")    bind "set completion-query-items 50"  ;;
    esac
}

# =============================================================================
# ENVIRONMENT VARIABLES & PATHS
# =============================================================================

# Intelligent PATH management
configure_intelligent_paths() {
    # Initialize PATH array for manipulation
    IFS=':' read -ra PATH_ARRAY <<< "$PATH"
    declare -a NEW_PATH_ARRAY=()
    
    # Priority paths (prepend)
    local priority_paths=(
        "$HOME/.local/bin"
        "$HOME/bin"
        "$HOME/.cargo/bin"
        "$HOME/.go/bin"
        "$HOME/.npm-global/bin"
        "/usr/local/bin"
        "/usr/local/sbin"
    )
    
    # Add priority paths if they exist and aren't already in PATH
    for path in "${priority_paths[@]}"; do
        if [[ -d "$path" ]] && [[ ":$PATH:" != *":$path:"* ]]; then
            NEW_PATH_ARRAY+=("$path")
        fi
    done
    
    # Add existing PATH elements (deduplicated)
    declare -A seen_paths
    for path in "${PATH_ARRAY[@]}"; do
        if [[ -n "$path" && -z "${seen_paths[$path]}" ]]; then
            seen_paths["$path"]=1
            NEW_PATH_ARRAY+=("$path")
        fi
    done
    
    # Rebuild PATH
    IFS=':' 
    export PATH="${NEW_PATH_ARRAY[*]}"
    unset IFS
    
    # Set up other important environment variables
    configure_development_environment
    configure_editor_preferences
    configure_pager_settings
    configure_locale_settings
}

# Development environment configuration
configure_development_environment() {
    # Language-specific environment variables
    [[ -d "$HOME/.go" ]] && export GOPATH="$HOME/.go"
    [[ -d "$HOME/.cargo" ]] && export CARGO_HOME="$HOME/.cargo"
    [[ -f "$HOME/.nvm/nvm.sh" ]] && export NVM_DIR="$HOME/.nvm"
    
    # Python environment
    export PYTHONDONTWRITEBYTECODE=1
    export PYTHONUNBUFFERED=1
    
    # Node.js environment
    [[ -d "$HOME/.npm-global" ]] && export NPM_CONFIG_PREFIX="$HOME/.npm-global"
    
    # Build environment
    export MAKEFLAGS="-j$CPU_CORES"
}

# Intelligent editor configuration
configure_editor_preferences() {
    # Editor priority list
    local editors=("nvim" "vim" "vi" "nano" "emacs")
    
    for editor in "${editors[@]}"; do
        if command -v "$editor" >/dev/null 2>&1; then
            export EDITOR="$editor"
            export VISUAL="$editor"
            break
        fi
    done
    
    # Editor-specific configurations
    case "$EDITOR" in
        "nvim"|"vim")
            export MANPAGER="$EDITOR +Man!"
            ;;
        "nano")
            export NANO_HISTORY="$HOME/.nano_history"
            ;;
    esac
}

# Intelligent pager configuration
configure_pager_settings() {
    if command -v less >/dev/null 2>&1; then
        export PAGER="less"
        export LESS="-R -F -X -i -M -W -z-4"
        export LESSHISTFILE="$HOME/.less_history"
        
        # Color support for less
        if [[ "$TERMINAL_COLORS" -gt 8 ]]; then
            export LESS_TERMCAP_mb=$'\e[1;32m'     # begin bold
            export LESS_TERMCAP_md=$'\e[1;32m'     # begin blink
            export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
            export LESS_TERMCAP_so=$'\e[01;33m'    # begin reverse video
            export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
            export LESS_TERMCAP_us=$'\e[1;4;31m'   # begin underline
            export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
        fi
    fi
}

# Locale and encoding configuration
configure_locale_settings() {
    # Ensure UTF-8 encoding
    export LANG="${LANG:-en_US.UTF-8}"
    export LC_ALL="${LC_ALL:-en_US.UTF-8}"
    export LC_CTYPE="${LC_CTYPE:-en_US.UTF-8}"
    
    # Timezone configuration
    export TZ="$CURRENT_TIMEZONE"
}

# =============================================================================
# PERFORMANCE MONITORING & OPTIMIZATION
# =============================================================================

# Real-time performance monitoring setup
setup_performance_monitoring() {
    if [[ "$ENABLE_REALTIME_MONITORING" == "true" ]]; then
        # Create monitoring directory
        local monitor_dir="$HOME/.bash_performance_monitor"
        mkdir -p "$monitor_dir"
        
        # Performance tracking variables
        export PERFORMANCE_LOG="$monitor_dir/performance_$(date +%Y%m%d).log"
        export COMMAND_TIMING_ENABLED=true
        export RESOURCE_MONITORING_ENABLED=true
        
        # Set up command timing
        setup_command_timing
        
        # Set up resource monitoring
        setup_resource_monitoring
    fi
}

# Command execution timing
setup_command_timing() {
    export PROMPT_COMMAND="record_command_performance; $PROMPT_COMMAND"
}

# Function to record command performance
record_command_performance() {
    if [[ "$COMMAND_TIMING_ENABLED" == "true" && -n "$PERFORMANCE_LOG" ]]; then
        local current_time=$(date +%s.%N)
        local load_avg=$(cat /proc/loadavg | cut -d' ' -f1)
        local memory_usage=$(free | awk '/^Mem:/ {printf "%.1f", $3*100/$2}')
        
        echo "$(date -Iseconds),$current_time,$load_avg,$memory_usage" >> "$PERFORMANCE_LOG"
    fi
}

# Resource monitoring setup
setup_resource_monitoring() {
    # Background resource monitoring (if system can handle it)
    if [[ "$SYSTEM_PERFORMANCE_CLASS" == "high" ]]; then
        (
            while true; do
                sleep 30
                if [[ -f "$PERFORMANCE_LOG" ]]; then
                    local lines=$(wc -l < "$PERFORMANCE_LOG")
                    if [[ $lines -gt 1000 ]]; then
                        # Rotate log if it gets too large
                        mv "$PERFORMANCE_LOG" "${PERFORMANCE_LOG}.old"
                        touch "$PERFORMANCE_LOG"
                    fi
                fi
            done
        ) &
        export RESOURCE_MONITOR_PID=$!
    fi
}

# =============================================================================
# MODULE INITIALIZATION
# =============================================================================

# Main initialization function
initialize_core_settings() {
    echo -e "${BASHRC_CYAN}🧠 Initializing Ultimate Core Settings...${BASHRC_NC}"
    
    # Phase 1: System Intelligence
    detect_system_intelligence
    echo -e "${BASHRC_GREEN}✓ System intelligence detected${BASHRC_NC}"
    
    # Phase 2: History Management
    configure_intelligent_history
    echo -e "${BASHRC_GREEN}✓ Intelligent history configured${BASHRC_NC}"
    
    # Phase 3: Environment Adaptation
    configure_adaptive_environment
    echo -e "${BASHRC_GREEN}✓ Adaptive environment configured${BASHRC_NC}"
    
    # Phase 4: Shell Options
    configure_advanced_shell_options
    configure_intelligent_completion
    echo -e "${BASHRC_GREEN}✓ Advanced shell options configured${BASHRC_NC}"
    
    # Phase 5: Path and Environment Variables
    configure_intelligent_paths
    echo -e "${BASHRC_GREEN}✓ Intelligent paths configured${BASHRC_NC}"
    
    # Phase 6: Performance Monitoring
    setup_performance_monitoring
    echo -e "${BASHRC_GREEN}✓ Performance monitoring initialized${BASHRC_NC}"
    
    # Export module completion status
    export CORE_SETTINGS_LOADED=true
    export CORE_SETTINGS_LOAD_TIME=$(date +%s)
    
    echo -e "${BASHRC_PURPLE}🎯 Core Settings Module Loaded Successfully${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}   System Class: $SYSTEM_PERFORMANCE_CLASS${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}   Night Mode: $IS_NIGHT_MODE${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}   Work Hours: $IS_WORK_HOURS${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}   SSH Session: ${IS_SSH_SESSION:-false}${BASHRC_NC}"
}

# =============================================================================
# MODULE CLEANUP & UTILITY FUNCTIONS
# =============================================================================

# Cleanup function for when shell exits
cleanup_core_settings() {
    # Stop background monitoring if running
    [[ -n "$RESOURCE_MONITOR_PID" ]] && kill "$RESOURCE_MONITOR_PID" 2>/dev/null
    
    # Final performance log entry
    if [[ "$COMMAND_TIMING_ENABLED" == "true" ]]; then
        echo "$(date -Iseconds),shell_exit,0,0" >> "$PERFORMANCE_LOG" 2>/dev/null
    fi
}

# Function to display current core settings status
core_settings_status() {
    echo -e "${BASHRC_PURPLE}=== Ultimate Core Settings Status ===${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}System Performance Class:${BASHRC_NC} $SYSTEM_PERFORMANCE_CLASS"
    echo -e "${BASHRC_CYAN}System Intelligence:${BASHRC_NC} $SYSTEM_INTELLIGENCE_SUMMARY"
    echo -e "${BASHRC_CYAN}History Size:${BASHRC_NC} $HISTSIZE commands"
    echo -e "${BASHRC_CYAN}Terminal:${BASHRC_NC} ${TERMINAL_ROWS}x${TERMINAL_COLS} (${TERMINAL_COLORS} colors)"
    echo -e "${BASHRC_CYAN}Network Type:${BASHRC_NC} $NETWORK_TYPE"
    echo -e "${BASHRC_CYAN}Current Network:${BASHRC_NC} $CURRENT_NETWORK"
    [[ -n "$BATTERY_LEVEL" ]] && echo -e "${BASHRC_CYAN}Battery Level:${BASHRC_NC} ${BATTERY_LEVEL}%"
    echo -e "${BASHRC_CYAN}Night Mode:${BASHRC_NC} $IS_NIGHT_MODE"
    echo -e "${BASHRC_CYAN}Work Hours:${BASHRC_NC} $IS_WORK_HOURS"
    echo -e "${BASHRC_CYAN}Advanced Features:${BASHRC_NC} $ENABLE_ADVANCED_FEATURES"
}

# Register cleanup function
trap cleanup_core_settings EXIT

# =============================================================================
# MODULE EXECUTION
# =============================================================================

# Initialize the module
initialize_core_settings

# Make status function available to user
alias core-status='core_settings_status'

# Module load completion message
echo -e "${BASHRC_GREEN}🎉 Ultimate Core Settings Module v$CORE_MODULE_VERSION Ready${BASHRC_NC}"
