#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - EASTER EGG DISCOVERY SYSTEM
# File: .easter_eggs.sh
# =============================================================================
# 🥚 This file contains the secret discovery mechanisms for hidden modules
# Source this in your main .bashrc for the full experience!
# =============================================================================

# Hidden module discovery flags
EASTER_EGGS_DIR="$HOME/.ultimate-bashrc/.easter_eggs"
mkdir -p "$EASTER_EGGS_DIR" 2>/dev/null

# =============================================================================
# SECRET DISCOVERY MECHANISMS
# =============================================================================

# Counter for certain command patterns
declare -g ULTIMATE_COMMAND_COUNTER=0
declare -g KONAMI_SEQUENCE=""

# Track command patterns for discovery
track_command_for_eggs() {
    local cmd="$1"
    
    # Increment counter for ultimate commands
    if [[ "$cmd" =~ ^ultimate ]]; then
        ((ULTIMATE_COMMAND_COUNTER++))
        
        # Discover assistant after using ultimate commands 42 times
        if [[ $ULTIMATE_COMMAND_COUNTER -eq 42 ]] && [[ ! -f "$EASTER_EGGS_DIR/.assistant_unlocked" ]]; then
            unlock_secret_assistant
        fi
    fi
    
    # Check for specific command sequences
    check_secret_sequences "$cmd"
}

# Check for secret command sequences
check_secret_sequences() {
    local cmd="$1"
    
    # The Matrix sequence: "matrix" typed 3 times
    if [[ "$cmd" == "matrix" ]]; then
        MATRIX_COUNT=$((${MATRIX_COUNT:-0} + 1))
        if [[ $MATRIX_COUNT -eq 3 ]]; then
            unlock_matrix_mode
            MATRIX_COUNT=0
        fi
    else
        MATRIX_COUNT=0
    fi
    
    # Hacker sequence: "sudo hack the planet"
    if [[ "$cmd" == "sudo hack the planet" ]]; then
        unlock_stealth_mode
    fi
    
    # Secret phrase: "i am root"
    if [[ "$cmd" == "i am root" ]] || [[ "$cmd" == "i am groot" ]]; then
        show_secret_message
    fi
    
    # Developer mode: "developer developer developer"
    if [[ "$cmd" == "developer developer developer" ]]; then
        unlock_developer_mode
    fi
}

# =============================================================================
# UNLOCK FUNCTIONS
# =============================================================================

# Unlock Secret AI Assistant
unlock_secret_assistant() {
    touch "$EASTER_EGGS_DIR/.assistant_unlocked"
    touch "$HOME/.ultimate-bashrc/.assistant_discovered"
    
    clear
    cat << 'EOF'

    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⣿⣿⣿⠟⠋⠉⠉⠉⠉⠉⠉⠉⠉⠉⠉⠙⠻⣿⣿⣿⣿⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⣿⡿⠁                     ⠈⢿⣿⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⡿⠁   🎉 ACHIEVEMENT UNLOCKED! 🎉   ⠈⢿⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⠇                          ⠸⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿   SECRET AI ASSISTANT DISCOVERED!    ⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿                              ⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿  You've unlocked JARVIS, your personal  ⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿  bash AI assistant!                   ⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿                              ⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⡄ Type 'assistant enable' to activate  ⢠⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⣷⡀                         ⢀⣾⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⣿⣷⣄                     ⣠⣾⣿⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⣿⣿⣿⣷⣤⣀⣀⣀⣀⣀⣀⣀⣀⣀⣠⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿
    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿

EOF
    
    sleep 3
    
    # Load the assistant module
    if [[ -f "$ULTIMATE_BASHRC_MODULES_DIR/11_secret-assistant.sh" ]]; then
        export LOAD_SECRET_ASSISTANT=true
        source "$ULTIMATE_BASHRC_MODULES_DIR/11_secret-assistant.sh"
    fi
    
    echo -e "\n${BASHRC_PURPLE}🤖 The AI Assistant is now available!${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}Type 'assistant help' to get started${BASHRC_NC}\n"
}

# Unlock Stealth Mode
unlock_stealth_mode() {
    touch "$EASTER_EGGS_DIR/.stealth_unlocked"
    touch "$HOME/.ultimate-bashrc/.stealth_discovered"
    
    clear
    echo -e "${BASHRC_GREEN}"
    cat << 'EOF'
    
    ██╗  ██╗ █████╗  ██████╗██╗  ██╗    ████████╗██╗  ██╗███████╗
    ██║  ██║██╔══██╗██╔════╝██║ ██╔╝    ╚══██╔══╝██║  ██║██╔════╝
    ███████║███████║██║     █████╔╝        ██║   ███████║█████╗  
    ██╔══██║██╔══██║██║     ██╔═██╗        ██║   ██╔══██║██╔══╝  
    ██║  ██║██║  ██║╚██████╗██║  ██╗       ██║   ██║  ██║███████╗
    ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝       ╚═╝   ╚═╝  ╚═╝╚══════╝
    
    ██████╗ ██╗      █████╗ ███╗   ██╗███████╗████████╗
    ██╔══██╗██║     ██╔══██╗████╗  ██║██╔════╝╚══██╔══╝
    ██████╔╝██║     ███████║██╔██╗ ██║█████╗     ██║   
    ██╔═══╝ ██║     ██╔══██║██║╚██╗██║██╔══╝     ██║   
    ██║     ███████╗██║  ██║██║ ╚████║███████╗   ██║   
    ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   

EOF
    echo -e "${BASHRC_NC}"
    
    sleep 2
    echo -e "${BASHRC_PURPLE}🕵️ STEALTH MODE UNLOCKED!${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}You've discovered the secret privacy and security module!${BASHRC_NC}"
    
    # Load the stealth module
    if [[ -f "$ULTIMATE_BASHRC_MODULES_DIR/12_stealth-mode.sh" ]]; then
        export LOAD_STEALTH_MODE=true
        source "$ULTIMATE_BASHRC_MODULES_DIR/12_stealth-mode.sh"
    fi
    
    echo -e "\n${BASHRC_YELLOW}Type 'stealth help' to explore your new powers${BASHRC_NC}\n"
}

# Unlock Matrix Mode
unlock_matrix_mode() {
    echo -e "${BASHRC_GREEN}Welcome to the Matrix, Neo...${BASHRC_NC}"
    sleep 2
    
    # If assistant is loaded, activate matrix mode
    if command -v assistant &> /dev/null; then
        assistant game matrix
    else
        # Simple matrix effect
        echo -e "${BASHRC_GREEN}The Matrix has you...${BASHRC_NC}"
        echo -e "${BASHRC_GREEN}Follow the white rabbit.${BASHRC_NC}"
        echo -e "\n${BASHRC_YELLOW}Hint: There's a secret AI assistant hidden in this system...${BASHRC_NC}"
    fi
}

# Show secret message
show_secret_message() {
    local messages=(
        "With great power comes great responsibility 🕷️"
        "I am Groot! 🌳"
        "The cake is a lie 🎂"
        "All your base are belong to us 👾"
        "There is no spoon 🥄"
        "Would you like to play a game? 🎮"
        "Hello, World! 👋"
        "42 is the answer 🌌"
        "May the source be with you ⚔️"
        "There are 10 types of people: those who understand binary and those who don't 😏"
    )
    
    local random_message="${messages[$((RANDOM % ${#messages[@]}))]}"
    echo -e "\n${BASHRC_PURPLE}🔮 $random_message${BASHRC_NC}\n"
    
    # Give hint about hidden modules
    if [[ ! -f "$EASTER_EGGS_DIR/.hint_given" ]]; then
        echo -e "${BASHRC_YELLOW}💡 Psst... there are hidden modules in this system.${BASHRC_NC}"
        echo -e "${BASHRC_YELLOW}   Try 'ultimate' 42 times or type 'sudo hack the planet'${BASHRC_NC}\n"
        touch "$EASTER_EGGS_DIR/.hint_given"
    fi
}

# Unlock developer mode
unlock_developer_mode() {
    echo -e "${BASHRC_PURPLE}🔓 DEVELOPER MODE ACTIVATED${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}All hidden modules are now visible!${BASHRC_NC}\n"
    
    # Enable all hidden modules
    export LOAD_SECRET_ASSISTANT=true
    export LOAD_STEALTH_MODE=true
    export ENABLE_DEBUG_MODE=true
    export DEVELOPER_MODE_ACTIVE=true
    
    # Mark as discovered
    touch "$HOME/.ultimate-bashrc/.assistant_discovered"
    touch "$HOME/.ultimate-bashrc/.stealth_discovered"
    
    # Load hidden modules if available
    if [[ -f "$ULTIMATE_BASHRC_MODULES_DIR/11_secret-assistant.sh" ]]; then
        source "$ULTIMATE_BASHRC_MODULES_DIR/11_secret-assistant.sh"
    fi
    
    if [[ -f "$ULTIMATE_BASHRC_MODULES_DIR/12_stealth-mode.sh" ]]; then
        source "$ULTIMATE_BASHRC_MODULES_DIR/12_stealth-mode.sh"
    fi
    
    echo -e "${BASHRC_GREEN}Hidden Modules Loaded:${BASHRC_NC}"
    echo -e "  🤖 Secret AI Assistant - Type 'assistant help'"
    echo -e "  🕵️ Stealth Mode - Type 'stealth help'"
    echo
}

# =============================================================================
# KONAMI CODE DETECTION
# =============================================================================

# Detect arrow keys and build Konami code
detect_konami() {
    # This would need to be integrated with key binding
    # Konami Code: ↑ ↑ ↓ ↓ ← → ← → B A
    
    bind '"\e[A": "konami_up"'    # Up arrow
    bind '"\e[B": "konami_down"'  # Down arrow
    bind '"\e[C": "konami_right"' # Right arrow
    bind '"\e[D": "konami_left"'  # Left arrow
}

konami_up() {
    KONAMI_SEQUENCE="${KONAMI_SEQUENCE}U"
    check_konami_code
}

konami_down() {
    KONAMI_SEQUENCE="${KONAMI_SEQUENCE}D"
    check_konami_code
}

konami_left() {
    KONAMI_SEQUENCE="${KONAMI_SEQUENCE}L"
    check_konami_code
}

konami_right() {
    KONAMI_SEQUENCE="${KONAMI_SEQUENCE}R"
    check_konami_code
}

check_konami_code() {
    if [[ "$KONAMI_SEQUENCE" == "UUDDLRLR" ]]; then
        echo -e "\n${BASHRC_PURPLE}🎮 KONAMI CODE ACTIVATED!${BASHRC_NC}"
        unlock_all_secrets
        KONAMI_SEQUENCE=""
    elif [[ ${#KONAMI_SEQUENCE} -gt 8 ]]; then
        KONAMI_SEQUENCE=""
    fi
}

# Unlock everything
unlock_all_secrets() {
    echo -e "${BASHRC_PURPLE}🎊 ALL SECRETS UNLOCKED! 🎊${BASHRC_NC}\n"
    
    unlock_secret_assistant
    unlock_stealth_mode
    unlock_developer_mode
    
    echo -e "${BASHRC_GREEN}You are now a POWER USER!${BASHRC_NC}"
}

# =============================================================================
# RANDOM EASTER EGGS
# =============================================================================

# Random chance of discovering secrets
random_discovery() {
    # 1 in 1000 chance on each command
    if [[ $((RANDOM % 1000)) -eq 42 ]]; then
        if [[ ! -f "$EASTER_EGGS_DIR/.random_discovered" ]]; then
            echo -e "\n${BASHRC_PURPLE}🎲 RANDOM DISCOVERY!${BASHRC_NC}"
            echo -e "${BASHRC_CYAN}You've randomly discovered a secret!${BASHRC_NC}"
            show_secret_message
            touch "$EASTER_EGGS_DIR/.random_discovered"
        fi
    fi
}

# =============================================================================
# SPECIAL DAY EASTER EGGS
# =============================================================================

# Check for special days
check_special_days() {
    local month_day=$(date +%m-%d)
    local hour=$(date +%H)
    
    case "$month_day" in
        "01-01")  # New Year
            [[ $hour -eq 0 ]] && echo -e "${BASHRC_PURPLE}🎊 Happy New Year! Here's a gift...${BASHRC_NC}" && unlock_random_secret
            ;;
        "03-14")  # Pi Day
            [[ $hour -eq 15 ]] && echo -e "${BASHRC_PURPLE}🥧 Happy Pi Day! 3.14159...${BASHRC_NC}" && show_secret_message
            ;;
        "04-01")  # April Fools
            echo -e "${BASHRC_PURPLE}🃏 April Fools! Everything is backwards today!${BASHRC_NC}"
            ;;
        "05-04")  # Star Wars Day
            echo -e "${BASHRC_PURPLE}⚔️ May the Fourth be with you!${BASHRC_NC}"
            ;;
        "10-31")  # Halloween
            echo -e "${BASHRC_PURPLE}🎃 Trick or treat! Here's a spooky secret...${BASHRC_NC}" && unlock_stealth_mode
            ;;
        "12-25")  # Christmas
            echo -e "${BASHRC_PURPLE}🎄 Merry Christmas! Unwrap your gift...${BASHRC_NC}" && unlock_secret_assistant
            ;;
    esac
}

# Unlock random secret
unlock_random_secret() {
    local secrets=("assistant" "stealth")
    local random_secret="${secrets[$((RANDOM % ${#secrets[@]}))]}"
    
    case "$random_secret" in
        "assistant")
            unlock_secret_assistant
            ;;
        "stealth")
            unlock_stealth_mode
            ;;
    esac
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Hook into command execution to track patterns
if [[ "$BASH_VERSION" ]] && [[ "${BASH_VERSINFO[0]}" -ge 4 ]]; then
    # Set up command preprocessing
    trap 'track_command_for_eggs "$BASH_COMMAND"' DEBUG
fi

# Check special days on shell start
check_special_days

# Occasionally show hints
if [[ $((RANDOM % 20)) -eq 0 ]] && [[ ! -f "$EASTER_EGGS_DIR/.hint_shown_today" ]]; then
    echo -e "${BASHRC_YELLOW}💡 Tip: There might be hidden features in this system...${BASHRC_NC}"
    touch "$EASTER_EGGS_DIR/.hint_shown_today"
    # Clean up daily
    (sleep 86400 && rm -f "$EASTER_EGGS_DIR/.hint_shown_today") &
fi

# Export functions
export -f track_command_for_eggs check_secret_sequences
export -f unlock_secret_assistant unlock_stealth_mode
export -f show_secret_message unlock_all_secrets

# Secret aliases (not visible in normal alias list)
alias "hack the planet"='unlock_stealth_mode' 2>/dev/null
alias "42"='unlock_secret_assistant' 2>/dev/null
alias "red pill"='unlock_all_secrets' 2>/dev/null
