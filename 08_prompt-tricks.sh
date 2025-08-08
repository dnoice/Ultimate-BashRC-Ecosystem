#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - PROMPT TRICKS MODULE
# File: 08_prompt-tricks.sh
# =============================================================================
# This module provides advanced prompt customization with dynamic information,
# contextual awareness, git integration, performance indicators, system status,
# and intelligent display features that adapt to your environment.
# =============================================================================

# Module metadata
declare -r PROMPT_MODULE_VERSION="2.1.0"
declare -r PROMPT_MODULE_NAME="Prompt Tricks"
declare -r PROMPT_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# Module initialization
echo -e "${BASHRC_CYAN}💫 Loading Prompt Tricks...${BASHRC_NC}"

# =============================================================================
# DYNAMIC PROMPT SYSTEM CORE
# =============================================================================

# Main prompt configuration system
promptconfig() {
    local usage="Usage: promptconfig [COMMAND] [OPTIONS]
    
💫 Advanced Prompt Configuration System
Commands:
    theme       Set prompt theme
    enable      Enable prompt components  
    disable     Disable prompt components
    status      Show current prompt configuration
    reset       Reset to default prompt
    preview     Preview prompt themes
    custom      Create custom prompt
    save        Save current configuration
    load        Load saved configuration
    
Themes:
    minimal     Clean, minimal prompt
    standard    Balanced information display
    developer   Developer-focused with git/tools
    power       Maximum information display
    retro       Classic terminal styling
    neon        Colorful, modern styling
    
Components:
    git         Git repository information
    time        Current time display
    load        System load average
    battery     Battery status (laptops)
    network     Network connection status
    tasks       Active task count
    jobs        Background job count
    conda       Conda environment
    venv        Python virtual environment
    docker      Docker context
    k8s         Kubernetes context
    
Examples:
    promptconfig theme developer
    promptconfig enable git battery network
    promptconfig disable time load
    promptconfig preview
    promptconfig save myconfig"

    local command="${1:-status}"
    [[ "$command" =~ ^(theme|enable|disable|status|reset|preview|custom|save|load)$ ]] && shift || command="status"
    
    case "$command" in
        theme)      prompt_set_theme "$@" ;;
        enable)     prompt_enable_components "$@" ;;
        disable)    prompt_disable_components "$@" ;;
        status)     prompt_show_status "$@" ;;
        reset)      prompt_reset "$@" ;;
        preview)    prompt_preview "$@" ;;
        custom)     prompt_custom "$@" ;;
        save)       prompt_save_config "$@" ;;
        load)       prompt_load_config "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Set prompt theme
prompt_set_theme() {
    local theme="$1"
    [[ -z "$theme" ]] && { echo "Theme required"; return 1; }
    
    case "$theme" in
        minimal)    setup_minimal_theme ;;
        standard)   setup_standard_theme ;;
        developer)  setup_developer_theme ;;
        power)      setup_power_theme ;;
        retro)      setup_retro_theme ;;
        neon)       setup_neon_theme ;;
        *)          echo "Unknown theme: $theme"; return 1 ;;
    esac
    
    export CURRENT_PROMPT_THEME="$theme"
    echo -e "🎨 Prompt theme set to: $theme"
    
    # Save theme preference
    local prompt_dir="$HOME/.bash_prompt_config"
    mkdir -p "$prompt_dir"
    echo "CURRENT_PROMPT_THEME=$theme" > "$prompt_dir/theme.conf"
}

# Enable prompt components
prompt_enable_components() {
    local components=("$@")
    [[ ${#components[@]} -eq 0 ]] && { echo "Component(s) required"; return 1; }
    
    for component in "${components[@]}"; do
        case "$component" in
            git|time|load|battery|network|tasks|jobs|conda|venv|docker|k8s)
                export "PROMPT_SHOW_${component^^}"=true
                echo -e "✅ Enabled: $component"
                ;;
            *)
                echo -e "❌ Unknown component: $component"
                ;;
        esac
    done
    
    save_component_config
    refresh_prompt
}

# Disable prompt components
prompt_disable_components() {
    local components=("$@")
    [[ ${#components[@]} -eq 0 ]] && { echo "Component(s) required"; return 1; }
    
    for component in "${components[@]}"; do
        case "$component" in
            git|time|load|battery|network|tasks|jobs|conda|venv|docker|k8s)
                export "PROMPT_SHOW_${component^^}"=false
                echo -e "❌ Disabled: $component"
                ;;
            *)
                echo -e "❌ Unknown component: $component"
                ;;
        esac
    done
    
    save_component_config
    refresh_prompt
}

# Show current prompt status
prompt_show_status() {
    echo -e "💫 Current Prompt Configuration"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
    
    echo -e "🎨 Theme: ${CURRENT_PROMPT_THEME:-standard}"
    echo
    
    echo -e "📋 Components:"
    local components=(git time load battery network tasks jobs conda venv docker k8s)
    for component in "${components[@]}"; do
        local var_name="PROMPT_SHOW_${component^^}"
        local status="${!var_name:-false}"
        local icon="❌"
        [[ "$status" == "true" ]] && icon="✅"
        echo -e "   $icon $component"
    done
    
    echo
    echo -e "💡 Current prompt preview:"
    generate_sample_prompt
}

# =============================================================================
# PROMPT THEMES
# =============================================================================

# Minimal theme - Clean and simple
setup_minimal_theme() {
    export PROMPT_SHOW_GIT=true
    export PROMPT_SHOW_TIME=false
    export PROMPT_SHOW_LOAD=false
    export PROMPT_SHOW_BATTERY=false
    export PROMPT_SHOW_NETWORK=false
    export PROMPT_SHOW_TASKS=false
    export PROMPT_SHOW_JOBS=false
    export PROMPT_SHOW_CONDA=true
    export PROMPT_SHOW_VENV=true
    export PROMPT_SHOW_DOCKER=false
    export PROMPT_SHOW_K8S=false
    
    setup_prompt_function "minimal"
}

# Standard theme - Balanced information
setup_standard_theme() {
    export PROMPT_SHOW_GIT=true
    export PROMPT_SHOW_TIME=true
    export PROMPT_SHOW_LOAD=false
    export PROMPT_SHOW_BATTERY=true
    export PROMPT_SHOW_NETWORK=false
    export PROMPT_SHOW_TASKS=true
    export PROMPT_SHOW_JOBS=true
    export PROMPT_SHOW_CONDA=true
    export PROMPT_SHOW_VENV=true
    export PROMPT_SHOW_DOCKER=true
    export PROMPT_SHOW_K8S=false
    
    setup_prompt_function "standard"
}

# Developer theme - Development-focused
setup_developer_theme() {
    export PROMPT_SHOW_GIT=true
    export PROMPT_SHOW_TIME=false
    export PROMPT_SHOW_LOAD=true
    export PROMPT_SHOW_BATTERY=false
    export PROMPT_SHOW_NETWORK=true
    export PROMPT_SHOW_TASKS=true
    export PROMPT_SHOW_JOBS=true
    export PROMPT_SHOW_CONDA=true
    export PROMPT_SHOW_VENV=true
    export PROMPT_SHOW_DOCKER=true
    export PROMPT_SHOW_K8S=true
    
    setup_prompt_function "developer"
}

# Power theme - Maximum information
setup_power_theme() {
    export PROMPT_SHOW_GIT=true
    export PROMPT_SHOW_TIME=true
    export PROMPT_SHOW_LOAD=true
    export PROMPT_SHOW_BATTERY=true
    export PROMPT_SHOW_NETWORK=true
    export PROMPT_SHOW_TASKS=true
    export PROMPT_SHOW_JOBS=true
    export PROMPT_SHOW_CONDA=true
    export PROMPT_SHOW_VENV=true
    export PROMPT_SHOW_DOCKER=true
    export PROMPT_SHOW_K8S=true
    
    setup_prompt_function "power"
}

# Retro theme - Classic terminal styling
setup_retro_theme() {
    export PROMPT_SHOW_GIT=true
    export PROMPT_SHOW_TIME=true
    export PROMPT_SHOW_LOAD=false
    export PROMPT_SHOW_BATTERY=false
    export PROMPT_SHOW_NETWORK=false
    export PROMPT_SHOW_TASKS=false
    export PROMPT_SHOW_JOBS=true
    export PROMPT_SHOW_CONDA=true
    export PROMPT_SHOW_VENV=true
    export PROMPT_SHOW_DOCKER=false
    export PROMPT_SHOW_K8S=false
    
    setup_prompt_function "retro"
}

# Neon theme - Colorful and modern
setup_neon_theme() {
    export PROMPT_SHOW_GIT=true
    export PROMPT_SHOW_TIME=true
    export PROMPT_SHOW_LOAD=true
    export PROMPT_SHOW_BATTERY=true
    export PROMPT_SHOW_NETWORK=true
    export PROMPT_SHOW_TASKS=true
    export PROMPT_SHOW_JOBS=true
    export PROMPT_SHOW_CONDA=true
    export PROMPT_SHOW_VENV=true
    export PROMPT_SHOW_DOCKER=true
    export PROMPT_SHOW_K8S=true
    
    setup_prompt_function "neon"
}

# =============================================================================
# DYNAMIC PROMPT COMPONENTS
# =============================================================================

# Git status component
get_git_info() {
    [[ "$PROMPT_SHOW_GIT" != "true" ]] && return
    
    # Check if in git repository
    git rev-parse --git-dir >/dev/null 2>&1 || return
    
    local branch=""
    local git_status=""
    local git_info=""
    
    # Get current branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    
    # Get repository status
    local status_output=$(git status --porcelain 2>/dev/null)
    local ahead_behind=$(git status --porcelain=v1 --branch 2>/dev/null | head -1)
    
    # Parse status indicators
    local staged=0 modified=0 untracked=0
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        case "${line:0:1}" in
            A|M|D|R|C) ((staged++)) ;;
        esac
        case "${line:1:1}" in
            M|D) ((modified++)) ;;
            \?) ((untracked++)) ;;
        esac
    done <<< "$status_output"
    
    # Build status string
    local status_parts=()
    [[ $staged -gt 0 ]] && status_parts+=("${staged}S")
    [[ $modified -gt 0 ]] && status_parts+=("${modified}M")  
    [[ $untracked -gt 0 ]] && status_parts+=("${untracked}U")
    
    # Check for ahead/behind
    local ahead_behind_info=""
    if [[ "$ahead_behind" =~ \[ahead\ ([0-9]+)\] ]]; then
        ahead_behind_info="↑${BASH_REMATCH[1]}"
    fi
    if [[ "$ahead_behind" =~ \[behind\ ([0-9]+)\] ]]; then
        ahead_behind_info="${ahead_behind_info}↓${BASH_REMATCH[1]}"
    fi
    
    # Color coding based on status
    local git_color=""
    if [[ ${#status_parts[@]} -eq 0 ]]; then
        git_color="\[\e[32m\]" # Green - clean
    elif [[ $staged -gt 0 ]]; then
        git_color="\[\e[33m\]" # Yellow - staged changes
    else
        git_color="\[\e[31m\]" # Red - unstaged changes
    fi
    
    # Format git info
    git_info="$git_color$branch"
    [[ ${#status_parts[@]} -gt 0 ]] && git_info="${git_info}[${status_parts[*]}]"
    [[ -n "$ahead_behind_info" ]] && git_info="${git_info}$ahead_behind_info"
    git_info="${git_info}\[\e[0m\]"
    
    echo "$git_info"
}

# Time component
get_time_info() {
    [[ "$PROMPT_SHOW_TIME" != "true" ]] && return
    echo "\[\e[36m\]$(date +%H:%M:%S)\[\e[0m\]"
}

# System load component
get_load_info() {
    [[ "$PROMPT_SHOW_LOAD" != "true" ]] && return
    
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | sed 's/^ *//')
    local load_color=""
    
    # Color based on load (assuming 4 core system)
    local load_num=$(echo "$load_avg" | cut -d'.' -f1)
    if [[ $load_num -ge 3 ]]; then
        load_color="\[\e[31m\]" # Red - high load
    elif [[ $load_num -ge 1 ]]; then
        load_color="\[\e[33m\]" # Yellow - medium load
    else
        load_color="\[\e[32m\]" # Green - low load
    fi
    
    echo "${load_color}${load_avg}\[\e[0m\]"
}

# Battery component
get_battery_info() {
    [[ "$PROMPT_SHOW_BATTERY" != "true" ]] && return
    
    # Check if battery exists
    local battery_path="/sys/class/power_supply/BAT0"
    [[ ! -d "$battery_path" ]] && return
    
    local capacity=$(cat "$battery_path/capacity" 2>/dev/null)
    local status=$(cat "$battery_path/status" 2>/dev/null)
    
    [[ -z "$capacity" ]] && return
    
    local battery_icon="🔋"
    local battery_color=""
    
    # Icon and color based on capacity and status
    if [[ "$status" == "Charging" ]]; then
        battery_icon="⚡"
        battery_color="\[\e[32m\]"
    elif [[ $capacity -le 20 ]]; then
        battery_icon="🪫"
        battery_color="\[\e[31m\]"
    elif [[ $capacity -le 50 ]]; then
        battery_color="\[\e[33m\]"
    else
        battery_color="\[\e[32m\]"
    fi
    
    echo "${battery_color}${battery_icon}${capacity}%\[\e[0m\]"
}

# Network connection component
get_network_info() {
    [[ "$PROMPT_SHOW_NETWORK" != "true" ]] && return
    
    # Check network connectivity (simplified)
    local connected=false
    local network_icon="📶"
    local network_color="\[\e[32m\]"
    
    # Quick connectivity check
    if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
        connected=true
        network_color="\[\e[32m\]"
        network_icon="📶"
    else
        connected=false
        network_color="\[\e[31m\]"
        network_icon="📵"
    fi
    
    # Get current network (if available)
    local current_network=""
    if command -v nmcli >/dev/null 2>&1; then
        current_network=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2 | head -1)
        [[ -n "$current_network" ]] && current_network=" ($current_network)"
    fi
    
    echo "${network_color}${network_icon}${current_network}\[\e[0m\]"
}

# Active tasks component
get_tasks_info() {
    [[ "$PROMPT_SHOW_TASKS" != "true" ]] && return
    
    local tasks_file="$HOME/.bash_productivity/tasks.csv"
    [[ ! -f "$tasks_file" ]] && return
    
    local active_tasks=$(awk -F',' '$8=="todo" || $8=="doing" {count++} END {print count+0}' "$tasks_file" 2>/dev/null)
    [[ $active_tasks -eq 0 ]] && return
    
    echo "\[\e[35m\]✓${active_tasks}\[\e[0m\]"
}

# Background jobs component
get_jobs_info() {
    [[ "$PROMPT_SHOW_JOBS" != "true" ]] && return
    
    local job_count=$(jobs -r | wc -l)
    [[ $job_count -eq 0 ]] && return
    
    echo "\[\e[33m\]&${job_count}\[\e[0m\]"
}

# Conda environment component
get_conda_info() {
    [[ "$PROMPT_SHOW_CONDA" != "true" ]] && return
    [[ -z "$CONDA_DEFAULT_ENV" ]] && return
    [[ "$CONDA_DEFAULT_ENV" == "base" ]] && return
    
    echo "\[\e[36m\](conda:$CONDA_DEFAULT_ENV)\[\e[0m\]"
}

# Python virtual environment component
get_venv_info() {
    [[ "$PROMPT_SHOW_VENV" != "true" ]] && return
    [[ -z "$VIRTUAL_ENV" ]] && return
    
    local venv_name=$(basename "$VIRTUAL_ENV")
    echo "\[\e[36m\](venv:$venv_name)\[\e[0m\]"
}

# Docker context component
get_docker_info() {
    [[ "$PROMPT_SHOW_DOCKER" != "true" ]] && return
    
    # Check if docker is available and context is not default
    if command -v docker >/dev/null 2>&1; then
        local docker_context=$(docker context show 2>/dev/null)
        [[ -n "$docker_context" && "$docker_context" != "default" ]] && {
            echo "\[\e[34m\]🐳${docker_context}\[\e[0m\]"
        }
    fi
}

# Kubernetes context component
get_k8s_info() {
    [[ "$PROMPT_SHOW_K8S" != "true" ]] && return
    
    # Check if kubectl is available
    if command -v kubectl >/dev/null 2>&1; then
        local k8s_context=$(kubectl config current-context 2>/dev/null)
        [[ -n "$k8s_context" ]] && {
            # Shorten context name if too long
            [[ ${#k8s_context} -gt 15 ]] && k8s_context="${k8s_context:0:12}..."
            echo "\[\e[34m\]☸️${k8s_context}\[\e[0m\]"
        }
    fi
}

# =============================================================================
# PROMPT ASSEMBLY ENGINE
# =============================================================================

# Main prompt building function
build_dynamic_prompt() {
    local theme="${CURRENT_PROMPT_THEME:-standard}"
    local prompt_parts=()
    
    # Collect all enabled components
    local time_info=$(get_time_info)
    local load_info=$(get_load_info)
    local battery_info=$(get_battery_info)
    local network_info=$(get_network_info)
    local tasks_info=$(get_tasks_info)
    local jobs_info=$(get_jobs_info)
    local conda_info=$(get_conda_info)
    local venv_info=$(get_venv_info)
    local docker_info=$(get_docker_info)
    local k8s_info=$(get_k8s_info)
    local git_info=$(get_git_info)
    
    # Build prompt based on theme
    case "$theme" in
        minimal)
            build_minimal_prompt "$git_info" "$conda_info" "$venv_info"
            ;;
        standard)
            build_standard_prompt "$time_info" "$battery_info" "$tasks_info" "$jobs_info" "$conda_info" "$venv_info" "$docker_info" "$git_info"
            ;;
        developer)
            build_developer_prompt "$load_info" "$network_info" "$tasks_info" "$jobs_info" "$conda_info" "$venv_info" "$docker_info" "$k8s_info" "$git_info"
            ;;
        power)
            build_power_prompt "$time_info" "$load_info" "$battery_info" "$network_info" "$tasks_info" "$jobs_info" "$conda_info" "$venv_info" "$docker_info" "$k8s_info" "$git_info"
            ;;
        retro)
            build_retro_prompt "$time_info" "$jobs_info" "$conda_info" "$venv_info" "$git_info"
            ;;
        neon)
            build_neon_prompt "$time_info" "$load_info" "$battery_info" "$network_info" "$tasks_info" "$jobs_info" "$conda_info" "$venv_info" "$docker_info" "$k8s_info" "$git_info"
            ;;
        *)
            build_standard_prompt "$time_info" "$battery_info" "$tasks_info" "$jobs_info" "$conda_info" "$venv_info" "$docker_info" "$git_info"
            ;;
    esac
}

# Minimal prompt theme
build_minimal_prompt() {
    local git_info="$1" conda_info="$2" venv_info="$3"
    
    local prompt=""
    
    # Environment info on same line
    [[ -n "$conda_info" ]] && prompt="${prompt}${conda_info} "
    [[ -n "$venv_info" ]] && prompt="${prompt}${venv_info} "
    
    # Directory and git on main line
    prompt="${prompt}\[\e[34m\]\w\[\e[0m\]"
    [[ -n "$git_info" ]] && prompt="${prompt} ${git_info}"
    prompt="${prompt} \$ "
    
    PS1="$prompt"
}

# Standard prompt theme
build_standard_prompt() {
    local time_info="$1" battery_info="$2" tasks_info="$3" jobs_info="$4"
    local conda_info="$5" venv_info="$6" docker_info="$7" git_info="$8"
    
    local prompt=""
    local info_line=""
    
    # Top info line
    local top_parts=()
    [[ -n "$time_info" ]] && top_parts+=("$time_info")
    [[ -n "$battery_info" ]] && top_parts+=("$battery_info")
    [[ -n "$tasks_info" ]] && top_parts+=("$tasks_info")
    [[ -n "$jobs_info" ]] && top_parts+=("$jobs_info")
    
    if [[ ${#top_parts[@]} -gt 0 ]]; then
        info_line=$(IFS=' │ '; echo "${top_parts[*]}")
        prompt="┌─ $info_line\n"
    fi
    
    # Environment info
    [[ -n "$conda_info" ]] && prompt="${prompt}${conda_info} "
    [[ -n "$venv_info" ]] && prompt="${prompt}${venv_info} "
    [[ -n "$docker_info" ]] && prompt="${prompt}${docker_info} "
    
    # Main prompt line
    prompt="${prompt}└─ \[\e[32m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[0m\]"
    [[ -n "$git_info" ]] && prompt="${prompt} ${git_info}"
    prompt="${prompt} \$ "
    
    PS1="$prompt"
}

# Developer prompt theme
build_developer_prompt() {
    local load_info="$1" network_info="$2" tasks_info="$3" jobs_info="$4"
    local conda_info="$5" venv_info="$6" docker_info="$7" k8s_info="$8" git_info="$9"
    
    local prompt=""
    
    # System status line
    local status_parts=()
    [[ -n "$load_info" ]] && status_parts+=("⚡$load_info")
    [[ -n "$network_info" ]] && status_parts+=("$network_info")
    [[ -n "$tasks_info" ]] && status_parts+=("$tasks_info")
    [[ -n "$jobs_info" ]] && status_parts+=("$jobs_info")
    
    if [[ ${#status_parts[@]} -gt 0 ]]; then
        local status_line=$(IFS=' '; echo "${status_parts[*]}")
        prompt="╭─ $status_line\n"
    fi
    
    # Environment line
    local env_parts=()
    [[ -n "$conda_info" ]] && env_parts+=("$conda_info")
    [[ -n "$venv_info" ]] && env_parts+=("$venv_info")
    [[ -n "$docker_info" ]] && env_parts+=("$docker_info")
    [[ -n "$k8s_info" ]] && env_parts+=("$k8s_info")
    
    if [[ ${#env_parts[@]} -gt 0 ]]; then
        local env_line=$(IFS=' '; echo "${env_parts[*]}")
        prompt="${prompt}├─ $env_line\n"
    fi
    
    # Main prompt
    prompt="${prompt}╰─ \[\e[35m\]\u\[\e[0m\] \[\e[34m\]\w\[\e[0m\]"
    [[ -n "$git_info" ]] && prompt="${prompt} ${git_info}"
    prompt="${prompt}\n└─▶ "
    
    PS1="$prompt"
}

# Power prompt theme
build_power_prompt() {
    local time_info="$1" load_info="$2" battery_info="$3" network_info="$4"
    local tasks_info="$5" jobs_info="$6" conda_info="$7" venv_info="$8"
    local docker_info="$9" k8s_info="${10}" git_info="${11}"
    
    local prompt=""
    
    # Top system info bar
    local sys_parts=()
    [[ -n "$time_info" ]] && sys_parts+=("⏰$time_info")
    [[ -n "$load_info" ]] && sys_parts+=("⚡$load_info")
    [[ -n "$battery_info" ]] && sys_parts+=("$battery_info")
    [[ -n "$network_info" ]] && sys_parts+=("$network_info")
    
    if [[ ${#sys_parts[@]} -gt 0 ]]; then
        local sys_line=$(IFS=' │ '; echo "${sys_parts[*]}")
        prompt="╔══ $sys_line\n"
    fi
    
    # Task/Job status
    local task_parts=()
    [[ -n "$tasks_info" ]] && task_parts+=("$tasks_info")
    [[ -n "$jobs_info" ]] && task_parts+=("$jobs_info")
    
    if [[ ${#task_parts[@]} -gt 0 ]]; then
        local task_line=$(IFS=' '; echo "${task_parts[*]}")
        prompt="${prompt}╠══ $task_line\n"
    fi
    
    # Environment status
    local env_parts=()
    [[ -n "$conda_info" ]] && env_parts+=("$conda_info")
    [[ -n "$venv_info" ]] && env_parts+=("$venv_info")
    [[ -n "$docker_info" ]] && env_parts+=("$docker_info")
    [[ -n "$k8s_info" ]] && env_parts+=("$k8s_info")
    
    if [[ ${#env_parts[@]} -gt 0 ]]; then
        local env_line=$(IFS=' '; echo "${env_parts[*]}")
        prompt="${prompt}╠══ $env_line\n"
    fi
    
    # Main command line
    prompt="${prompt}╚══ \[\e[32m\]\u@\h\[\e[0m\] \[\e[34m\]\w\[\e[0m\]"
    [[ -n "$git_info" ]] && prompt="${prompt} ${git_info}"
    prompt="${prompt}\n └─▶ "
    
    PS1="$prompt"
}

# Retro prompt theme
build_retro_prompt() {
    local time_info="$1" jobs_info="$2" conda_info="$3" venv_info="$4" git_info="$5"
    
    local prompt=""
    
    # Classic style with brackets
    prompt="["
    [[ -n "$time_info" ]] && prompt="${prompt}${time_info} "
    prompt="${prompt}\u@\h"
    [[ -n "$jobs_info" ]] && prompt="${prompt} ${jobs_info}"
    prompt="${prompt}] "
    
    [[ -n "$conda_info" ]] && prompt="${prompt}${conda_info} "
    [[ -n "$venv_info" ]] && prompt="${prompt}${venv_info} "
    
    prompt="${prompt}\w"
    [[ -n "$git_info" ]] && prompt="${prompt} ${git_info}"
    prompt="${prompt} $ "
    
    PS1="$prompt"
}

# Neon prompt theme
build_neon_prompt() {
    local time_info="$1" load_info="$2" battery_info="$3" network_info="$4"
    local tasks_info="$5" jobs_info="$6" conda_info="$7" venv_info="$8"
    local docker_info="$9" k8s_info="${10}" git_info="${11}"
    
    local prompt=""
    
    # Neon-style with bright colors and symbols
    prompt="\[\e[1;35m\]▓▓▓\[\e[0m\] "
    
    # System status with neon colors
    local status_parts=()
    [[ -n "$time_info" ]] && status_parts+=("\[\e[1;36m\]⏰\[\e[0m\]$time_info")
    [[ -n "$load_info" ]] && status_parts+=("\[\e[1;33m\]⚡\[\e[0m\]$load_info")
    [[ -n "$battery_info" ]] && status_parts+=("$battery_info")
    [[ -n "$network_info" ]] && status_parts+=("$network_info")
    [[ -n "$tasks_info" ]] && status_parts+=("\[\e[1;35m\]✓\[\e[0m\]$tasks_info")
    [[ -n "$jobs_info" ]] && status_parts+=("\[\e[1;33m\]&\[\e[0m\]$jobs_info")
    
    if [[ ${#status_parts[@]} -gt 0 ]]; then
        local status_line=$(IFS=' \[\e[1;35m\]▶\[\e[0m\] '; echo "${status_parts[*]}")
        prompt="${prompt}${status_line}\n"
    fi
    
    # Environment with neon styling
    local env_parts=()
    [[ -n "$conda_info" ]] && env_parts+=("\[\e[1;36m\]🐍\[\e[0m\]$conda_info")
    [[ -n "$venv_info" ]] && env_parts+=("\[\e[1;32m\]🐍\[\e[0m\]$venv_info")
    [[ -n "$docker_info" ]] && env_parts+=("$docker_info")
    [[ -n "$k8s_info" ]] && env_parts+=("$k8s_info")
    
    if [[ ${#env_parts[@]} -gt 0 ]]; then
        local env_line=$(IFS=' '; echo "${env_parts[*]}")
        prompt="${prompt}\[\e[1;35m\]▓▓▓\[\e[0m\] $env_line\n"
    fi
    
    # Main neon prompt
    prompt="${prompt}\[\e[1;35m\]▓▓▓\[\e[0m\] \[\e[1;32m\]\u\[\e[1;35m\]@\[\e[1;36m\]\h\[\e[0m\] \[\e[1;34m\]\w\[\e[0m\]"
    [[ -n "$git_info" ]] && prompt="${prompt} ${git_info}"
    prompt="${prompt}\n\[\e[1;35m\]▶▶▶\[\e[0m\] "
    
    PS1="$prompt"
}

# =============================================================================
# PROMPT MANAGEMENT FUNCTIONS
# =============================================================================

# Set up prompt function based on theme
setup_prompt_function() {
    local theme="$1"
    
    # Set PROMPT_COMMAND to rebuild prompt dynamically
    export PROMPT_COMMAND="build_dynamic_prompt${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    
    # Initial prompt build
    build_dynamic_prompt
}

# Refresh the prompt
refresh_prompt() {
    build_dynamic_prompt
}

# Save component configuration
save_component_config() {
    local prompt_dir="$HOME/.bash_prompt_config"
    mkdir -p "$prompt_dir"
    
    local config_file="$prompt_dir/components.conf"
    {
        echo "# Prompt components configuration"
        echo "# Generated: $(date)"
        echo "PROMPT_SHOW_GIT=${PROMPT_SHOW_GIT:-false}"
        echo "PROMPT_SHOW_TIME=${PROMPT_SHOW_TIME:-false}"
        echo "PROMPT_SHOW_LOAD=${PROMPT_SHOW_LOAD:-false}"
        echo "PROMPT_SHOW_BATTERY=${PROMPT_SHOW_BATTERY:-false}"
        echo "PROMPT_SHOW_NETWORK=${PROMPT_SHOW_NETWORK:-false}"
        echo "PROMPT_SHOW_TASKS=${PROMPT_SHOW_TASKS:-false}"
        echo "PROMPT_SHOW_JOBS=${PROMPT_SHOW_JOBS:-false}"
        echo "PROMPT_SHOW_CONDA=${PROMPT_SHOW_CONDA:-false}"
        echo "PROMPT_SHOW_VENV=${PROMPT_SHOW_VENV:-false}"
        echo "PROMPT_SHOW_DOCKER=${PROMPT_SHOW_DOCKER:-false}"
        echo "PROMPT_SHOW_K8S=${PROMPT_SHOW_K8S:-false}"
    } > "$config_file"
}

# Load component configuration
load_component_config() {
    local prompt_dir="$HOME/.bash_prompt_config"
    local config_file="$prompt_dir/components.conf"
    
    [[ -f "$config_file" ]] && source "$config_file"
}

# Preview prompt themes
prompt_preview() {
    echo -e "🎨 Prompt Theme Preview"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    local current_theme="$CURRENT_PROMPT_THEME"
    local themes=(minimal standard developer power retro neon)
    
    for theme in "${themes[@]}"; do
        echo -e "\n🎨 ${theme^} Theme:"
        echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
        
        # Temporarily set theme and generate sample
        CURRENT_PROMPT_THEME="$theme"
        case "$theme" in
            minimal)    echo -e "(venv:myproject) \[\e[34m\]/home/user/project\[\e[0m\] \[\e[32m\]main[2M]\[\e[0m\] $ " ;;
            standard)   echo -e "┌─ \[\e[36m\]14:32:15\[\e[0m\] │ \[\e[32m\]🔋85%\[\e[0m\] │ \[\e[35m\]✓3\[\e[0m\] │ \[\e[33m\]&1\[\e[0m\]\n└─ \[\e[32m\]user@hostname\[\e[0m\] \[\e[34m\]/project\[\e[0m\] \[\e[32m\]main\[\e[0m\] $ " ;;
            developer)  echo -e "╭─ ⚡\[\e[32m\]0.5\[\e[0m\] 📶 \[\e[35m\]✓2\[\e[0m\] \[\e[33m\]&1\[\e[0m\]\n├─ \[\e[36m\](conda:ml)\[\e[0m\] \[\e[34m\]🐳prod\[\e[0m\] \[\e[34m\]☸️cluster\[\e[0m\]\n╰─ \[\e[35m\]user\[\e[0m\] \[\e[34m\]/project\[\e[0m\] \[\e[32m\]main\[\e[0m\]\n└─▶ " ;;
            power)      echo -e "╔══ ⏰\[\e[36m\]14:32:15\[\e[0m\] │ ⚡\[\e[32m\]0.5\[\e[0m\] │ \[\e[32m\]🔋85%\[\e[0m\] │ 📶\n╠══ \[\e[35m\]✓3\[\e[0m\] \[\e[33m\]&1\[\e[0m\]\n╠══ \[\e[36m\](conda:ml)\[\e[0m\] \[\e[34m\]🐳prod\[\e[0m\] \[\e[34m\]☸️cluster\[\e[0m\]\n╚══ \[\e[32m\]user@hostname\[\e[0m\] \[\e[34m\]/project\[\e[0m\] \[\e[32m\]main\[\e[0m\]\n └─▶ " ;;
            retro)      echo -e "[\[\e[36m\]14:32:15\[\e[0m\] user@hostname \[\e[33m\]&1\[\e[0m\]] \[\e[36m\](venv:myproject)\[\e[0m\] /project \[\e[32m\]main\[\e[0m\] $ " ;;
            neon)       echo -e "\[\e[1;35m\]▓▓▓\[\e[0m\] ⏰\[\e[36m\]14:32:15\[\e[0m\] \[\e[1;35m\]▶\[\e[0m\] ⚡\[\e[32m\]0.5\[\e[0m\] \[\e[1;35m\]▶\[\e[0m\] 🔋85%\n\[\e[1;35m\]▓▓▓\[\e[0m\] 🐍\[\e[36m\](conda:ml)\[\e[0m\] \[\e[34m\]🐳prod\[\e[0m\]\n\[\e[1;35m\]▓▓▓\[\e[0m\] \[\e[1;32m\]user\[\e[1;35m\]@\[\e[1;36m\]hostname\[\e[0m\] \[\e[1;34m\]/project\[\e[0m\] \[\e[32m\]main\[\e[0m\]\n\[\e[1;35m\]▶▶▶\[\e[0m\] " ;;
        esac
    done
    
    # Restore current theme
    CURRENT_PROMPT_THEME="$current_theme"
    echo -e "\n💡 Set a theme with: promptconfig theme THEME_NAME"
}

# Generate sample prompt for status display
generate_sample_prompt() {
    local sample_git_info="\[\e[32m\]main[1M]\[\e[0m\]"
    local sample_time="\[\e[36m\]$(date +%H:%M:%S)\[\e[0m\]"
    
    case "${CURRENT_PROMPT_THEME:-standard}" in
        minimal)
            echo -e "\[\e[34m\]~/project\[\e[0m\] $sample_git_info \$ "
            ;;
        standard)
            echo -e "┌─ $sample_time │ \[\e[32m\]🔋85%\[\e[0m\]\n└─ \[\e[32m\]\u@\h\[\e[0m\] \[\e[34m\]~/project\[\e[0m\] $sample_git_info \$ "
            ;;
        *)
            echo -e "\[\e[32m\]\u@\h\[\e[0m\] \[\e[34m\]~/project\[\e[0m\] $sample_git_info \$ "
            ;;
    esac
}

# Reset prompt to default
prompt_reset() {
    unset PROMPT_COMMAND
    PS1='\u@\h:\w\$ '
    
    # Clear all component settings
    unset PROMPT_SHOW_GIT PROMPT_SHOW_TIME PROMPT_SHOW_LOAD PROMPT_SHOW_BATTERY
    unset PROMPT_SHOW_NETWORK PROMPT_SHOW_TASKS PROMPT_SHOW_JOBS PROMPT_SHOW_CONDA
    unset PROMPT_SHOW_VENV PROMPT_SHOW_DOCKER PROMPT_SHOW_K8S CURRENT_PROMPT_THEME
    
    echo -e "🔄 Prompt reset to system default"
}

# Save current configuration
prompt_save_config() {
    local config_name="$1"
    [[ -z "$config_name" ]] && { echo "Configuration name required"; return 1; }
    
    local prompt_dir="$HOME/.bash_prompt_config"
    local saved_dir="$prompt_dir/saved"
    mkdir -p "$saved_dir"
    
    local config_file="$saved_dir/${config_name}.conf"
    
    {
        echo "# Saved prompt configuration: $config_name"
        echo "# Created: $(date)"
        echo "CURRENT_PROMPT_THEME=${CURRENT_PROMPT_THEME:-standard}"
        echo "PROMPT_SHOW_GIT=${PROMPT_SHOW_GIT:-false}"
        echo "PROMPT_SHOW_TIME=${PROMPT_SHOW_TIME:-false}"
        echo "PROMPT_SHOW_LOAD=${PROMPT_SHOW_LOAD:-false}"
        echo "PROMPT_SHOW_BATTERY=${PROMPT_SHOW_BATTERY:-false}"
        echo "PROMPT_SHOW_NETWORK=${PROMPT_SHOW_NETWORK:-false}"
        echo "PROMPT_SHOW_TASKS=${PROMPT_SHOW_TASKS:-false}"
        echo "PROMPT_SHOW_JOBS=${PROMPT_SHOW_JOBS:-false}"
        echo "PROMPT_SHOW_CONDA=${PROMPT_SHOW_CONDA:-false}"
        echo "PROMPT_SHOW_VENV=${PROMPT_SHOW_VENV:-false}"
        echo "PROMPT_SHOW_DOCKER=${PROMPT_SHOW_DOCKER:-false}"
        echo "PROMPT_SHOW_K8S=${PROMPT_SHOW_K8S:-false}"
    } > "$config_file"
    
    echo -e "💾 Configuration saved as: $config_name"
}

# Load saved configuration
prompt_load_config() {
    local config_name="$1"
    [[ -z "$config_name" ]] && { echo "Configuration name required"; return 1; }
    
    local prompt_dir="$HOME/.bash_prompt_config"
    local config_file="$prompt_dir/saved/${config_name}.conf"
    
    if [[ ! -f "$config_file" ]]; then
        echo "❌ Configuration '$config_name' not found"
        return 1
    fi
    
    source "$config_file"
    setup_prompt_function "$CURRENT_PROMPT_THEME"
    
    echo -e "📥 Configuration loaded: $config_name"
}

# =============================================================================
# MODULE INITIALIZATION
# =============================================================================

# Initialize prompt system
initialize_prompt_system() {
    local prompt_dir="$HOME/.bash_prompt_config"
    mkdir -p "$prompt_dir/saved"
    
    # Load saved theme and components if they exist
    [[ -f "$prompt_dir/theme.conf" ]] && source "$prompt_dir/theme.conf"
    load_component_config
    
    # Set default theme if none configured
    if [[ -z "$CURRENT_PROMPT_THEME" ]]; then
        export CURRENT_PROMPT_THEME="standard"
        setup_standard_theme
    else
        setup_prompt_function "$CURRENT_PROMPT_THEME"
    fi
    
    echo -e "💫 Prompt system initialized with theme: ${CURRENT_PROMPT_THEME}"
}

# Create convenient aliases
alias prompt='promptconfig'
alias ptheme='promptconfig theme'
alias pstatus='promptconfig status'
alias ppreview='promptconfig preview'

# Export all functions
export -f promptconfig prompt_set_theme prompt_enable_components prompt_disable_components
export -f prompt_show_status prompt_preview prompt_reset prompt_save_config prompt_load_config
export -f setup_minimal_theme setup_standard_theme setup_developer_theme setup_power_theme
export -f setup_retro_theme setup_neon_theme
export -f get_git_info get_time_info get_load_info get_battery_info get_network_info
export -f get_tasks_info get_jobs_info get_conda_info get_venv_info get_docker_info get_k8s_info
export -f build_dynamic_prompt build_minimal_prompt build_standard_prompt build_developer_prompt
export -f build_power_prompt build_retro_prompt build_neon_prompt
export -f setup_prompt_function refresh_prompt save_component_config load_component_config
export -f generate_sample_prompt

# Initialize the system
initialize_prompt_system

echo -e "${BASHRC_GREEN}✅ Prompt Tricks Module Loaded${BASHRC_NC}"
echo -e "${BASHRC_PURPLE}💫 Prompt Tricks v$PROMPT_MODULE_VERSION Ready!${BASHRC_NC}"
echo -e "${BASHRC_CYAN}💡 Try: 'promptconfig preview', 'promptconfig theme developer', 'promptconfig enable battery network'${BASHRC_NC}"
