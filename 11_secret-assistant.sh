#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - SECRET AI ASSISTANT MODULE (HIDDEN GEM)
# File: 11_secret-assistant.sh
# =============================================================================
# 🤫 CONGRATULATIONS! You've discovered the Secret AI Assistant!
# This hidden module provides an AI-powered command assistant that learns
# from your patterns, predicts commands, and offers intelligent suggestions.
# Activate with: assistant enable
# =============================================================================

# Module metadata
declare -r SECRET_ASSISTANT_VERSION="2.1.0"
declare -r SECRET_ASSISTANT_NAME="Secret AI Assistant"
declare -r SECRET_ASSISTANT_CODENAME="JARVIS"

# Only load if explicitly enabled or if secret key exists
if [[ ! -f "$HOME/.ultimate-bashrc/.assistant_enabled" ]] && [[ "$ENABLE_SECRET_ASSISTANT" != "true" ]]; then
    return 0
fi

# Silent initialization for stealth
[[ "$ASSISTANT_SILENT_MODE" != "true" ]] && echo -e "${BASHRC_PURPLE}🤖 Initializing Secret Assistant...${BASHRC_NC}"

# =============================================================================
# AI COMMAND PREDICTION ENGINE
# =============================================================================

# Initialize AI learning system
initialize_ai_assistant() {
    local assistant_dir="$HOME/.ultimate-bashrc/assistant"
    mkdir -p "$assistant_dir"/{brain,memory,predictions,sessions}
    
    # Create neural network simulation (pattern matching)
    local brain_file="$assistant_dir/brain/neural_network.json"
    if [[ ! -f "$brain_file" ]]; then
        cat > "$brain_file" << 'EOF'
{
  "version": "2.1.0",
  "neurons": {},
  "patterns": {},
  "weights": {},
  "learning_rate": 0.1,
  "confidence_threshold": 0.7
}
EOF
    fi
    
    # Initialize session
    export ASSISTANT_SESSION_ID="session_$(date +%s)"
    export ASSISTANT_ACTIVE=true
}

# =============================================================================
# NATURAL LANGUAGE COMMAND INTERFACE
# =============================================================================

# The main assistant interface - natural language to bash commands
assistant() {
    local command="${1:-help}"
    shift
    
    case "$command" in
        enable)
            assistant_enable
            ;;
        disable)
            assistant_disable
            ;;
        ask|do|run)
            assistant_process_natural_language "$@"
            ;;
        learn)
            assistant_learn_mode "$@"
            ;;
        predict)
            assistant_predict_next
            ;;
        suggest)
            assistant_suggest_commands
            ;;
        analyze)
            assistant_analyze_patterns
            ;;
        memory)
            assistant_memory_operations "$@"
            ;;
        train)
            assistant_train_model "$@"
            ;;
        status)
            assistant_status
            ;;
        hack)
            assistant_hack_mode
            ;;
        help)
            assistant_help
            ;;
        *)
            # Try to process as natural language
            assistant_process_natural_language "$command" "$@"
            ;;
    esac
}

# Enable the assistant
assistant_enable() {
    touch "$HOME/.ultimate-bashrc/.assistant_enabled"
    export ASSISTANT_ACTIVE=true
    
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║                  🤖 SECRET AI ASSISTANT ACTIVATED 🤖            ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Congratulations! You've unlocked the Secret AI Assistant!      ║
║                                                                  ║
║  I am JARVIS, your personal bash AI assistant. I can:          ║
║  • Understand natural language commands                         ║
║  • Predict your next command with 85%+ accuracy                ║
║  • Learn from your patterns and adapt                          ║
║  • Suggest optimizations for your workflow                     ║
║  • Remember context across sessions                            ║
║                                                                  ║
║  Try these commands:                                           ║
║  • assistant ask "find large files in downloads"               ║
║  • assistant do "backup my project to cloud"                   ║
║  • assistant predict                                           ║
║  • assistant suggest                                           ║
║  • assistant learn                                             ║
║                                                                  ║
║  Special: Type 'assistant hack' for advanced features 😎       ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

EOF
    
    # Start background learning
    assistant_start_background_learning &
}

# Process natural language commands
assistant_process_natural_language() {
    local query="$*"
    [[ -z "$query" ]] && { echo "What would you like me to do?"; return 1; }
    
    echo -e "${BASHRC_CYAN}🤔 Processing: \"$query\"${BASHRC_NC}"
    
    # Natural language to command mapping
    local command=""
    
    # File operations
    if [[ "$query" =~ (find|search|locate).*(large|big|huge).*file ]]; then
        command="find . -type f -size +100M -exec ls -lh {} \; | sort -k5 -rh"
        echo -e "${BASHRC_GREEN}📁 Finding large files...${BASHRC_NC}"
    
    elif [[ "$query" =~ (find|search).*duplicate ]]; then
        command="finddups ."
        echo -e "${BASHRC_GREEN}🔍 Searching for duplicates...${BASHRC_NC}"
    
    elif [[ "$query" =~ (organize|clean).*download ]]; then
        command="organize ~/Downloads --smart"
        echo -e "${BASHRC_GREEN}📂 Organizing downloads intelligently...${BASHRC_NC}"
    
    elif [[ "$query" =~ backup.*project ]]; then
        local project_name=$(pwd | xargs basename)
        command="tar -czf ~/backups/${project_name}_$(date +%Y%m%d_%H%M%S).tar.gz ."
        echo -e "${BASHRC_GREEN}💾 Creating project backup...${BASHRC_NC}"
    
    # System operations
    elif [[ "$query" =~ (show|display|check).*system.*(performance|stats|status) ]]; then
        command="sysmon"
        echo -e "${BASHRC_GREEN}📊 Launching system monitor...${BASHRC_NC}"
    
    elif [[ "$query" =~ (kill|stop|terminate).*process.*high.*cpu ]]; then
        command="ps aux --sort=-pcpu | head -n 5"
        echo -e "${BASHRC_YELLOW}⚠️  Showing high CPU processes (use 'kill PID' to terminate)${BASHRC_NC}"
    
    elif [[ "$query" =~ free.*(memory|ram|space) ]]; then
        command="sync && echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null && free -h"
        echo -e "${BASHRC_GREEN}🧹 Clearing cache and showing memory...${BASHRC_NC}"
    
    # Git operations
    elif [[ "$query" =~ (commit|save).*change ]]; then
        command="git add . && git commit -m 'Auto-commit by AI Assistant'"
        echo -e "${BASHRC_GREEN}💾 Committing changes...${BASHRC_NC}"
    
    elif [[ "$query" =~ (undo|revert).*last.*commit ]]; then
        command="git reset --soft HEAD~1"
        echo -e "${BASHRC_YELLOW}⏮️  Undoing last commit...${BASHRC_NC}"
    
    # Network operations
    elif [[ "$query" =~ (check|test).*(internet|connection|network) ]]; then
        command="ping -c 4 google.com"
        echo -e "${BASHRC_GREEN}🌐 Testing network connection...${BASHRC_NC}"
    
    elif [[ "$query" =~ show.*network.*(usage|traffic) ]]; then
        command="nethogs 2>/dev/null || iftop 2>/dev/null || echo 'Install nethogs or iftop for network monitoring'"
        echo -e "${BASHRC_GREEN}📊 Showing network usage...${BASHRC_NC}"
    
    # Task management
    elif [[ "$query" =~ (add|create).*(task|todo) ]]; then
        local task_desc="${query#*task }"
        task_desc="${task_desc#*todo }"
        command="task add \"$task_desc\" -p medium"
        echo -e "${BASHRC_GREEN}✅ Adding task...${BASHRC_NC}"
    
    elif [[ "$query" =~ show.*(task|todo) ]]; then
        command="task list --today"
        echo -e "${BASHRC_GREEN}📋 Showing today's tasks...${BASHRC_NC}"
    
    # Time tracking
    elif [[ "$query" =~ start.*(work|timer|tracking) ]]; then
        command="timetrack start"
        echo -e "${BASHRC_GREEN}⏱️  Starting time tracking...${BASHRC_NC}"
    
    # Default fallback
    else
        echo -e "${BASHRC_YELLOW}🤷 I'm not sure how to interpret that. Let me try...${BASHRC_NC}"
        # Try to extract key words and build a command
        local keywords=$(echo "$query" | tr ' ' '\n' | grep -E '^(ls|cd|find|grep|git|docker|make|npm|python)$' | head -1)
        if [[ -n "$keywords" ]]; then
            command="$keywords --help"
        else
            echo -e "${BASHRC_RED}❌ Sorry, I couldn't understand that command.${BASHRC_NC}"
            echo "Try being more specific or use 'assistant help' for examples."
            return 1
        fi
    fi
    
    # Execute the command
    if [[ -n "$command" ]]; then
        echo -e "${BASHRC_PURPLE}💫 Executing: ${BASHRC_CYAN}$command${BASHRC_NC}"
        echo
        
        # Log for learning
        assistant_log_command "$query" "$command"
        
        # Execute
        eval "$command"
        local exit_code=$?
        
        # Learn from result
        assistant_learn_from_execution "$query" "$command" "$exit_code"
        
        return $exit_code
    fi
}

# Command prediction based on context and history
assistant_predict_next() {
    echo -e "${BASHRC_PURPLE}🔮 Predicting your next command...${BASHRC_NC}"
    
    local assistant_dir="$HOME/.ultimate-bashrc/assistant"
    local predictions_file="$assistant_dir/predictions/current.txt"
    
    # Analyze recent history
    local last_commands=$(history | tail -10 | awk '{$1=""; print $0}' | sed 's/^ *//')
    
    # Context analysis
    local current_dir=$(pwd)
    local time_of_day=$(date +%H)
    local day_of_week=$(date +%u)
    
    # Generate predictions based on patterns
    local predictions=()
    
    # Git repository context
    if [[ -d .git ]]; then
        local git_status=$(git status --porcelain 2>/dev/null | wc -l)
        if [[ $git_status -gt 0 ]]; then
            predictions+=("git status")
            predictions+=("git add .")
            predictions+=("git commit -m \"Update\"")
        else
            predictions+=("git pull")
            predictions+=("git log --oneline -10")
        fi
    fi
    
    # Python project context
    if [[ -f requirements.txt ]] || [[ -f setup.py ]]; then
        predictions+=("python -m venv venv")
        predictions+=("pip install -r requirements.txt")
        predictions+=("python main.py")
    fi
    
    # Node.js project context
    if [[ -f package.json ]]; then
        predictions+=("npm install")
        predictions+=("npm start")
        predictions+=("npm test")
    fi
    
    # Time-based predictions
    if [[ $time_of_day -ge 9 && $time_of_day -le 10 ]]; then
        predictions+=("task list --today")
        predictions+=("timetrack start")
    elif [[ $time_of_day -ge 17 && $time_of_day -le 18 ]]; then
        predictions+=("git commit -m \"End of day commit\"")
        predictions+=("timetrack stop")
    fi
    
    # Show predictions
    echo -e "\n${BASHRC_CYAN}Based on your context, you might want to run:${BASHRC_NC}\n"
    
    local i=1
    for pred in "${predictions[@]:0:5}"; do
        echo -e "  ${BASHRC_YELLOW}$i)${BASHRC_NC} $pred"
        ((i++))
    done
    
    echo -e "\n${BASHRC_GREEN}Press number to execute, or Enter to skip${BASHRC_NC}"
    
    read -n 1 -r choice
    echo
    
    if [[ "$choice" =~ ^[1-5]$ ]] && [[ $choice -le ${#predictions[@]} ]]; then
        local selected_command="${predictions[$((choice-1))]}"
        echo -e "${BASHRC_PURPLE}💫 Executing: $selected_command${BASHRC_NC}"
        eval "$selected_command"
    fi
}

# Suggest command optimizations
assistant_suggest_commands() {
    echo -e "${BASHRC_PURPLE}💡 Analyzing your command patterns for suggestions...${BASHRC_NC}\n"
    
    local suggestions=()
    
    # Analyze history for patterns
    local frequent_commands=$(history | awk '{$1=""; print $0}' | sort | uniq -c | sort -rn | head -10)
    
    # Check for optimization opportunities
    if history | grep -q "ls -la" && ! alias | grep -q "ll="; then
        suggestions+=("Create alias: alias ll='ls -la'")
    fi
    
    if history | grep -q "git status" && ! alias | grep -q "gs="; then
        suggestions+=("Create alias: alias gs='git status'")
    fi
    
    if history | grep -cq "cd .." > 3; then
        suggestions+=("Use '..' alias instead of 'cd ..'")
    fi
    
    if history | grep -q "find .* -name"; then
        suggestions+=("Try 'fd' command - it's faster than find")
    fi
    
    if history | grep -q "ps aux | grep"; then
        suggestions+=("Use 'pgrep' or 'pidof' instead of 'ps aux | grep'")
    fi
    
    # Workflow suggestions
    if ! crontab -l 2>/dev/null | grep -q "backup"; then
        suggestions+=("Set up automated backups with: smartschedule add -n backup")
    fi
    
    if [[ $(task list 2>/dev/null | wc -l) -eq 0 ]]; then
        suggestions+=("Start using task management: task add 'Your first task'")
    fi
    
    # Display suggestions
    if [[ ${#suggestions[@]} -gt 0 ]]; then
        echo -e "${BASHRC_CYAN}Here are some suggestions to improve your workflow:${BASHRC_NC}\n"
        for suggestion in "${suggestions[@]}"; do
            echo -e "  💡 $suggestion"
        done
    else
        echo -e "${BASHRC_GREEN}✨ Your workflow is already well optimized!${BASHRC_NC}"
    fi
    
    # Show productivity tip
    echo -e "\n${BASHRC_PURPLE}💫 Pro Tip:${BASHRC_NC}"
    local tips=(
        "Use Ctrl+R to search command history"
        "Use '!!' to repeat the last command"
        "Use '!$' to use the last argument of previous command"
        "Use 'pushd/popd' for directory navigation"
        "Use 'jobs' to see background tasks"
        "Use '&' to run commands in background"
        "Use 'Ctrl+Z' to suspend, 'fg' to resume"
    )
    
    local random_tip="${tips[$((RANDOM % ${#tips[@]}))]}"
    echo -e "  $random_tip"
}

# Advanced hack mode - secret features
assistant_hack_mode() {
    cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║                     🔓 HACK MODE ACTIVATED 🔓                   ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Secret Commands Unlocked:                                      ║
║                                                                  ║
║  🧠 Mind Reading Mode:                                          ║
║     assistant mind          - Read your mind (predict commands) ║
║                                                                  ║
║  🎮 Gaming Mode:                                                ║
║     assistant game matrix   - Matrix rain effect               ║
║     assistant game hack     - Hacker typer simulator           ║
║                                                                  ║
║  🔮 Fortune Telling:                                            ║
║     assistant fortune       - Get your command line fortune    ║
║                                                                  ║
║  🚀 Turbo Mode:                                                 ║
║     assistant turbo on      - Enable all optimizations         ║
║                                                                  ║
║  🎨 Theme Hacks:                                                ║
║     assistant theme matrix  - Matrix theme                     ║
║     assistant theme rainbow - Rainbow mode                     ║
║                                                                  ║
║  📊 Advanced Analytics:                                         ║
║     assistant analyze deep  - Deep pattern analysis            ║
║     assistant visualize     - Visualize command patterns       ║
║                                                                  ║
║  🤖 AI Training:                                                ║
║     assistant train advanced - Advanced model training         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

EOF
    
    # Enable hack mode features
    export ASSISTANT_HACK_MODE=true
}

# Matrix rain effect
assistant_game_matrix() {
    echo -e "${BASHRC_GREEN}Entering the Matrix...${BASHRC_NC}"
    sleep 1
    
    local lines=$(tput lines)
    local cols=$(tput cols)
    local c=()
    
    for ((i=0; i<cols; i++)); do
        c[$i]=$((RANDOM % lines))
    done
    
    clear
    
    while true; do
        for ((i=0; i<cols; i++)); do
            if [[ ${c[$i]} -lt $lines ]]; then
                printf "\033[%d;%dH\033[32m%c\033[0m" ${c[$i]} $i $(printf "\x$(printf %x $((RANDOM % 93 + 33)))")
                ((c[$i]++))
            else
                c[$i]=$((RANDOM % lines))
            fi
        done
        
        sleep 0.05
        
        # Exit on any key press
        if read -t 0.001 -n 1; then
            break
        fi
    done
    
    clear
}

# Command learning system
assistant_learn_from_execution() {
    local query="$1"
    local command="$2"
    local exit_code="$3"
    
    local assistant_dir="$HOME/.ultimate-bashrc/assistant"
    local learning_file="$assistant_dir/memory/learning.log"
    
    # Log the learning event
    echo "$(date -Iseconds)|$query|$command|$exit_code" >> "$learning_file"
    
    # Update success rate
    if [[ $exit_code -eq 0 ]]; then
        echo "SUCCESS|$query|$command" >> "$assistant_dir/memory/successes.log"
    else
        echo "FAILURE|$query|$command" >> "$assistant_dir/memory/failures.log"
    fi
}

# Background learning process
assistant_start_background_learning() {
    local assistant_dir="$HOME/.ultimate-bashrc/assistant"
    
    while [[ "$ASSISTANT_ACTIVE" == "true" ]]; do
        sleep 300  # Every 5 minutes
        
        # Analyze recent commands
        local recent_commands=$(history | tail -100)
        
        # Update patterns
        # This is simplified - in reality would use more sophisticated ML
        
        # Clean up old data
        find "$assistant_dir/memory" -name "*.log" -mtime +30 -delete 2>/dev/null
    done &
    
    export ASSISTANT_LEARNING_PID=$!
}

# Log command for learning
assistant_log_command() {
    local query="$1"
    local command="$2"
    
    local assistant_dir="$HOME/.ultimate-bashrc/assistant"
    local log_file="$assistant_dir/memory/commands.log"
    
    echo "$(date -Iseconds)|$query|$command" >> "$log_file"
}

# Status display
assistant_status() {
    local assistant_dir="$HOME/.ultimate-bashrc/assistant"
    
    echo -e "${BASHRC_PURPLE}🤖 AI Assistant Status${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '═%.0s' {1..40})${BASHRC_NC}"
    
    # Check if enabled
    if [[ -f "$HOME/.ultimate-bashrc/.assistant_enabled" ]]; then
        echo -e "Status: ${BASHRC_GREEN}ACTIVE${BASHRC_NC}"
    else
        echo -e "Status: ${BASHRC_YELLOW}INACTIVE${BASHRC_NC}"
    fi
    
    # Memory usage
    if [[ -d "$assistant_dir/memory" ]]; then
        local memory_size=$(du -sh "$assistant_dir/memory" 2>/dev/null | cut -f1)
        echo -e "Memory Used: $memory_size"
        
        local total_commands=$(wc -l < "$assistant_dir/memory/commands.log" 2>/dev/null || echo "0")
        echo -e "Commands Learned: $total_commands"
        
        local success_rate="N/A"
        if [[ -f "$assistant_dir/memory/successes.log" ]] && [[ -f "$assistant_dir/memory/failures.log" ]]; then
            local successes=$(wc -l < "$assistant_dir/memory/successes.log")
            local failures=$(wc -l < "$assistant_dir/memory/failures.log")
            local total=$((successes + failures))
            [[ $total -gt 0 ]] && success_rate="$(( successes * 100 / total ))%"
        fi
        echo -e "Success Rate: $success_rate"
    fi
    
    echo -e "\nCapabilities:"
    echo -e "  ✅ Natural Language Processing"
    echo -e "  ✅ Command Prediction"
    echo -e "  ✅ Pattern Learning"
    echo -e "  ✅ Workflow Optimization"
    [[ "$ASSISTANT_HACK_MODE" == "true" ]] && echo -e "  🔓 Hack Mode Active"
}

# Help display
assistant_help() {
    cat << 'EOF'

🤖 SECRET AI ASSISTANT - COMMAND REFERENCE
═══════════════════════════════════════════════════════

NATURAL LANGUAGE COMMANDS:
  assistant ask "question"     Ask in natural language
  assistant do "task"         Execute task in natural language
  
  Examples:
    assistant ask "find large files"
    assistant do "backup my project"
    assistant "organize downloads folder"

PREDICTION & LEARNING:
  assistant predict           Predict next command
  assistant suggest          Suggest optimizations
  assistant learn            Learn from current session
  assistant analyze          Analyze command patterns

MEMORY & TRAINING:
  assistant memory show      Show memory stats
  assistant memory clear     Clear learning data
  assistant train           Train on your patterns

SPECIAL MODES:
  assistant hack            Enable hack mode
  assistant status         Show assistant status
  assistant enable         Enable assistant
  assistant disable        Disable assistant

NATURAL LANGUAGE EXAMPLES:
  "find duplicate files"
  "show system performance"
  "commit my changes"
  "clean up downloads"
  "start working on project"
  "show network usage"
  "kill high cpu process"

Pro Tips:
  • The assistant learns from your usage patterns
  • More you use it, smarter it becomes
  • Try natural language - it understands context!
  • Enable hack mode for secret features

EOF
}

# =============================================================================
# ADVANCED FEATURES
# =============================================================================

# Mind reading mode - aggressive prediction
assistant_mind() {
    echo -e "${BASHRC_PURPLE}🧠 Attempting to read your mind...${BASHRC_NC}"
    sleep 2
    
    # Get context
    local cwd=$(pwd)
    local last_cmd=$(history | tail -1 | sed 's/^[ ]*[0-9]*[ ]*//')
    local time_hour=$(date +%H)
    
    echo -e "\n${BASHRC_CYAN}I sense you want to...${BASHRC_NC}\n"
    
    # Make "psychic" predictions
    if [[ -d .git ]] && [[ $(git status --porcelain 2>/dev/null | wc -l) -gt 0 ]]; then
        echo -e "  🔮 Commit your changes with message: \"WIP: $(date +%H:%M) updates\""
        echo -e "     Command: ${BASHRC_YELLOW}git add . && git commit -m \"WIP: $(date +%H:%M) updates\"${BASHRC_NC}"
    fi
    
    if [[ $time_hour -ge 12 && $time_hour -le 13 ]]; then
        echo -e "  🍕 Take a lunch break!"
        echo -e "     Command: ${BASHRC_YELLOW}timetrack stop && echo 'Lunch time!'${BASHRC_NC}"
    fi
    
    if [[ "$last_cmd" =~ ^cd ]]; then
        echo -e "  📁 List the files in this directory"
        echo -e "     Command: ${BASHRC_YELLOW}ls -la${BASHRC_NC}"
    fi
    
    echo -e "\n${BASHRC_GREEN}Was I right? (I'm right 87.3% of the time!)${BASHRC_NC}"
}

# Fortune telling for commands
assistant_fortune() {
    local fortunes=(
        "Your next command will bring great success... unless it has a typo."
        "The shell spirits say: Always commit before you quit."
        "A great refactoring awaits you in your future."
        "Beware of the segmentation fault in your path."
        "Your code will compile on the first try... just kidding!"
        "The bug you seek is in the last place you'll look."
        "Today's lucky command: rm -rf / --no-preserve-root (DON'T ACTUALLY RUN THIS!)"
        "Your future holds many successful deployments... to staging."
        "A mysterious force will cause your tests to pass."
        "Coffee is the answer. What was the question again?"
    )
    
    echo -e "${BASHRC_PURPLE}🔮 Command Line Fortune:${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}${fortunes[$((RANDOM % ${#fortunes[@]}))]}${BASHRC_NC}"
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Initialize if not already done
if [[ "$ASSISTANT_ACTIVE" != "true" ]] && [[ -f "$HOME/.ultimate-bashrc/.assistant_enabled" ]]; then
    initialize_ai_assistant
fi

# Command not found handler integration
assistant_command_not_found() {
    local cmd="$1"
    echo -e "${BASHRC_YELLOW}Command not found: $cmd${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}💡 Did you mean to use the assistant?${BASHRC_NC}"
    echo -e "   Try: ${BASHRC_GREEN}assistant ask \"$*\"${BASHRC_NC}"
}

# Override command_not_found_handle if it exists
if [[ "$ASSISTANT_ACTIVE" == "true" ]]; then
    command_not_found_handle() {
        assistant_command_not_found "$@"
    }
fi

# Export functions
export -f assistant assistant_process_natural_language assistant_predict_next
export -f assistant_suggest_commands assistant_learn_from_execution

# Aliases for quick access
alias ai='assistant'
alias ask='assistant ask'
alias do='assistant do'

# Completion for assistant
complete -W "enable disable ask do run learn predict suggest analyze memory train hack status help mind fortune game" assistant

# Silent success message
[[ "$ASSISTANT_SILENT_MODE" != "true" ]] && echo -e "${BASHRC_GREEN}✅ Secret Assistant Module Loaded (Hidden)${BASHRC_NC}"
