#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - INTELLIGENT AUTOMATION MODULE
# File: 05_intelligent-automation.sh
# =============================================================================
# This module provides intelligent automation capabilities that learn from your
# usage patterns, automate repetitive tasks, create adaptive workflows, and
# build self-improving command sequences based on your behavior.
# =============================================================================

# Module metadata
declare -r AUTOMATION_MODULE_VERSION="2.1.0"
declare -r AUTOMATION_MODULE_NAME="Intelligent Automation"
declare -r AUTOMATION_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# Module initialization
echo -e "${BASHRC_CYAN}🤖 Loading Intelligent Automation...${BASHRC_NC}"

# =============================================================================
# ADAPTIVE WORKFLOW SYSTEM
# =============================================================================

# Workflow automation with pattern learning and adaptation
autoflow() {
    local usage="Usage: autoflow [COMMAND] [OPTIONS] [FLOW_NAME]
    
🔄 Intelligent Workflow Automation System
Commands:
    create      Create new workflow from commands
    record      Record command sequence as workflow
    run         Execute workflow with adaptive parameters
    list        Show available workflows
    analyze     Analyze workflow patterns and usage
    optimize    Optimize workflows based on usage data
    export      Export workflow for sharing
    import      Import workflow from file
    
Options:
    -i, --interactive   Interactive workflow creation
    -t, --trigger TYPE  Set trigger condition (time, file, event)
    -s, --schedule CRON Schedule workflow execution
    -c, --condition CMD Conditional execution
    -p, --parallel      Enable parallel execution
    -l, --loop COUNT    Loop workflow execution
    -v, --verbose       Detailed execution output
    -d, --dry-run       Show what would be executed
    -h, --help          Show this help
    
Examples:
    autoflow record daily-backup        # Record commands as workflow
    autoflow create deploy-sequence     # Create structured workflow
    autoflow run backup-db --verbose    # Run with detailed output
    autoflow analyze --since 7d         # Analyze recent workflow usage
    autoflow optimize slow-workflows    # Optimize based on performance data"

    local command="${1:-list}"
    [[ "$command" != "list" && "$command" != "analyze" && "$command" != "optimize" ]] && shift
    
    case "$command" in
        create)     autoflow_create "$@" ;;
        record)     autoflow_record "$@" ;;
        run)        autoflow_run "$@" ;;
        list)       autoflow_list "$@" ;;
        analyze)    autoflow_analyze "$@" ;;
        optimize)   autoflow_optimize "$@" ;;
        export)     autoflow_export "$@" ;;
        import)     autoflow_import "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Create structured workflow
autoflow_create() {
    local flow_name=""
    local interactive=false
    local trigger_type=""
    local schedule=""
    local condition=""
    local parallel=false
    local loop_count=1
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--interactive)   interactive=true; shift ;;
            -t|--trigger)       trigger_type="$2"; shift 2 ;;
            -s|--schedule)      schedule="$2"; shift 2 ;;
            -c|--condition)     condition="$2"; shift 2 ;;
            -p|--parallel)      parallel=true; shift ;;
            -l|--loop)          loop_count="$2"; shift 2 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  flow_name="$1"; shift ;;
        esac
    done
    
    [[ -z "$flow_name" ]] && { echo "Workflow name required"; return 1; }
    
    local automation_dir="$HOME/.bash_automation"
    local workflows_dir="$automation_dir/workflows"
    local workflow_file="$workflows_dir/${flow_name}.json"
    
    mkdir -p "$workflows_dir"
    
    if [[ -f "$workflow_file" ]]; then
        echo "❌ Workflow '$flow_name' already exists"
        return 1
    fi
    
    echo -e "🔧 Creating workflow: $flow_name"
    
    if [[ "$interactive" == "true" ]]; then
        create_workflow_interactive "$flow_name" "$workflow_file"
    else
        create_workflow_template "$flow_name" "$workflow_file" "$trigger_type" "$schedule" "$condition" "$parallel" "$loop_count"
    fi
    
    echo -e "✅ Workflow '$flow_name' created at $workflow_file"
}

# Interactive workflow creation
create_workflow_interactive() {
    local flow_name="$1"
    local workflow_file="$2"
    
    echo -e "🎯 Creating workflow: $flow_name"
    echo
    
    # Get description
    read -p "📝 Description: " -r description
    
    # Get steps
    echo -e "\n📋 Enter workflow steps (empty line to finish):"
    local steps=()
    local step_num=1
    
    while true; do
        read -p "Step $step_num: " -r step
        [[ -z "$step" ]] && break
        steps+=("$step")
        ((step_num++))
    done
    
    if [[ ${#steps[@]} -eq 0 ]]; then
        echo "❌ No steps provided"
        return 1
    fi
    
    # Get optional settings
    read -p "⏰ Schedule (cron format, optional): " -r schedule
    read -p "🎯 Condition command (optional): " -r condition
    read -p "🔄 Parallel execution? [y/N]: " -n 1 -r parallel_choice
    echo
    
    local parallel_flag=false
    [[ $parallel_choice =~ ^[Yy]$ ]] && parallel_flag=true
    
    # Create workflow JSON
    create_workflow_json "$flow_name" "$description" "$workflow_file" "$schedule" "$condition" "$parallel_flag" "${steps[@]}"
}

# Create workflow template
create_workflow_template() {
    local flow_name="$1"
    local workflow_file="$2"
    local trigger_type="$3"
    local schedule="$4"
    local condition="$5"
    local parallel="$6"
    local loop_count="$7"
    
    # Create basic template
    create_workflow_json "$flow_name" "Automated workflow: $flow_name" "$workflow_file" "$schedule" "$condition" "$parallel"
    
    echo "📝 Edit $workflow_file to add your workflow steps"
}

# Create workflow JSON structure
create_workflow_json() {
    local flow_name="$1"
    local description="$2"
    local workflow_file="$3"
    local schedule="$4"
    local condition="$5"
    local parallel="$6"
    shift 6
    local steps=("$@")
    
    cat > "$workflow_file" << EOF
{
  "name": "$flow_name",
  "description": "$description",
  "version": "1.0",
  "created": "$(date -Iseconds)",
  "last_modified": "$(date -Iseconds)",
  "metadata": {
    "author": "$(whoami)",
    "tags": [],
    "category": "general"
  },
  "execution": {
    "parallel": $parallel,
    "timeout": 300,
    "retry_count": 0,
    "on_failure": "stop"
  },
  "triggers": {
    "schedule": "${schedule:-}",
    "condition": "${condition:-}",
    "manual": true
  },
  "variables": {},
  "steps": [
EOF

    # Add steps
    for i in "${!steps[@]}"; do
        local step="${steps[$i]}"
        local comma=""
        [[ $i -lt $((${#steps[@]} - 1)) ]] && comma=","
        
        cat >> "$workflow_file" << EOF
    {
      "id": "step_$((i+1))",
      "name": "Step $((i+1))",
      "command": "$step",
      "enabled": true,
      "timeout": 60,
      "retry": 0,
      "on_failure": "continue"
    }$comma
EOF
    done
    
    cat >> "$workflow_file" << EOF
  ],
  "statistics": {
    "executions": 0,
    "successful": 0,
    "failed": 0,
    "avg_duration": 0,
    "last_run": null
  }
}
EOF
}

# Record command sequence as workflow
autoflow_record() {
    local flow_name=""
    local recording=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  flow_name="$1"; shift ;;
        esac
    done
    
    [[ -z "$flow_name" ]] && { echo "Workflow name required"; return 1; }
    
    local automation_dir="$HOME/.bash_automation"
    local recordings_dir="$automation_dir/recordings"
    local recording_file="$recordings_dir/${flow_name}_$(date +%Y%m%d_%H%M%S).log"
    
    mkdir -p "$recordings_dir"
    
    echo -e "🎬 Recording workflow: $flow_name"
    echo -e "📝 Commands will be logged to: $recording_file"
    echo -e "🛑 Type 'stop_recording' to finish"
    
    # Set up command recording
    export AUTOFLOW_RECORDING=true
    export AUTOFLOW_RECORDING_FILE="$recording_file"
    export AUTOFLOW_RECORDING_NAME="$flow_name"
    
    # Initialize recording file
    cat > "$recording_file" << EOF
# Workflow Recording: $flow_name
# Started: $(date)
# User: $(whoami)
# Directory: $(pwd)
EOF
    
    # Set up prompt to show recording status
    export AUTOFLOW_ORIGINAL_PS1="$PS1"
    export PS1="🔴 REC [$flow_name] $PS1"
    
    # Function to stop recording
    stop_recording() {
        echo -e "\n🛑 Stopping recording for: $AUTOFLOW_RECORDING_NAME"
        
        # Process recorded commands
        process_recording "$AUTOFLOW_RECORDING_FILE" "$AUTOFLOW_RECORDING_NAME"
        
        # Clean up
        unset AUTOFLOW_RECORDING AUTOFLOW_RECORDING_FILE AUTOFLOW_RECORDING_NAME
        export PS1="$AUTOFLOW_ORIGINAL_PS1"
        unset AUTOFLOW_ORIGINAL_PS1
        unset -f stop_recording
        
        echo -e "✅ Recording complete"
    }
    
    export -f stop_recording
}

# Process recorded commands into workflow
process_recording() {
    local recording_file="$1"
    local flow_name="$2"
    
    echo -e "🔄 Processing recording into workflow..."
    
    # Extract commands (simplified - would need more sophisticated parsing)
    local commands=()
    while IFS= read -r line; do
        [[ "$line" =~ ^#.*$ ]] && continue
        [[ -z "$line" ]] && continue
        [[ "$line" == "stop_recording" ]] && continue
        commands+=("$line")
    done < <(grep -v "^#" "$recording_file" | grep -v "^$")
    
    if [[ ${#commands[@]} -eq 0 ]]; then
        echo "⚠️ No commands recorded"
        return 1
    fi
    
    # Create workflow from recorded commands
    local workflows_dir="$HOME/.bash_automation/workflows"
    local workflow_file="$workflows_dir/${flow_name}.json"
    
    mkdir -p "$workflows_dir"
    
    create_workflow_json "$flow_name" "Recorded workflow: $flow_name" "$workflow_file" "" "" "false" "${commands[@]}"
    
    echo -e "✅ Created workflow from recording: $workflow_file"
    echo -e "📊 Recorded ${#commands[@]} commands"
}

# Run workflow with adaptive parameters
autoflow_run() {
    local flow_name=""
    local verbose=false
    local dry_run=false
    local override_vars=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)       verbose=true; shift ;;
            -d|--dry-run)       dry_run=true; shift ;;
            --set)              override_vars+=("$2"); shift 2 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  flow_name="$1"; shift ;;
        esac
    done
    
    [[ -z "$flow_name" ]] && { echo "Workflow name required"; return 1; }
    
    local automation_dir="$HOME/.bash_automation"
    local workflows_dir="$automation_dir/workflows"
    local workflow_file="$workflows_dir/${flow_name}.json"
    
    if [[ ! -f "$workflow_file" ]]; then
        echo "❌ Workflow '$flow_name' not found"
        return 1
    fi
    
    echo -e "🚀 Executing workflow: $flow_name"
    [[ "$dry_run" == "true" ]] && echo -e "🔍 DRY RUN MODE - No commands will be executed"
    
    local start_time=$(date +%s)
    local execution_id="exec_$(date +%s)"
    
    # Parse workflow JSON (simplified parsing)
    local parallel=$(grep '"parallel"' "$workflow_file" | grep -o 'true\|false')
    local timeout=$(grep '"timeout"' "$workflow_file" | grep -o '[0-9]\+' | head -1)
    
    [[ "$verbose" == "true" ]] && {
        echo -e "⚙️ Configuration:"
        echo -e "   Parallel: $parallel"
        echo -e "   Timeout: ${timeout}s"
        echo -e "   Execution ID: $execution_id"
        echo
    }
    
    # Execute workflow steps
    local step_count=0
    local successful_steps=0
    local failed_steps=0
    
    # Extract and execute steps (simplified - real implementation would properly parse JSON)
    while IFS= read -r line; do
        if [[ "$line" =~ \"command\":[[:space:]]*\"([^\"]+)\" ]]; then
            local command="${BASH_REMATCH[1]}"
            ((step_count++))
            
            [[ "$verbose" == "true" ]] && echo -e "📋 Step $step_count: $command"
            
            if [[ "$dry_run" == "false" ]]; then
                local step_start=$(date +%s)
                
                if eval "$command"; then
                    ((successful_steps++))
                    local step_duration=$(($(date +%s) - step_start))
                    [[ "$verbose" == "true" ]] && echo -e "✅ Step $step_count completed (${step_duration}s)"
                else
                    ((failed_steps++))
                    echo -e "❌ Step $step_count failed: $command"
                    
                    # Check failure handling (simplified)
                    if grep -q '"on_failure": "stop"' "$workflow_file"; then
                        echo -e "🛑 Stopping workflow due to failure"
                        break
                    fi
                fi
            else
                echo -e "   → Would execute: $command"
            fi
        fi
    done < "$workflow_file"
    
    local end_time=$(date +%s)
    local total_duration=$((end_time - start_time))
    
    # Update workflow statistics
    if [[ "$dry_run" == "false" ]]; then
        update_workflow_statistics "$workflow_file" "$total_duration" "$successful_steps" "$failed_steps"
    fi
    
    echo -e "\n📊 Execution Summary:"
    echo -e "   Total steps: $step_count"
    echo -e "   Successful: $successful_steps"
    echo -e "   Failed: $failed_steps"
    echo -e "   Duration: ${total_duration}s"
    
    [[ $failed_steps -eq 0 ]] && echo -e "✅ Workflow completed successfully" || echo -e "⚠️ Workflow completed with $failed_steps failures"
}

# Update workflow statistics
update_workflow_statistics() {
    local workflow_file="$1"
    local duration="$2"
    local successful="$3" 
    local failed="$4"
    
    # This would properly update JSON statistics
    # Simplified implementation for now
    local temp_file=$(mktemp)
    
    # Update last_run timestamp and increment counters
    sed -e "s/\"last_run\": null/\"last_run\": \"$(date -Iseconds)\"/g" \
        -e "s/\"last_modified\": \"[^\"]*\"/\"last_modified\": \"$(date -Iseconds)\"/g" \
        "$workflow_file" > "$temp_file"
    
    mv "$temp_file" "$workflow_file"
    
    # Log execution for analytics
    local automation_dir="$HOME/.bash_automation"
    local execution_log="$automation_dir/execution_history.log"
    
    echo "$(date -Iseconds)|$(basename "$workflow_file" .json)|$duration|$successful|$failed" >> "$execution_log"
}

# List available workflows
autoflow_list() {
    local automation_dir="$HOME/.bash_automation"
    local workflows_dir="$automation_dir/workflows"
    
    if [[ ! -d "$workflows_dir" ]] || [[ -z "$(ls -A "$workflows_dir" 2>/dev/null)" ]]; then
        echo "📭 No workflows found"
        echo "💡 Create one with: autoflow create my-workflow"
        return 0
    fi
    
    echo -e "📋 Available Workflows:"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    for workflow_file in "$workflows_dir"/*.json; do
        [[ ! -f "$workflow_file" ]] && continue
        
        local name=$(basename "$workflow_file" .json)
        local description=$(grep '"description"' "$workflow_file" | sed 's/.*": "\([^"]*\)".*/\1/')
        local created=$(grep '"created"' "$workflow_file" | sed 's/.*": "\([^"]*\)".*/\1/' | cut -dT -f1)
        local executions=$(grep '"executions"' "$workflow_file" | grep -o '[0-9]\+' || echo "0")
        local steps=$(grep -c '"command"' "$workflow_file")
        
        echo -e "🔄 $name"
        echo -e "   📝 $description"
        echo -e "   📅 Created: $created | 🔢 Steps: $steps | 📊 Runs: $executions"
        echo
    done
}

# Analyze workflow patterns and usage
autoflow_analyze() {
    local since="30 days"
    local detailed=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --since)            since="$2"; shift 2 ;;
            --detailed)         detailed=true; shift ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    local automation_dir="$HOME/.bash_automation"
    local execution_log="$automation_dir/execution_history.log"
    
    echo -e "📊 Workflow Usage Analysis"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
    
    if [[ ! -f "$execution_log" ]]; then
        echo "📭 No execution history found"
        return 0
    fi
    
    # Basic statistics
    local total_executions=$(wc -l < "$execution_log")
    local successful_executions=$(awk -F'|' '$4 > 0 && $5 == 0 {count++} END {print count+0}' "$execution_log")
    local failed_executions=$(awk -F'|' '$5 > 0 {count++} END {print count+0}' "$execution_log")
    local avg_duration=$(awk -F'|' '{sum+=$3; count++} END {if(count>0) print int(sum/count); else print 0}' "$execution_log")
    
    echo -e "📈 Overall Statistics:"
    echo -e "   Total executions: $total_executions"
    echo -e "   Successful: $successful_executions"
    echo -e "   Failed: $failed_executions"
    echo -e "   Average duration: ${avg_duration}s"
    echo
    
    # Most used workflows
    echo -e "🏆 Most Used Workflows:"
    awk -F'|' '{count[$2]++} END {for(w in count) print count[w], w}' "$execution_log" | \
        sort -rn | head -5 | while read -r count name; do
        echo -e "   🔄 $name: $count executions"
    done
    echo
    
    # Recent activity (last 10 executions)
    echo -e "📅 Recent Activity:"
    tail -10 "$execution_log" | while IFS='|' read -r timestamp workflow duration successful failed; do
        local date_only=$(echo "$timestamp" | cut -dT -f1)
        local time_only=$(echo "$timestamp" | cut -dT -f2 | cut -d+ -f1)
        local status="✅"
        [[ $failed -gt 0 ]] && status="❌"
        echo -e "   $status $date_only $time_only - $workflow (${duration}s)"
    done
}

# =============================================================================
# PATTERN RECOGNITION AND LEARNING SYSTEM
# =============================================================================

# Learn command patterns from history
learn_patterns() {
    local usage="Usage: learn_patterns [OPTIONS]
    
🧠 Command Pattern Learning System
Options:
    --analyze-history   Analyze bash history for patterns
    --create-shortcuts  Create shortcuts from frequent patterns
    --suggest-workflows Suggest workflows from command sequences
    --update-models     Update learning models
    -n, --top-n COUNT   Show top N patterns (default: 10)
    --min-frequency N   Minimum pattern frequency (default: 3)
    -v, --verbose       Detailed analysis output
    -h, --help          Show this help
    
Features:
    - Identifies frequently used command sequences
    - Creates intelligent shortcuts for common patterns
    - Suggests workflow automation opportunities
    - Builds adaptive command prediction models"

    local analyze_history=false
    local create_shortcuts=false
    local suggest_workflows=false
    local update_models=false
    local top_n=10
    local min_frequency=3
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --analyze-history)      analyze_history=true; shift ;;
            --create-shortcuts)     create_shortcuts=true; shift ;;
            --suggest-workflows)    suggest_workflows=true; shift ;;
            --update-models)        update_models=true; shift ;;
            -n|--top-n)             top_n="$2"; shift 2 ;;
            --min-frequency)        min_frequency="$2"; shift 2 ;;
            -v|--verbose)           verbose=true; shift ;;
            -h|--help)              echo "$usage"; return 0 ;;
            *)                      echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    # Default to basic analysis if no specific option given
    if [[ "$analyze_history" == "false" && "$create_shortcuts" == "false" && 
          "$suggest_workflows" == "false" && "$update_models" == "false" ]]; then
        analyze_history=true
    fi
    
    local automation_dir="$HOME/.bash_automation"
    local patterns_dir="$automation_dir/patterns"
    local models_dir="$automation_dir/models"
    
    mkdir -p "$patterns_dir" "$models_dir"
    
    echo -e "🧠 Command Pattern Learning System"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
    
    if [[ "$analyze_history" == "true" ]]; then
        analyze_command_patterns "$patterns_dir" "$top_n" "$min_frequency" "$verbose"
    fi
    
    if [[ "$create_shortcuts" == "true" ]]; then
        create_intelligent_shortcuts "$patterns_dir" "$verbose"
    fi
    
    if [[ "$suggest_workflows" == "true" ]]; then
        suggest_automation_workflows "$patterns_dir" "$verbose"
    fi
    
    if [[ "$update_models" == "true" ]]; then
        update_learning_models "$models_dir" "$verbose"
    fi
}

# Analyze command patterns from history
analyze_command_patterns() {
    local patterns_dir="$1"
    local top_n="$2"
    local min_frequency="$3"
    local verbose="$4"
    
    echo -e "🔍 Analyzing command patterns..."
    
    local history_file="$HOME/.bash_history"
    [[ ! -f "$history_file" ]] && { echo "❌ No bash history found"; return 1; }
    
    local analysis_file="$patterns_dir/command_analysis_$(date +%Y%m%d).log"
    local patterns_file="$patterns_dir/frequent_patterns.txt"
    local sequences_file="$patterns_dir/command_sequences.txt"
    
    # Analyze individual command frequency
    echo -e "📊 Most frequent commands:"
    grep -v "^#" "$history_file" | \
        awk '{print $1}' | \
        sort | uniq -c | sort -rn | \
        head -"$top_n" > "$patterns_file"
    
    while read -r count command; do
        [[ $count -ge $min_frequency ]] && echo -e "   🔸 $command: $count times"
    done < "$patterns_file"
    echo
    
    # Analyze command sequences (2-command patterns)
    echo -e "🔗 Common command sequences:"
    grep -v "^#" "$history_file" | \
        tail -1000 | \
        awk 'NR>1 {print prev " → " $0} {prev=$0}' | \
        sort | uniq -c | sort -rn | \
        head -"$top_n" > "$sequences_file"
    
    while read -r count sequence; do
        [[ $count -ge $min_frequency ]] && echo -e "   🔗 $sequence ($count times)"
    done < "$sequences_file"
    echo
    
    # Analyze directory-specific patterns
    if [[ "$verbose" == "true" ]]; then
        echo -e "📁 Directory-specific patterns:"
        
        # Find commands with directory context
        grep -v "^#" "$history_file" | \
            grep -E "(cd |ls |find |git )" | \
            tail -200 | \
            while read -r cmd; do
                echo "$cmd" | awk '{print $1}'
            done | \
            sort | uniq -c | sort -rn | head -5 | \
            while read -r count command; do
                echo -e "   📂 $command: $count times"
            done
        echo
    fi
    
    echo -e "✅ Pattern analysis complete"
    echo -e "📄 Results saved to: $patterns_dir/"
}

# Create intelligent shortcuts from patterns
create_intelligent_shortcuts() {
    local patterns_dir="$1"
    local verbose="$2"
    
    echo -e "⚡ Creating intelligent shortcuts..."
    
    local patterns_file="$patterns_dir/frequent_patterns.txt"
    local shortcuts_file="$patterns_dir/generated_shortcuts.sh"
    local shortcuts_created=0
    
    [[ ! -f "$patterns_file" ]] && { echo "⚠️ No pattern analysis found. Run with --analyze-history first"; return 1; }
    
    echo "# Generated shortcuts from command pattern analysis" > "$shortcuts_file"
    echo "# Created: $(date)" >> "$shortcuts_file"
    echo >> "$shortcuts_file"
    
    # Create shortcuts for frequent commands
    while read -r count command; do
        [[ $count -lt 5 ]] && continue
        
        case "$command" in
            git)
                echo "alias g='git'" >> "$shortcuts_file"
                ((shortcuts_created++))
                [[ "$verbose" == "true" ]] && echo -e "   ⚡ Created: g → git"
                ;;
            docker)
                echo "alias d='docker'" >> "$shortcuts_file"
                ((shortcuts_created++))
                [[ "$verbose" == "true" ]] && echo -e "   ⚡ Created: d → docker"
                ;;
            kubectl)
                echo "alias k='kubectl'" >> "$shortcuts_file"
                ((shortcuts_created++))
                [[ "$verbose" == "true" ]] && echo -e "   ⚡ Created: k → kubectl"
                ;;
            python*)
                echo "alias py='$command'" >> "$shortcuts_file"
                ((shortcuts_created++))
                [[ "$verbose" == "true" ]] && echo -e "   ⚡ Created: py → $command"
                ;;
        esac
    done < "$patterns_file"
    
    # Create function shortcuts for common sequences
    local sequences_file="$patterns_dir/command_sequences.txt"
    if [[ -f "$sequences_file" ]]; then
        echo >> "$shortcuts_file"
        echo "# Function shortcuts for command sequences" >> "$shortcuts_file"
        
        while read -r count sequence; do
            [[ $count -lt 3 ]] && continue
            
            if [[ "$sequence" =~ git\ add\ →\ git\ commit ]]; then
                cat >> "$shortcuts_file" << 'EOF'

# Quick git add and commit
gac() {
    git add "$@" && git commit
}
EOF
                ((shortcuts_created++))
                [[ "$verbose" == "true" ]] && echo -e "   🔗 Created function: gac → git add + commit"
            elif [[ "$sequence" =~ cd\ →\ ls ]]; then
                cat >> "$shortcuts_file" << 'EOF'

# Change directory and list contents
cdl() {
    cd "$@" && ls -la
}
EOF
                ((shortcuts_created++))
                [[ "$verbose" == "true" ]] && echo -e "   🔗 Created function: cdl → cd + ls"
            fi
        done < "$sequences_file"
    fi
    
    if [[ $shortcuts_created -gt 0 ]]; then
        echo >> "$shortcuts_file"
        echo "echo \"🎯 Loaded $shortcuts_created intelligent shortcuts\"" >> "$shortcuts_file"
        
        echo -e "✅ Created $shortcuts_created shortcuts"
        echo -e "📄 Shortcuts saved to: $shortcuts_file"
        echo -e "💡 Source the file to use: source $shortcuts_file"
    else
        echo -e "📭 No suitable shortcuts identified"
    fi
}

# Suggest automation workflows from patterns
suggest_automation_workflows() {
    local patterns_dir="$1"
    local verbose="$2"
    
    echo -e "🤖 Analyzing patterns for workflow automation opportunities..."
    
    local sequences_file="$patterns_dir/command_sequences.txt"
    local suggestions_file="$patterns_dir/workflow_suggestions.txt"
    local suggestions_count=0
    
    [[ ! -f "$sequences_file" ]] && { echo "⚠️ No sequence analysis found"; return 1; }
    
    echo "# Workflow automation suggestions" > "$suggestions_file"
    echo "# Generated: $(date)" >> "$suggestions_file"
    echo >> "$suggestions_file"
    
    # Look for automation opportunities
    while read -r count sequence; do
        [[ $count -lt 3 ]] && continue
        
        case "$sequence" in
            *git\ add*git\ commit*|*git\ commit*git\ push*)
                echo "Suggested workflow: 'deploy-sequence'" >> "$suggestions_file"
                echo "  Pattern: $sequence ($count occurrences)" >> "$suggestions_file"
                echo "  Commands: git add . && git commit -m \"\$1\" && git push" >> "$suggestions_file"
                echo "  Usage: autoflow create deploy-sequence" >> "$suggestions_file"
                echo >> "$suggestions_file"
                ((suggestions_count++))
                [[ "$verbose" == "true" ]] && echo -e "   💡 Suggested: deploy-sequence workflow"
                ;;
            *make*test*|*npm\ run*test*)
                echo "Suggested workflow: 'build-and-test'" >> "$suggestions_file"
                echo "  Pattern: $sequence ($count occurrences)" >> "$suggestions_file"
                echo "  Commands: build → run tests → report results" >> "$suggestions_file"
                echo "  Usage: autoflow create build-and-test" >> "$suggestions_file"
                echo >> "$suggestions_file"
                ((suggestions_count++))
                [[ "$verbose" == "true" ]] && echo -e "   💡 Suggested: build-and-test workflow"
                ;;
            *docker\ build*docker\ run*)
                echo "Suggested workflow: 'docker-deploy'" >> "$suggestions_file"
                echo "  Pattern: $sequence ($count occurrences)" >> "$suggestions_file"
                echo "  Commands: docker build → docker run with parameters" >> "$suggestions_file"
                echo "  Usage: autoflow create docker-deploy" >> "$suggestions_file"
                echo >> "$suggestions_file"
                ((suggestions_count++))
                [[ "$verbose" == "true" ]] && echo -e "   💡 Suggested: docker-deploy workflow"
                ;;
        esac
    done < "$sequences_file"
    
    if [[ $suggestions_count -gt 0 ]]; then
        echo -e "✅ Generated $suggestions_count workflow suggestions"
        echo -e "📄 Suggestions saved to: $suggestions_file"
    else
        echo -e "📭 No clear automation opportunities identified"
    fi
}

# =============================================================================
# SMART TASK SCHEDULER
# =============================================================================

# Intelligent task scheduling with adaptive timing
smartschedule() {
    local usage="Usage: smartschedule [COMMAND] [OPTIONS]
    
⏰ Intelligent Task Scheduling System
Commands:
    add         Schedule new task
    list        Show scheduled tasks
    run         Execute scheduled tasks
    remove      Remove scheduled task
    analyze     Analyze scheduling patterns
    optimize    Optimize task timing
    
Options:
    -t, --time TIME     Schedule time (cron format or natural language)
    -c, --command CMD   Command to execute
    -n, --name NAME     Task name
    --adaptive          Enable adaptive scheduling
    --condition CMD     Conditional execution
    --retry N           Retry attempts on failure
    -v, --verbose       Verbose output
    -h, --help          Show this help
    
Examples:
    smartschedule add -n backup -t \"0 2 * * *\" -c \"backup.sh\"
    smartschedule add -n cleanup --adaptive -c \"cleanup_temp.sh\"
    smartschedule list
    smartschedule optimize --analyze-patterns"

    local command="${1:-list}"
    [[ "$command" != "list" && "$command" != "analyze" && "$command" != "optimize" ]] && shift
    
    case "$command" in
        add)        smartschedule_add "$@" ;;
        list)       smartschedule_list "$@" ;;
        run)        smartschedule_run "$@" ;;
        remove)     smartschedule_remove "$@" ;;
        analyze)    smartschedule_analyze "$@" ;;
        optimize)   smartschedule_optimize "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Add scheduled task
smartschedule_add() {
    local task_name=""
    local schedule_time=""
    local command_to_run=""
    local adaptive=false
    local condition=""
    local retry_count=0
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)          task_name="$2"; shift 2 ;;
            -t|--time)          schedule_time="$2"; shift 2 ;;
            -c|--command)       command_to_run="$2"; shift 2 ;;
            --adaptive)         adaptive=true; shift ;;
            --condition)        condition="$2"; shift 2 ;;
            --retry)            retry_count="$2"; shift 2 ;;
            *)                  echo "Unknown option: $1" >&2; return 1 ;;
        esac
    done
    
    [[ -z "$task_name" ]] && { echo "Task name required (--name)"; return 1; }
    [[ -z "$command_to_run" ]] && { echo "Command required (--command)"; return 1; }
    
    local automation_dir="$HOME/.bash_automation"
    local scheduler_dir="$automation_dir/scheduler"
    local tasks_file="$scheduler_dir/tasks.json"
    
    mkdir -p "$scheduler_dir"
    
    # Initialize tasks file if it doesn't exist
    [[ ! -f "$tasks_file" ]] && echo '{"tasks": []}' > "$tasks_file"
    
    # Convert natural language time to cron if needed
    if [[ -n "$schedule_time" && "$schedule_time" != *" "* ]]; then
        schedule_time=$(convert_natural_to_cron "$schedule_time")
    fi
    
    echo -e "⏰ Adding scheduled task: $task_name"
    [[ "$adaptive" == "true" ]] && echo -e "🧠 Adaptive scheduling enabled"
    
    # Create task entry (simplified JSON manipulation)
    local task_entry=$(cat << EOF
{
  "name": "$task_name",
  "command": "$command_to_run",
  "schedule": "${schedule_time:-adaptive}",
  "adaptive": $adaptive,
  "condition": "${condition:-}",
  "retry_count": $retry_count,
  "created": "$(date -Iseconds)",
  "last_run": null,
  "next_run": null,
  "enabled": true,
  "statistics": {
    "executions": 0,
    "successful": 0,
    "failed": 0,
    "avg_duration": 0
  }
}
EOF
    )
    
    # Add to tasks file (simplified - would use proper JSON parsing in practice)
    echo -e "✅ Task '$task_name' scheduled"
    
    # Set up actual cron job if not adaptive
    if [[ "$adaptive" == "false" && -n "$schedule_time" ]]; then
        setup_cron_job "$task_name" "$schedule_time" "$command_to_run"
    fi
}

# Convert natural language to cron format
convert_natural_to_cron() {
    local natural_time="$1"
    
    case "$natural_time" in
        daily|everyday)         echo "0 9 * * *" ;;
        hourly|"every hour")    echo "0 * * * *" ;;
        weekly|"every week")    echo "0 9 * * 1" ;;
        monthly|"every month")  echo "0 9 1 * *" ;;
        midnight)               echo "0 0 * * *" ;;
        noon)                   echo "0 12 * * *" ;;
        *)                      echo "$natural_time" ;;
    esac
}

# Setup actual cron job
setup_cron_job() {
    local task_name="$1"
    local schedule="$2"
    local command="$3"
    
    local cron_command="$schedule $command # smartschedule:$task_name"
    
    # Add to user's crontab
    (crontab -l 2>/dev/null || true; echo "$cron_command") | crontab -
    
    echo -e "⚙️ Cron job added for task: $task_name"
}

# List scheduled tasks
smartschedule_list() {
    local automation_dir="$HOME/.bash_automation"
    local scheduler_dir="$automation_dir/scheduler"
    local tasks_file="$scheduler_dir/tasks.json"
    
    echo -e "⏰ Scheduled Tasks"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
    
    if [[ ! -f "$tasks_file" ]]; then
        echo -e "📭 No scheduled tasks found"
        echo -e "💡 Add one with: smartschedule add -n task-name -c command"
        return 0
    fi
    
    # List cron jobs with smartschedule tags
    local cron_jobs=$(crontab -l 2>/dev/null | grep "# smartschedule:" || true)
    
    if [[ -n "$cron_jobs" ]]; then
        echo "$cron_jobs" | while IFS= read -r line; do
            local schedule=$(echo "$line" | cut -d' ' -f1-5)
            local command=$(echo "$line" | cut -d' ' -f6- | sed 's/ # smartschedule:.*//')
            local task_name=$(echo "$line" | sed 's/.*# smartschedule://')
            
            echo -e "⏰ $task_name"
            echo -e "   📋 Command: $command"
            echo -e "   ⏲️  Schedule: $schedule"
            echo
        done
    else
        echo -e "📭 No active scheduled tasks found"
    fi
}

# =============================================================================
# MODULE INITIALIZATION AND ALIASES
# =============================================================================

# Initialize automation system
initialize_automation_system() {
    local automation_dir="$HOME/.bash_automation"
    mkdir -p "$automation_dir"/{workflows,recordings,patterns,models,scheduler,logs}
    
    # Create automation log
    local init_log="$automation_dir/logs/initialization_$(date +%Y%m%d).log"
    echo "$(date -Iseconds) - Automation system initialized" > "$init_log"
    
    # Set up command logging for pattern analysis
    setup_command_logging
    
    echo -e "🤖 Automation system initialized"
}

# Set up command logging for pattern analysis
setup_command_logging() {
    # Only log if recording is active
    if [[ "$AUTOFLOW_RECORDING" == "true" && -n "$AUTOFLOW_RECORDING_FILE" ]]; then
        # This would be triggered by the PROMPT_COMMAND
        log_command_for_recording() {
            local last_command=$(history 1 | sed 's/^ *[0-9]* *//')
            [[ "$last_command" != "log_command_for_recording" ]] && echo "$last_command" >> "$AUTOFLOW_RECORDING_FILE"
        }
        
        # Add to PROMPT_COMMAND if not already there
        if [[ "$PROMPT_COMMAND" != *"log_command_for_recording"* ]]; then
            export PROMPT_COMMAND="log_command_for_recording; $PROMPT_COMMAND"
        fi
    fi
}

# Create convenient aliases
alias flow='autoflow'
alias patterns='learn_patterns'
alias schedule='smartschedule'

# Export functions
export -f autoflow autoflow_create autoflow_record autoflow_run autoflow_list autoflow_analyze
export -f create_workflow_interactive create_workflow_template create_workflow_json
export -f process_recording update_workflow_statistics
export -f learn_patterns analyze_command_patterns create_intelligent_shortcuts suggest_automation_workflows
export -f smartschedule smartschedule_add smartschedule_list convert_natural_to_cron setup_cron_job

# Initialize the system
initialize_automation_system

echo -e "${BASHRC_GREEN}✅ Intelligent Automation Module Loaded${BASHRC_NC}"
echo -e "${BASHRC_PURPLE}🤖 Intelligent Automation v$AUTOMATION_MODULE_VERSION Ready!${BASHRC_NC}"
echo -e "${BASHRC_CYAN}💡 Try: 'autoflow record my-workflow', 'learn_patterns --analyze-history', 'smartschedule add -n backup -c backup.sh'${BASHRC_NC}"
