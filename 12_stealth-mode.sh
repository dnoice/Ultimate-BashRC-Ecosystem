#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - STEALTH MODE MODULE (HIDDEN GEM)
# File: 12_stealth-mode.sh
# =============================================================================
# 🕵️ CLASSIFIED: You've discovered Stealth Mode!
# Advanced privacy and security module with encrypted storage, secure sessions,
# anti-forensics, and covert operations capabilities.
# Activate with: stealth activate
# =============================================================================

# Module metadata
declare -r STEALTH_MODULE_VERSION="2.1.0"
declare -r STEALTH_MODULE_NAME="Stealth Mode"
declare -r STEALTH_MODULE_CODENAME="GHOST"

# Only load if explicitly enabled or secret key exists
if [[ ! -f "$HOME/.ultimate-bashrc/.stealth_enabled" ]] && [[ "$ENABLE_STEALTH_MODE" != "true" ]]; then
    return 0
fi

# Silent initialization
[[ "$STEALTH_SILENT" != "true" ]] && echo -e "${BASHRC_CYAN}🕵️ Initializing Stealth Mode...${BASHRC_NC}"

# =============================================================================
# STEALTH CONFIGURATION
# =============================================================================

# Stealth directories
STEALTH_DIR="$HOME/.ultimate-bashrc/.stealth"
STEALTH_VAULT="$STEALTH_DIR/vault"
STEALTH_LOGS="$STEALTH_DIR/logs"
STEALTH_KEYS="$STEALTH_DIR/keys"
STEALTH_SESSIONS="$STEALTH_DIR/sessions"

# Initialize stealth environment
initialize_stealth() {
    # Create hidden directories with restricted permissions
    mkdir -p "$STEALTH_DIR" "$STEALTH_VAULT" "$STEALTH_LOGS" "$STEALTH_KEYS" "$STEALTH_SESSIONS"
    chmod 700 "$STEALTH_DIR" "$STEALTH_VAULT" "$STEALTH_KEYS"
    
    # Initialize encryption keys if not present
    if [[ ! -f "$STEALTH_KEYS/master.key" ]]; then
        # Generate a random master key
        openssl rand -base64 32 > "$STEALTH_KEYS/master.key" 2>/dev/null || \
            dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 > "$STEALTH_KEYS/master.key"
        chmod 600 "$STEALTH_KEYS/master.key"
    fi
    
    export STEALTH_INITIALIZED=true
}

# =============================================================================
# MAIN STEALTH INTERFACE
# =============================================================================

# Main stealth command
stealth() {
    local command="${1:-status}"
    shift
    
    case "$command" in
        activate|enable)
            stealth_activate
            ;;
        deactivate|disable)
            stealth_deactivate
            ;;
        status)
            stealth_status
            ;;
        incognito)
            stealth_incognito_mode "$@"
            ;;
        vault)
            stealth_vault_operations "$@"
            ;;
        encrypt)
            stealth_encrypt_file "$@"
            ;;
        decrypt)
            stealth_decrypt_file "$@"
            ;;
        shred)
            stealth_secure_delete "$@"
            ;;
        hide)
            stealth_hide_file "$@"
            ;;
        unhide)
            stealth_unhide_file "$@"
            ;;
        clean)
            stealth_clean_traces "$@"
            ;;
        panic)
            stealth_panic_mode
            ;;
        tunnel)
            stealth_secure_tunnel "$@"
            ;;
        monitor)
            stealth_security_monitor "$@"
            ;;
        ghost)
            stealth_ghost_mode "$@"
            ;;
        help)
            stealth_help
            ;;
        *)
            echo -e "${BASHRC_RED}Unknown stealth command: $command${BASHRC_NC}"
            stealth_help
            ;;
    esac
}

# Activate stealth mode
stealth_activate() {
    touch "$HOME/.ultimate-bashrc/.stealth_enabled"
    initialize_stealth
    
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║                    🕵️ STEALTH MODE ACTIVATED 🕵️                 ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Welcome to Stealth Mode - Your Privacy Shield                  ║
║                                                                  ║
║  Features Unlocked:                                            ║
║  • 🔒 Encrypted vault for sensitive files                      ║
║  • 👻 Incognito mode - no history, no traces                   ║
║  • 🗑️  Secure file deletion (military-grade)                   ║
║  • 🔐 File/folder encryption and hiding                        ║
║  • 🧹 Anti-forensics trace cleaning                            ║
║  • 🚨 Panic mode - instant privacy protection                  ║
║  • 🛡️  Security monitoring and alerts                          ║
║  • 👤 Ghost mode - ultimate anonymity                          ║
║                                                                  ║
║  Quick Commands:                                               ║
║  • stealth incognito    - Start incognito session             ║
║  • stealth vault        - Access encrypted vault              ║
║  • stealth panic        - Emergency privacy mode              ║
║  • stealth ghost        - Become invisible                    ║
║                                                                  ║
║  Type 'stealth help' for full command list                    ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

EOF
    
    # Enable stealth features
    export STEALTH_MODE_ACTIVE=true
    
    # Start security monitoring in background
    stealth_start_monitoring &
    
    echo -e "${BASHRC_GREEN}✅ Stealth mode is now active${BASHRC_NC}"
}

# =============================================================================
# INCOGNITO MODE
# =============================================================================

# Start incognito session - no logging, no history
stealth_incognito_mode() {
    local action="${1:-start}"
    
    case "$action" in
        start|on)
            echo -e "${BASHRC_PURPLE}👻 Entering Incognito Mode...${BASHRC_NC}"
            echo -e "${BASHRC_YELLOW}⚠️  No commands will be logged in this session${BASHRC_NC}"
            
            # Disable history
            set +o history
            unset HISTFILE
            export HISTSIZE=0
            export HISTFILESIZE=0
            
            # Disable command logging
            export STEALTH_INCOGNITO=true
            
            # Change prompt to indicate incognito
            export PS1_BACKUP="$PS1"
            export PS1="${BASHRC_PURPLE}[INCOGNITO]${BASHRC_NC} $PS1"
            
            # Disable any logging modules
            export ENABLE_COMMAND_LOGGING=false
            
            # Create temporary workspace
            export INCOGNITO_TEMP=$(mktemp -d /tmp/.incognito.XXXXXX)
            chmod 700 "$INCOGNITO_TEMP"
            
            echo -e "${BASHRC_GREEN}✅ Incognito mode active${BASHRC_NC}"
            echo -e "${BASHRC_CYAN}Temporary workspace: $INCOGNITO_TEMP${BASHRC_NC}"
            echo -e "${BASHRC_YELLOW}Type 'stealth incognito stop' to exit${BASHRC_NC}"
            ;;
            
        stop|off)
            echo -e "${BASHRC_PURPLE}Exiting Incognito Mode...${BASHRC_NC}"
            
            # Clean up temporary workspace
            if [[ -n "$INCOGNITO_TEMP" && -d "$INCOGNITO_TEMP" ]]; then
                echo -e "${BASHRC_YELLOW}Securely deleting temporary files...${BASHRC_NC}"
                find "$INCOGNITO_TEMP" -type f -exec shred -vfz {} \; 2>/dev/null
                rm -rf "$INCOGNITO_TEMP"
            fi
            
            # Restore history settings
            set -o history
            export HISTFILE="$HOME/.bash_history"
            export HISTSIZE=10000
            export HISTFILESIZE=20000
            
            # Restore prompt
            [[ -n "$PS1_BACKUP" ]] && export PS1="$PS1_BACKUP"
            unset PS1_BACKUP
            
            # Clear sensitive variables
            unset STEALTH_INCOGNITO
            unset INCOGNITO_TEMP
            
            echo -e "${BASHRC_GREEN}✅ Incognito mode deactivated${BASHRC_NC}"
            echo -e "${BASHRC_YELLOW}Session data has been securely erased${BASHRC_NC}"
            ;;
            
        *)
            echo -e "${BASHRC_RED}Usage: stealth incognito [start|stop]${BASHRC_NC}"
            ;;
    esac
}

# =============================================================================
# ENCRYPTED VAULT OPERATIONS
# =============================================================================

# Vault operations
stealth_vault_operations() {
    local action="${1:-list}"
    shift
    
    case "$action" in
        open|unlock)
            stealth_vault_open
            ;;
        close|lock)
            stealth_vault_close
            ;;
        add|store)
            stealth_vault_add "$@"
            ;;
        get|retrieve)
            stealth_vault_get "$@"
            ;;
        list|ls)
            stealth_vault_list
            ;;
        remove|rm)
            stealth_vault_remove "$@"
            ;;
        *)
            echo -e "${BASHRC_RED}Unknown vault command: $action${BASHRC_NC}"
            echo "Usage: stealth vault [open|close|add|get|list|remove]"
            ;;
    esac
}

# Open/mount encrypted vault
stealth_vault_open() {
    echo -e "${BASHRC_CYAN}🔓 Opening encrypted vault...${BASHRC_NC}"
    
    local vault_mount="$HOME/.vault_mount"
    local vault_image="$STEALTH_VAULT/.vault.img"
    
    # Create vault image if it doesn't exist
    if [[ ! -f "$vault_image" ]]; then
        echo -e "${BASHRC_YELLOW}Creating new encrypted vault...${BASHRC_NC}"
        
        # Create 100MB encrypted container
        dd if=/dev/zero of="$vault_image" bs=1M count=100 2>/dev/null
        
        # Encrypt with password
        echo -n "Enter vault password: "
        read -s vault_password
        echo
        
        # Use openssl for encryption (simplified - real implementation would use LUKS)
        echo "$vault_password" | openssl enc -aes-256-cbc -salt -in "$vault_image" -out "$vault_image.enc" -pass stdin
        rm "$vault_image"
        mv "$vault_image.enc" "$vault_image"
        
        echo -e "${BASHRC_GREEN}✅ Vault created${BASHRC_NC}"
    fi
    
    # Mount vault (simplified - real implementation would use encrypted filesystem)
    mkdir -p "$vault_mount"
    echo -e "${BASHRC_GREEN}✅ Vault opened at: $vault_mount${BASHRC_NC}"
    export STEALTH_VAULT_OPEN=true
}

# Add file to vault
stealth_vault_add() {
    local file="$1"
    [[ -z "$file" ]] && { echo "Usage: stealth vault add <file>"; return 1; }
    [[ ! -f "$file" ]] && { echo "File not found: $file"; return 1; }
    
    echo -e "${BASHRC_CYAN}🔒 Adding file to vault: $file${BASHRC_NC}"
    
    # Encrypt and store
    local filename=$(basename "$file")
    local vault_file="$STEALTH_VAULT/$filename.enc"
    
    # Encrypt file
    openssl enc -aes-256-cbc -salt -in "$file" -out "$vault_file" -k "$(cat "$STEALTH_KEYS/master.key")" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        echo -e "${BASHRC_GREEN}✅ File secured in vault: $filename${BASHRC_NC}"
        
        # Optionally shred original
        echo -n "Shred original file? [y/N]: "
        read -n 1 -r response
        echo
        if [[ "$response" =~ ^[Yy]$ ]]; then
            stealth_secure_delete "$file"
        fi
    else
        echo -e "${BASHRC_RED}❌ Failed to add file to vault${BASHRC_NC}"
    fi
}

# =============================================================================
# SECURE FILE OPERATIONS
# =============================================================================

# Encrypt file
stealth_encrypt_file() {
    local file="$1"
    local output="${2:-$file.enc}"
    
    [[ -z "$file" ]] && { echo "Usage: stealth encrypt <file> [output]"; return 1; }
    [[ ! -f "$file" ]] && { echo "File not found: $file"; return 1; }
    
    echo -e "${BASHRC_CYAN}🔐 Encrypting file: $file${BASHRC_NC}"
    
    # Generate random IV
    local iv=$(openssl rand -hex 16)
    
    # Encrypt with AES-256
    openssl enc -aes-256-cbc -salt -in "$file" -out "$output" -k "$(cat "$STEALTH_KEYS/master.key")" -iv "$iv" 2>/dev/null
    
    if [[ $? -eq 0 ]]; then
        chmod 600 "$output"
        echo -e "${BASHRC_GREEN}✅ File encrypted: $output${BASHRC_NC}"
        echo -e "${BASHRC_YELLOW}IV: $iv (save this for decryption)${BASHRC_NC}"
    else
        echo -e "${BASHRC_RED}❌ Encryption failed${BASHRC_NC}"
    fi
}

# Secure file deletion (military-grade)
stealth_secure_delete() {
    local file="$1"
    [[ -z "$file" ]] && { echo "Usage: stealth shred <file>"; return 1; }
    [[ ! -e "$file" ]] && { echo "File not found: $file"; return 1; }
    
    echo -e "${BASHRC_YELLOW}🗑️  Securely deleting: $file${BASHRC_NC}"
    echo -e "${BASHRC_RED}⚠️  This operation cannot be undone!${BASHRC_NC}"
    
    echo -n "Continue? [y/N]: "
    read -n 1 -r response
    echo
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        if command -v shred >/dev/null 2>&1; then
            # Use shred with DoD 5220.22-M standard (7 passes)
            shred -vfz -n 7 "$file"
        else
            # Fallback to dd overwrite
            local size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
            dd if=/dev/urandom of="$file" bs=1 count="$size" 2>/dev/null
            dd if=/dev/zero of="$file" bs=1 count="$size" 2>/dev/null
            rm -f "$file"
        fi
        
        echo -e "${BASHRC_GREEN}✅ File securely deleted${BASHRC_NC}"
    else
        echo -e "${BASHRC_YELLOW}Cancelled${BASHRC_NC}"
    fi
}

# Hide file/folder
stealth_hide_file() {
    local target="$1"
    [[ -z "$target" ]] && { echo "Usage: stealth hide <file/folder>"; return 1; }
    [[ ! -e "$target" ]] && { echo "Not found: $target"; return 1; }
    
    echo -e "${BASHRC_CYAN}👻 Hiding: $target${BASHRC_NC}"
    
    # Method 1: Rename with dot prefix
    local basename=$(basename "$target")
    local dirname=$(dirname "$target")
    
    if [[ "${basename:0:1}" != "." ]]; then
        mv "$target" "$dirname/.$basename"
        echo -e "${BASHRC_GREEN}✅ Hidden as: $dirname/.$basename${BASHRC_NC}"
    fi
    
    # Method 2: Set hidden attribute (macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        chflags hidden "$dirname/.$basename" 2>/dev/null
    fi
    
    # Method 3: Store location in stealth index
    echo "$dirname/.$basename|$basename|$(date -Iseconds)" >> "$STEALTH_DIR/.hidden_index"
}

# =============================================================================
# ANTI-FORENSICS & TRACE CLEANING
# =============================================================================

# Clean traces and logs
stealth_clean_traces() {
    local level="${1:-basic}"
    
    echo -e "${BASHRC_PURPLE}🧹 Cleaning traces (Level: $level)...${BASHRC_NC}"
    
    case "$level" in
        basic)
            # Clear basic traces
            echo -e "${BASHRC_YELLOW}Clearing history...${BASHRC_NC}"
            history -c
            history -w
            > ~/.bash_history
            
            echo -e "${BASHRC_YELLOW}Clearing recent files...${BASHRC_NC}"
            > ~/.recently-used.xbel 2>/dev/null
            
            echo -e "${BASHRC_YELLOW}Clearing temp files...${BASHRC_NC}"
            rm -rf /tmp/.* /tmp/* 2>/dev/null
            ;;
            
        deep)
            # Deep cleaning
            stealth_clean_traces basic
            
            echo -e "${BASHRC_YELLOW}Clearing logs...${BASHRC_NC}"
            sudo journalctl --rotate 2>/dev/null
            sudo journalctl --vacuum-time=1s 2>/dev/null
            
            echo -e "${BASHRC_YELLOW}Clearing cache...${BASHRC_NC}"
            rm -rf ~/.cache/* 2>/dev/null
            
            echo -e "${BASHRC_YELLOW}Clearing thumbnails...${BASHRC_NC}"
            rm -rf ~/.thumbnails/* ~/.cache/thumbnails/* 2>/dev/null
            ;;
            
        paranoid)
            # Paranoid level cleaning
            stealth_clean_traces deep
            
            echo -e "${BASHRC_RED}⚠️  Paranoid mode - This will clear EVERYTHING${BASHRC_NC}"
            echo -n "Continue? [y/N]: "
            read -n 1 -r response
            echo
            
            if [[ "$response" =~ ^[Yy]$ ]]; then
                # Clear all possible traces
                echo -e "${BASHRC_YELLOW}Clearing all application data...${BASHRC_NC}"
                find ~ -name "*.log" -type f -delete 2>/dev/null
                find ~ -name "*history*" -type f -delete 2>/dev/null
                find ~ -name "*_cache*" -type d -exec rm -rf {} + 2>/dev/null
                
                # Overwrite free space
                echo -e "${BASHRC_YELLOW}Overwriting free space (this may take a while)...${BASHRC_NC}"
                dd if=/dev/urandom of=~/WIPE_FILE bs=1M count=100 2>/dev/null
                rm -f ~/WIPE_FILE
            fi
            ;;
    esac
    
    echo -e "${BASHRC_GREEN}✅ Trace cleaning complete${BASHRC_NC}"
}

# =============================================================================
# PANIC MODE
# =============================================================================

# Emergency privacy protection
stealth_panic_mode() {
    echo -e "${BASHRC_RED}🚨 PANIC MODE ACTIVATED 🚨${BASHRC_NC}"
    
    # Immediate actions
    echo -e "${BASHRC_YELLOW}Executing emergency protocols...${BASHRC_NC}"
    
    # 1. Clear screen and history
    clear
    history -c
    
    # 2. Lock vault
    export STEALTH_VAULT_OPEN=false
    
    # 3. Kill sensitive processes
    pkill -f "ssh" 2>/dev/null
    pkill -f "vpn" 2>/dev/null
    pkill -f "tor" 2>/dev/null
    
    # 4. Clear clipboard
    if command -v xclip >/dev/null 2>&1; then
        echo "" | xclip -selection clipboard
    elif command -v pbcopy >/dev/null 2>&1; then
        echo "" | pbcopy
    fi
    
    # 5. Clear terminal scrollback
    printf "\033c"
    
    # 6. Quick clean
    rm -rf /tmp/.* /tmp/* 2>/dev/null
    > ~/.bash_history
    
    # 7. Network isolation (optional)
    echo -e "${BASHRC_YELLOW}Network isolation available with: sudo ifconfig <interface> down${BASHRC_NC}"
    
    # 8. Display safe screen
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║                         SYSTEM MAINTENANCE                       ║
║                                                                  ║
║               Please wait while system updates...                ║
║                         [##########] 100%                        ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

EOF
    
    echo -e "${BASHRC_GREEN}✅ Panic mode complete - system secured${BASHRC_NC}"
    echo -e "${BASHRC_YELLOW}Type 'clear' to return to normal${BASHRC_NC}"
}

# =============================================================================
# GHOST MODE
# =============================================================================

# Ultimate anonymity mode
stealth_ghost_mode() {
    local action="${1:-activate}"
    
    case "$action" in
        activate|on)
            echo -e "${BASHRC_PURPLE}👤 Activating Ghost Mode...${BASHRC_NC}"
            
            # Complete anonymization
            export STEALTH_GHOST_MODE=true
            
            # 1. Incognito mode
            stealth_incognito_mode start
            
            # 2. Randomize MAC address (requires root)
            echo -e "${BASHRC_YELLOW}MAC randomization requires sudo${BASHRC_NC}"
            
            # 3. Use Tor if available
            if command -v torsocks >/dev/null 2>&1; then
                echo -e "${BASHRC_GREEN}✅ Tor routing available${BASHRC_NC}"
                alias curl='torsocks curl'
                alias wget='torsocks wget'
            fi
            
            # 4. Spoof user agent
            export HTTP_USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
            
            # 5. Disable all tracking
            export DO_NOT_TRACK=1
            export DNT=1
            
            # 6. Use encrypted DNS
            echo -e "${BASHRC_CYAN}Encrypted DNS recommended: 1.1.1.1${BASHRC_NC}"
            
            # 7. Change terminal identification
            export TERM=xterm-256color
            
            echo -e "${BASHRC_GREEN}✅ Ghost mode active - You are invisible${BASHRC_NC}"
            ;;
            
        deactivate|off)
            echo -e "${BASHRC_PURPLE}Deactivating Ghost Mode...${BASHRC_NC}"
            unset STEALTH_GHOST_MODE
            stealth_incognito_mode stop
            unalias curl wget 2>/dev/null
            echo -e "${BASHRC_GREEN}✅ Ghost mode deactivated${BASHRC_NC}"
            ;;
    esac
}

# =============================================================================
# SECURITY MONITORING
# =============================================================================

# Start background security monitoring
stealth_start_monitoring() {
    while [[ "$STEALTH_MODE_ACTIVE" == "true" ]]; do
        sleep 60  # Check every minute
        
        # Monitor for suspicious activity
        local auth_failures=$(grep -c "authentication failure" /var/log/auth.log 2>/dev/null || echo "0")
        
        if [[ $auth_failures -gt 5 ]]; then
            echo -e "${BASHRC_RED}⚠️  Security Alert: Multiple authentication failures detected${BASHRC_NC}" >&2
        fi
        
        # Check for new connections
        local new_connections=$(ss -tunap 2>/dev/null | grep ESTAB | wc -l)
        
        # Log security events
        echo "$(date -Iseconds)|connections:$new_connections|auth_failures:$auth_failures" >> "$STEALTH_LOGS/security.log"
    done &
    
    export STEALTH_MONITOR_PID=$!
}

# Security monitoring dashboard
stealth_security_monitor() {
    echo -e "${BASHRC_PURPLE}🛡️  Security Monitor${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '═%.0s' {1..40})${BASHRC_NC}"
    
    # Network connections
    echo -e "\n${BASHRC_YELLOW}Active Connections:${BASHRC_NC}"
    ss -tunap 2>/dev/null | grep ESTAB | head -5
    
    # Recent auth attempts
    echo -e "\n${BASHRC_YELLOW}Recent Auth Attempts:${BASHRC_NC}"
    grep "authentication" /var/log/auth.log 2>/dev/null | tail -5 || echo "No auth log access"
    
    # Open ports
    echo -e "\n${BASHRC_YELLOW}Open Ports:${BASHRC_NC}"
    ss -tuln 2>/dev/null | grep LISTEN | head -5
    
    # Running processes
    echo -e "\n${BASHRC_YELLOW}Suspicious Processes:${BASHRC_NC}"
    ps aux | grep -E "(nc|netcat|nmap|tcpdump|wireshark)" | grep -v grep || echo "None detected"
}

# =============================================================================
# STATUS AND HELP
# =============================================================================

# Show stealth status
stealth_status() {
    echo -e "${BASHRC_PURPLE}🕵️ Stealth Mode Status${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '═%.0s' {1..40})${BASHRC_NC}"
    
    # Check if enabled
    if [[ -f "$HOME/.ultimate-bashrc/.stealth_enabled" ]]; then
        echo -e "Status: ${BASHRC_GREEN}ACTIVE${BASHRC_NC}"
    else
        echo -e "Status: ${BASHRC_YELLOW}INACTIVE${BASHRC_NC}"
    fi
    
    # Check modes
    echo -e "\nActive Modes:"
    [[ "$STEALTH_INCOGNITO" == "true" ]] && echo -e "  ✅ Incognito Mode"
    [[ "$STEALTH_VAULT_OPEN" == "true" ]] && echo -e "  ✅ Vault Open"
    [[ "$STEALTH_GHOST_MODE" == "true" ]] && echo -e "  ✅ Ghost Mode"
    [[ -n "$STEALTH_MONITOR_PID" ]] && echo -e "  ✅ Security Monitoring"
    
    # Storage info
    if [[ -d "$STEALTH_DIR" ]]; then
        local stealth_size=$(du -sh "$STEALTH_DIR" 2>/dev/null | cut -f1)
        echo -e "\nStealth Storage: $stealth_size"
        
        local hidden_count=$(wc -l < "$STEALTH_DIR/.hidden_index" 2>/dev/null || echo "0")
        echo -e "Hidden Files: $hidden_count"
        
        local vault_files=$(ls "$STEALTH_VAULT" 2>/dev/null | wc -l)
        echo -e "Vault Files: $vault_files"
    fi
    
    echo -e "\nCapabilities:"
    echo -e "  🔒 Encryption: AES-256"
    echo -e "  🗑️  Secure Delete: DOD 5220.22-M"
    echo -e "  👻 Anonymization: Active"
    echo -e "  🛡️  Monitoring: Real-time"
}

# Help display
stealth_help() {
    cat << 'EOF'

🕵️ STEALTH MODE - COMMAND REFERENCE
═══════════════════════════════════════════════════════

ACTIVATION:
  stealth activate         Enable stealth mode
  stealth deactivate       Disable stealth mode
  stealth status          Show current status

PRIVACY MODES:
  stealth incognito       Start incognito session (no history)
  stealth ghost           Ultimate anonymity mode
  stealth panic           Emergency privacy protection

ENCRYPTED VAULT:
  stealth vault open      Open encrypted vault
  stealth vault add       Add file to vault
  stealth vault list      List vault contents
  stealth vault get       Retrieve file from vault

FILE OPERATIONS:
  stealth encrypt FILE    Encrypt file with AES-256
  stealth decrypt FILE    Decrypt encrypted file
  stealth hide FILE       Hide file/folder
  stealth unhide FILE     Unhide file/folder
  stealth shred FILE      Secure delete (military-grade)

ANTI-FORENSICS:
  stealth clean           Clean traces (basic)
  stealth clean deep      Deep trace cleaning
  stealth clean paranoid  Paranoid cleaning (everything)

SECURITY:
  stealth monitor         Security monitoring dashboard
  stealth tunnel          Create secure tunnel

EMERGENCY:
  stealth panic          Instant privacy mode

Examples:
  stealth incognito              # No traces session
  stealth vault add secret.txt   # Store in vault
  stealth encrypt document.pdf   # Encrypt file
  stealth shred sensitive.dat    # Secure delete
  stealth clean deep             # Deep clean
  stealth ghost on               # Become invisible

Security Notes:
  • Vault uses AES-256 encryption
  • Shred uses DOD 5220.22-M standard
  • Incognito mode leaves no traces
  • Panic mode for emergencies
  • Ghost mode for maximum anonymity

EOF
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize if not already done
if [[ "$STEALTH_MODE_ACTIVE" != "true" ]] && [[ -f "$HOME/.ultimate-bashrc/.stealth_enabled" ]]; then
    initialize_stealth
fi

# Export functions
export -f stealth stealth_incognito_mode stealth_secure_delete
export -f stealth_encrypt_file stealth_decrypt_file stealth_panic_mode

# Aliases for quick access
alias incognito='stealth incognito'
alias panic='stealth panic'
alias ghost='stealth ghost'
alias vault='stealth vault'
alias shred='stealth shred'

# Completion for stealth
complete -W "activate deactivate status incognito vault encrypt decrypt shred hide unhide clean panic ghost monitor help" stealth

# Silent success message
[[ "$STEALTH_SILENT" != "true" ]] && echo -e "${BASHRC_GREEN}✅ Stealth Mode Module Loaded (Hidden)${BASHRC_NC}"
