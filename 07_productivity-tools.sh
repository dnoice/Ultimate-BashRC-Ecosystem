#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - PRODUCTIVITY TOOLS MODULE
# File: 07_productivity-tools.sh
# =============================================================================
# This module provides comprehensive productivity tools including task management,
# time tracking, note-taking, project organization, goal tracking, and
# productivity analytics to optimize your workflow and efficiency.
# =============================================================================

# Module metadata
declare -r PRODUCTIVITY_MODULE_VERSION="2.1.0"
declare -r PRODUCTIVITY_MODULE_NAME="Productivity Tools"
declare -r PRODUCTIVITY_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# Module initialization
echo -e "${BASHRC_CYAN}📊 Loading Productivity Tools...${BASHRC_NC}"

# =============================================================================
# INTELLIGENT TASK MANAGEMENT SYSTEM
# =============================================================================

# Comprehensive task management with priorities, projects, and tracking
task() {
    local usage="Usage: task [COMMAND] [OPTIONS] [TASK_DESCRIPTION]
    
✅ Intelligent Task Management System
Commands:
    add         Add new task
    list        Show tasks (default)
    done        Mark task as completed
    edit        Edit existing task
    delete      Delete task
    start       Start working on task (time tracking)
    stop        Stop current task
    priority    Set task priority
    project     Assign task to project
    due         Set due date
    search      Search tasks
    report      Generate task reports
    archive     Archive completed tasks
    
Options:
    -p, --priority LEVEL    Priority (1-5, or low/med/high/critical)
    -P, --project NAME      Project name
    -d, --due DATE          Due date (YYYY-MM-DD or natural language)
    -t, --tags TAGS         Comma-separated tags
    -s, --status STATUS     Status (todo, doing, done, blocked)
    -a, --assignee USER     Assignee (for team tasks)
    -e, --estimate TIME     Time estimate (e.g., 2h, 30m)
    -c, --context CONTEXT   Context (@home, @office, @online)
    -r, --recurring PATTERN Recurring pattern (daily, weekly, monthly)
    -f, --format FORMAT     Output format (table, json, simple)
    -l, --limit N           Limit number of results
    --overdue               Show only overdue tasks
    --today                 Show tasks due today
    --week                  Show tasks due this week
    -v, --verbose           Verbose output
    -h, --help              Show this help
    
Examples:
    task add \"Fix bug in login system\" -p high -P webapp -d tomorrow
    task list -P webapp --today
    task done 15
    task start 12
    task report --week --project webapp"

    local command="${1:-list}"
    [[ "$command" =~ ^(add|list|done|edit|delete|start|stop|priority|project|due|search|report|archive)$ ]] && shift || command="list"
    
    case "$command" in
        add)        task_add "$@" ;;
        list)       task_list "$@" ;;
        done)       task_complete "$@" ;;
        edit)       task_edit "$@" ;;
        delete)     task_delete "$@" ;;
        start)      task_start "$@" ;;
        stop)       task_stop "$@" ;;
        priority)   task_priority "$@" ;;
        project)    task_project "$@" ;;
        due)        task_due "$@" ;;
        search)     task_search "$@" ;;
        report)     task_report "$@" ;;
        archive)    task_archive "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Add new task
task_add() {
    local description=""
    local priority="medium"
    local project=""
    local due_date=""
    local tags=""
    local status="todo"
    local assignee=""
    local estimate=""
    local context=""
    local recurring=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--priority)      priority="$(normalize_priority "$2")"; shift 2 ;;
            -P|--project)       project="$2"; shift 2 ;;
            -d|--due)           due_date="$(parse_date "$2")"; shift 2 ;;
            -t|--tags)          tags="$2"; shift 2 ;;
            -s|--status)        status="$2"; shift 2 ;;
            -a|--assignee)      assignee="$2"; shift 2 ;;
            -e|--estimate)      estimate="$2"; shift 2 ;;
            -c|--context)       context="$2"; shift 2 ;;
            -r|--recurring)     recurring="$2"; shift 2 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  description="$*"; break ;;
        esac
    done
    
    [[ -z "$description" ]] && { echo "Task description required"; return 1; }
    
    local productivity_dir="$HOME/.bash_productivity"
    local tasks_file="$productivity_dir/tasks.csv"
    
    mkdir -p "$productivity_dir"
    
    # Initialize tasks file with header if it doesn't exist
    if [[ ! -f "$tasks_file" ]]; then
        echo "id,created,description,priority,project,due_date,tags,status,assignee,estimate,context,recurring,completed,time_spent" > "$tasks_file"
    fi
    
    # Generate unique task ID
    local task_id=$(get_next_task_id "$tasks_file")
    local created=$(date -Iseconds)
    
    # Create task record
    echo "$task_id,$created,\"$description\",$priority,\"$project\",\"$due_date\",\"$tags\",$status,\"$assignee\",\"$estimate\",\"$context\",\"$recurring\",,0" >> "$tasks_file"
    
    echo -e "✅ Task added: #$task_id - $description"
    [[ -n "$project" ]] && echo -e "📁 Project: $project"
    [[ -n "$due_date" ]] && echo -e "📅 Due: $due_date"
    echo -e "🎯 Priority: $(format_priority "$priority")"
    
    # Log task creation for analytics
    log_task_action "create" "$task_id" "$description"
}

# List tasks with intelligent filtering
task_list() {
    local project_filter=""
    local priority_filter=""
    local status_filter=""
    local show_overdue=false
    local show_today=false
    local show_week=false
    local format="table"
    local limit=""
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -P|--project)       project_filter="$2"; shift 2 ;;
            -p|--priority)      priority_filter="$(normalize_priority "$2")"; shift 2 ;;
            -s|--status)        status_filter="$2"; shift 2 ;;
            --overdue)          show_overdue=true; shift ;;
            --today)            show_today=true; shift ;;
            --week)             show_week=true; shift ;;
            -f|--format)        format="$2"; shift 2 ;;
            -l|--limit)         limit="$2"; shift 2 ;;
            -v|--verbose)       verbose=true; shift ;;
            *)                  shift ;;
        esac
    done
    
    local productivity_dir="$HOME/.bash_productivity"
    local tasks_file="$productivity_dir/tasks.csv"
    
    if [[ ! -f "$tasks_file" ]]; then
        echo "📭 No tasks found. Add one with: task add \"Your task\""
        return 0
    fi
    
    echo -e "📋 Task List"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    # Read and filter tasks
    local matching_tasks=()
    local current_date=$(date +%Y-%m-%d)
    local week_end=$(date -d "+7 days" +%Y-%m-%d)
    
    while IFS=',' read -r id created description priority project due_date tags status assignee estimate context recurring completed time_spent; do
        [[ "$id" == "id" ]] && continue  # Skip header
        
        # Apply filters
        [[ -n "$project_filter" && "$project" != *"$project_filter"* ]] && continue
        [[ -n "$priority_filter" && "$priority" != "$priority_filter" ]] && continue
        [[ -n "$status_filter" && "$status" != "$status_filter" ]] && continue
        
        # Date filters
        if [[ "$show_overdue" == "true" ]]; then
            [[ -z "$due_date" || "$due_date" > "$current_date" ]] && continue
        fi
        
        if [[ "$show_today" == "true" ]]; then
            [[ "$due_date" != "$current_date" ]] && continue
        fi
        
        if [[ "$show_week" == "true" ]]; then
            [[ -z "$due_date" || "$due_date" > "$week_end" ]] && continue
        fi
        
        matching_tasks+=("$id,$created,$description,$priority,$project,$due_date,$tags,$status,$assignee,$estimate,$context,$recurring,$completed,$time_spent")
    done < "$tasks_file"
    
    # Apply limit
    if [[ -n "$limit" && ${#matching_tasks[@]} -gt $limit ]]; then
        matching_tasks=("${matching_tasks[@]:0:$limit}")
    fi
    
    # Display tasks
    if [[ ${#matching_tasks[@]} -eq 0 ]]; then
        echo "📭 No matching tasks found"
        return 0
    fi
    
    case "$format" in
        table)
            display_tasks_table "${matching_tasks[@]}"
            ;;
        json)
            display_tasks_json "${matching_tasks[@]}"
            ;;
        simple)
            display_tasks_simple "${matching_tasks[@]}"
            ;;
    esac
    
    echo -e "\n📊 Total: ${#matching_tasks[@]} tasks"
}

# Complete task
task_complete() {
    local task_id="$1"
    [[ -z "$task_id" ]] && { echo "Task ID required"; return 1; }
    
    local productivity_dir="$HOME/.bash_productivity"
    local tasks_file="$productivity_dir/tasks.csv"
    
    if [[ ! -f "$tasks_file" ]]; then
        echo "❌ No tasks file found"
        return 1
    fi
    
    # Update task status
    local temp_file=$(mktemp)
    local task_found=false
    local completed_date=$(date -Iseconds)
    
    while IFS=',' read -r id created description priority project due_date tags status assignee estimate context recurring completed time_spent; do
        if [[ "$id" == "$task_id" ]]; then
            task_found=true
            echo "$id,$created,$description,$priority,$project,$due_date,$tags,done,$assignee,$estimate,$context,$recurring,$completed_date,$time_spent"
            echo -e "✅ Task completed: #$id - $(echo "$description" | tr -d '"')"
        else
            echo "$id,$created,$description,$priority,$project,$due_date,$tags,$status,$assignee,$estimate,$context,$recurring,$completed,$time_spent"
        fi
    done < "$tasks_file" > "$temp_file"
    
    if [[ "$task_found" == "true" ]]; then
        mv "$temp_file" "$tasks_file"
        log_task_action "complete" "$task_id" "Task completed"
    else
        rm -f "$temp_file"
        echo "❌ Task #$task_id not found"
        return 1
    fi
}

# Start time tracking for task
task_start() {
    local task_id="$1"
    [[ -z "$task_id" ]] && { echo "Task ID required"; return 1; }
    
    local productivity_dir="$HOME/.bash_productivity"
    local tasks_file="$productivity_dir/tasks.csv"
    local timer_file="$productivity_dir/current_timer.txt"
    
    # Stop any current timer
    if [[ -f "$timer_file" ]]; then
        local current_task=$(cat "$timer_file")
        task_stop "$current_task"
    fi
    
    # Verify task exists and get description
    local task_description=""
    while IFS=',' read -r id created description priority project due_date tags status assignee estimate context recurring completed time_spent; do
        if [[ "$id" == "$task_id" ]]; then
            task_description=$(echo "$description" | tr -d '"')
            break
        fi
    done < "$tasks_file"
    
    if [[ -z "$task_description" ]]; then
        echo "❌ Task #$task_id not found"
        return 1
    fi
    
    # Start timer
    echo "$task_id" > "$timer_file"
    echo "$(date +%s)" > "$productivity_dir/timer_start.txt"
    
    echo -e "⏱️ Started working on: #$task_id - $task_description"
    echo -e "💡 Use 'task stop' to stop the timer"
    
    # Update shell prompt to show active task (optional)
    export CURRENT_TASK="$task_id"
}

# Stop current timer
task_stop() {
    local productivity_dir="$HOME/.bash_productivity"
    local timer_file="$productivity_dir/current_timer.txt"
    local timer_start_file="$productivity_dir/timer_start.txt"
    
    if [[ ! -f "$timer_file" || ! -f "$timer_start_file" ]]; then
        echo "⏱️ No active timer found"
        return 0
    fi
    
    local task_id=$(cat "$timer_file")
    local start_time=$(cat "$timer_start_file")
    local end_time=$(date +%s)
    local elapsed=$((end_time - start_time))
    
    # Update task with time spent
    update_task_time "$task_id" "$elapsed"
    
    # Clean up timer files
    rm -f "$timer_file" "$timer_start_file"
    unset CURRENT_TASK
    
    local hours=$((elapsed / 3600))
    local minutes=$(((elapsed % 3600) / 60))
    
    echo -e "⏹️ Stopped timer for task #$task_id"
    echo -e "⏱️ Time worked: ${hours}h ${minutes}m"
    
    log_task_action "stop_timer" "$task_id" "Worked ${hours}h ${minutes}m"
}

# Generate task reports
task_report() {
    local period="week"
    local project_filter=""
    local format="summary"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --today|--daily)    period="today"; shift ;;
            --week|--weekly)    period="week"; shift ;;
            --month|--monthly)  period="month"; shift ;;
            -P|--project)       project_filter="$2"; shift 2 ;;
            -f|--format)        format="$2"; shift 2 ;;
            *)                  shift ;;
        esac
    done
    
    local productivity_dir="$HOME/.bash_productivity"
    local tasks_file="$productivity_dir/tasks.csv"
    
    if [[ ! -f "$tasks_file" ]]; then
        echo "❌ No tasks file found"
        return 1
    fi
    
    echo -e "📊 Task Report - $(echo ${period^})"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}\n"
    
    # Calculate date range
    local start_date end_date
    case "$period" in
        today)
            start_date=$(date +%Y-%m-%d)
            end_date=$(date +%Y-%m-%d)
            ;;
        week)
            start_date=$(date -d "monday" +%Y-%m-%d)
            end_date=$(date -d "sunday" +%Y-%m-%d)
            ;;
        month)
            start_date=$(date +%Y-%m-01)
            end_date=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%Y-%m-%d)
            ;;
    esac
    
    # Generate statistics
    generate_task_statistics "$tasks_file" "$start_date" "$end_date" "$project_filter"
}

# Utility functions
get_next_task_id() {
    local tasks_file="$1"
    if [[ ! -f "$tasks_file" ]]; then
        echo "1"
        return
    fi
    
    local max_id=$(tail -n +2 "$tasks_file" | cut -d',' -f1 | sort -n | tail -1)
    echo $((max_id + 1))
}

normalize_priority() {
    case "$1" in
        1|low)      echo "1" ;;
        2|med|medium) echo "3" ;;
        3|high)     echo "4" ;;
        4|critical) echo "5" ;;
        5)          echo "5" ;;
        *)          echo "3" ;;
    esac
}

format_priority() {
    case "$1" in
        1) echo "🔵 Low" ;;
        2) echo "🟡 Medium" ;;
        3) echo "🟡 Medium" ;;
        4) echo "🟠 High" ;;
        5) echo "🔴 Critical" ;;
        *) echo "🟡 Medium" ;;
    esac
}

parse_date() {
    case "$1" in
        today)      date +%Y-%m-%d ;;
        tomorrow)   date -d "+1 day" +%Y-%m-%d ;;
        "next week") date -d "+7 days" +%Y-%m-%d ;;
        "next month") date -d "+1 month" +%Y-%m-%d ;;
        *)          echo "$1" ;;
    esac
}

display_tasks_table() {
    local tasks=("$@")
    
    printf "%-3s %-8s %-40s %-8s %-12s %-10s %-8s\n" "ID" "Priority" "Description" "Status" "Project" "Due Date" "Time"
    printf "%-3s %-8s %-40s %-8s %-12s %-10s %-8s\n" "---" "--------" "$(printf '%.40s' "----------------------------------------")" "--------" "------------" "----------" "--------"
    
    for task in "${tasks[@]}"; do
        IFS=',' read -r id created description priority project due_date tags status assignee estimate context recurring completed time_spent <<< "$task"
        
        local priority_display=$(format_priority "$priority" | cut -d' ' -f1)
        local desc_short=$(echo "$description" | tr -d '"' | cut -c1-38)
        local project_short=$(echo "$project" | tr -d '"' | cut -c1-10)
        local time_display=$(format_time_spent "$time_spent")
        
        # Color coding for status
        local status_color=""
        case "$status" in
            todo)    status_color="${BASHRC_YELLOW}$status${BASHRC_NC}" ;;
            doing)   status_color="${BASHRC_CYAN}$status${BASHRC_NC}" ;;
            done)    status_color="${BASHRC_GREEN}$status${BASHRC_NC}" ;;
            blocked) status_color="${BASHRC_RED}$status${BASHRC_NC}" ;;
            *)       status_color="$status" ;;
        esac
        
        printf "%-3s %-8s %-40s %-8s %-12s %-10s %-8s\n" "$id" "$priority_display" "$desc_short" "$status_color" "$project_short" "$due_date" "$time_display"
    done
}

format_time_spent() {
    local seconds="$1"
    [[ -z "$seconds" || "$seconds" -eq 0 ]] && { echo "-"; return; }
    
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    
    if [[ $hours -gt 0 ]]; then
        echo "${hours}h${minutes}m"
    else
        echo "${minutes}m"
    fi
}

update_task_time() {
    local task_id="$1"
    local additional_seconds="$2"
    
    local productivity_dir="$HOME/.bash_productivity"
    local tasks_file="$productivity_dir/tasks.csv"
    local temp_file=$(mktemp)
    
    while IFS=',' read -r id created description priority project due_date tags status assignee estimate context recurring completed time_spent; do
        if [[ "$id" == "$task_id" ]]; then
            local current_time=${time_spent:-0}
            local new_time=$((current_time + additional_seconds))
            echo "$id,$created,$description,$priority,$project,$due_date,$tags,$status,$assignee,$estimate,$context,$recurring,$completed,$new_time"
        else
            echo "$id,$created,$description,$priority,$project,$due_date,$tags,$status,$assignee,$estimate,$context,$recurring,$completed,$time_spent"
        fi
    done < "$tasks_file" > "$temp_file"
    
    mv "$temp_file" "$tasks_file"
}

log_task_action() {
    local action="$1"
    local task_id="$2"
    local description="$3"
    
    local productivity_dir="$HOME/.bash_productivity"
    local log_file="$productivity_dir/task_log.csv"
    
    echo "$(date -Iseconds),$action,$task_id,\"$description\"" >> "$log_file"
}

generate_task_statistics() {
    local tasks_file="$1"
    local start_date="$2"
    local end_date="$3"
    local project_filter="$4"
    
    local total_tasks=0
    local completed_tasks=0
    local total_time=0
    local overdue_tasks=0
    local current_date=$(date +%Y-%m-%d)
    
    declare -A project_stats
    declare -A priority_stats
    
    while IFS=',' read -r id created description priority project due_date tags status assignee estimate context recurring completed time_spent; do
        [[ "$id" == "id" ]] && continue
        
        # Filter by project if specified
        [[ -n "$project_filter" && "$project" != *"$project_filter"* ]] && continue
        
        # Filter by date range (using created date)
        local created_date=$(echo "$created" | cut -d'T' -f1)
        [[ "$created_date" < "$start_date" || "$created_date" > "$end_date" ]] && continue
        
        ((total_tasks++))
        
        # Count by status
        [[ "$status" == "done" ]] && ((completed_tasks++))
        
        # Count overdue
        [[ -n "$due_date" && "$due_date" < "$current_date" && "$status" != "done" ]] && ((overdue_tasks++))
        
        # Sum time spent
        [[ -n "$time_spent" && "$time_spent" -gt 0 ]] && total_time=$((total_time + time_spent))
        
        # Project statistics
        local proj_name=${project:-"No Project"}
        project_stats["$proj_name"]=$((${project_stats["$proj_name"]:-0} + 1))
        
        # Priority statistics
        priority_stats["$priority"]=$((${priority_stats["$priority"]:-0} + 1))
        
    done < "$tasks_file"
    
    # Display statistics
    local completion_rate=0
    [[ $total_tasks -gt 0 ]] && completion_rate=$(echo "scale=1; $completed_tasks * 100 / $total_tasks" | bc -l)
    
    echo -e "📈 ${BASHRC_YELLOW}Overview:${BASHRC_NC}"
    echo -e "   Total Tasks: $total_tasks"
    echo -e "   Completed: $completed_tasks (${completion_rate}%)"
    echo -e "   Overdue: $overdue_tasks"
    echo -e "   Total Time: $(format_time_spent "$total_time")"
    echo
    
    # Project breakdown
    if [[ ${#project_stats[@]} -gt 0 ]]; then
        echo -e "📁 ${BASHRC_YELLOW}By Project:${BASHRC_NC}"
        for project in "${!project_stats[@]}"; do
            echo -e "   $project: ${project_stats[$project]} tasks"
        done
        echo
    fi
    
    # Priority breakdown
    if [[ ${#priority_stats[@]} -gt 0 ]]; then
        echo -e "🎯 ${BASHRC_YELLOW}By Priority:${BASHRC_NC}"
        for priority in "${!priority_stats[@]}"; do
            local priority_name=$(format_priority "$priority")
            echo -e "   $priority_name: ${priority_stats[$priority]} tasks"
        done
        echo
    fi
}

# =============================================================================
# INTELLIGENT NOTE-TAKING SYSTEM
# =============================================================================

# Advanced note management with tagging, search, and organization
note() {
    local usage="Usage: note [COMMAND] [OPTIONS] [CONTENT]
    
📝 Intelligent Note-Taking System
Commands:
    add         Create new note
    list        Show notes (default)
    show        Display specific note
    edit        Edit existing note
    delete      Delete note
    search      Search notes by content or tags
    tag         Add/remove tags from note
    export      Export notes to different formats
    import      Import notes from files
    sync        Synchronize notes (if configured)
    
Options:
    -t, --title TITLE       Note title
    -T, --tags TAGS         Comma-separated tags
    -c, --category CAT      Category/folder
    -f, --format FORMAT     Format (md, txt, org)
    -e, --editor EDITOR     Editor to use for editing
    -s, --search QUERY      Search query
    -l, --limit N           Limit number of results
    --since DATE            Notes since date
    --before DATE           Notes before date
    -v, --verbose           Verbose output
    -h, --help              Show this help
    
Examples:
    note add \"Meeting notes\" -T meeting,project -c work
    note list -T project
    note search \"important deadline\"
    note show 5
    note export --format md -c work > work_notes.md"

    local command="${1:-list}"
    [[ "$command" =~ ^(add|list|show|edit|delete|search|tag|export|import|sync)$ ]] && shift || command="list"
    
    case "$command" in
        add)        note_add "$@" ;;
        list)       note_list "$@" ;;
        show)       note_show "$@" ;;
        edit)       note_edit "$@" ;;
        delete)     note_delete "$@" ;;
        search)     note_search "$@" ;;
        tag)        note_tag "$@" ;;
        export)     note_export "$@" ;;
        import)     note_import "$@" ;;
        sync)       note_sync "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Add new note
note_add() {
    local title=""
    local content=""
    local tags=""
    local category=""
    local format="md"
    local editor="${EDITOR:-nano}"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--title)         title="$2"; shift 2 ;;
            -T|--tags)          tags="$2"; shift 2 ;;
            -c|--category)      category="$2"; shift 2 ;;
            -f|--format)        format="$2"; shift 2 ;;
            -e|--editor)        editor="$2"; shift 2 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  content="$*"; break ;;
        esac
    done
    
    local productivity_dir="$HOME/.bash_productivity"
    local notes_dir="$productivity_dir/notes"
    local notes_index="$notes_dir/index.csv"
    
    mkdir -p "$notes_dir"
    
    # Initialize notes index if it doesn't exist
    if [[ ! -f "$notes_index" ]]; then
        echo "id,created,modified,title,category,tags,format,filename" > "$notes_index"
    fi
    
    # Generate note ID and filename
    local note_id=$(get_next_note_id "$notes_index")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local filename="note_${note_id}_${timestamp}.${format}"
    local filepath="$notes_dir/$filename"
    
    # Get title if not provided
    if [[ -z "$title" ]]; then
        read -p "📝 Note title: " -r title
        [[ -z "$title" ]] && title="Note $note_id"
    fi
    
    # Create note file
    {
        case "$format" in
            md)
                echo "# $title"
                echo
                echo "Created: $(date)"
                [[ -n "$tags" ]] && echo "Tags: $tags"
                [[ -n "$category" ]] && echo "Category: $category"
                echo
                ;;
            org)
                echo "#+TITLE: $title"
                echo "#+DATE: $(date)"
                [[ -n "$tags" ]] && echo "#+TAGS: $tags"
                echo
                ;;
        esac
        
        [[ -n "$content" ]] && echo "$content"
        
    } > "$filepath"
    
    # Open in editor if no content provided
    if [[ -z "$content" ]]; then
        "$editor" "$filepath"
    fi
    
    # Add to index
    local created=$(date -Iseconds)
    echo "$note_id,$created,$created,\"$title\",\"$category\",\"$tags\",$format,$filename" >> "$notes_index"
    
    echo -e "📝 Note created: #$note_id - $title"
    [[ -n "$category" ]] && echo -e "📁 Category: $category"
    [[ -n "$tags" ]] && echo -e "🏷️ Tags: $tags"
    echo -e "💾 File: $filepath"
}

# List notes with filtering
note_list() {
    local category_filter=""
    local tag_filter=""
    local format_filter=""
    local since_date=""
    local before_date=""
    local limit=""
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--category)      category_filter="$2"; shift 2 ;;
            -T|--tags)          tag_filter="$2"; shift 2 ;;
            -f|--format)        format_filter="$2"; shift 2 ;;
            --since)            since_date="$2"; shift 2 ;;
            --before)           before_date="$2"; shift 2 ;;
            -l|--limit)         limit="$2"; shift 2 ;;
            -v|--verbose)       verbose=true; shift ;;
            *)                  shift ;;
        esac
    done
    
    local productivity_dir="$HOME/.bash_productivity"
    local notes_dir="$productivity_dir/notes"
    local notes_index="$notes_dir/index.csv"
    
    if [[ ! -f "$notes_index" ]]; then
        echo "📭 No notes found. Create one with: note add \"Your note\""
        return 0
    fi
    
    echo -e "📚 Notes List"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    local matching_notes=()
    local count=0
    
    while IFS=',' read -r id created modified title category tags format filename; do
        [[ "$id" == "id" ]] && continue
        
        # Apply filters
        [[ -n "$category_filter" && "$category" != *"$category_filter"* ]] && continue
        [[ -n "$tag_filter" && "$tags" != *"$tag_filter"* ]] && continue
        [[ -n "$format_filter" && "$format" != "$format_filter" ]] && continue
        
        # Date filters
        if [[ -n "$since_date" ]]; then
            local note_date=$(echo "$created" | cut -d'T' -f1)
            [[ "$note_date" < "$since_date" ]] && continue
        fi
        
        if [[ -n "$before_date" ]]; then
            local note_date=$(echo "$created" | cut -d'T' -f1)
            [[ "$note_date" > "$before_date" ]] && continue
        fi
        
        matching_notes+=("$id,$created,$modified,$title,$category,$tags,$format,$filename")
        ((count++))
        
        [[ -n "$limit" && $count -ge $limit ]] && break
        
    done < "$notes_index"
    
    # Display notes
    if [[ ${#matching_notes[@]} -eq 0 ]]; then
        echo "📭 No matching notes found"
        return 0
    fi
    
    for note in "${matching_notes[@]}"; do
        IFS=',' read -r id created modified title category tags format filename <<< "$note"
        
        local created_date=$(echo "$created" | cut -d'T' -f1)
        local title_clean=$(echo "$title" | tr -d '"')
        local category_clean=$(echo "$category" | tr -d '"')
        local tags_clean=$(echo "$tags" | tr -d '"')
        
        echo -e "📄 #$id - $title_clean"
        echo -e "   📅 Created: $created_date"
        [[ -n "$category_clean" ]] && echo -e "   📁 Category: $category_clean"
        [[ -n "$tags_clean" ]] && echo -e "   🏷️ Tags: $tags_clean"
        
        if [[ "$verbose" == "true" ]]; then
            local filepath="$notes_dir/$filename"
            if [[ -f "$filepath" ]]; then
                local preview=$(head -10 "$filepath" | tail -5 | sed 's/^/     /')
                echo -e "   📝 Preview:"
                echo "$preview"
            fi
        fi
        
        echo
    done
    
    echo -e "📊 Total: ${#matching_notes[@]} notes"
}

# Show specific note
note_show() {
    local note_id="$1"
    [[ -z "$note_id" ]] && { echo "Note ID required"; return 1; }
    
    local productivity_dir="$HOME/.bash_productivity"
    local notes_dir="$productivity_dir/notes"
    local notes_index="$notes_dir/index.csv"
    
    local note_found=false
    local filename=""
    
    while IFS=',' read -r id created modified title category tags format file; do
        if [[ "$id" == "$note_id" ]]; then
            note_found=true
            filename="$file"
            local title_clean=$(echo "$title" | tr -d '"')
            local category_clean=$(echo "$category" | tr -d '"')
            local tags_clean=$(echo "$tags" | tr -d '"')
            
            echo -e "📄 Note #$id: $title_clean"
            echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}"
            echo -e "📅 Created: $(echo "$created" | cut -d'T' -f1)"
            echo -e "✏️ Modified: $(echo "$modified" | cut -d'T' -f1)"
            [[ -n "$category_clean" ]] && echo -e "📁 Category: $category_clean"
            [[ -n "$tags_clean" ]] && echo -e "🏷️ Tags: $tags_clean"
            echo -e "📝 Format: $format"
            echo
            break
        fi
    done < "$notes_index"
    
    if [[ "$note_found" == "false" ]]; then
        echo "❌ Note #$note_id not found"
        return 1
    fi
    
    local filepath="$notes_dir/$filename"
    if [[ -f "$filepath" ]]; then
        cat "$filepath"
    else
        echo "❌ Note file not found: $filepath"
        return 1
    fi
}

# Search notes
note_search() {
    local query=""
    local category_filter=""
    local tag_filter=""
    local limit=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s|--search)        query="$2"; shift 2 ;;
            -c|--category)      category_filter="$2"; shift 2 ;;
            -T|--tags)          tag_filter="$2"; shift 2 ;;
            -l|--limit)         limit="$2"; shift 2 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  query="$*"; break ;;
        esac
    done
    
    [[ -z "$query" ]] && { echo "Search query required"; return 1; }
    
    local productivity_dir="$HOME/.bash_productivity"
    local notes_dir="$productivity_dir/notes"
    local notes_index="$notes_dir/index.csv"
    
    if [[ ! -f "$notes_index" ]]; then
        echo "📭 No notes found"
        return 0
    fi
    
    echo -e "🔍 Search Results for: \"$query\""
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    local results=()
    local count=0
    
    while IFS=',' read -r id created modified title category tags format filename; do
        [[ "$id" == "id" ]] && continue
        
        # Apply filters
        [[ -n "$category_filter" && "$category" != *"$category_filter"* ]] && continue
        [[ -n "$tag_filter" && "$tags" != *"$tag_filter"* ]] && continue
        
        local filepath="$notes_dir/$filename"
        local matches=""
        
        # Search in title
        if [[ "$title" == *"$query"* ]]; then
            matches="title"
        fi
        
        # Search in content
        if [[ -f "$filepath" ]] && grep -q -i "$query" "$filepath"; then
            matches="${matches:+$matches,}content"
        fi
        
        # Search in tags
        if [[ "$tags" == *"$query"* ]]; then
            matches="${matches:+$matches,}tags"
        fi
        
        if [[ -n "$matches" ]]; then
            results+=("$id,$title,$matches,$filepath")
            ((count++))
            [[ -n "$limit" && $count -ge $limit ]] && break
        fi
        
    done < "$notes_index"
    
    if [[ ${#results[@]} -eq 0 ]]; then
        echo "📭 No matches found"
        return 0
    fi
    
    for result in "${results[@]}"; do
        IFS=',' read -r id title matches filepath <<< "$result"
        
        local title_clean=$(echo "$title" | tr -d '"')
        echo -e "📄 #$id - $title_clean"
        echo -e "   🎯 Matched in: $matches"
        
        # Show context from content
        if [[ "$matches" == *"content"* && -f "$filepath" ]]; then
            local context=$(grep -i -n -C2 "$query" "$filepath" | head -5)
            if [[ -n "$context" ]]; then
                echo -e "   📝 Context:"
                echo "$context" | sed 's/^/     /'
            fi
        fi
        
        echo
    done
    
    echo -e "📊 Found ${#results[@]} matching notes"
}

# Utility functions for notes
get_next_note_id() {
    local index_file="$1"
    if [[ ! -f "$index_file" ]]; then
        echo "1"
        return
    fi
    
    local max_id=$(tail -n +2 "$index_file" | cut -d',' -f1 | sort -n | tail -1)
    echo $((max_id + 1))
}

# =============================================================================
# TIME TRACKING AND PRODUCTIVITY ANALYTICS
# =============================================================================

# Advanced time tracking with project and activity categorization
timetrack() {
    local usage="Usage: timetrack [COMMAND] [OPTIONS]
    
⏱️ Advanced Time Tracking System
Commands:
    start       Start time tracking
    stop        Stop current tracking
    status      Show current tracking status
    log         Manual time entry
    report      Generate time reports
    projects    Manage projects
    categories  Manage categories
    export      Export time data
    
Options:
    -p, --project NAME      Project name
    -c, --category CAT      Activity category
    -d, --description DESC  Activity description
    -t, --time DURATION     Time duration (for manual entry)
    -f, --from TIME         Start time (HH:MM or YYYY-MM-DD HH:MM)
    -T, --to TIME          End time (HH:MM or YYYY-MM-DD HH:MM)
    --date DATE            Date for manual entry (YYYY-MM-DD)
    --billable             Mark as billable time
    --rate AMOUNT          Hourly rate for billing
    -r, --range PERIOD     Report period (today, week, month, year)
    --format FORMAT        Output format (table, csv, json)
    -v, --verbose          Verbose output
    -h, --help             Show this help
    
Examples:
    timetrack start -p \"WebApp\" -c development -d \"Bug fixes\"
    timetrack stop
    timetrack log -p \"WebApp\" -t 2h30m -d \"Code review\"
    timetrack report --range week -p \"WebApp\"
    timetrack projects add \"WebApp\" --rate 75"

    local command="${1:-status}"
    [[ "$command" =~ ^(start|stop|status|log|report|projects|categories|export)$ ]] && shift || command="status"
    
    case "$command" in
        start)      timetrack_start "$@" ;;
        stop)       timetrack_stop "$@" ;;
        status)     timetrack_status "$@" ;;
        log)        timetrack_log "$@" ;;
        report)     timetrack_report "$@" ;;
        projects)   timetrack_projects "$@" ;;
        categories) timetrack_categories "$@" ;;
        export)     timetrack_export "$@" ;;
        -h|--help)  echo "$usage"; return 0 ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Start time tracking
timetrack_start() {
    local project=""
    local category=""
    local description=""
    local billable=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--project)       project="$2"; shift 2 ;;
            -c|--category)      category="$2"; shift 2 ;;
            -d|--description)   description="$2"; shift 2 ;;
            --billable)         billable=true; shift ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  description="$*"; break ;;
        esac
    done
    
    local productivity_dir="$HOME/.bash_productivity"
    local timetrack_dir="$productivity_dir/timetracking"
    local active_file="$timetrack_dir/active.txt"
    
    mkdir -p "$timetrack_dir"
    
    # Check if already tracking
    if [[ -f "$active_file" ]]; then
        echo "⏱️ Already tracking time. Stop current session first:"
        timetrack_status
        return 1
    fi
    
    # Prompt for missing information
    [[ -z "$project" ]] && { read -p "📁 Project name: " -r project; }
    [[ -z "$category" ]] && { read -p "🏷️ Category: " -r category; }
    [[ -z "$description" ]] && { read -p "📝 Description: " -r description; }
    
    # Create active tracking record
    local start_time=$(date +%s)
    local start_timestamp=$(date -Iseconds)
    
    cat > "$active_file" << EOF
start_time=$start_time
start_timestamp=$start_timestamp
project=$project
category=$category
description=$description
billable=$billable
EOF
    
    echo -e "⏱️ Started time tracking"
    echo -e "📁 Project: $project"
    echo -e "🏷️ Category: $category"
    echo -e "📝 Description: $description"
    echo -e "💰 Billable: $([ "$billable" == "true" ] && echo "Yes" || echo "No")"
    echo -e "🕐 Started at: $(date)"
}

# Stop time tracking
timetrack_stop() {
    local productivity_dir="$HOME/.bash_productivity"
    local timetrack_dir="$productivity_dir/timetracking"
    local active_file="$timetrack_dir/active.txt"
    local log_file="$timetrack_dir/time_log.csv"
    
    if [[ ! -f "$active_file" ]]; then
        echo "⏱️ No active time tracking session"
        return 0
    fi
    
    # Read active session
    source "$active_file"
    
    local end_time=$(date +%s)
    local end_timestamp=$(date -Iseconds)
    local duration=$((end_time - start_time))
    
    # Initialize log file if needed
    if [[ ! -f "$log_file" ]]; then
        echo "date,start_time,end_time,duration,project,category,description,billable" > "$log_file"
    fi
    
    # Log the session
    echo "$(date +%Y-%m-%d),$start_timestamp,$end_timestamp,$duration,\"$project\",\"$category\",\"$description\",$billable" >> "$log_file"
    
    # Remove active file
    rm -f "$active_file"
    
    local hours=$((duration / 3600))
    local minutes=$(((duration % 3600) / 60))
    
    echo -e "⏹️ Stopped time tracking"
    echo -e "📁 Project: $project"
    echo -e "🏷️ Category: $category"
    echo -e "📝 Description: $description"
    echo -e "⏱️ Duration: ${hours}h ${minutes}m"
    echo -e "🕐 Session: $(date -d "@$start_time" +"%H:%M") - $(date -d "@$end_time" +"%H:%M")"
}

# Show current tracking status
timetrack_status() {
    local productivity_dir="$HOME/.bash_productivity"
    local timetrack_dir="$productivity_dir/timetracking"
    local active_file="$timetrack_dir/active.txt"
    
    if [[ ! -f "$active_file" ]]; then
        echo -e "⏱️ No active time tracking session"
        echo -e "💡 Start tracking with: timetrack start"
        return 0
    fi
    
    source "$active_file"
    
    local current_time=$(date +%s)
    local elapsed=$((current_time - start_time))
    local hours=$((elapsed / 3600))
    local minutes=$(((elapsed % 3600) / 60))
    
    echo -e "⏱️ ${BASHRC_GREEN}Currently Tracking${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..30})${BASHRC_NC}"
    echo -e "📁 Project: $project"
    echo -e "🏷️ Category: $category"
    echo -e "📝 Description: $description"
    echo -e "💰 Billable: $([ "$billable" == "true" ] && echo "Yes" || echo "No")"
    echo -e "🕐 Started: $(date -d "$start_timestamp" +"%H:%M")"
    echo -e "⏱️ Elapsed: ${hours}h ${minutes}m"
}

# Generate time tracking reports
timetrack_report() {
    local range="week"
    local project_filter=""
    local category_filter=""
    local format="table"
    local show_billable=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -r|--range)         range="$2"; shift 2 ;;
            -p|--project)       project_filter="$2"; shift 2 ;;
            -c|--category)      category_filter="$2"; shift 2 ;;
            --format)           format="$2"; shift 2 ;;
            --billable)         show_billable=true; shift ;;
            *)                  shift ;;
        esac
    done
    
    local productivity_dir="$HOME/.bash_productivity"
    local timetrack_dir="$productivity_dir/timetracking"
    local log_file="$timetrack_dir/time_log.csv"
    
    if [[ ! -f "$log_file" ]]; then
        echo "📭 No time tracking data found"
        return 0
    fi
    
    echo -e "📊 Time Tracking Report - $(echo ${range^})"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    # Calculate date range
    local start_date end_date
    case "$range" in
        today)
            start_date=$(date +%Y-%m-%d)
            end_date=$(date +%Y-%m-%d)
            ;;
        week)
            start_date=$(date -d "monday" +%Y-%m-%d)
            end_date=$(date -d "sunday" +%Y-%m-%d)
            ;;
        month)
            start_date=$(date +%Y-%m-01)
            end_date=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%Y-%m-%d)
            ;;
    esac
    
    # Process time entries
    local total_duration=0
    local billable_duration=0
    declare -A project_time
    declare -A category_time
    
    while IFS=',' read -r date start_time end_time duration project category description billable; do
        [[ "$date" == "date" ]] && continue
        
        # Filter by date range
        [[ "$date" < "$start_date" || "$date" > "$end_date" ]] && continue
        
        # Apply filters
        [[ -n "$project_filter" && "$project" != *"$project_filter"* ]] && continue
        [[ -n "$category_filter" && "$category" != *"$category_filter"* ]] && continue
        
        total_duration=$((total_duration + duration))
        [[ "$billable" == "true" ]] && billable_duration=$((billable_duration + duration))
        
        # Project totals
        local proj_name=$(echo "$project" | tr -d '"')
        project_time["$proj_name"]=$((${project_time["$proj_name"]:-0} + duration))
        
        # Category totals
        local cat_name=$(echo "$category" | tr -d '"')
        category_time["$cat_name"]=$((${category_time["$cat_name"]:-0} + duration))
        
    done < "$log_file"
    
    # Display summary
    echo -e "⏱️ ${BASHRC_YELLOW}Summary:${BASHRC_NC}"
    echo -e "   Total Time: $(format_duration $total_duration)"
    echo -e "   Billable Time: $(format_duration $billable_duration)"
    local billable_percent=0
    [[ $total_duration -gt 0 ]] && billable_percent=$(echo "scale=1; $billable_duration * 100 / $total_duration" | bc -l)
    echo -e "   Billable %: ${billable_percent}%"
    echo
    
    # Project breakdown
    if [[ ${#project_time[@]} -gt 0 ]]; then
        echo -e "📁 ${BASHRC_YELLOW}By Project:${BASHRC_NC}"
        for project in "${!project_time[@]}"; do
            local duration=${project_time["$project"]}
            echo -e "   $project: $(format_duration $duration)"
        done
        echo
    fi
    
    # Category breakdown
    if [[ ${#category_time[@]} -gt 0 ]]; then
        echo -e "🏷️ ${BASHRC_YELLOW}By Category:${BASHRC_NC}"
        for category in "${!category_time[@]}"; do
            local duration=${category_time["$category"]}
            echo -e "   $category: $(format_duration $duration)"
        done
        echo
    fi
}

format_duration() {
    local seconds="$1"
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    
    if [[ $hours -gt 0 ]]; then
        echo "${hours}h ${minutes}m"
    else
        echo "${minutes}m"
    fi
}

# =============================================================================
# MODULE INITIALIZATION AND ALIASES
# =============================================================================

# Initialize productivity system
initialize_productivity_system() {
    local productivity_dir="$HOME/.bash_productivity"
    mkdir -p "$productivity_dir"/{tasks,notes,timetracking,reports,analytics}
    
    # Create productivity log
    local init_log="$productivity_dir/initialization.log"
    echo "$(date -Iseconds) - Productivity system initialized" > "$init_log"
    
    echo -e "📊 Productivity system initialized"
}

# Create convenient aliases
alias t='task'
alias n='note'
alias tt='timetrack'

# Quick task aliases
alias ta='task add'
alias tl='task list'
alias td='task done'
alias ts='task start'

# Quick note aliases
alias na='note add'
alias nl='note list'
alias ns='note search'

# Quick time tracking aliases
alias tts='timetrack start'
alias ttp='timetrack stop'
alias ttr='timetrack report'

# Export functions
export -f task task_add task_list task_complete task_start task_stop task_priority task_report
export -f get_next_task_id normalize_priority format_priority parse_date display_tasks_table format_time_spent
export -f update_task_time log_task_action generate_task_statistics
export -f note note_add note_list note_show note_search get_next_note_id
export -f timetrack timetrack_start timetrack_stop timetrack_status timetrack_log timetrack_report format_duration

# Initialize the system
initialize_productivity_system

echo -e "${BASHRC_GREEN}✅ Productivity Tools Module Loaded${BASHRC_NC}"
echo -e "${BASHRC_PURPLE}📊 Productivity Tools v$PRODUCTIVITY_MODULE_VERSION Ready!${BASHRC_NC}"
echo -e "${BASHRC_CYAN}💡 Try: 'task add \"My task\" -p high', 'note add \"Meeting notes\"', 'timetrack start -p project'${BASHRC_NC}"
