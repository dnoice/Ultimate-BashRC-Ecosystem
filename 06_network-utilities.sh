#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - NETWORK UTILITIES MODULE
# File: 06_network-utilities.sh
# =============================================================================
# This module provides comprehensive network utilities with intelligent analysis,
# real-time monitoring, security scanning, performance optimization, and
# advanced network troubleshooting capabilities.
# =============================================================================

# Module metadata
declare -r NETWORK_MODULE_VERSION="2.1.0"
declare -r NETWORK_MODULE_NAME="Network Utilities"
declare -r NETWORK_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# Module initialization
echo -e "${BASHRC_CYAN}🌐 Loading Network Utilities...${BASHRC_NC}"

# =============================================================================
# INTELLIGENT NETWORK CONNECTIVITY TESTING
# =============================================================================

# Advanced network connectivity testing with intelligent analysis
netcheck() {
    local usage="Usage: netcheck [OPTIONS] [TARGET]
    
🌐 Intelligent Network Connectivity Tester
Options:
    -t, --target HOST   Target host or IP to test
    -p, --port PORT     Specific port to test (default: varies by service)
    -c, --count N       Number of tests to run (default: 4)
    -i, --interval SEC  Interval between tests (default: 1)
    -T, --timeout SEC   Timeout per test (default: 5)
    -s, --service TYPE  Test specific service (http, https, ssh, ftp, smtp, dns)
    -v, --verbose       Detailed output with timing
    -j, --json          JSON output format
    -l, --log FILE      Log results to file
    -6, --ipv6          Use IPv6 when available
    -4, --ipv4          Force IPv4 only
    -q, --quiet         Minimal output
    -h, --help          Show this help
    
Services:
    http/https  - Web connectivity (ports 80/443)
    ssh         - SSH connectivity (port 22)
    ftp         - FTP connectivity (port 21)
    smtp        - Mail server (port 25/587)
    dns         - DNS resolution (port 53)
    ping        - ICMP ping test
    
Examples:
    netcheck google.com                     # Basic connectivity test
    netcheck -s https -v google.com         # HTTPS test with verbose output
    netcheck -p 22 -c 10 server.example.com # SSH connectivity, 10 tests
    netcheck -j -l results.json google.com  # JSON output to file"

    local target=""
    local port=""
    local count=4
    local interval=1
    local timeout=5
    local service=""
    local verbose=false
    local json_output=false
    local log_file=""
    local use_ipv6=false
    local force_ipv4=false
    local quiet=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target)        target="$2"; shift 2 ;;
            -p|--port)          port="$2"; shift 2 ;;
            -c|--count)         count="$2"; shift 2 ;;
            -i|--interval)      interval="$2"; shift 2 ;;
            -T|--timeout)       timeout="$2"; shift 2 ;;
            -s|--service)       service="$2"; shift 2 ;;
            -v|--verbose)       verbose=true; shift ;;
            -j|--json)          json_output=true; shift ;;
            -l|--log)           log_file="$2"; shift 2 ;;
            -6|--ipv6)          use_ipv6=true; shift ;;
            -4|--ipv4)          force_ipv4=true; shift ;;
            -q|--quiet)         quiet=true; shift ;;
            -h|--help)          echo "$usage"; return 0 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  target="$1"; shift ;;
        esac
    done
    
    [[ -z "$target" ]] && { echo "Target required"; return 1; }
    
    # Set default port based on service
    if [[ -z "$port" && -n "$service" ]]; then
        case "$service" in
            http)   port=80 ;;
            https)  port=443 ;;
            ssh)    port=22 ;;
            ftp)    port=21 ;;
            smtp)   port=25 ;;
            dns)    port=53 ;;
            ping)   port="" ;;
            *)      echo "Unknown service: $service"; return 1 ;;
        esac
    fi
    
    [[ "$quiet" == "false" ]] && {
        echo -e "🌐 Network Connectivity Test"
        echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}"
        echo -e "🎯 Target: $target"
        [[ -n "$port" ]] && echo -e "🔌 Port: $port"
        [[ -n "$service" ]] && echo -e "🔧 Service: $service"
        echo -e "📊 Tests: $count (${interval}s interval)"
        echo
    }
    
    # Initialize results tracking
    local results=()
    local success_count=0
    local total_time=0
    local min_time=999999
    local max_time=0
    local start_time=$(date +%s.%N)
    
    # Resolve target IP
    local target_ip=$(resolve_target_ip "$target" "$force_ipv4" "$use_ipv6")
    [[ "$verbose" == "true" && "$quiet" == "false" ]] && echo -e "🔍 Resolved: $target → $target_ip"
    
    # Run connectivity tests
    for ((i=1; i<=count; i++)); do
        local test_start=$(date +%s.%N)
        local test_result=""
        local response_time=""
        
        if [[ "$service" == "ping" || (-z "$service" && -z "$port") ]]; then
            # ICMP ping test
            test_result=$(run_ping_test "$target" "$timeout")
            local ping_success=$?
        elif [[ -n "$port" ]]; then
            # TCP port test
            test_result=$(run_tcp_test "$target_ip" "$port" "$timeout")
            local ping_success=$?
        else
            # HTTP/HTTPS test
            test_result=$(run_http_test "$target" "$service" "$timeout")
            local ping_success=$?
        fi
        
        local test_end=$(date +%s.%N)
        response_time=$(echo "$test_end - $test_start" | bc -l 2>/dev/null | sed 's/^\./0./')
        
        # Track results
        results+=("$ping_success:$response_time:$test_result")
        
        if [[ $ping_success -eq 0 ]]; then
            ((success_count++))
            total_time=$(echo "$total_time + $response_time" | bc -l)
            
            # Update min/max times
            if (( $(echo "$response_time < $min_time" | bc -l) )); then
                min_time="$response_time"
            fi
            if (( $(echo "$response_time > $max_time" | bc -l) )); then
                max_time="$response_time"
            fi
            
            [[ "$quiet" == "false" ]] && echo -e "✅ Test $i: Success (${response_time}s) - $test_result"
        else
            [[ "$quiet" == "false" ]] && echo -e "❌ Test $i: Failed - $test_result"
        fi
        
        # Wait between tests (except for last test)
        [[ $i -lt $count ]] && sleep "$interval"
    done
    
    local end_time=$(date +%s.%N)
    local total_duration=$(echo "$end_time - $start_time" | bc -l)
    
    # Calculate statistics
    local success_rate=$(echo "scale=1; $success_count * 100 / $count" | bc -l)
    local avg_time="0"
    [[ $success_count -gt 0 ]] && avg_time=$(echo "scale=3; $total_time / $success_count" | bc -l)
    
    # Generate output
    if [[ "$json_output" == "true" ]]; then
        generate_json_output "$target" "$target_ip" "$port" "$service" "$count" "$success_count" "$success_rate" "$avg_time" "$min_time" "$max_time" "$total_duration" "${results[@]}"
    else
        [[ "$quiet" == "false" ]] && {
            echo
            echo -e "📊 ${BASHRC_PURPLE}Test Results Summary${BASHRC_NC}"
            echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..30})${BASHRC_NC}"
            echo -e "🎯 Target: $target ($target_ip)"
            echo -e "✅ Success Rate: ${success_rate}% ($success_count/$count)"
            [[ $success_count -gt 0 ]] && {
                echo -e "⏱️  Response Time: avg=${avg_time}s, min=${min_time}s, max=${max_time}s"
            }
            echo -e "⏰ Total Duration: ${total_duration}s"
            
            # Quality assessment
            assess_connection_quality "$success_rate" "$avg_time"
        }
    fi
    
    # Log results if requested
    if [[ -n "$log_file" ]]; then
        log_connectivity_results "$log_file" "$target" "$target_ip" "$success_rate" "$avg_time" "${results[@]}"
    fi
    
    # Return appropriate exit code
    [[ $success_count -gt 0 ]] && return 0 || return 1
}

# Resolve target IP address
resolve_target_ip() {
    local target="$1"
    local force_ipv4="$2"
    local use_ipv6="$3"
    
    # If already an IP, return as-is
    if [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$target"
        return 0
    fi
    
    # DNS resolution
    local resolved_ip=""
    if [[ "$force_ipv4" == "true" ]]; then
        resolved_ip=$(dig +short A "$target" 2>/dev/null | head -1)
    elif [[ "$use_ipv6" == "true" ]]; then
        resolved_ip=$(dig +short AAAA "$target" 2>/dev/null | head -1)
    else
        resolved_ip=$(dig +short "$target" 2>/dev/null | head -1)
    fi
    
    [[ -n "$resolved_ip" ]] && echo "$resolved_ip" || echo "$target"
}

# Run ping test
run_ping_test() {
    local target="$1"
    local timeout="$2"
    
    local ping_result
    if ping -c 1 -W "$timeout" "$target" >/dev/null 2>&1; then
        ping_result=$(ping -c 1 -W "$timeout" "$target" 2>&1 | grep "time=" | sed 's/.*time=\([0-9.]*\).*/\1/')
        echo "ICMP ping successful (${ping_result}ms)"
        return 0
    else
        echo "ICMP ping failed or timeout"
        return 1
    fi
}

# Run TCP port test
run_tcp_test() {
    local target="$1"
    local port="$2"
    local timeout="$3"
    
    if timeout "$timeout" bash -c "echo >/dev/tcp/$target/$port" 2>/dev/null; then
        echo "TCP connection successful"
        return 0
    else
        echo "TCP connection failed or timeout"
        return 1
    fi
}

# Run HTTP/HTTPS test
run_http_test() {
    local target="$1"
    local service="$2"
    local timeout="$3"
    
    local protocol="${service:-http}"
    local url="${protocol}://${target}"
    
    if command -v curl >/dev/null 2>&1; then
        local http_code=$(curl -o /dev/null -s -w "%{http_code}" --connect-timeout "$timeout" --max-time "$timeout" "$url" 2>/dev/null)
        if [[ "$http_code" =~ ^[23] ]]; then
            echo "HTTP response: $http_code"
            return 0
        else
            echo "HTTP failed: $http_code"
            return 1
        fi
    else
        # Fallback to basic TCP test on port 80/443
        local port=80
        [[ "$service" == "https" ]] && port=443
        run_tcp_test "$target" "$port" "$timeout"
    fi
}

# Assess connection quality
assess_connection_quality() {
    local success_rate="$1"
    local avg_time="$2"
    
    local quality="Unknown"
    local quality_icon="❓"
    
    if (( $(echo "$success_rate >= 95" | bc -l) )); then
        if (( $(echo "$avg_time < 0.1" | bc -l) )); then
            quality="Excellent"
            quality_icon="🟢"
        elif (( $(echo "$avg_time < 0.5" | bc -l) )); then
            quality="Good"
            quality_icon="🟡"
        else
            quality="Fair"
            quality_icon="🟠"
        fi
    elif (( $(echo "$success_rate >= 80" | bc -l) )); then
        quality="Poor"
        quality_icon="🔴"
    else
        quality="Very Poor"
        quality_icon="💀"
    fi
    
    echo -e "$quality_icon Quality: $quality"
}

# Generate JSON output
generate_json_output() {
    local target="$1" target_ip="$2" port="$3" service="$4" count="$5"
    local success_count="$6" success_rate="$7" avg_time="$8" min_time="$9" max_time="${10}"
    local total_duration="${11}"
    shift 11
    local results=("$@")
    
    echo "{"
    echo "  \"target\": \"$target\","
    echo "  \"target_ip\": \"$target_ip\","
    [[ -n "$port" ]] && echo "  \"port\": $port,"
    [[ -n "$service" ]] && echo "  \"service\": \"$service\","
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"test_count\": $count,"
    echo "  \"successful\": $success_count,"
    echo "  \"success_rate\": $success_rate,"
    echo "  \"timing\": {"
    echo "    \"average\": $avg_time,"
    [[ "$success_count" -gt 0 ]] && {
        echo "    \"minimum\": $min_time,"
        echo "    \"maximum\": $max_time,"
    }
    echo "    \"total_duration\": $total_duration"
    echo "  },"
    echo "  \"results\": ["
    
    for i in "${!results[@]}"; do
        local result="${results[$i]}"
        IFS=':' read -r success time message <<< "$result"
        local comma=""
        [[ $i -lt $((${#results[@]} - 1)) ]] && comma=","
        echo "    {"
        echo "      \"test_id\": $((i+1)),"
        echo "      \"success\": $([ "$success" -eq 0 ] && echo "true" || echo "false"),"
        echo "      \"response_time\": $time,"
        echo "      \"message\": \"$message\""
        echo "    }$comma"
    done
    
    echo "  ]"
    echo "}"
}

# Log connectivity results
log_connectivity_results() {
    local log_file="$1" target="$2" target_ip="$3" success_rate="$4" avg_time="$5"
    shift 5
    local results=("$@")
    
    local timestamp=$(date -Iseconds)
    echo "$timestamp|$target|$target_ip|$success_rate|$avg_time|${#results[@]}" >> "$log_file"
}

# =============================================================================
# ADVANCED PORT SCANNING AND SERVICE DETECTION
# =============================================================================

# Comprehensive port scanner with service detection
portscan() {
    local usage="Usage: portscan [OPTIONS] TARGET [PORTS]
    
🔍 Advanced Port Scanner with Service Detection
Options:
    -t, --target HOST   Target host or IP
    -p, --ports RANGE   Port range (e.g., 80, 80-443, 22,80,443)
    -f, --fast          Fast scan (top 1000 ports)
    -F, --full          Full scan (all 65535 ports)
    -s, --stealth       Stealth mode (slower but less detectable)
    -T, --timeout SEC   Timeout per port (default: 2)
    -j, --threads N     Number of parallel threads (default: 10)
    -v, --verbose       Verbose output with service detection
    -o, --output FILE   Save results to file
    --json              JSON output format
    --services-only     Show only open ports with services
    -h, --help          Show this help
    
Port Ranges:
    Single port:    80
    Range:          80-443
    Multiple:       22,80,443,8080
    Predefined:     --fast (top 1000), --full (all ports)
    
Examples:
    portscan 192.168.1.1                    # Scan common ports
    portscan -f google.com                   # Fast scan of top 1000 ports
    portscan -p 80-443 -v example.com       # Scan web ports with details
    portscan -F --json -o scan.json host    # Full scan with JSON output"

    local target=""
    local ports=""
    local fast_scan=false
    local full_scan=false
    local stealth_mode=false
    local timeout=2
    local threads=10
    local verbose=false
    local output_file=""
    local json_output=false
    local services_only=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target)        target="$2"; shift 2 ;;
            -p|--ports)         ports="$2"; shift 2 ;;
            -f|--fast)          fast_scan=true; shift ;;
            -F|--full)          full_scan=true; shift ;;
            -s|--stealth)       stealth_mode=true; shift ;;
            -T|--timeout)       timeout="$2"; shift 2 ;;
            -j|--threads)       threads="$2"; shift 2 ;;
            -v|--verbose)       verbose=true; shift ;;
            -o|--output)        output_file="$2"; shift 2 ;;
            --json)             json_output=true; shift ;;
            --services-only)    services_only=true; shift ;;
            -h|--help)          echo "$usage"; return 0 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  [[ -z "$target" ]] && target="$1" || ports="$1"; shift ;;
        esac
    done
    
    [[ -z "$target" ]] && { echo "Target required"; return 1; }
    
    # Determine port list
    local port_list=()
    if [[ "$full_scan" == "true" ]]; then
        port_list=($(seq 1 65535))
    elif [[ "$fast_scan" == "true" ]]; then
        port_list=($(get_common_ports))
    elif [[ -n "$ports" ]]; then
        port_list=($(parse_port_range "$ports"))
    else
        port_list=($(get_common_ports | head -100))
    fi
    
    echo -e "🔍 Advanced Port Scanner"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}"
    echo -e "🎯 Target: $target"
    echo -e "🔌 Ports: ${#port_list[@]} ports to scan"
    [[ "$stealth_mode" == "true" ]] && echo -e "🥷 Stealth mode enabled"
    echo -e "⚡ Threads: $threads"
    echo
    
    local scan_start=$(date +%s)
    local open_ports=()
    local scan_results=()
    
    # Create scan results directory
    local scan_dir="/tmp/portscan_$$"
    mkdir -p "$scan_dir"
    
    # Run port scan with threading
    echo -e "🚀 Starting scan..."
    
    # Split ports into chunks for threading
    local chunk_size=$(((${#port_list[@]} + threads - 1) / threads))
    local pids=()
    
    for ((i=0; i<${#port_list[@]}; i+=chunk_size)); do
        local chunk=("${port_list[@]:i:chunk_size}")
        scan_port_chunk "$target" "$timeout" "$stealth_mode" "$scan_dir/chunk_$i" "${chunk[@]}" &
        pids+=($!)
    done
    
    # Wait for all scans to complete
    for pid in "${pids[@]}"; do
        wait "$pid"
    done
    
    # Collect results
    for result_file in "$scan_dir"/chunk_*; do
        [[ -f "$result_file" ]] && {
            while IFS=':' read -r port status service banner; do
                scan_results+=("$port:$status:$service:$banner")
                [[ "$status" == "open" ]] && open_ports+=("$port")
            done < "$result_file"
        }
    done
    
    # Clean up
    rm -rf "$scan_dir"
    
    local scan_end=$(date +%s)
    local scan_duration=$((scan_end - scan_start))
    
    # Process and display results
    display_scan_results "$target" "${#port_list[@]}" "${#open_ports[@]}" "$scan_duration" "$verbose" "$services_only" "${scan_results[@]}"
    
    # Output to file if requested
    if [[ -n "$output_file" ]]; then
        if [[ "$json_output" == "true" ]]; then
            output_scan_json "$target" "${#port_list[@]}" "${#open_ports[@]}" "$scan_duration" "$output_file" "${scan_results[@]}"
        else
            output_scan_text "$target" "${#port_list[@]}" "${#open_ports[@]}" "$scan_duration" "$output_file" "${scan_results[@]}"
        fi
        echo -e "💾 Results saved to: $output_file"
    fi
    
    echo -e "\n✅ Scan completed in ${scan_duration}s - ${#open_ports[@]} open ports found"
}

# Get common ports list
get_common_ports() {
    echo "21 22 23 25 53 80 110 111 135 139 143 443 993 995 1723 3306 3389 5432 5900 8080 8443 8888 9090"
}

# Parse port range specification
parse_port_range() {
    local port_spec="$1"
    local ports=()
    
    # Split by comma
    IFS=',' read -ra port_parts <<< "$port_spec"
    
    for part in "${port_parts[@]}"; do
        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            # Range: start-end
            local start="${BASH_REMATCH[1]}"
            local end="${BASH_REMATCH[2]}"
            ports+=($(seq "$start" "$end"))
        elif [[ "$part" =~ ^[0-9]+$ ]]; then
            # Single port
            ports+=("$part")
        fi
    done
    
    printf '%s\n' "${ports[@]}" | sort -n | uniq
}

# Scan chunk of ports (for threading)
scan_port_chunk() {
    local target="$1"
    local timeout="$2"
    local stealth="$3"
    local output_file="$4"
    shift 4
    local ports=("$@")
    
    for port in "${ports[@]}"; do
        local status="closed"
        local service=""
        local banner=""
        
        # TCP connect test
        if timeout "$timeout" bash -c "exec 3<>/dev/tcp/$target/$port" 2>/dev/null; then
            status="open"
            exec 3<&-
            
            # Service detection
            service=$(detect_service "$port")
            
            # Banner grabbing (if not stealth)
            if [[ "$stealth" == "false" ]]; then
                banner=$(grab_banner "$target" "$port" "$timeout")
            fi
        fi
        
        echo "$port:$status:$service:$banner" >> "$output_file"
        
        # Stealth delay
        [[ "$stealth" == "true" ]] && sleep 0.1
    done
}

# Detect service by port
detect_service() {
    local port="$1"
    
    case "$port" in
        21)   echo "ftp" ;;
        22)   echo "ssh" ;;
        23)   echo "telnet" ;;
        25)   echo "smtp" ;;
        53)   echo "dns" ;;
        80)   echo "http" ;;
        110)  echo "pop3" ;;
        143)  echo "imap" ;;
        443)  echo "https" ;;
        993)  echo "imaps" ;;
        995)  echo "pop3s" ;;
        3306) echo "mysql" ;;
        3389) echo "rdp" ;;
        5432) echo "postgresql" ;;
        5900) echo "vnc" ;;
        8080) echo "http-proxy" ;;
        *)    echo "unknown" ;;
    esac
}

# Grab service banner
grab_banner() {
    local target="$1"
    local port="$2"
    local timeout="$3"
    local banner=""
    
    case "$port" in
        21|22|25|110|143)
            # Services that send banner on connect
            banner=$(timeout "$timeout" bash -c "exec 3<>/dev/tcp/$target/$port; read -t1 banner <&3; echo \$banner" 2>/dev/null | tr -d '\r\n' | head -c 50)
            ;;
        80|8080)
            # HTTP banner
            banner=$(echo -e "HEAD / HTTP/1.0\r\n\r\n" | timeout "$timeout" nc "$target" "$port" 2>/dev/null | head -1 | tr -d '\r\n')
            ;;
    esac
    
    echo "$banner"
}

# Display scan results
display_scan_results() {
    local target="$1"
    local total_ports="$2"
    local open_count="$3"
    local duration="$4"
    local verbose="$5"
    local services_only="$6"
    shift 6
    local results=("$@")
    
    echo -e "\n📊 ${BASHRC_PURPLE}Scan Results${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..30})${BASHRC_NC}"
    echo -e "🎯 Host: $target"
    echo -e "🔌 Scanned: $total_ports ports"
    echo -e "✅ Open: $open_count ports"
    echo -e "⏱️ Duration: ${duration}s"
    echo
    
    if [[ $open_count -gt 0 ]]; then
        echo -e "🔓 ${BASHRC_GREEN}Open Ports:${BASHRC_NC}"
        for result in "${results[@]}"; do
            IFS=':' read -r port status service banner <<< "$result"
            
            [[ "$status" != "open" ]] && continue
            [[ "$services_only" == "true" && "$service" == "unknown" ]] && continue
            
            if [[ "$verbose" == "true" ]]; then
                echo -e "   🔌 $port/$service"
                [[ -n "$banner" ]] && echo -e "      📝 Banner: $banner"
            else
                echo -e "   🔌 $port/$service"
            fi
        done
    else
        echo -e "🔒 No open ports found"
    fi
}

# =============================================================================
# NETWORK PERFORMANCE ANALYSIS
# =============================================================================

# Comprehensive network performance testing
netperf() {
    local usage="Usage: netperf [OPTIONS] [TARGET]
    
⚡ Network Performance Analysis Tool
Options:
    -t, --target HOST   Target for performance testing
    -d, --duration SEC  Test duration in seconds (default: 10)
    -i, --interval SEC  Reporting interval (default: 1)
    -b, --bandwidth     Bandwidth test (requires iperf3)
    -l, --latency       Latency analysis (ping-based)
    -j, --jitter        Jitter measurement
    -p, --packet-loss   Packet loss analysis
    -s, --size BYTES    Packet size for tests (default: 64)
    -c, --count N       Number of test packets (default: 100)
    --mtu              MTU discovery test
    --route            Route performance analysis
    -o, --output FILE   Save results to file
    --csv              CSV output format
    -v, --verbose       Detailed analysis
    -h, --help          Show this help
    
Tests:
    Default:    Latency, jitter, and packet loss analysis
    Bandwidth:  Throughput testing (requires iperf3 server)
    MTU:        Maximum Transmission Unit discovery
    Route:      Per-hop latency analysis
    
Examples:
    netperf google.com                      # Basic performance test
    netperf -b -d 30 speedtest.net         # 30-second bandwidth test
    netperf -l -j -p --verbose 8.8.8.8     # Comprehensive latency analysis
    netperf --mtu --route example.com      # MTU and route analysis"

    local target=""
    local duration=10
    local interval=1
    local test_bandwidth=false
    local test_latency=true
    local test_jitter=false
    local test_packet_loss=false
    local packet_size=64
    local packet_count=100
    local test_mtu=false
    local test_route=false
    local output_file=""
    local csv_output=false
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target)        target="$2"; shift 2 ;;
            -d|--duration)      duration="$2"; shift 2 ;;
            -i|--interval)      interval="$2"; shift 2 ;;
            -b|--bandwidth)     test_bandwidth=true; shift ;;
            -l|--latency)       test_latency=true; shift ;;
            -j|--jitter)        test_jitter=true; shift ;;
            -p|--packet-loss)   test_packet_loss=true; shift ;;
            -s|--size)          packet_size="$2"; shift 2 ;;
            -c|--count)         packet_count="$2"; shift 2 ;;
            --mtu)              test_mtu=true; shift ;;
            --route)            test_route=true; shift ;;
            -o|--output)        output_file="$2"; shift 2 ;;
            --csv)              csv_output=true; shift ;;
            -v|--verbose)       verbose=true; shift ;;
            -h|--help)          echo "$usage"; return 0 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  target="$1"; shift ;;
        esac
    done
    
    [[ -z "$target" ]] && { echo "Target required"; return 1; }
    
    echo -e "⚡ Network Performance Analysis"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}"
    echo -e "🎯 Target: $target"
    echo -e "⏱️ Duration: ${duration}s"
    echo
    
    local results=()
    
    # Latency test
    if [[ "$test_latency" == "true" ]]; then
        echo -e "📊 Running latency test..."
        local latency_result=$(run_latency_test "$target" "$packet_count" "$packet_size")
        results+=("latency:$latency_result")
        [[ "$verbose" == "true" ]] && echo -e "   $latency_result"
    fi
    
    # Jitter test  
    if [[ "$test_jitter" == "true" ]]; then
        echo -e "📈 Running jitter test..."
        local jitter_result=$(run_jitter_test "$target" "$packet_count")
        results+=("jitter:$jitter_result")
        [[ "$verbose" == "true" ]] && echo -e "   $jitter_result"
    fi
    
    # Packet loss test
    if [[ "$test_packet_loss" == "true" ]]; then
        echo -e "📉 Running packet loss test..."
        local loss_result=$(run_packet_loss_test "$target" "$packet_count")
        results+=("packet_loss:$loss_result")
        [[ "$verbose" == "true" ]] && echo -e "   $loss_result"
    fi
    
    # MTU discovery
    if [[ "$test_mtu" == "true" ]]; then
        echo -e "🔍 Running MTU discovery..."
        local mtu_result=$(run_mtu_discovery "$target")
        results+=("mtu:$mtu_result")
        [[ "$verbose" == "true" ]] && echo -e "   $mtu_result"
    fi
    
    # Route analysis
    if [[ "$test_route" == "true" ]]; then
        echo -e "🛣️ Running route analysis..."
        local route_result=$(run_route_analysis "$target")
        results+=("route:$route_result")
        [[ "$verbose" == "true" ]] && echo -e "   $route_result"
    fi
    
    # Bandwidth test
    if [[ "$test_bandwidth" == "true" ]]; then
        echo -e "🚀 Running bandwidth test..."
        local bandwidth_result=$(run_bandwidth_test "$target" "$duration")
        results+=("bandwidth:$bandwidth_result")
        [[ "$verbose" == "true" ]] && echo -e "   $bandwidth_result"
    fi
    
    # Display summary
    display_performance_summary "$target" "${results[@]}"
    
    # Output to file
    if [[ -n "$output_file" ]]; then
        if [[ "$csv_output" == "true" ]]; then
            output_performance_csv "$target" "$output_file" "${results[@]}"
        else
            output_performance_text "$target" "$output_file" "${results[@]}"
        fi
        echo -e "💾 Results saved to: $output_file"
    fi
}

# Run latency test
run_latency_test() {
    local target="$1"
    local count="$2"
    local size="$3"
    
    local ping_output=$(ping -c "$count" -s "$size" -q "$target" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        local stats=$(echo "$ping_output" | tail -1)
        local min max avg mdev
        
        if [[ "$stats" =~ min/avg/max/mdev\ =\ ([0-9.]+)/([0-9.]+)/([0-9.]+)/([0-9.]+) ]]; then
            min="${BASH_REMATCH[1]}"
            avg="${BASH_REMATCH[2]}"
            max="${BASH_REMATCH[3]}"
            mdev="${BASH_REMATCH[4]}"
            echo "min=${min}ms,avg=${avg}ms,max=${max}ms,mdev=${mdev}ms"
        else
            echo "failed"
        fi
    else
        echo "failed"
    fi
}

# Run jitter test
run_jitter_test() {
    local target="$1"
    local count="$2"
    
    local times=()
    local prev_time=""
    local jitter_sum=0
    local jitter_count=0
    
    # Collect ping times
    for ((i=1; i<=count; i++)); do
        local ping_time=$(ping -c 1 -W 2 "$target" 2>/dev/null | grep "time=" | sed 's/.*time=\([0-9.]*\).*/\1/')
        if [[ -n "$ping_time" ]]; then
            times+=("$ping_time")
            
            if [[ -n "$prev_time" ]]; then
                local jitter=$(echo "$ping_time - $prev_time" | bc -l | tr -d '-')
                jitter_sum=$(echo "$jitter_sum + $jitter" | bc -l)
                ((jitter_count++))
            fi
            
            prev_time="$ping_time"
        fi
    done
    
    if [[ $jitter_count -gt 0 ]]; then
        local avg_jitter=$(echo "scale=3; $jitter_sum / $jitter_count" | bc -l)
        echo "avg=${avg_jitter}ms,samples=${jitter_count}"
    else
        echo "failed"
    fi
}

# Run packet loss test
run_packet_loss_test() {
    local target="$1"
    local count="$2"
    
    local ping_output=$(ping -c "$count" -q "$target" 2>/dev/null)
    if [[ $? -eq 0 ]]; then
        local packet_loss=$(echo "$ping_output" | grep "packet loss" | sed 's/.*\([0-9.]*\)% packet loss.*/\1/')
        echo "loss=${packet_loss}%,packets=$count"
    else
        echo "failed"
    fi
}

# Run MTU discovery
run_mtu_discovery() {
    local target="$1"
    local mtu=1500
    
    # Binary search for maximum MTU
    local min_mtu=68
    local max_mtu=9000
    local found_mtu=0
    
    while [[ $min_mtu -le $max_mtu ]]; do
        local test_mtu=$(( (min_mtu + max_mtu) / 2 ))
        
        if ping -c 1 -M do -s $((test_mtu - 28)) "$target" >/dev/null 2>&1; then
            found_mtu=$test_mtu
            min_mtu=$((test_mtu + 1))
        else
            max_mtu=$((test_mtu - 1))
        fi
    done
    
    echo "mtu=${found_mtu}bytes"
}

# Run route analysis
run_route_analysis() {
    local target="$1"
    
    local traceroute_output=""
    if command -v traceroute >/dev/null 2>&1; then
        traceroute_output=$(traceroute -n -q 1 "$target" 2>/dev/null | head -10)
    elif command -v tracepath >/dev/null 2>&1; then
        traceroute_output=$(tracepath -n "$target" 2>/dev/null | head -10)
    else
        echo "no_traceroute_tool"
        return
    fi
    
    local hop_count=$(echo "$traceroute_output" | grep -c "^ *[0-9]")
    local avg_hop_time=$(echo "$traceroute_output" | grep -o '[0-9.]*ms' | awk '{sum+=$1; count++} END {if(count>0) printf "%.2f", sum/count; else print "0"}')
    
    echo "hops=${hop_count},avg_hop_time=${avg_hop_time}ms"
}

# Run bandwidth test
run_bandwidth_test() {
    local target="$1"
    local duration="$2"
    
    if command -v iperf3 >/dev/null 2>&1; then
        local iperf_output=$(iperf3 -c "$target" -t "$duration" -f M 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            local bandwidth=$(echo "$iperf_output" | grep "sender" | awk '{print $(NF-1)}')
            echo "bandwidth=${bandwidth}Mbps"
        else
            echo "iperf3_failed"
        fi
    else
        # Fallback to HTTP download test if available
        if command -v curl >/dev/null 2>&1; then
            local download_url="http://$target/speedtest"
            local download_speed=$(curl -w "%{speed_download}" -s -o /dev/null --max-time "$duration" "$download_url" 2>/dev/null)
            if [[ -n "$download_speed" && "$download_speed" != "0" ]]; then
                local mbps=$(echo "scale=2; $download_speed * 8 / 1000000" | bc -l)
                echo "bandwidth_est=${mbps}Mbps"
            else
                echo "no_bandwidth_tool"
            fi
        else
            echo "no_bandwidth_tool"
        fi
    fi
}

# Display performance summary
display_performance_summary() {
    local target="$1"
    shift
    local results=("$@")
    
    echo -e "\n📊 ${BASHRC_PURPLE}Performance Summary${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..30})${BASHRC_NC}"
    echo -e "🎯 Target: $target"
    
    for result in "${results[@]}"; do
        IFS=':' read -r test_type data <<< "$result"
        
        case "$test_type" in
            latency)
                echo -e "⏱️ Latency: $data"
                ;;
            jitter)
                echo -e "📈 Jitter: $data"
                ;;
            packet_loss)
                echo -e "📉 Packet Loss: $data"
                ;;
            mtu)
                echo -e "📏 MTU: $data"
                ;;
            route)
                echo -e "🛣️ Route: $data"
                ;;
            bandwidth)
                echo -e "🚀 Bandwidth: $data"
                ;;
        esac
    done
}

# =============================================================================
# NETWORK SECURITY SCANNING
# =============================================================================

# Basic network security scanner
netsec() {
    local usage="Usage: netsec [OPTIONS] TARGET
    
🔒 Network Security Scanner
Options:
    -t, --target HOST   Target host or network
    -p, --ports RANGE   Port range to scan for vulnerabilities
    -s, --ssl           SSL/TLS security analysis
    -d, --dns           DNS security analysis
    -h, --headers       HTTP security headers analysis
    -v, --vulnerabilities Common vulnerability checks
    -o, --output FILE   Save results to file
    --severity LEVEL    Minimum severity (low, medium, high)
    --timeout SEC       Timeout for tests (default: 5)
    -q, --quiet         Minimal output
    --help              Show this help
    
Checks:
    SSL/TLS:    Certificate validation, cipher analysis, protocol versions
    DNS:        DNS configuration security, zone transfer attempts
    Headers:    HTTP security headers, information disclosure
    Vulns:      Common service vulnerabilities and misconfigurations
    
Examples:
    netsec example.com                      # Basic security scan
    netsec -s -h --severity high site.com  # SSL and headers, high severity only
    netsec -v -o report.txt 192.168.1.1    # Vulnerability scan with report"

    local target=""
    local ports=""
    local check_ssl=false
    local check_dns=false
    local check_headers=false
    local check_vulns=false
    local output_file=""
    local min_severity="low"
    local timeout=5
    local quiet=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--target)            target="$2"; shift 2 ;;
            -p|--ports)             ports="$2"; shift 2 ;;
            -s|--ssl)               check_ssl=true; shift ;;
            -d|--dns)               check_dns=true; shift ;;
            -h|--headers)           check_headers=true; shift ;;
            -v|--vulnerabilities)   check_vulns=true; shift ;;
            -o|--output)            output_file="$2"; shift 2 ;;
            --severity)             min_severity="$2"; shift 2 ;;
            --timeout)              timeout="$2"; shift 2 ;;
            -q|--quiet)             quiet=true; shift ;;
            --help)                 echo "$usage"; return 0 ;;
            -*)                     echo "Unknown option: $1" >&2; return 1 ;;
            *)                      target="$1"; shift ;;
        esac
    done
    
    [[ -z "$target" ]] && { echo "Target required"; return 1; }
    
    # Default to all checks if none specified
    if [[ "$check_ssl" == "false" && "$check_dns" == "false" && 
          "$check_headers" == "false" && "$check_vulns" == "false" ]]; then
        check_ssl=true
        check_dns=true
        check_headers=true
        check_vulns=true
    fi
    
    [[ "$quiet" == "false" ]] && {
        echo -e "🔒 Network Security Scanner"
        echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}"
        echo -e "🎯 Target: $target"
        echo -e "⚠️ Minimum Severity: $min_severity"
        echo
    }
    
    local findings=()
    local scan_start=$(date +%s)
    
    # SSL/TLS Analysis
    if [[ "$check_ssl" == "true" ]]; then
        [[ "$quiet" == "false" ]] && echo -e "🔐 Analyzing SSL/TLS..."
        local ssl_findings=($(analyze_ssl_security "$target" "$timeout"))
        findings+=("${ssl_findings[@]}")
    fi
    
    # DNS Analysis
    if [[ "$check_dns" == "true" ]]; then
        [[ "$quiet" == "false" ]] && echo -e "🌐 Analyzing DNS security..."
        local dns_findings=($(analyze_dns_security "$target"))
        findings+=("${dns_findings[@]}")
    fi
    
    # HTTP Headers Analysis
    if [[ "$check_headers" == "true" ]]; then
        [[ "$quiet" == "false" ]] && echo -e "📋 Analyzing HTTP headers..."
        local header_findings=($(analyze_http_headers "$target" "$timeout"))
        findings+=("${header_findings[@]}")
    fi
    
    # Vulnerability Checks
    if [[ "$check_vulns" == "true" ]]; then
        [[ "$quiet" == "false" ]] && echo -e "🔍 Checking for vulnerabilities..."
        local vuln_findings=($(check_common_vulnerabilities "$target" "$timeout"))
        findings+=("${vuln_findings[@]}")
    fi
    
    local scan_end=$(date +%s)
    local scan_duration=$((scan_end - scan_start))
    
    # Display results
    display_security_findings "$target" "$min_severity" "$scan_duration" "${findings[@]}"
    
    # Output to file
    if [[ -n "$output_file" ]]; then
        output_security_report "$target" "$min_severity" "$scan_duration" "$output_file" "${findings[@]}"
        [[ "$quiet" == "false" ]] && echo -e "💾 Security report saved to: $output_file"
    fi
}

# Analyze SSL/TLS security
analyze_ssl_security() {
    local target="$1"
    local timeout="$2"
    local findings=()
    
    if command -v openssl >/dev/null 2>&1; then
        # Check SSL certificate
        local cert_info=$(echo | timeout "$timeout" openssl s_client -connect "$target:443" -servername "$target" 2>/dev/null | openssl x509 -noout -dates -subject 2>/dev/null)
        
        if [[ -n "$cert_info" ]]; then
            # Check certificate expiry
            local not_after=$(echo "$cert_info" | grep "notAfter=" | cut -d= -f2-)
            if [[ -n "$not_after" ]]; then
                local expiry_date=$(date -d "$not_after" +%s 2>/dev/null)
                local current_date=$(date +%s)
                local days_until_expiry=$(( (expiry_date - current_date) / 86400 ))
                
                if [[ $days_until_expiry -lt 30 ]]; then
                    findings+=("ssl:high:Certificate expires in $days_until_expiry days")
                elif [[ $days_until_expiry -lt 90 ]]; then
                    findings+=("ssl:medium:Certificate expires in $days_until_expiry days")
                fi
            fi
            
            # Check for weak ciphers
            local ciphers=$(echo | timeout "$timeout" openssl s_client -connect "$target:443" -cipher 'LOW:!aNULL' 2>/dev/null | grep "Cipher is")
            if [[ "$ciphers" =~ (NULL|EXPORT|DES|RC4|MD5) ]]; then
                findings+=("ssl:high:Weak cipher suites detected")
            fi
            
        else
            findings+=("ssl:medium:SSL/TLS not available or connection failed")
        fi
    fi
    
    printf '%s\n' "${findings[@]}"
}

# Analyze DNS security
analyze_dns_security() {
    local target="$1"
    local findings=()
    
    if command -v dig >/dev/null 2>&1; then
        # Check for DNS zone transfer
        local zone_transfer=$(dig @"$target" "$target" axfr +short 2>/dev/null)
        if [[ -n "$zone_transfer" ]]; then
            findings+=("dns:high:DNS zone transfer allowed")
        fi
        
        # Check for SPF record
        local spf_record=$(dig "$target" txt +short 2>/dev/null | grep "v=spf1")
        if [[ -z "$spf_record" ]]; then
            findings+=("dns:medium:No SPF record found")
        fi
        
        # Check for DMARC record
        local dmarc_record=$(dig "_dmarc.$target" txt +short 2>/dev/null | grep "v=DMARC1")
        if [[ -z "$dmarc_record" ]]; then
            findings+=("dns:medium:No DMARC record found")
        fi
        
        # Check for DNSSEC
        local dnssec=$(dig "$target" +dnssec +short 2>/dev/null | grep "RRSIG")
        if [[ -z "$dnssec" ]]; then
            findings+=("dns:low:DNSSEC not implemented")
        fi
    fi
    
    printf '%s\n' "${findings[@]}"
}

# Analyze HTTP headers
analyze_http_headers() {
    local target="$1"
    local timeout="$2"
    local findings=()
    
    if command -v curl >/dev/null 2>&1; then
        local headers=$(curl -s -I -m "$timeout" "https://$target" 2>/dev/null || curl -s -I -m "$timeout" "http://$target" 2>/dev/null)
        
        if [[ -n "$headers" ]]; then
            # Check for security headers
            [[ ! "$headers" =~ Strict-Transport-Security ]] && findings+=("headers:medium:Missing HSTS header")
            [[ ! "$headers" =~ X-Frame-Options ]] && findings+=("headers:medium:Missing X-Frame-Options header")
            [[ ! "$headers" =~ X-Content-Type-Options ]] && findings+=("headers:medium:Missing X-Content-Type-Options header")
            [[ ! "$headers" =~ X-XSS-Protection ]] && findings+=("headers:medium:Missing X-XSS-Protection header")
            [[ ! "$headers" =~ Content-Security-Policy ]] && findings+=("headers:medium:Missing Content-Security-Policy header")
            
            # Check for information disclosure
            [[ "$headers" =~ Server: ]] && {
                local server_header=$(echo "$headers" | grep -i "server:" | head -1)
                findings+=("headers:low:Server information disclosed: ${server_header#*: }")
            }
            [[ "$headers" =~ X-Powered-By: ]] && findings+=("headers:low:Technology stack disclosed in X-Powered-By header")
        fi
    fi
    
    printf '%s\n' "${findings[@]}"
}

# Check common vulnerabilities
check_common_vulnerabilities() {
    local target="$1"
    local timeout="$2"
    local findings=()
    
    # Check for common web vulnerabilities
    if command -v curl >/dev/null 2>&1; then
        # Directory traversal test
        local dir_traversal=$(curl -s -m "$timeout" "http://$target/../../etc/passwd" 2>/dev/null | head -5)
        if [[ "$dir_traversal" =~ root:.*:/bin/ ]]; then
            findings+=("vuln:high:Directory traversal vulnerability detected")
        fi
        
        # Check for default pages
        local default_page=$(curl -s -m "$timeout" -o /dev/null -w "%{http_code}" "http://$target/admin" 2>/dev/null)
        if [[ "$default_page" == "200" ]]; then
            findings+=("vuln:medium:Default admin page accessible")
        fi
        
        # Check for backup files
        local backup_files=("backup.sql" "database.bak" ".env" "config.php.bak")
        for backup_file in "${backup_files[@]}"; do
            local backup_check=$(curl -s -m "$timeout" -o /dev/null -w "%{http_code}" "http://$target/$backup_file" 2>/dev/null)
            if [[ "$backup_check" == "200" ]]; then
                findings+=("vuln:high:Backup file exposed: $backup_file")
            fi
        done
    fi
    
    printf '%s\n' "${findings[@]}"
}

# Display security findings
display_security_findings() {
    local target="$1"
    local min_severity="$2"
    local duration="$3"
    shift 3
    local findings=("$@")
    
    echo -e "\n🔒 ${BASHRC_PURPLE}Security Scan Results${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}"
    echo -e "🎯 Target: $target"
    echo -e "⏱️ Scan Duration: ${duration}s"
    echo -e "📊 Total Findings: ${#findings[@]}"
    echo
    
    # Count findings by severity
    local high_count=0 medium_count=0 low_count=0
    
    for finding in "${findings[@]}"; do
        IFS=':' read -r category severity message <<< "$finding"
        case "$severity" in
            high)   ((high_count++)) ;;
            medium) ((medium_count++)) ;;
            low)    ((low_count++)) ;;
        esac
    done
    
    echo -e "📈 Severity Distribution:"
    echo -e "   🔴 High: $high_count"
    echo -e "   🟡 Medium: $medium_count"
    echo -e "   🔵 Low: $low_count"
    echo
    
    if [[ ${#findings[@]} -gt 0 ]]; then
        echo -e "🔍 ${BASHRC_YELLOW}Detailed Findings:${BASHRC_NC}"
        
        for finding in "${findings[@]}"; do
            IFS=':' read -r category severity message <<< "$finding"
            
            # Filter by minimum severity
            case "$min_severity" in
                high)
                    [[ "$severity" != "high" ]] && continue
                    ;;
                medium)
                    [[ "$severity" == "low" ]] && continue
                    ;;
            esac
            
            local severity_icon="🔵"
            case "$severity" in
                high)   severity_icon="🔴" ;;
                medium) severity_icon="🟡" ;;
            esac
            
            local category_icon="🔧"
            case "$category" in
                ssl)     category_icon="🔐" ;;
                dns)     category_icon="🌐" ;;
                headers) category_icon="📋" ;;
                vuln)    category_icon="🚨" ;;
            esac
            
            echo -e "   $severity_icon $category_icon [$category] $message"
        done
    else
        echo -e "✅ ${BASHRC_GREEN}No security issues found${BASHRC_NC}"
    fi
}

# =============================================================================
# MODULE INITIALIZATION AND ALIASES
# =============================================================================

# Initialize network utilities system
initialize_network_system() {
    local network_dir="$HOME/.bash_network_utilities"
    mkdir -p "$network_dir"/{logs,reports,cache}
    
    # Test for required tools and show warnings for missing ones
    check_network_tools
    
    echo -e "🌐 Network utilities system initialized"
}

# Check for network tools availability
check_network_tools() {
    local missing_tools=()
    
    # Essential tools
    command -v ping >/dev/null 2>&1 || missing_tools+=("ping")
    command -v nc >/dev/null 2>&1 || missing_tools+=("netcat")
    
    # Optional but recommended tools
    local optional_tools=("dig" "nslookup" "curl" "wget" "traceroute" "iperf3" "openssl")
    for tool in "${optional_tools[@]}"; do
        command -v "$tool" >/dev/null 2>&1 || missing_tools+=("$tool (optional)")
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "⚠️ ${BASHRC_YELLOW}Missing network tools:${BASHRC_NC} ${missing_tools[*]}"
        echo -e "💡 Install them for full functionality"
    fi
}

# Create convenient aliases
alias netstat='netcheck'
alias scan='portscan'
alias perf='netperf'  
alias sec='netsec'

# Advanced network aliases
alias myip='curl -s http://ipinfo.io/ip 2>/dev/null || curl -s https://api.ipify.org 2>/dev/null || echo "Unable to determine public IP"'
alias localip='ip route get 8.8.8.8 | awk "{print \$7}" | head -1 2>/dev/null || ifconfig | grep -Eo "inet (addr:)?([0-9]*\.){3}[0-9]*" | grep -v 127.0.0.1 | head -1'
alias ports='netstat -tuln'
alias connections='netstat -tuln | grep ESTABLISHED'

# Export functions
export -f netcheck resolve_target_ip run_ping_test run_tcp_test run_http_test assess_connection_quality
export -f generate_json_output log_connectivity_results
export -f portscan get_common_ports parse_port_range scan_port_chunk detect_service grab_banner display_scan_results
export -f netperf run_latency_test run_jitter_test run_packet_loss_test run_mtu_discovery run_route_analysis run_bandwidth_test display_performance_summary
export -f netsec analyze_ssl_security analyze_dns_security analyze_http_headers check_common_vulnerabilities display_security_findings

# Initialize the system
initialize_network_system

echo -e "${BASHRC_GREEN}✅ Network Utilities Module Loaded${BASHRC_NC}"
echo -e "${BASHRC_PURPLE}🌐 Network Utilities v$NETWORK_MODULE_VERSION Ready!${BASHRC_NC}"
echo -e "${BASHRC_CYAN}💡 Try: 'netcheck google.com', 'portscan -f example.com', 'netperf -l 8.8.8.8', 'netsec -s site.com'${BASHRC_NC}"
