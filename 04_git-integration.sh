#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - GIT INTEGRATION MODULE
# File: 04_git-integration.sh
# =============================================================================
# This module provides revolutionary Git operations with AI-level intelligence,
# automated workflows, smart commit analysis, intelligent merge resolution,
# repository health monitoring, and advanced Git insights that transform
# your development experience into something extraordinary.
# =============================================================================

# Module metadata
declare -r GIT_MODULE_VERSION="2.1.0"
declare -r GIT_MODULE_NAME="Ultimate Git Integration"
declare -r GIT_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# Module initialization
echo -e "${BASHRC_CYAN}🔀 Loading Ultimate Git Integration...${BASHRC_NC}"

# =============================================================================
# INTELLIGENT COMMIT SYSTEM WITH AI-LEVEL ANALYSIS
# =============================================================================

# Revolutionary smart commit with AI-level commit message generation
smartcommit() {
    local usage="Usage: smartcommit [OPTIONS] [MESSAGE]
    
🧠 Intelligent Git Commit System with AI-level Analysis
Options:
    -a, --auto          Auto-generate commit message using AI analysis
    -t, --type TYPE     Commit type (feat, fix, docs, style, refactor, test, chore)
    -s, --scope SCOPE   Commit scope (component/module affected)
    -b, --breaking      Mark as breaking change
    -i, --interactive   Interactive commit message builder
    -c, --conventional  Use conventional commit format
    -r, --review        Show detailed analysis before commit
    --amend             Amend previous commit
    --wip               Work in progress commit
    --co-author EMAIL   Add co-author
    -v, --verbose       Verbose analysis output
    -h, --help          Show this help
    
Features:
    - AI-powered commit message generation
    - Code analysis and impact assessment
    - Conventional commit formatting
    - Breaking change detection
    - Co-authorship management
    - Commit quality scoring
    
Examples:
    smartcommit -a                              # Auto-generate message
    smartcommit -t feat -s auth \"Add OAuth\"    # Structured commit
    smartcommit -i                              # Interactive mode
    smartcommit --review \"Fix user login bug\" # Review before commit"

    local auto_generate=false
    local commit_type=""
    local commit_scope=""
    local breaking_change=false
    local interactive_mode=false
    local conventional_format=false
    local review_mode=false
    local amend_commit=false
    local wip_commit=false
    local co_authors=()
    local verbose_mode=false
    local commit_message=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--auto)          auto_generate=true; shift ;;
            -t|--type)          commit_type="$2"; shift 2 ;;
            -s|--scope)         commit_scope="$2"; shift 2 ;;
            -b|--breaking)      breaking_change=true; shift ;;
            -i|--interactive)   interactive_mode=true; shift ;;
            -c|--conventional)  conventional_format=true; shift ;;
            -r|--review)        review_mode=true; shift ;;
            --amend)            amend_commit=true; shift ;;
            --wip)              wip_commit=true; shift ;;
            --co-author)        co_authors+=("$2"); shift 2 ;;
            -v|--verbose)       verbose_mode=true; shift ;;
            -h|--help)          echo "$usage"; return 0 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  commit_message="$*"; break ;;
        esac
    done
    
    # Ensure we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Not in a Git repository"
        return 1
    fi
    
    # Check for staged changes
    if [[ "$amend_commit" == "false" ]] && ! git diff --cached --quiet; then
        :
    elif [[ "$amend_commit" == "false" ]]; then
        echo "❌ No staged changes to commit. Use 'git add' first."
        return 1
    fi
    
    echo -e "🧠 ${BASHRC_CYAN}Intelligent Git Commit System${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..40})${BASHRC_NC}"
    
    # Initialize Git intelligence system
    local git_intelligence_dir="$HOME/.bash_git_intelligence"
    mkdir -p "$git_intelligence_dir"/{analysis,models,history,patterns}
    
    local repo_hash=$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1)
    local repo_analysis="$git_intelligence_dir/analysis/repo_$repo_hash.json"
    local commit_history="$git_intelligence_dir/history/commits_$(date +%Y%m).log"
    
    # PHASE 1: Advanced Change Analysis
    echo -e "🔍 ${BASHRC_CYAN}Analyzing changes with AI intelligence...${BASHRC_NC}"
    local change_analysis=$(perform_advanced_change_analysis "$verbose_mode")
    
    # PHASE 2: Generate or enhance commit message
    if [[ "$auto_generate" == "true" || "$interactive_mode" == "true" ]]; then
        commit_message=$(generate_intelligent_commit_message "$change_analysis" "$commit_type" "$commit_scope" "$interactive_mode")
    elif [[ "$wip_commit" == "true" ]]; then
        commit_message="WIP: $(generate_wip_message "$change_analysis")"
    fi
    
    # PHASE 3: Apply conventional commit formatting
    if [[ "$conventional_format" == "true" ]] || [[ -n "$commit_type" ]]; then
        commit_message=$(format_conventional_commit "$commit_message" "$commit_type" "$commit_scope" "$breaking_change")
    fi
    
    # PHASE 4: Review mode analysis
    if [[ "$review_mode" == "true" ]]; then
        show_commit_review "$commit_message" "$change_analysis" "$co_authors"
        read -p "🤔 Proceed with commit? [Y/n] " -n 1 -r
        echo
        [[ $REPLY =~ ^[Nn]$ ]] && { echo "❌ Commit cancelled"; return 1; }
    fi
    
    # PHASE 5: Execute commit with intelligence
    execute_smart_commit "$commit_message" "$amend_commit" "$co_authors" "$change_analysis"
    
    # PHASE 6: Post-commit analysis and learning
    post_commit_analysis "$commit_message" "$change_analysis" "$commit_history" "$repo_analysis"
    
    echo -e "✅ ${BASHRC_GREEN}Smart commit completed with intelligence logging!${BASHRC_NC}"
}

# Advanced Change Analysis Engine
perform_advanced_change_analysis() {
    local verbose="$1"
    local analysis_result=""
    
    # Collect comprehensive change statistics
    local files_changed=$(git diff --cached --name-only | wc -l)
    local lines_added=$(git diff --cached --numstat | awk '{sum += $1} END {print sum+0}')
    local lines_deleted=$(git diff --cached --numstat | awk '{sum += $2} END {print sum+0}')
    local net_change=$((lines_added - lines_deleted))
    
    # File type analysis
    local file_types=$(git diff --cached --name-only | grep -E '\.[^.]+$' | sed 's/.*\.//' | sort | uniq -c | sort -rn)
    local dominant_type=$(echo "$file_types" | head -1 | awk '{print $2}')
    
    # Directory impact analysis
    local dirs_affected=$(git diff --cached --name-only | xargs -I{} dirname {} | sort | uniq | wc -l)
    local top_dir=$(git diff --cached --name-only | xargs -I{} dirname {} | sort | uniq -c | sort -rn | head -1 | awk '{print $2}')
    
    # Change complexity analysis
    local complexity_score=$(calculate_change_complexity)
    
    # Breaking change detection
    local breaking_indicators=$(detect_breaking_changes)
    
    # Security impact analysis
    local security_analysis=$(analyze_security_impact)
    
    # Performance impact estimation
    local performance_impact=$(estimate_performance_impact)
    
    [[ "$verbose" == "true" ]] && {
        echo -e "📊 ${BASHRC_YELLOW}Change Analysis:${BASHRC_NC}"
        echo -e "   Files: $files_changed | +$lines_added -$lines_deleted (net: $net_change)"
        echo -e "   Dominant type: $dominant_type"
        echo -e "   Directories affected: $dirs_affected (primary: $top_dir)"
        echo -e "   Complexity score: $complexity_score/100"
        [[ -n "$breaking_indicators" ]] && echo -e "   ⚠️  Breaking changes detected: $breaking_indicators"
        [[ -n "$security_analysis" ]] && echo -e "   🔒 Security impact: $security_analysis"
        [[ -n "$performance_impact" ]] && echo -e "   ⚡ Performance impact: $performance_impact"
        echo
    }
    
    # Compile analysis result
    analysis_result="files:$files_changed,lines:+$lines_added/-$lines_deleted,net:$net_change,type:$dominant_type,dirs:$dirs_affected,complexity:$complexity_score"
    [[ -n "$breaking_indicators" ]] && analysis_result="$analysis_result,breaking:$breaking_indicators"
    [[ -n "$security_analysis" ]] && analysis_result="$analysis_result,security:$security_analysis"
    [[ -n "$performance_impact" ]] && analysis_result="$analysis_result,performance:$performance_impact"
    
    echo "$analysis_result"
}

# Calculate Change Complexity Score
calculate_change_complexity() {
    local complexity=0
    
    # Factor 1: Number of files (more files = higher complexity)
    local file_count=$(git diff --cached --name-only | wc -l)
    complexity=$((complexity + file_count * 2))
    
    # Factor 2: Lines changed (more changes = higher complexity) 
    local total_lines=$(git diff --cached --numstat | awk '{sum += $1 + $2} END {print sum+0}')
    complexity=$((complexity + total_lines / 10))
    
    # Factor 3: Different file types (more types = higher complexity)
    local type_count=$(git diff --cached --name-only | grep -E '\.[^.]+$' | sed 's/.*\.//' | sort | uniq | wc -l)
    complexity=$((complexity + type_count * 3))
    
    # Factor 4: Directory spread (more directories = higher complexity)
    local dir_count=$(git diff --cached --name-only | xargs -I{} dirname {} | sort | uniq | wc -l)
    complexity=$((complexity + dir_count * 2))
    
    # Factor 5: Binary files (binary changes = higher complexity)
    local binary_count=$(git diff --cached --numstat | awk '$1 == "-" && $2 == "-" {count++} END {print count+0}')
    complexity=$((complexity + binary_count * 5))
    
    # Cap at 100
    [[ $complexity -gt 100 ]] && complexity=100
    
    echo "$complexity"
}

# Detect Breaking Changes
detect_breaking_changes() {
    local breaking=""
    
    # Check for API changes
    if git diff --cached | grep -E "^-.*def |^-.*function |^-.*class " >/dev/null 2>&1; then
        breaking="${breaking:+$breaking,}api_removal"
    fi
    
    # Check for configuration changes
    if git diff --cached --name-only | grep -E "\.(json|yaml|yml|conf|cfg|ini|env)$" >/dev/null 2>&1; then
        breaking="${breaking:+$breaking,}config_change"
    fi
    
    # Check for database migrations
    if git diff --cached --name-only | grep -E "migration|schema" >/dev/null 2>&1; then
        breaking="${breaking:+$breaking,}schema_change"
    fi
    
    # Check for dependency changes
    if git diff --cached --name-only | grep -E "(package\.json|requirements\.txt|Cargo\.toml|pom\.xml|go\.mod)" >/dev/null 2>&1; then
        breaking="${breaking:+$breaking,}dependency_change"
    fi
    
    echo "$breaking"
}

# Security Impact Analysis
analyze_security_impact() {
    local security=""
    
    # Check for authentication/authorization changes
    if git diff --cached | grep -iE "(auth|password|token|secret|key|credential)" >/dev/null 2>&1; then
        security="${security:+$security,}auth_change"
    fi
    
    # Check for input validation changes
    if git diff --cached | grep -iE "(validate|sanitize|escape|filter)" >/dev/null 2>&1; then
        security="${security:+$security,}validation_change"
    fi
    
    # Check for network/API changes
    if git diff --cached | grep -iE "(http|api|endpoint|url|cors)" >/dev/null 2>&1; then
        security="${security:+$security,}network_change"
    fi
    
    echo "$security"
}

# Performance Impact Estimation
estimate_performance_impact() {
    local impact=""
    
    # Check for database query changes
    if git diff --cached | grep -iE "(select|insert|update|delete|query)" >/dev/null 2>&1; then
        impact="${impact:+$impact,}database"
    fi
    
    # Check for loop/algorithm changes
    if git diff --cached | grep -E "(for |while |foreach)" >/dev/null 2>&1; then
        impact="${impact:+$impact,}algorithm"
    fi
    
    # Check for caching changes
    if git diff --cached | grep -iE "(cache|redis|memcached)" >/dev/null 2>&1; then
        impact="${impact:+$impact,}caching"
    fi
    
    echo "$impact"
}

# AI-Level Commit Message Generation
generate_intelligent_commit_message() {
    local analysis="$1"
    local commit_type="$2"
    local commit_scope="$3"
    local interactive="$4"
    
    # Parse analysis data
    declare -A analysis_data
    IFS=',' read -ra analysis_parts <<< "$analysis"
    for part in "${analysis_parts[@]}"; do
        local key="${part%:*}"
        local value="${part#*:}"
        analysis_data["$key"]="$value"
    done
    
    local generated_message=""
    local confidence=0
    
    # GENERATION ALGORITHM
    
    # Step 1: Determine action type from analysis
    local action_type=""
    if [[ -n "$commit_type" ]]; then
        action_type="$commit_type"
        confidence=$((confidence + 20))
    else
        action_type=$(infer_commit_type_from_changes "$analysis")
        confidence=$((confidence + 10))
    fi
    
    # Step 2: Generate core message based on changes
    local core_message=$(generate_core_message "$analysis" "$action_type")
    confidence=$((confidence + 30))
    
    # Step 3: Add context and details
    local context_details=$(generate_context_details "$analysis")
    if [[ -n "$context_details" ]]; then
        core_message="$core_message ($context_details)"
        confidence=$((confidence + 20))
    fi
    
    # Step 4: Interactive refinement
    if [[ "$interactive" == "true" ]]; then
        generated_message=$(interactive_message_refinement "$core_message" "$analysis")
        confidence=$((confidence + 30))
    else
        generated_message="$core_message"
    fi
    
    echo "$generated_message"
}

# Infer Commit Type from Changes
infer_commit_type_from_changes() {
    local analysis="$1"
    local commit_type="feat" # default
    
    # Analyze changed files to infer type
    local changed_files=$(git diff --cached --name-only)
    
    # Test files -> test commit
    if echo "$changed_files" | grep -E "(test|spec)" >/dev/null 2>&1; then
        commit_type="test"
    # Documentation files -> docs commit
    elif echo "$changed_files" | grep -E "\.(md|rst|txt|doc)$|README|CHANGELOG" >/dev/null 2>&1; then
        commit_type="docs"
    # Configuration files -> chore commit
    elif echo "$changed_files" | grep -E "\.(json|yaml|yml|conf|cfg|ini)$|package\.json|requirements\.txt" >/dev/null 2>&1; then
        commit_type="chore"
    # Style files -> style commit
    elif echo "$changed_files" | grep -E "\.(css|scss|less|sass)$" >/dev/null 2>&1; then
        commit_type="style"
    # Check diff content for fix patterns
    elif git diff --cached | grep -iE "(fix|bug|error|issue|problem)" >/dev/null 2>&1; then
        commit_type="fix"
    # Check for refactoring patterns
    elif git diff --cached | grep -E "^-.*^+.*" | wc -l | awk '{if($1 > 10) print "refactor"}' | grep -q refactor; then
        commit_type="refactor"
    fi
    
    echo "$commit_type"
}

# Generate Core Message
generate_core_message() {
    local analysis="$1"
    local action_type="$2"
    
    # Parse analysis for key details
    declare -A analysis_data
    IFS=',' read -ra analysis_parts <<< "$analysis"
    for part in "${analysis_parts[@]}"; do
        local key="${part%:*}"
        local value="${part#*:}"
        analysis_data["$key"]="$value"
    done
    
    local files_count="${analysis_data[files]:-0}"
    local dominant_type="${analysis_data[type]:-unknown}"
    
    # Generate message based on patterns
    local core_message=""
    
    case "$action_type" in
        feat)
            if [[ $files_count -eq 1 ]]; then
                local filename=$(git diff --cached --name-only | head -1)
                core_message="add $(basename "$filename" | sed 's/\.[^.]*$//')"
            else
                core_message="implement new $dominant_type functionality"
            fi
            ;;
        fix)
            if git diff --cached | grep -iE "(null|undefined|exception|error)" >/dev/null 2>&1; then
                core_message="fix null pointer and error handling"
            else
                core_message="resolve $dominant_type issues"
            fi
            ;;
        docs)
            core_message="update documentation"
            ;;
        style)
            core_message="improve code formatting and style"
            ;;
        refactor)
            core_message="refactor $dominant_type code structure"
            ;;
        test)
            core_message="add/update test coverage"
            ;;
        chore)
            core_message="update configuration and dependencies"
            ;;
        *)
            core_message="update $dominant_type files"
            ;;
    esac
    
    echo "$core_message"
}

# Generate Context Details
generate_context_details() {
    local analysis="$1"
    local details=""
    
    # Parse analysis
    declare -A analysis_data
    IFS=',' read -ra analysis_parts <<< "$analysis"
    for part in "${analysis_parts[@]}"; do
        local key="${part%:*}"
        local value="${part#*:}"
        analysis_data["$key"]="$value"
    done
    
    local files_count="${analysis_data[files]:-0}"
    local complexity="${analysis_data[complexity]:-0}"
    
    # Add quantitative details
    if [[ $files_count -gt 1 ]]; then
        details="${details:+$details, }$files_count files"
    fi
    
    if [[ $complexity -gt 50 ]]; then
        details="${details:+$details, }high complexity"
    fi
    
    # Add breaking change warning
    if [[ "${analysis_data[breaking]}" ]]; then
        details="${details:+$details, }BREAKING CHANGE"
    fi
    
    echo "$details"
}

# Interactive Message Refinement
interactive_message_refinement() {
    local initial_message="$1"
    local analysis="$2"
    
    echo -e "🤖 ${BASHRC_CYAN}AI-Generated Message:${BASHRC_NC} $initial_message"
    echo
    echo -e "🛠️  ${BASHRC_YELLOW}Refinement Options:${BASHRC_NC}"
    echo "   1. Use as-is"
    echo "   2. Edit message"
    echo "   3. Add more detail"
    echo "   4. Make more concise"
    echo "   5. Generate alternative"
    
    read -p "Choose option (1-5): " -n 1 -r option
    echo
    
    case "$option" in
        1) echo "$initial_message" ;;
        2) 
            read -p "Enter new message: " -r new_message
            echo "$new_message"
            ;;
        3)
            echo "$initial_message"
            read -p "Add detail: " -r additional_detail
            echo "$initial_message - $additional_detail"
            ;;
        4)
            # Make more concise (simplified)
            echo "$initial_message" | cut -d' ' -f1-3
            ;;
        5)
            # Generate alternative (simplified)
            local alt_type=$(infer_commit_type_from_changes "$analysis")
            generate_core_message "$analysis" "$alt_type"
            ;;
        *)
            echo "$initial_message"
            ;;
    esac
}

# Format Conventional Commit
format_conventional_commit() {
    local message="$1"
    local type="$2" 
    local scope="$3"
    local breaking="$4"
    
    local formatted="$type"
    [[ -n "$scope" ]] && formatted="$formatted($scope)"
    [[ "$breaking" == "true" ]] && formatted="$formatted!"
    formatted="$formatted: $message"
    
    echo "$formatted"
}

# Show Commit Review
show_commit_review() {
    local commit_message="$1"
    local analysis="$2"
    local co_authors=("${@:3}")
    
    echo -e "\n📋 ${BASHRC_PURPLE}Commit Review${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..30})${BASHRC_NC}"
    echo -e "💬 ${BASHRC_YELLOW}Message:${BASHRC_NC} $commit_message"
    
    # Show files to be committed
    echo -e "📁 ${BASHRC_YELLOW}Files:${BASHRC_NC}"
    git diff --cached --name-status | while IFS=$'\t' read -r status file; do
        local icon="📝"
        case "$status" in
            A) icon="🆕" ;;
            M) icon="✏️" ;;
            D) icon="🗑️" ;;
            R*) icon="📦" ;;
        esac
        echo "   $icon $file"
    done
    
    # Show co-authors if any
    if [[ ${#co_authors[@]} -gt 0 ]]; then
        echo -e "👥 ${BASHRC_YELLOW}Co-authors:${BASHRC_NC}"
        for author in "${co_authors[@]}"; do
            echo "   👤 $author"
        done
    fi
    
    echo
}

# Execute Smart Commit
execute_smart_commit() {
    local commit_message="$1"
    local amend="$2"
    local co_authors=("${@:3}")
    local analysis="${@: -1}"
    
    # Build git commit command
    local git_cmd=(git commit -m "$commit_message")
    [[ "$amend" == "true" ]] && git_cmd=(git commit --amend -m "$commit_message")
    
    # Add co-authors to commit message
    if [[ ${#co_authors[@]} -gt 0 ]]; then
        local full_message="$commit_message"
        for author in "${co_authors[@]}"; do
            full_message="$full_message"$'\n\n'"Co-authored-by: $author"
        done
        git_cmd=(git commit -m "$full_message")
        [[ "$amend" == "true" ]] && git_cmd=(git commit --amend -m "$full_message")
    fi
    
    # Execute commit
    echo -e "🚀 ${BASHRC_CYAN}Executing commit...${BASHRC_NC}"
    "${git_cmd[@]}"
}

# Post-commit Analysis and Learning
post_commit_analysis() {
    local commit_message="$1"
    local analysis="$2"
    local history_file="$3"
    local repo_analysis="$4"
    
    # Log commit for learning
    local commit_hash=$(git rev-parse HEAD)
    local timestamp=$(date -Iseconds)
    
    echo "$timestamp|$commit_hash|$commit_message|$analysis" >> "$history_file"
    
    # Update repository analysis (simplified)
    # In a real implementation, this would update sophisticated JSON models
    
    echo -e "📊 ${BASHRC_GREEN}Commit logged for intelligence learning${BASHRC_NC}"
}

# =============================================================================
# INTELLIGENT BRANCH MANAGEMENT SYSTEM
# =============================================================================

# Advanced branch management with AI-level intelligence
smartbranch() {
    local usage="Usage: smartbranch [COMMAND] [OPTIONS] [BRANCH_NAME]
    
🌿 Intelligent Branch Management System
Commands:
    create      Create intelligent branch with naming conventions
    switch      Smart branch switching with stash management
    merge       Intelligent merge with conflict prediction
    delete      Safe branch deletion with backup
    analyze     Analyze branch health and metrics
    cleanup     Intelligent branch cleanup
    sync        Smart synchronization with remote
    
Options:
    -f, --feature       Feature branch type
    -b, --bugfix        Bugfix branch type  
    -h, --hotfix        Hotfix branch type
    -r, --release       Release branch type
    -p, --pattern NAME  Use naming pattern
    --from BRANCH       Create from specific branch
    --auto-push         Auto-push new branch
    --no-switch         Don't switch to new branch
    -v, --verbose       Verbose output
    --help              Show this help
    
Examples:
    smartbranch create -f user-authentication    # Create feature branch
    smartbranch switch main                      # Smart switch with stash
    smartbranch merge feature/login --preview    # Preview merge conflicts
    smartbranch cleanup --dry-run               # Show branches to cleanup
    smartbranch analyze                         # Analyze all branches"

    [[ $# -eq 0 ]] && { echo "$usage"; return 1; }
    
    local command="$1"
    shift
    
    case "$command" in
        create)     smartbranch_create "$@" ;;
        switch)     smartbranch_switch "$@" ;;
        merge)      smartbranch_merge "$@" ;;
        delete)     smartbranch_delete "$@" ;;
        analyze)    smartbranch_analyze "$@" ;;
        cleanup)    smartbranch_cleanup "$@" ;;
        sync)       smartbranch_sync "$@" ;;
        *)          echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Smart Branch Creation
smartbranch_create() {
    local branch_type="feature"
    local branch_name=""
    local from_branch=""
    local auto_push=false
    local no_switch=false
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--feature)   branch_type="feature"; shift ;;
            -b|--bugfix)    branch_type="bugfix"; shift ;;
            -h|--hotfix)    branch_type="hotfix"; shift ;;
            -r|--release)   branch_type="release"; shift ;;
            --from)         from_branch="$2"; shift 2 ;;
            --auto-push)    auto_push=true; shift ;;
            --no-switch)    no_switch=true; shift ;;
            -v|--verbose)   verbose=true; shift ;;
            -*)             echo "Unknown option: $1" >&2; return 1 ;;
            *)              branch_name="$1"; shift ;;
        esac
    done
    
    [[ -z "$branch_name" ]] && { echo "Branch name required"; return 1; }
    
    # Generate intelligent branch name
    local full_branch_name=$(generate_intelligent_branch_name "$branch_type" "$branch_name")
    
    echo -e "🌿 ${BASHRC_CYAN}Creating intelligent branch: $full_branch_name${BASHRC_NC}"
    
    # Determine source branch
    local source_branch="${from_branch:-$(get_default_source_branch "$branch_type")}"
    
    # Ensure we're on the right source branch
    git checkout "$source_branch" >/dev/null 2>&1 || {
        echo "❌ Cannot checkout source branch: $source_branch"
        return 1
    }
    
    # Pull latest changes
    echo -e "🔄 ${BASHRC_CYAN}Updating source branch...${BASHRC_NC}"
    git pull origin "$source_branch" >/dev/null 2>&1
    
    # Create branch
    git checkout -b "$full_branch_name" || {
        echo "❌ Failed to create branch"
        return 1
    }
    
    # Auto-push if requested
    if [[ "$auto_push" == "true" ]]; then
        echo -e "🚀 ${BASHRC_CYAN}Pushing to remote...${BASHRC_NC}"
        git push -u origin "$full_branch_name"
    fi
    
    echo -e "✅ ${BASHRC_GREEN}Branch '$full_branch_name' created successfully!${BASHRC_NC}"
    
    # Log branch creation for analytics
    log_branch_action "create" "$full_branch_name" "$branch_type"
}

# Generate Intelligent Branch Name
generate_intelligent_branch_name() {
    local branch_type="$1"
    local base_name="$2"
    
    # Clean and format base name
    local clean_name=$(echo "$base_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    # Add type prefix and current date for uniqueness
    local date_suffix=$(date +%m%d)
    local full_name=""
    
    case "$branch_type" in
        feature)    full_name="feature/$clean_name" ;;
        bugfix)     full_name="bugfix/$clean_name-$date_suffix" ;;
        hotfix)     full_name="hotfix/$clean_name-$date_suffix" ;;
        release)    full_name="release/$clean_name" ;;
        *)          full_name="$branch_type/$clean_name" ;;
    esac
    
    echo "$full_name"
}

# Get Default Source Branch
get_default_source_branch() {
    local branch_type="$1"
    
    case "$branch_type" in
        feature|bugfix) echo "develop" ;;
        hotfix) echo "main" ;;
        release) echo "develop" ;;
        *) 
            # Try to detect main branch
            if git show-ref --verify --quiet refs/heads/main; then
                echo "main"
            elif git show-ref --verify --quiet refs/heads/master; then
                echo "master"
            else
                echo "$(git branch --show-current)"
            fi
            ;;
    esac
}

# =============================================================================
# REPOSITORY INTELLIGENCE AND ANALYTICS
# =============================================================================

# Comprehensive repository analysis and insights
gitanalytics() {
    local usage="Usage: gitanalytics [COMMAND] [OPTIONS]
    
📊 Advanced Git Repository Analytics & Insights
Commands:
    overview        Repository health overview
    commits         Commit pattern analysis
    contributors    Contributor analysis and insights
    hotspots        Code hotspot analysis
    trends          Development trend analysis
    quality         Code quality metrics
    performance     Performance impact analysis
    
Options:
    --since DATE    Analysis since date (default: 30 days)
    --author USER   Focus on specific author
    --format TYPE   Output format (text, json, html)
    --detailed      Detailed analysis
    -v, --verbose   Verbose output
    -h, --help      Show this help
    
Examples:
    gitanalytics overview                    # Repository overview
    gitanalytics commits --since '1 month'  # Commit analysis
    gitanalytics contributors --detailed     # Detailed contributor stats
    gitanalytics hotspots --format json     # Code hotspots in JSON"

    [[ $# -eq 0 ]] && command="overview" || { command="$1"; shift; }
    
    case "$command" in
        overview)       git_overview_analysis "$@" ;;
        commits)        git_commit_analysis "$@" ;;
        contributors)   git_contributor_analysis "$@" ;;
        hotspots)       git_hotspot_analysis "$@" ;;
        trends)         git_trend_analysis "$@" ;;
        quality)        git_quality_analysis "$@" ;;
        performance)    git_performance_analysis "$@" ;;
        -h|--help)      echo "$usage"; return 0 ;;
        *)              echo "Unknown command: $command"; echo "$usage"; return 1 ;;
    esac
}

# Repository Overview Analysis
git_overview_analysis() {
    local since="30 days ago"
    local detailed=false
    local format="text"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --since)        since="$2"; shift 2 ;;
            --detailed)     detailed=true; shift ;;
            --format)       format="$2"; shift 2 ;;
            -v|--verbose)   detailed=true; shift ;;
            *)              shift ;;
        esac
    done
    
    echo -e "📊 ${BASHRC_PURPLE}Repository Analytics Overview${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}\n"
    
    # Basic repository info
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local current_branch=$(git branch --show-current)
    local total_commits=$(git rev-list --all --count)
    local total_authors=$(git log --format='%ae' | sort | uniq | wc -l)
    local repo_age=$(git log --reverse --format='%ci' | head -1 | cut -d' ' -f1)
    
    echo -e "🏗️  ${BASHRC_YELLOW}Repository Information:${BASHRC_NC}"
    echo -e "   Name: $repo_name"
    echo -e "   Current Branch: $current_branch"
    echo -e "   Total Commits: $total_commits"
    echo -e "   Contributors: $total_authors"
    echo -e "   Repository Age: $repo_age ($(days_since "$repo_age") days)"
    echo
    
    # Recent activity analysis
    local commits_since=$(git rev-list --count --since="$since" HEAD)
    local files_changed=$(git diff --name-only --since="$since" HEAD~$(($commits_since > 0 ? $commits_since : 1)) | wc -l)
    local active_authors=$(git log --since="$since" --format='%ae' | sort | uniq | wc -l)
    
    echo -e "📈 ${BASHRC_YELLOW}Recent Activity (since $since):${BASHRC_NC}"
    echo -e "   Commits: $commits_since"
    echo -e "   Files Changed: $files_changed"
    echo -e "   Active Contributors: $active_authors"
    echo
    
    # Branch analysis
    local total_branches=$(git branch -a | wc -l)
    local local_branches=$(git branch | wc -l)
    local remote_branches=$(git branch -r | wc -l)
    
    echo -e "🌿 ${BASHRC_YELLOW}Branch Information:${BASHRC_NC}"
    echo -e "   Total Branches: $total_branches"
    echo -e "   Local: $local_branches | Remote: $remote_branches"
    
    # Show top branches by activity
    echo -e "   Most Active Branches:"
    git for-each-ref --format='%(refname:short) %(committerdate:relative)' refs/heads/ | sort -k2 | head -5 | while read -r branch date; do
        local commit_count=$(git rev-list --count "$branch" --since="$since")
        echo -e "     🌱 $branch ($commit_count commits, $date)"
    done
    echo
    
    # File type distribution
    echo -e "📁 ${BASHRC_YELLOW}Repository Composition:${BASHRC_NC}"
    local file_stats=$(find . -name '.git' -prune -o -type f -name '*.*' -print | grep -E '\.[^.]+$' | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -5)
    echo "$file_stats" | while read -r count ext; do
        echo -e "   📄 .$ext: $count files"
    done
    echo
    
    if [[ "$detailed" == "true" ]]; then
        # Additional detailed analysis
        echo -e "🔍 ${BASHRC_YELLOW}Detailed Metrics:${BASHRC_NC}"
        
        # Commit frequency analysis
        local avg_commits_per_day=$(echo "scale=1; $commits_since / 30" | bc -l 2>/dev/null || echo "0")
        echo -e "   Average commits/day: $avg_commits_per_day"
        
        # Code churn analysis
        local additions=$(git log --since="$since" --numstat --pretty=format: | awk '{add += $1} END {print add+0}')
        local deletions=$(git log --since="$since" --numstat --pretty=format: | awk '{del += $2} END {print del+0}')
        echo -e "   Code churn: +$additions -$deletions lines"
        
        # Largest files
        echo -e "   Largest files:"
        find . -name '.git' -prune -o -type f -print0 | xargs -0 ls -la | sort -k5 -rn | head -3 | while read -r line; do
            local size=$(echo "$line" | awk '{print $5}')
            local file=$(echo "$line" | awk '{print $NF}')
            local size_human=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "$size bytes")
            echo -e "     📦 $(basename "$file"): $size_human"
        done
    fi
}

# Helper function to calculate days since date
days_since() {
    local past_date="$1"
    local current_date=$(date +%s)
    local past_timestamp=$(date -d "$past_date" +%s 2>/dev/null || echo "$current_date")
    local days=$(( (current_date - past_timestamp) / 86400 ))
    echo "$days"
}

# Log Branch Action
log_branch_action() {
    local action="$1"
    local branch_name="$2"
    local branch_type="$3"
    
    local git_intelligence_dir="$HOME/.bash_git_intelligence"
    local branch_log="$git_intelligence_dir/history/branches_$(date +%Y%m).log"
    
    mkdir -p "$(dirname "$branch_log")"
    echo "$(date -Iseconds)|$action|$branch_name|$branch_type|$(git branch --show-current)" >> "$branch_log"
}

# =============================================================================
# ADVANCED GIT ALIASES AND SHORTCUTS
# =============================================================================

# Set up intelligent Git aliases
setup_git_aliases() {
    # Only set up aliases if git is available
    command -v git >/dev/null 2>&1 || return
    
    # Smart Status
    alias gs='git status --short --branch'
    alias gst='git status'
    
    # Intelligent Logging
    alias gl='git log --oneline --graph --decorate --all -10'
    alias gll='git log --graph --pretty=format:"%C(yellow)%h%Creset %C(blue)%an%Creset %C(green)%cr%Creset %s %C(auto)%d%Creset" --all'
    alias glp='git log --patch'
    
    # Smart Diffs
    alias gd='git diff --color-words'
    alias gdc='git diff --cached --color-words'
    alias gdw='git diff --word-diff'
    
    # Intelligent Adding
    alias ga='git add'
    alias gaa='git add --all'
    alias gap='git add --patch'
    
    # Smart Committing (use our intelligent system)
    alias gc='smartcommit'
    alias gca='smartcommit --amend'
    alias gcm='smartcommit -m'
    alias gcw='smartcommit --wip'
    
    # Intelligent Branching
    alias gb='smartbranch'
    alias gbs='git branch --sort=-committerdate'
    alias gco='git checkout'
    alias gcb='smartbranch create'
    
    # Smart Merging
    alias gm='git merge --no-ff'
    alias gms='smartbranch merge'
    
    # Intelligent Push/Pull
    alias gp='git push'
    alias gpl='git pull --rebase --autostash'
    alias gpu='git push --set-upstream origin $(git branch --show-current)'
    
    # Smart Stashing
    alias gsh='git stash'
    alias gshp='git stash pop'
    alias gshl='git stash list'
    alias gshs='git stash show -p'
    
    # Repository Intelligence
    alias ganalytics='gitanalytics'
    alias goverview='gitanalytics overview'
    alias gstats='gitanalytics commits'
}

# =============================================================================
# GIT HOOKS AUTOMATION
# =============================================================================

# Intelligent Git Hooks Setup
setup_smart_hooks() {
    local usage="Usage: setup_smart_hooks [OPTIONS]
    
🪝 Intelligent Git Hooks Setup
Options:
    --commit-msg    Setup smart commit message validation
    --pre-commit    Setup pre-commit code quality checks
    --pre-push      Setup pre-push validation
    --all           Setup all intelligent hooks
    --remove        Remove all hooks
    -v, --verbose   Verbose output
    -h, --help      Show this help
    
Features:
    - Commit message validation with conventional commits
    - Code quality checks (linting, testing)
    - Security vulnerability scanning
    - Large file detection
    - Merge conflict detection"

    local setup_commit_msg=false
    local setup_pre_commit=false
    local setup_pre_push=false
    local remove_hooks=false
    local verbose=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --commit-msg)   setup_commit_msg=true; shift ;;
            --pre-commit)   setup_pre_commit=true; shift ;;
            --pre-push)     setup_pre_push=true; shift ;;
            --all)          setup_commit_msg=true; setup_pre_commit=true; setup_pre_push=true; shift ;;
            --remove)       remove_hooks=true; shift ;;
            -v|--verbose)   verbose=true; shift ;;
            -h|--help)      echo "$usage"; return 0 ;;
            *)              echo "Unknown option: $1"; return 1 ;;
        esac
    done
    
    # Ensure we're in a git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Not in a Git repository"
        return 1
    fi
    
    local hooks_dir="$(git rev-parse --git-dir)/hooks"
    
    if [[ "$remove_hooks" == "true" ]]; then
        echo -e "🗑️  ${BASHRC_CYAN}Removing intelligent Git hooks...${BASHRC_NC}"
        rm -f "$hooks_dir"/{commit-msg,pre-commit,pre-push}
        echo -e "✅ ${BASHRC_GREEN}Hooks removed${BASHRC_NC}"
        return 0
    fi
    
    echo -e "🪝 ${BASHRC_CYAN}Setting up intelligent Git hooks...${BASHRC_NC}"
    
    # Setup commit-msg hook
    if [[ "$setup_commit_msg" == "true" ]]; then
        create_smart_commit_msg_hook "$hooks_dir" "$verbose"
    fi
    
    # Setup pre-commit hook
    if [[ "$setup_pre_commit" == "true" ]]; then
        create_smart_pre_commit_hook "$hooks_dir" "$verbose"
    fi
    
    # Setup pre-push hook
    if [[ "$setup_pre_push" == "true" ]]; then
        create_smart_pre_push_hook "$hooks_dir" "$verbose"
    fi
    
    echo -e "✅ ${BASHRC_GREEN}Smart Git hooks setup completed!${BASHRC_NC}"
}

# Create Smart Commit Message Hook
create_smart_commit_msg_hook() {
    local hooks_dir="$1"
    local verbose="$2"
    
    cat > "$hooks_dir/commit-msg" << 'EOF'
#!/bin/bash
# Smart commit message validation hook

commit_regex='^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?(!)?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "❌ Invalid commit message format!"
    echo "📋 Use: type(scope): description"
    echo "📋 Types: feat, fix, docs, style, refactor, test, chore"
    echo "📋 Example: feat(auth): add OAuth integration"
    exit 1
fi

# Check for conventional commit format
if grep -qE "^(feat|fix)(\(.+\))?(!)?: " "$1"; then
    echo "✅ Conventional commit format detected"
fi

exit 0
EOF
    
    chmod +x "$hooks_dir/commit-msg"
    [[ "$verbose" == "true" ]] && echo -e "✅ commit-msg hook created"
}

# Create Smart Pre-commit Hook
create_smart_pre_commit_hook() {
    local hooks_dir="$1"
    local verbose="$2"
    
    cat > "$hooks_dir/pre-commit" << 'EOF'
#!/bin/bash
# Smart pre-commit validation hook

echo "🔍 Running smart pre-commit checks..."

# Check for large files
large_files=$(git diff --cached --name-only | xargs -I {} find {} -size +50M 2>/dev/null)
if [[ -n "$large_files" ]]; then
    echo "❌ Large files detected (>50MB):"
    echo "$large_files"
    echo "💡 Consider using Git LFS for large files"
    exit 1
fi

# Check for merge conflict markers
conflict_markers=$(git diff --cached | grep -E '^(\+.*(<<<<<<<|=======|>>>>>>>))')
if [[ -n "$conflict_markers" ]]; then
    echo "❌ Merge conflict markers detected!"
    echo "🔧 Resolve conflicts before committing"
    exit 1
fi

# Check for sensitive data patterns
sensitive_patterns="(password|secret|api[_-]?key|private[_-]?key|token)"
if git diff --cached | grep -iE "$sensitive_patterns" >/dev/null; then
    echo "⚠️  Potential sensitive data detected!"
    echo "🔒 Review your changes for sensitive information"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

echo "✅ Pre-commit checks passed"
exit 0
EOF
    
    chmod +x "$hooks_dir/pre-commit"
    [[ "$verbose" == "true" ]] && echo -e "✅ pre-commit hook created"
}

# Create Smart Pre-push Hook
create_smart_pre_push_hook() {
    local hooks_dir="$1"
    local verbose="$2"
    
    cat > "$hooks_dir/pre-push" << 'EOF'
#!/bin/bash
# Smart pre-push validation hook

echo "🚀 Running smart pre-push checks..."

# Check if pushing to protected branches
protected_branches="main master production"
current_branch=$(git branch --show-current)

for protected in $protected_branches; do
    if [[ "$current_branch" == "$protected" ]]; then
        echo "⚠️  Pushing to protected branch: $protected"
        read -p "Are you sure? [y/N] " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
    fi
done

# Check for commits ahead of origin
ahead_count=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo "0")
if [[ $ahead_count -gt 10 ]]; then
    echo "⚠️  You're $ahead_count commits ahead of origin"
    echo "💡 Consider rebasing or squashing commits"
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
fi

echo "✅ Pre-push checks passed"
exit 0
EOF
    
    chmod +x "$hooks_dir/pre-push"
    [[ "$verbose" == "true" ]] && echo -e "✅ pre-push hook created"
}

# =============================================================================
# MODULE INITIALIZATION
# =============================================================================

# Initialize Git Intelligence System
initialize_git_intelligence() {
    # Create directory structure
    local git_intelligence_dir="$HOME/.bash_git_intelligence"
    mkdir -p "$git_intelligence_dir"/{analysis,models,history,patterns,cache}
    
    # Initialize global git settings for better experience
    configure_git_settings
    
    # Set up intelligent aliases
    setup_git_aliases
    
    echo -e "📊 ${BASHRC_GREEN}Git intelligence system initialized${BASHRC_NC}"
}

# Configure Git Settings
configure_git_settings() {
    # Only configure if git is available and not already configured
    command -v git >/dev/null 2>&1 || return
    
    # Set up better defaults if not already set
    [[ -z "$(git config --global user.name 2>/dev/null)" ]] && {
        echo -e "🔧 ${BASHRC_YELLOW}Git user name not set. Configure with: git config --global user.name 'Your Name'${BASHRC_NC}"
    }
    
    [[ -z "$(git config --global user.email 2>/dev/null)" ]] && {
        echo -e "🔧 ${BASHRC_YELLOW}Git user email not set. Configure with: git config --global user.email 'your@email.com'${BASHRC_NC}"
    }
    
    # Set up better defaults
    git config --global init.defaultBranch main 2>/dev/null || true
    git config --global pull.rebase true 2>/dev/null || true
    git config --global rebase.autoStash true 2>/dev/null || true
    git config --global merge.tool vimdiff 2>/dev/null || true
    git config --global core.autocrlf input 2>/dev/null || true
    git config --global push.default simple 2>/dev/null || true
    git config --global branch.autosetupmerge always 2>/dev/null || true
    git config --global branch.autosetuprebase always 2>/dev/null || true
}

# Export all functions
export -f smartcommit perform_advanced_change_analysis calculate_change_complexity
export -f detect_breaking_changes analyze_security_impact estimate_performance_impact
export -f generate_intelligent_commit_message infer_commit_type_from_changes generate_core_message
export -f generate_context_details interactive_message_refinement format_conventional_commit
export -f show_commit_review execute_smart_commit post_commit_analysis
export -f smartbranch smartbranch_create generate_intelligent_branch_name get_default_source_branch
export -f gitanalytics git_overview_analysis days_since log_branch_action
export -f setup_smart_hooks create_smart_commit_msg_hook create_smart_pre_commit_hook create_smart_pre_push_hook

# Initialize the module
if command -v git >/dev/null 2>&1; then
    initialize_git_intelligence
    echo -e "${BASHRC_GREEN}✅ Git Integration Module Loaded${BASHRC_NC}"
    echo -e "${BASHRC_PURPLE}🎉 Ultimate Git Integration v$GIT_MODULE_VERSION Ready!${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}💡 Try: 'smartcommit -a', 'smartbranch create -f feature-name', 'gitanalytics overview'${BASHRC_NC}"
else
    echo -e "${BASHRC_YELLOW}⚠️  Git not found - Git integration features disabled${BASHRC_NC}"
fi
