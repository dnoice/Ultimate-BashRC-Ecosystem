#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - SYSTEM MONITORING & PERFORMANCE MODULE
# File: 09_system-monitoring.sh
# =============================================================================
# This module provides comprehensive system monitoring, performance analysis,
# resource usage tracking, process management, service monitoring, benchmarking,
# and intelligent system optimization recommendations.
# =============================================================================

# Module metadata
declare -r MONITORING_MODULE_VERSION="2.1.0"
declare -r MONITORING_MODULE_NAME="System Monitoring & Performance"
declare -r MONITORING_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# Module initialization
echo -e "${BASHRC_CYAN}📊 Loading System Monitoring & Performance...${BASHRC_NC}"

# =============================================================================
# REAL-TIME SYSTEM MONITORING DASHBOARD
# =============================================================================

# Comprehensive system monitoring with intelligent analysis
sysmon() {
    local usage="Usage: sysmon [COMMAND] [OPTIONS]
    
📊 Advanced System Monitoring Dashboard
Commands:
    dashboard   Real-time monitoring dashboard (default)
    cpu         CPU usage analysis
    memory      Memory usage analysis
    disk        Disk usage and I/O analysis
    network     Network usage analysis
    processes   Process monitoring and analysis
    services    Service status monitoring
    logs        Log analysis and monitoring
    alerts      Alert management
    benchmark   System benchmarking
    optimize    System optimization suggestions
    
Options:
    -i, --interval SEC  Update interval (default: 2)
    -d, --duration SEC  Monitoring duration
    -t, --top N         Show top N items (default: 10)
    -f, --format TYPE   Output format (table, json, csv)
    -o, --output FILE   Save output to file
    -w, --watch         Continuous monitoring
    -a, --alerts        Enable alert notifications
    -v, --verbose       Verbose output
    -h, --help          Show this help
    
Examples:
    sysmon                          # Launch monitoring dashboard
    sysmon cpu -i 1 -d 60          # Monitor CPU for 60 seconds
    sysmon processes --top 20       # Show top 20 processes
    sysmon benchmark --cpu --memory # Run CPU and memory benchmarks
    sysmon alerts enable --cpu 80   # Alert when CPU > 80%"

    local command="${1:-dashboard}"
    [[ "$command" =~ ^(dashboard|cpu|memory|disk|network|processes|services|logs|alerts|benchmark|optimize)$ ]] && shift || command="dashboard"
    
    case "$command" in
        dashboard)  sysmon_dashboard "$@" ;;
        cpu)        sysmon_cpu "$@" ;;
        memory)     sysmon_memory "$@" ;;
        disk)       sysmon_disk "$@" ;;
        network)    sysmon_network "$@" ;;
        processes)  sysmon_processes "$@" ;;
        services)   sysmon_services "$@" ;;
        logs)       sysmon_logs "$@" ;;
        alerts)     sysmon_alerts "$@" ;;
        benchmark)  sysmon_benchmark "$@" ;;
        optimize)   sysmon_optimize "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Real-time monitoring dashboard
sysmon_dashboard() {
    local interval=2
    local duration=""
    local watch_mode=false
    local alerts_enabled=false
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interval)      interval="$2"; shift 2 ;;
            -d|--duration)      duration="$2"; shift 2 ;;
            -w|--watch)         watch_mode=true; shift ;;
            -a|--alerts)        alerts_enabled=true; shift ;;
            -v|--verbose)       verbose=true; shift ;;
            *)                  shift ;;
        esac
    done
    
    echo -e "📊 ${BASHRC_PURPLE}System Monitoring Dashboard${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..60})${BASHRC_NC}"
    echo -e "⏱️ Update Interval: ${interval}s"
    [[ -n "$duration" ]] && echo -e "⏰ Duration: ${duration}s"
    echo -e "🔔 Alerts: $([ "$alerts_enabled" == "true" ] && echo "Enabled" || echo "Disabled")"
    echo
    
    local start_time=$(date +%s)
    local monitoring_dir="$HOME/.bash_monitoring"
    mkdir -p "$monitoring_dir/logs"
    
    # Setup monitoring data collection
    setup_monitoring_data_collection "$monitoring_dir"
    
    # Main monitoring loop
    while true; do
        clear
        display_system_overview
        echo
        display_cpu_summary
        echo
        display_memory_summary
        echo
        display_disk_summary
        echo
        display_network_summary
        echo
        display_top_processes 5
        
        # Check alerts if enabled
        if [[ "$alerts_enabled" == "true" ]]; then
            check_system_alerts
        fi
        
        # Check duration limit
        if [[ -n "$duration" ]]; then
            local current_time=$(date +%s)
            local elapsed=$((current_time - start_time))
            [[ $elapsed -ge $duration ]] && break
        fi
        
        echo -e "\n${BASHRC_CYAN}Press Ctrl+C to exit${BASHRC_NC}"
        sleep "$interval"
    done
}

# Display system overview
display_system_overview() {
    local hostname=$(hostname)
    local uptime_info=$(uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}')
    local kernel=$(uname -r)
    local os_info=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2 || echo "Unknown")
    
    echo -e "🖥️  ${BASHRC_YELLOW}System Overview${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
    echo -e "🏷️  Hostname: $hostname"
    echo -e "⏰ Uptime: $uptime_info"
    echo -e "🔧 Kernel: $kernel"
    echo -e "💻 OS: $os_info"
    echo -e "⏱️  Time: $(date '+%Y-%m-%d %H:%M:%S')"
}

# Display CPU summary
display_cpu_summary() {
    local cpu_count=$(nproc)
    local load_avg=$(uptime | awk -F'load average: ' '{print $2}')
    local cpu_usage=$(get_cpu_usage)
    local cpu_temp=$(get_cpu_temperature)
    
    echo -e "🔥 ${BASHRC_YELLOW}CPU Information${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
    echo -e "⚙️  Cores: $cpu_count"
    echo -e "📊 Usage: ${cpu_usage}%"
    echo -e "⚖️  Load: $load_avg"
    [[ -n "$cpu_temp" ]] && echo -e "🌡️  Temperature: ${cpu_temp}°C"
    
    # CPU usage bar
    display_usage_bar "$cpu_usage" "CPU"
}

# Display memory summary
display_memory_summary() {
    local mem_info=($(free -m | grep '^Mem:' | awk '{print $2, $3, $7}'))
    local total_mb=${mem_info[0]}
    local used_mb=${mem_info[1]}
    local available_mb=${mem_info[2]}
    
    local total_gb=$(echo "scale=1; $total_mb / 1024" | bc -l)
    local used_gb=$(echo "scale=1; $used_mb / 1024" | bc -l)
    local available_gb=$(echo "scale=1; $available_mb / 1024" | bc -l)
    local usage_percent=$(echo "scale=1; $used_mb * 100 / $total_mb" | bc -l)
    
    # Swap information
    local swap_info=($(free -m | grep '^Swap:' | awk '{print $2, $3}'))
    local swap_total_mb=${swap_info[0]:-0}
    local swap_used_mb=${swap_info[1]:-0}
    local swap_usage_percent=0
    [[ $swap_total_mb -gt 0 ]] && swap_usage_percent=$(echo "scale=1; $swap_used_mb * 100 / $swap_total_mb" | bc -l)
    
    echo -e "🧠 ${BASHRC_YELLOW}Memory Information${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
    echo -e "💾 Total: ${total_gb}GB"
    echo -e "📊 Used: ${used_gb}GB (${usage_percent}%)"
    echo -e "✅ Available: ${available_gb}GB"
    [[ $swap_total_mb -gt 0 ]] && echo -e "🔄 Swap: ${swap_used_mb}MB/${swap_total_mb}MB (${swap_usage_percent}%)"
    
    # Memory usage bar
    display_usage_bar "$usage_percent" "Memory"
}

# Display disk summary
display_disk_summary() {
    echo -e "💿 ${BASHRC_YELLOW}Disk Information${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
    
    # Get disk usage for mounted filesystems
    df -h | grep -E '^/dev/' | head -3 | while read filesystem size used avail use_percent mount; do
        local usage_num=$(echo "$use_percent" | tr -d '%')
        echo -e "📁 $mount: $used/$size (${use_percent})"
        display_usage_bar "$usage_num" "Disk" 20
    done
    
    # Show I/O statistics if available
    if command -v iostat >/dev/null 2>&1; then
        local io_stats=$(iostat -d 1 2 | tail -n +4 | grep -E '^[a-z]' | head -1)
        if [[ -n "$io_stats" ]]; then
            echo -e "💽 I/O: $(echo "$io_stats" | awk '{print "Read: " $3 "KB/s, Write: " $4 "KB/s"}')"
        fi
    fi
}

# Display network summary
display_network_summary() {
    echo -e "🌐 ${BASHRC_YELLOW}Network Information${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
    
    # Get active network interfaces
    local interfaces=$(ip link show | grep -E '^[0-9]+: [^lo]' | awk -F': ' '{print $2}' | head -3)
    
    for interface in $interfaces; do
        local ip_addr=$(ip addr show "$interface" 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1 | head -1)
        local status=$(ip link show "$interface" | grep -o 'state [A-Z]*' | awk '{print $2}')
        
        if [[ -n "$ip_addr" ]]; then
            echo -e "🔗 $interface: $ip_addr ($status)"
            
            # Show network statistics if available
            local net_stats=$(cat "/proc/net/dev" | grep "$interface:" 2>/dev/null)
            if [[ -n "$net_stats" ]]; then
                local rx_bytes=$(echo "$net_stats" | awk '{print $2}')
                local tx_bytes=$(echo "$net_stats" | awk '{print $10}')
                local rx_human=$(numfmt --to=iec-i --suffix=B "$rx_bytes" 2>/dev/null || echo "${rx_bytes}B")
                local tx_human=$(numfmt --to=iec-i --suffix=B "$tx_bytes" 2>/dev/null || echo "${tx_bytes}B")
                echo -e "   📥 RX: $rx_human | 📤 TX: $tx_human"
            fi
        fi
    done
}

# Display top processes
display_top_processes() {
    local count="${1:-5}"
    
    echo -e "🔧 ${BASHRC_YELLOW}Top Processes (CPU)${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
    
    # Get top processes by CPU usage
    ps axo pid,pcpu,pmem,comm --sort=-pcpu | head -n $((count + 1)) | tail -n +2 | while read pid cpu mem comm; do
        printf "%-6s %5s%% %5s%% %-15s\n" "$pid" "$cpu" "$mem" "$comm"
    done
}

# =============================================================================
# CPU MONITORING AND ANALYSIS
# =============================================================================

# Detailed CPU monitoring
sysmon_cpu() {
    local interval=2
    local duration=""
    local top_n=10
    local format="table"
    local output_file=""
    local watch_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interval)      interval="$2"; shift 2 ;;
            -d|--duration)      duration="$2"; shift 2 ;;
            -t|--top)           top_n="$2"; shift 2 ;;
            -f|--format)        format="$2"; shift 2 ;;
            -o|--output)        output_file="$2"; shift 2 ;;
            -w|--watch)         watch_mode=true; shift ;;
            *)                  shift ;;
        esac
    done
    
    echo -e "🔥 CPU Monitoring & Analysis"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    local monitoring_dir="$HOME/.bash_monitoring"
    local cpu_log="$monitoring_dir/logs/cpu_$(date +%Y%m%d_%H%M%S).log"
    mkdir -p "$(dirname "$cpu_log")"
    
    # Initialize log file
    echo "timestamp,cpu_usage,load_1m,load_5m,load_15m,temperature,frequency" > "$cpu_log"
    
    local start_time=$(date +%s)
    local sample_count=0
    
    while true; do
        local current_time=$(date +%s)
        local cpu_usage=$(get_cpu_usage)
        local load_avg=$(uptime | awk -F'load average: ' '{print $2}')
        local load_1m=$(echo "$load_avg" | cut -d',' -f1 | tr -d ' ')
        local load_5m=$(echo "$load_avg" | cut -d',' -f2 | tr -d ' ')
        local load_15m=$(echo "$load_avg" | cut -d',' -f3 | tr -d ' ')
        local cpu_temp=$(get_cpu_temperature)
        local cpu_freq=$(get_cpu_frequency)
        
        # Log data
        echo "$(date -Iseconds),$cpu_usage,$load_1m,$load_5m,$load_15m,$cpu_temp,$cpu_freq" >> "$cpu_log"
        
        ((sample_count++))
        
        if [[ "$watch_mode" == "true" ]]; then
            clear
            echo -e "🔥 ${BASHRC_PURPLE}CPU Monitoring${BASHRC_NC} (Sample #$sample_count)"
            echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
        fi
        
        # Current CPU information
        display_detailed_cpu_info "$cpu_usage" "$load_avg" "$cpu_temp" "$cpu_freq"
        echo
        
        # Top CPU processes
        echo -e "🔧 ${BASHRC_YELLOW}Top $top_n CPU Processes${BASHRC_NC}"
        echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..40})${BASHRC_NC}"
        printf "%-8s %-6s %-6s %-6s %-15s\n" "PID" "CPU%" "MEM%" "TIME" "COMMAND"
        ps axo pid,pcpu,pmem,etime,comm --sort=-pcpu | head -n $((top_n + 1)) | tail -n +2 | while read pid cpu mem time comm; do
            printf "%-8s %-6s %-6s %-6s %-15s\n" "$pid" "$cpu" "$mem" "$time" "$comm"
        done
        
        # Per-core CPU usage (if available)
        if command -v nproc >/dev/null 2>&1 && [[ -f /proc/stat ]]; then
            echo
            display_per_core_usage
        fi
        
        # Check duration and continue
        if [[ -n "$duration" ]]; then
            local elapsed=$((current_time - start_time))
            [[ $elapsed -ge $duration ]] && break
        fi
        
        [[ "$watch_mode" == "false" ]] && break
        sleep "$interval"
    done
    
    # Generate summary if we collected multiple samples
    if [[ $sample_count -gt 1 ]]; then
        echo
        generate_cpu_analysis_summary "$cpu_log" "$sample_count"
    fi
    
    # Save to output file if specified
    if [[ -n "$output_file" ]]; then
        cp "$cpu_log" "$output_file"
        echo -e "\n💾 CPU monitoring data saved to: $output_file"
    fi
}

# Display detailed CPU information
display_detailed_cpu_info() {
    local cpu_usage="$1"
    local load_avg="$2"
    local cpu_temp="$3"
    local cpu_freq="$4"
    
    echo -e "⚙️  ${BASHRC_YELLOW}CPU Details${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..20})${BASHRC_NC}"
    
    # CPU model
    local cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d':' -f2 | sed 's/^ *//')
    echo -e "🔧 Model: $cpu_model"
    
    # Core count
    local cpu_cores=$(nproc)
    local cpu_threads=$(grep "processor" /proc/cpuinfo | wc -l)
    echo -e "⚙️  Cores: $cpu_cores | Threads: $cpu_threads"
    
    # Usage and load
    echo -e "📊 Usage: ${cpu_usage}%"
    display_usage_bar "$cpu_usage" "CPU" 30
    echo -e "⚖️  Load Average: $load_avg"
    
    # Temperature and frequency
    [[ -n "$cpu_temp" ]] && echo -e "🌡️  Temperature: ${cpu_temp}°C"
    [[ -n "$cpu_freq" ]] && echo -e "⚡ Frequency: ${cpu_freq}MHz"
    
    # CPU cache information
    local cache_info=$(lscpu 2>/dev/null | grep -E "L[123] cache" | head -3)
    if [[ -n "$cache_info" ]]; then
        echo -e "💾 Cache:"
        echo "$cache_info" | sed 's/^/   /'
    fi
}

# Display per-core CPU usage
display_per_core_usage() {
    echo -e "🔥 ${BASHRC_YELLOW}Per-Core Usage${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..20})${BASHRC_NC}"
    
    # Get per-core usage from /proc/stat
    local core_usage=($(grep "^cpu[0-9]" /proc/stat | awk '{
        idle = $5
        total = $2 + $3 + $4 + $5 + $6 + $7 + $8
        usage = (total - idle) * 100 / total
        printf "%.1f ", usage
    }'))
    
    local core_count=${#core_usage[@]}
    for ((i=0; i<core_count; i++)); do
        local usage=${core_usage[$i]}
        printf "Core %2d: %5.1f%% " "$i" "$usage"
        display_usage_bar "$usage" "" 15
    done
}

# Generate CPU analysis summary
generate_cpu_analysis_summary() {
    local log_file="$1"
    local sample_count="$2"
    
    echo -e "📊 ${BASHRC_PURPLE}CPU Analysis Summary${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}"
    
    # Calculate statistics from log file
    local stats=$(tail -n +2 "$log_file" | awk -F',' '
    {
        cpu_sum += $2; cpu_count++
        if ($2 > cpu_max) cpu_max = $2
        if (cpu_min == 0 || $2 < cpu_min) cpu_min = $2
        load_sum += $3; load_count++
        if ($5 != "" && $5 > 0) {
            temp_sum += $5; temp_count++
            if ($5 > temp_max) temp_max = $5
        }
    }
    END {
        printf "%.1f %.1f %.1f %.1f %.1f %.1f", 
               cpu_sum/cpu_count, cpu_min, cpu_max,
               load_sum/load_count, temp_sum/temp_count, temp_max
    }')
    
    local cpu_avg cpu_min cpu_max load_avg temp_avg temp_max
    read cpu_avg cpu_min cpu_max load_avg temp_avg temp_max <<< "$stats"
    
    echo -e "📈 Samples Collected: $sample_count"
    echo -e "📊 CPU Usage: Avg ${cpu_avg}% | Min ${cpu_min}% | Max ${cpu_max}%"
    echo -e "⚖️  Load Average: ${load_avg}"
    [[ -n "$temp_avg" && "$temp_avg" != "0" ]] && {
        echo -e "🌡️  Temperature: Avg ${temp_avg}°C | Max ${temp_max}°C"
    }
    
    # Performance assessment
    local performance_level="Good"
    if (( $(echo "$cpu_avg > 80" | bc -l) )); then
        performance_level="High Load"
    elif (( $(echo "$cpu_avg > 60" | bc -l) )); then
        performance_level="Moderate Load"
    fi
    
    echo -e "🎯 Assessment: $performance_level"
}

# =============================================================================
# MEMORY MONITORING AND ANALYSIS
# =============================================================================

# Detailed memory monitoring
sysmon_memory() {
    local interval=2
    local duration=""
    local top_n=10
    local format="table"
    local watch_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interval)      interval="$2"; shift 2 ;;
            -d|--duration)      duration="$2"; shift 2 ;;
            -t|--top)           top_n="$2"; shift 2 ;;
            -f|--format)        format="$2"; shift 2 ;;
            -w|--watch)         watch_mode=true; shift ;;
            *)                  shift ;;
        esac
    done
    
    echo -e "🧠 Memory Monitoring & Analysis"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    local monitoring_dir="$HOME/.bash_monitoring"
    local memory_log="$monitoring_dir/logs/memory_$(date +%Y%m%d_%H%M%S).log"
    mkdir -p "$(dirname "$memory_log")"
    
    # Initialize log file
    echo "timestamp,total_mb,used_mb,free_mb,available_mb,buffers_mb,cached_mb,swap_total_mb,swap_used_mb" > "$memory_log"
    
    local start_time=$(date +%s)
    local sample_count=0
    
    while true; do
        local current_time=$(date +%s)
        ((sample_count++))
        
        # Get memory information
        local mem_info=($(free -m | awk 'NR==2{print $2,$3,$4,$7} NR==3{print $2,$3}'))
        local total_mb=${mem_info[0]}
        local used_mb=${mem_info[1]}
        local free_mb=${mem_info[2]}
        local available_mb=${mem_info[3]}
        local buffers_cached_mb=${mem_info[4]:-0}
        local swap_total_mb=${mem_info[5]:-0}
        local swap_used_mb=${mem_info[6]:-0}
        
        # Get additional memory details
        local buffers_mb=$(grep "^Buffers:" /proc/meminfo | awk '{print int($2/1024)}')
        local cached_mb=$(grep "^Cached:" /proc/meminfo | awk '{print int($2/1024)}')
        
        # Log data
        echo "$(date -Iseconds),$total_mb,$used_mb,$free_mb,$available_mb,$buffers_mb,$cached_mb,$swap_total_mb,$swap_used_mb" >> "$memory_log"
        
        if [[ "$watch_mode" == "true" ]]; then
            clear
            echo -e "🧠 ${BASHRC_PURPLE}Memory Monitoring${BASHRC_NC} (Sample #$sample_count)"
            echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
        fi
        
        # Display detailed memory information
        display_detailed_memory_info "$total_mb" "$used_mb" "$free_mb" "$available_mb" "$buffers_mb" "$cached_mb" "$swap_total_mb" "$swap_used_mb"
        echo
        
        # Memory usage breakdown
        display_memory_breakdown "$total_mb" "$used_mb" "$buffers_mb" "$cached_mb"
        echo
        
        # Top memory processes
        echo -e "🔧 ${BASHRC_YELLOW}Top $top_n Memory Processes${BASHRC_NC}"
        echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..40})${BASHRC_NC}"
        printf "%-8s %-6s %-6s %-8s %-15s\n" "PID" "MEM%" "RSS" "VSZ" "COMMAND"
        ps axo pid,pmem,rss,vsz,comm --sort=-pmem | head -n $((top_n + 1)) | tail -n +2 | while read pid mem rss vsz comm; do
            local rss_mb=$(echo "scale=1; $rss / 1024" | bc -l)
            local vsz_mb=$(echo "scale=1; $vsz / 1024" | bc -l)
            printf "%-8s %-6s %-6.1fM %-6.1fM %-15s\n" "$pid" "$mem" "$rss_mb" "$vsz_mb" "$comm"
        done
        
        # Check duration and continue
        if [[ -n "$duration" ]]; then
            local elapsed=$((current_time - start_time))
            [[ $elapsed -ge $duration ]] && break
        fi
        
        [[ "$watch_mode" == "false" ]] && break
        sleep "$interval"
    done
    
    # Generate summary if we collected multiple samples
    if [[ $sample_count -gt 1 ]]; then
        echo
        generate_memory_analysis_summary "$memory_log" "$sample_count"
    fi
}

# Display detailed memory information
display_detailed_memory_info() {
    local total_mb="$1" used_mb="$2" free_mb="$3" available_mb="$4"
    local buffers_mb="$5" cached_mb="$6" swap_total_mb="$7" swap_used_mb="$8"
    
    local total_gb=$(echo "scale=1; $total_mb / 1024" | bc -l)
    local used_gb=$(echo "scale=1; $used_mb / 1024" | bc -l)
    local available_gb=$(echo "scale=1; $available_mb / 1024" | bc -l)
    local usage_percent=$(echo "scale=1; $used_mb * 100 / $total_mb" | bc -l)
    
    echo -e "💾 ${BASHRC_YELLOW}Memory Overview${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..25})${BASHRC_NC}"
    echo -e "🔢 Total: ${total_gb}GB (${total_mb}MB)"
    echo -e "📊 Used: ${used_gb}GB (${usage_percent}%)"
    echo -e "✅ Available: ${available_gb}GB"
    
    # Memory usage bar
    display_usage_bar "$usage_percent" "Memory" 25
    
    # Additional memory details
    echo -e "💽 Buffers: ${buffers_mb}MB"
    echo -e "💾 Cached: ${cached_mb}MB"
    
    # Swap information
    if [[ $swap_total_mb -gt 0 ]]; then
        local swap_usage_percent=$(echo "scale=1; $swap_used_mb * 100 / $swap_total_mb" | bc -l)
        echo -e "🔄 Swap: ${swap_used_mb}MB/${swap_total_mb}MB (${swap_usage_percent}%)"
        display_usage_bar "$swap_usage_percent" "Swap" 25
    else
        echo -e "🔄 Swap: Not configured"
    fi
}

# Display memory breakdown visualization
display_memory_breakdown() {
    local total_mb="$1" used_mb="$2" buffers_mb="$3" cached_mb="$4"
    
    local actual_used_mb=$((used_mb - buffers_mb - cached_mb))
    local free_mb=$((total_mb - used_mb))
    
    echo -e "📊 ${BASHRC_YELLOW}Memory Breakdown${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..25})${BASHRC_NC}"
    
    local actual_used_percent=$(echo "scale=1; $actual_used_mb * 100 / $total_mb" | bc -l)
    local buffers_percent=$(echo "scale=1; $buffers_mb * 100 / $total_mb" | bc -l)
    local cached_percent=$(echo "scale=1; $cached_mb * 100 / $total_mb" | bc -l)
    local free_percent=$(echo "scale=1; $free_mb * 100 / $total_mb" | bc -l)
    
    printf "Applications: %6.1f%% (%dMB)\n" "$actual_used_percent" "$actual_used_mb"
    printf "Buffers:      %6.1f%% (%dMB)\n" "$buffers_percent" "$buffers_mb"
    printf "Cached:       %6.1f%% (%dMB)\n" "$cached_percent" "$cached_mb"
    printf "Free:         %6.1f%% (%dMB)\n" "$free_percent" "$free_mb"
}

# =============================================================================
# PROCESS MONITORING AND ANALYSIS
# =============================================================================

# Advanced process monitoring
sysmon_processes() {
    local top_n=20
    local sort_by="cpu"
    local format="table"
    local watch_mode=false
    local filter_user=""
    local filter_command=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--top)           top_n="$2"; shift 2 ;;
            -s|--sort)          sort_by="$2"; shift 2 ;;
            -f|--format)        format="$2"; shift 2 ;;
            -w|--watch)         watch_mode=true; shift ;;
            -u|--user)          filter_user="$2"; shift 2 ;;
            -c|--command)       filter_command="$2"; shift 2 ;;
            *)                  shift ;;
        esac
    done
    
    echo -e "🔧 Process Monitoring & Analysis"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    while true; do
        if [[ "$watch_mode" == "true" ]]; then
            clear
            echo -e "🔧 ${BASHRC_PURPLE}Process Monitor${BASHRC_NC}"
            echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
        fi
        
        # Process summary
        display_process_summary
        echo
        
        # Top processes based on sort criteria
        display_top_processes_detailed "$top_n" "$sort_by" "$filter_user" "$filter_command"
        echo
        
        # Process tree for interesting processes
        if command -v pstree >/dev/null 2>&1; then
            echo -e "🌳 ${BASHRC_YELLOW}Process Tree (Top Parents)${BASHRC_NC}"
            echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
            pstree -p | head -10
        fi
        
        [[ "$watch_mode" == "false" ]] && break
        sleep 2
    done
}

# Display process summary
display_process_summary() {
    local total_processes=$(ps aux | wc -l)
    local running_processes=$(ps aux | awk '$8 ~ /R/ {count++} END {print count+0}')
    local sleeping_processes=$(ps aux | awk '$8 ~ /S/ {count++} END {print count+0}')
    local zombie_processes=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')
    
    echo -e "📊 ${BASHRC_YELLOW}Process Summary${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..25})${BASHRC_NC}"
    echo -e "🔢 Total: $total_processes"
    echo -e "🏃 Running: $running_processes"
    echo -e "😴 Sleeping: $sleeping_processes"
    [[ $zombie_processes -gt 0 ]] && echo -e "🧟 Zombies: $zombie_processes"
    
    # Average load
    local load_avg=$(uptime | awk -F'load average: ' '{print $2}' | cut -d',' -f1 | tr -d ' ')
    echo -e "⚖️  Load Average: $load_avg"
}

# Display detailed top processes
display_top_processes_detailed() {
    local count="$1"
    local sort_by="$2"
    local filter_user="$3"
    local filter_command="$4"
    
    local sort_field=""
    case "$sort_by" in
        cpu)    sort_field="--sort=-pcpu" ;;
        memory) sort_field="--sort=-pmem" ;;
        time)   sort_field="--sort=-etime" ;;
        *)      sort_field="--sort=-pcpu" ;;
    esac
    
    echo -e "🏆 ${BASHRC_YELLOW}Top $count Processes (by ${sort_by})${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..50})${BASHRC_NC}"
    
    printf "%-8s %-8s %-6s %-6s %-8s %-8s %-15s\n" "PID" "USER" "CPU%" "MEM%" "VSZ" "RSS" "COMMAND"
    printf "%-8s %-8s %-6s %-6s %-8s %-8s %-15s\n" "────" "────" "────" "────" "────" "────" "─────────"
    
    local ps_cmd="ps axo pid,user,pcpu,pmem,vsz,rss,comm $sort_field"
    
    # Apply filters
    local filter_cmd=""
    [[ -n "$filter_user" ]] && filter_cmd="grep '$filter_user'"
    [[ -n "$filter_command" ]] && filter_cmd="${filter_cmd:+$filter_cmd | }grep '$filter_command'"
    
    if [[ -n "$filter_cmd" ]]; then
        eval "$ps_cmd | head -n $((count + 10)) | $filter_cmd | head -n $count"
    else
        eval "$ps_cmd | head -n $((count + 1)) | tail -n +2"
    fi | while read pid user cpu mem vsz rss comm; do
        # Format memory sizes
        local vsz_mb=$(echo "scale=1; $vsz / 1024" | bc -l 2>/dev/null || echo "0")
        local rss_mb=$(echo "scale=1; $rss / 1024" | bc -l 2>/dev/null || echo "0")
        
        printf "%-8s %-8s %-6s %-6s %-6.1fM %-6.1fM %-15s\n" "$pid" "$user" "$cpu" "$mem" "$vsz_mb" "$rss_mb" "$comm"
    done
}

# =============================================================================
# SYSTEM BENCHMARKING
# =============================================================================

# Comprehensive system benchmarking
sysmon_benchmark() {
    local bench_cpu=false
    local bench_memory=false
    local bench_disk=false
    local bench_network=false
    local iterations=3
    local output_file=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cpu)              bench_cpu=true; shift ;;
            --memory)           bench_memory=true; shift ;;
            --disk)             bench_disk=true; shift ;;
            --network)          bench_network=true; shift ;;
            --all)              bench_cpu=true; bench_memory=true; bench_disk=true; shift ;;
            -i|--iterations)    iterations="$2"; shift 2 ;;
            -o|--output)        output_file="$2"; shift 2 ;;
            *)                  shift ;;
        esac
    done
    
    # Default to CPU and memory if nothing specified
    if [[ "$bench_cpu" == "false" && "$bench_memory" == "false" && "$bench_disk" == "false" && "$bench_network" == "false" ]]; then
        bench_cpu=true
        bench_memory=true
    fi
    
    echo -e "🏃 System Benchmarking Suite"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    local benchmark_results=()
    local benchmark_start=$(date +%s)
    
    # CPU Benchmark
    if [[ "$bench_cpu" == "true" ]]; then
        echo -e "🔥 ${BASHRC_YELLOW}CPU Benchmark${BASHRC_NC}"
        echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
        local cpu_result=$(run_cpu_benchmark "$iterations")
        benchmark_results+=("CPU:$cpu_result")
        echo -e "✅ CPU Score: $cpu_result"
        echo
    fi
    
    # Memory Benchmark
    if [[ "$bench_memory" == "true" ]]; then
        echo -e "🧠 ${BASHRC_YELLOW}Memory Benchmark${BASHRC_NC}"
        echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
        local memory_result=$(run_memory_benchmark "$iterations")
        benchmark_results+=("Memory:$memory_result")
        echo -e "✅ Memory Score: $memory_result MB/s"
        echo
    fi
    
    # Disk Benchmark
    if [[ "$bench_disk" == "true" ]]; then
        echo -e "💿 ${BASHRC_YELLOW}Disk Benchmark${BASHRC_NC}"
        echo -e "${BASHRC_CYAN}$(printf '─%.0s' {1..30})${BASHRC_NC}"
        local disk_result=$(run_disk_benchmark "$iterations")
        benchmark_results+=("Disk:$disk_result")
        echo -e "✅ Disk Score: $disk_result MB/s"
        echo
    fi
    
    local benchmark_end=$(date +%s)
    local total_time=$((benchmark_end - benchmark_start))
    
    # Generate benchmark report
    echo -e "📊 ${BASHRC_PURPLE}Benchmark Summary${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}"
    echo -e "🖥️  System: $(hostname)"
    echo -e "⏰ Date: $(date)"
    echo -e "⏱️  Duration: ${total_time}s"
    echo
    
    for result in "${benchmark_results[@]}"; do
        local component="${result%:*}"
        local score="${result#*:}"
        echo -e "🏆 $component: $score"
    done
    
    # Save results if output file specified
    if [[ -n "$output_file" ]]; then
        {
            echo "# System Benchmark Results"
            echo "# Generated: $(date)"
            echo "# System: $(hostname)"
            echo "# Duration: ${total_time}s"
            echo
            for result in "${benchmark_results[@]}"; do
                echo "$result"
            done
        } > "$output_file"
        echo -e "\n💾 Results saved to: $output_file"
    fi
}

# CPU benchmark
run_cpu_benchmark() {
    local iterations="$1"
    local total_score=0
    
    echo -e "🔄 Running CPU benchmark ($iterations iterations)..."
    
    for ((i=1; i<=iterations; i++)); do
        echo -ne "   Iteration $i/$iterations... "
        
        # Simple CPU stress test - calculate prime numbers
        local start_time=$(date +%s.%N)
        local primes=$(bash -c '
            count=0
            for ((n=2; n<=10000; n++)); do
                is_prime=1
                for ((i=2; i*i<=n; i++)); do
                    if ((n % i == 0)); then
                        is_prime=0
                        break
                    fi
                done
                ((is_prime)) && ((count++))
            done
            echo $count
        ')
        local end_time=$(date +%s.%N)
        
        local duration=$(echo "$end_time - $start_time" | bc -l)
        local score=$(echo "scale=0; 1000 / $duration" | bc -l)
        total_score=$(echo "$total_score + $score" | bc -l)
        
        echo "Score: $score"
    done
    
    local avg_score=$(echo "scale=0; $total_score / $iterations" | bc -l)
    echo "$avg_score"
}

# Memory benchmark
run_memory_benchmark() {
    local iterations="$1"
    local total_throughput=0
    
    echo -e "🔄 Running memory benchmark ($iterations iterations)..."
    
    for ((i=1; i<=iterations; i++)); do
        echo -ne "   Iteration $i/$iterations... "
        
        # Memory throughput test
        local start_time=$(date +%s.%N)
        dd if=/dev/zero of=/dev/null bs=1M count=1024 2>/dev/null
        local end_time=$(date +%s.%N)
        
        local duration=$(echo "$end_time - $start_time" | bc -l)
        local throughput=$(echo "scale=0; 1024 / $duration" | bc -l)
        total_throughput=$(echo "$total_throughput + $throughput" | bc -l)
        
        echo "Throughput: ${throughput} MB/s"
    done
    
    local avg_throughput=$(echo "scale=0; $total_throughput / $iterations" | bc -l)
    echo "$avg_throughput"
}

# Disk benchmark
run_disk_benchmark() {
    local iterations="$1"
    local total_throughput=0
    local test_file="/tmp/benchmark_test_$$"
    
    echo -e "🔄 Running disk benchmark ($iterations iterations)..."
    
    for ((i=1; i<=iterations; i++)); do
        echo -ne "   Iteration $i/$iterations... "
        
        # Write test
        local start_time=$(date +%s.%N)
        dd if=/dev/zero of="$test_file" bs=1M count=100 2>/dev/null
        sync
        local end_time=$(date +%s.%N)
        
        local duration=$(echo "$end_time - $start_time" | bc -l)
        local throughput=$(echo "scale=0; 100 / $duration" | bc -l)
        total_throughput=$(echo "$total_throughput + $throughput" | bc -l)
        
        # Cleanup
        rm -f "$test_file"
        
        echo "Write: ${throughput} MB/s"
    done
    
    local avg_throughput=$(echo "scale=0; $total_throughput / $iterations" | bc -l)
    echo "$avg_throughput"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Get CPU usage percentage
get_cpu_usage() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    printf "%.1f" "$cpu_usage"
}

# Get CPU temperature
get_cpu_temperature() {
    local temp=""
    
    # Try different temperature sources
    if [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
        local temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp=$((temp_raw / 1000))
    elif command -v sensors >/dev/null 2>&1; then
        temp=$(sensors | grep -E "Core 0|temp1" | head -1 | awk '{print $3}' | tr -d '+°C')
    fi
    
    echo "$temp"
}

# Get CPU frequency
get_cpu_frequency() {
    local freq=""
    
    if [[ -f /proc/cpuinfo ]]; then
        freq=$(grep "cpu MHz" /proc/cpuinfo | head -1 | awk '{print int($4)}')
    elif [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]]; then
        local freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
        freq=$((freq_khz / 1000))
    fi
    
    echo "$freq"
}

# Display usage bar
display_usage_bar() {
    local percentage="$1"
    local label="$2"
    local width="${3:-20}"
    
    local filled=$(echo "scale=0; $percentage * $width / 100" | bc -l 2>/dev/null || echo "0")
    local empty=$((width - filled))
    
    # Color based on usage level
    local color=""
    if (( $(echo "$percentage > 80" | bc -l) )); then
        color="\[\e[31m\]"  # Red
    elif (( $(echo "$percentage > 60" | bc -l) )); then
        color="\[\e[33m\]"  # Yellow
    else
        color="\[\e[32m\]"  # Green
    fi
    
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    
    printf "%s[%s%s\[\e[0m\]] %5.1f%%\n" "$label" "$color" "$bar" "$percentage"
}

# Setup monitoring data collection
setup_monitoring_data_collection() {
    local monitoring_dir="$1"
    
    # Create directory structure
    mkdir -p "$monitoring_dir"/{logs,alerts,reports}
    
    # Initialize monitoring configuration
    local config_file="$monitoring_dir/config.conf"
    if [[ ! -f "$config_file" ]]; then
        cat > "$config_file" << 'EOF'
# Monitoring Configuration
CPU_ALERT_THRESHOLD=80
MEMORY_ALERT_THRESHOLD=85
DISK_ALERT_THRESHOLD=90
LOAD_ALERT_THRESHOLD=5.0
TEMP_ALERT_THRESHOLD=75
EOF
    fi
}

# Check system alerts
check_system_alerts() {
    local monitoring_dir="$HOME/.bash_monitoring"
    local config_file="$monitoring_dir/config.conf"
    
    # Load alert thresholds
    [[ -f "$config_file" ]] && source "$config_file"
    
    local cpu_threshold=${CPU_ALERT_THRESHOLD:-80}
    local memory_threshold=${MEMORY_ALERT_THRESHOLD:-85}
    local temp_threshold=${TEMP_ALERT_THRESHOLD:-75}
    
    local alerts=()
    
    # Check CPU usage
    local cpu_usage=$(get_cpu_usage)
    if (( $(echo "$cpu_usage > $cpu_threshold" | bc -l) )); then
        alerts+=("🔥 CPU usage high: ${cpu_usage}%")
    fi
    
    # Check memory usage
    local mem_usage=$(free | awk '/^Mem:/ {printf "%.1f", $3*100/$2}')
    if (( $(echo "$mem_usage > $memory_threshold" | bc -l) )); then
        alerts+=("🧠 Memory usage high: ${mem_usage}%")
    fi
    
    # Check temperature
    local cpu_temp=$(get_cpu_temperature)
    if [[ -n "$cpu_temp" ]] && (( cpu_temp > temp_threshold )); then
        alerts+=("🌡️ CPU temperature high: ${cpu_temp}°C")
    fi
    
    # Display alerts
    if [[ ${#alerts[@]} -gt 0 ]]; then
        echo -e "\n🚨 ${BASHRC_RED}ALERTS${BASHRC_NC}"
        echo -e "${BASHRC_RED}$(printf '=%.0s' {1..20})${BASHRC_NC}"
        for alert in "${alerts[@]}"; do
            echo -e "$alert"
        done
    fi
}

# =============================================================================
# MODULE INITIALIZATION AND ALIASES
# =============================================================================

# Initialize monitoring system
initialize_monitoring_system() {
    local monitoring_dir="$HOME/.bash_monitoring"
    mkdir -p "$monitoring_dir"/{logs,alerts,reports,benchmarks}
    
    # Create monitoring log
    local init_log="$monitoring_dir/initialization.log"
    echo "$(date -Iseconds) - Monitoring system initialized" > "$init_log"
    
    # Check for monitoring tools and show suggestions for missing ones
    check_monitoring_tools
    
    echo -e "📊 System monitoring initialized"
}

# Check for monitoring tools availability
check_monitoring_tools() {
    local missing_tools=()
    local optional_tools=("htop" "iotop" "nethogs" "sensors" "iostat" "vmstat" "pstree")
    
    for tool in "${optional_tools[@]}"; do
        command -v "$tool" >/dev/null 2>&1 || missing_tools+=("$tool")
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "💡 ${BASHRC_YELLOW}Suggested monitoring tools:${BASHRC_NC} ${missing_tools[*]}"
        echo -e "   Install for enhanced functionality"
    fi
}

# Create convenient aliases
alias mon='sysmon'
alias cpu='sysmon cpu'
alias mem='sysmon memory'
alias procs='sysmon processes'
alias bench='sysmon benchmark'

# Advanced monitoring aliases
alias topcpu='ps axo pid,pcpu,pmem,comm --sort=-pcpu | head -20'
alias topmem='ps axo pid,pcpu,pmem,comm --sort=-pmem | head -20'
alias diskusage='df -h | grep -E "^/dev/"'
alias meminfo='cat /proc/meminfo | head -20'

# Export functions
export -f sysmon sysmon_dashboard sysmon_cpu sysmon_memory sysmon_processes sysmon_benchmark
export -f display_system_overview display_cpu_summary display_memory_summary display_disk_summary display_network_summary
export -f display_top_processes display_detailed_cpu_info display_per_core_usage display_detailed_memory_info
export -f display_memory_breakdown display_process_summary display_top_processes_detailed
export -f run_cpu_benchmark run_memory_benchmark run_disk_benchmark
export -f get_cpu_usage get_cpu_temperature get_cpu_frequency display_usage_bar
export -f setup_monitoring_data_collection check_system_alerts

# Initialize the system
initialize_monitoring_system

echo -e "${BASHRC_GREEN}✅ System Monitoring & Performance Module Loaded${BASHRC_NC}"
echo -e "${BASHRC_PURPLE}📊 System Monitoring v$MONITORING_MODULE_VERSION Ready!${BASHRC_NC}"
echo -e "${BASHRC_CYAN}💡 Try: 'sysmon', 'sysmon cpu -w', 'sysmon benchmark --all', 'sysmon processes -t 20'${BASHRC_NC}"
