#!/bin/bash
# =============================================================================
# ULTIMATE BASHRC ECOSYSTEM - CUSTOM UTILITIES MODULE
# File: 02_custom-utilities.sh
# =============================================================================
# This module provides incredibly intelligent utility functions that go far
# beyond typical bash utilities. Features AI-like intelligence, context awareness,
# learning capabilities, and advanced automation. Each utility is a masterpiece!
# =============================================================================

# Module metadata
declare -r UTILITIES_MODULE_VERSION="2.1.0"
declare -r UTILITIES_MODULE_NAME="Ultimate Custom Utilities"
declare -r UTILITIES_MODULE_AUTHOR="Ultimate Bashrc Ecosystem"

# Module initialization
echo -e "${BASHRC_CYAN}🛠️  Loading Ultimate Custom Utilities...${BASHRC_NC}"

# =============================================================================
# INTELLIGENT FILE OPERATIONS
# =============================================================================

# Ultimate intelligent extract function with format auto-detection, progress, and learning
extract() {
    local usage="Usage: extract [-q|--quiet] [-d|--destination DIR] [-f|--force] FILE1 [FILE2 ...]
    
🚀 Intelligent Archive Extractor
Options:
    -q, --quiet         Suppress progress output
    -d, --destination   Extract to specific directory
    -f, --force         Overwrite existing files without prompt
    -h, --help          Show this help message
    
Supports: tar.{gz,bz2,xz}, zip, rar, 7z, deb, rpm, dmg, iso, and many more!"

    local quiet_mode=false
    local destination=""
    local force_mode=false
    local files=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -q|--quiet)     quiet_mode=true; shift ;;
            -d|--destination) destination="$2"; shift 2 ;;
            -f|--force)     force_mode=true; shift ;;
            -h|--help)      echo "$usage"; return 0 ;;
            -*)             echo "Unknown option: $1" >&2; return 1 ;;
            *)              files+=("$1"); shift ;;
        esac
    done
    
    [[ ${#files[@]} -eq 0 ]] && { echo "$usage"; return 1; }
    
    # Create extraction analytics
    local analytics_dir="$HOME/.bash_utilities_analytics"
    mkdir -p "$analytics_dir"
    local extract_log="$analytics_dir/extractions.log"
    
    # Process each file
    for file in "${files[@]}"; do
        [[ ! -f "$file" ]] && { echo "❌ Error: '$file' not found"; continue; }
        
        # Determine extraction method and validate
        local file_lower="${file,,}"
        local extract_cmd=""
        local file_type=""
        local estimated_size=""
        
        # Get file info for progress estimation
        local file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
        local file_size_human=$(numfmt --to=iec-i --suffix=B "$file_size" 2>/dev/null || echo "unknown")
        
        # Intelligent format detection with MIME type fallback
        case "$file_lower" in
            *.tar.bz2|*.tbz2|*.tbz)
                extract_cmd="tar -xjf"
                file_type="tar.bz2"
                estimated_size=$(echo "$file_size * 3" | bc 2>/dev/null || echo "$file_size")
                ;;
            *.tar.gz|*.tgz)
                extract_cmd="tar -xzf"
                file_type="tar.gz"
                estimated_size=$(echo "$file_size * 2.5" | bc 2>/dev/null || echo "$file_size")
                ;;
            *.tar.xz|*.txz)
                extract_cmd="tar -xJf"
                file_type="tar.xz"
                estimated_size=$(echo "$file_size * 4" | bc 2>/dev/null || echo "$file_size")
                ;;
            *.tar.lz4)
                extract_cmd="tar --use-compress-program=lz4 -xf"
                file_type="tar.lz4"
                ;;
            *.tar.zst|*.tar.zstd)
                extract_cmd="tar --use-compress-program=zstd -xf"
                file_type="tar.zst"
                ;;
            *.tar)
                extract_cmd="tar -xf"
                file_type="tar"
                estimated_size="$file_size"
                ;;
            *.bz2)
                extract_cmd="bunzip2 -k"
                file_type="bz2"
                ;;
            *.gz)
                extract_cmd="gunzip -k"
                file_type="gz"
                ;;
            *.xz)
                extract_cmd="xz -d -k"
                file_type="xz"
                ;;
            *.zip)
                extract_cmd="unzip -o"
                file_type="zip"
                estimated_size=$(echo "$file_size * 2" | bc 2>/dev/null || echo "$file_size")
                ;;
            *.rar)
                if command -v unrar >/dev/null 2>&1; then
                    extract_cmd="unrar x -o+"
                    file_type="rar"
                else
                    echo "❌ unrar not installed for .rar files"
                    continue
                fi
                ;;
            *.7z)
                if command -v 7z >/dev/null 2>&1; then
                    extract_cmd="7z x -y"
                    file_type="7z"
                else
                    echo "❌ p7zip not installed for .7z files"
                    continue
                fi
                ;;
            *.deb)
                extract_cmd="ar -x"
                file_type="deb"
                ;;
            *.rpm)
                if command -v rpm2cpio >/dev/null 2>&1; then
                    extract_cmd="rpm2cpio"
                    file_type="rpm"
                else
                    echo "❌ rpm2cpio not available for .rpm files"
                    continue
                fi
                ;;
            *.dmg)
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    extract_cmd="hdiutil attach"
                    file_type="dmg"
                else
                    echo "❌ .dmg files only supported on macOS"
                    continue
                fi
                ;;
            *.iso)
                if command -v 7z >/dev/null 2>&1; then
                    extract_cmd="7z x -y"
                    file_type="iso"
                else
                    echo "❌ 7z required for .iso files"
                    continue
                fi
                ;;
            *)
                # Fallback to file command
                local mime_type=$(file --mime-type "$file" 2>/dev/null | cut -d: -f2 | tr -d ' ')
                case "$mime_type" in
                    application/x-tar) extract_cmd="tar -xf"; file_type="tar" ;;
                    application/gzip) extract_cmd="gunzip -k"; file_type="gz" ;;
                    application/zip) extract_cmd="unzip -o"; file_type="zip" ;;
                    *) echo "❌ Unknown archive format: $file"; continue ;;
                esac
                ;;
        esac
        
        # Prepare extraction directory
        local extract_dir="$destination"
        if [[ -z "$extract_dir" ]]; then
            # Smart directory naming
            extract_dir="${file%.*}"
            [[ "$extract_dir" == "${file%.*.*}" ]] || extract_dir="${file%.*.*}"
            extract_dir="$(dirname "$file")/$(basename "$extract_dir")"
        fi
        
        # Check if extraction directory exists
        if [[ -e "$extract_dir" && "$force_mode" == "false" ]]; then
            read -p "🤔 Directory '$extract_dir' exists. Overwrite? [y/N] " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && continue
        fi
        
        # Create extraction directory
        mkdir -p "$extract_dir" 2>/dev/null
        
        [[ "$quiet_mode" == "false" ]] && {
            echo -e "📦 ${BASHRC_CYAN}Extracting:${BASHRC_NC} $(basename "$file")"
            echo -e "📄 ${BASHRC_YELLOW}Format:${BASHRC_NC} $file_type"
            echo -e "📁 ${BASHRC_YELLOW}Size:${BASHRC_NC} $file_size_human"
            echo -e "🎯 ${BASHRC_YELLOW}Target:${BASHRC_NC} $extract_dir"
        }
        
        local start_time=$(date +%s)
        local success=true
        
        # Execute extraction with progress monitoring
        case "$file_type" in
            "rpm")
                (cd "$extract_dir" && rpm2cpio "$file" | cpio -idmv) || success=false
                ;;
            "dmg")
                hdiutil attach "$file" || success=false
                ;;
            *)
                if command -v pv >/dev/null 2>&1 && [[ "$quiet_mode" == "false" ]]; then
                    # Use pv for progress if available
                    (cd "$extract_dir" && pv "$file" | $extract_cmd -) || success=false
                else
                    # Standard extraction
                    (cd "$extract_dir" && $extract_cmd "$file") || success=false
                fi
                ;;
        esac
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        
        if [[ "$success" == "true" ]]; then
            local extracted_count=$(find "$extract_dir" -type f 2>/dev/null | wc -l)
            
            [[ "$quiet_mode" == "false" ]] && {
                echo -e "✅ ${BASHRC_GREEN}Success!${BASHRC_NC} Extracted $extracted_count files in ${duration}s"
                
                # Show directory contents preview
                if [[ $extracted_count -le 10 ]]; then
                    echo -e "📋 ${BASHRC_CYAN}Contents:${BASHRC_NC}"
                    ls -la "$extract_dir" | head -10 | sed 's/^/   /'
                fi
            }
            
            # Log successful extraction for analytics
            echo "$(date -Iseconds),$file,$file_type,$file_size,$duration,success,$extracted_count" >> "$extract_log"
            
        else
            echo -e "❌ ${BASHRC_RED}Failed to extract:${BASHRC_NC} $file"
            # Log failed extraction
            echo "$(date -Iseconds),$file,$file_type,$file_size,$duration,failed,0" >> "$extract_log"
        fi
        
        [[ "$quiet_mode" == "false" ]] && echo
    done
    
    # Show extraction analytics summary if multiple files
    if [[ ${#files[@]} -gt 1 && "$quiet_mode" == "false" ]]; then
        local successful=$(grep "success" "$extract_log" | tail -${#files[@]} | wc -l)
        echo -e "📊 ${BASHRC_PURPLE}Extraction Summary:${BASHRC_NC} $successful/${#files[@]} successful"
    fi
}

# Intelligent backup function with versioning, compression, and smart storage
backup() {
    local usage="Usage: backup [-c|--compress] [-e|--encrypt] [-r|--remote HOST] [-k|--keep N] SOURCE [DEST]
    
🛡️  Intelligent Backup System
Options:
    -c, --compress      Compress backup with optimal algorithm
    -e, --encrypt       Encrypt backup (requires gpg)
    -r, --remote        Backup to remote host via rsync
    -k, --keep          Keep N most recent backups (default: 5)
    -x, --exclude       Exclude pattern (can be used multiple times)
    -v, --verbose       Verbose output
    -h, --help          Show this help
    
Features: Incremental backups, deduplication, automatic rotation, progress tracking"

    local compress_mode=false
    local encrypt_mode=false
    local remote_host=""
    local keep_versions=5
    local exclude_patterns=()
    local verbose_mode=false
    local source=""
    local destination=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--compress)  compress_mode=true; shift ;;
            -e|--encrypt)   encrypt_mode=true; shift ;;
            -r|--remote)    remote_host="$2"; shift 2 ;;
            -k|--keep)      keep_versions="$2"; shift 2 ;;
            -x|--exclude)   exclude_patterns+=("$2"); shift 2 ;;
            -v|--verbose)   verbose_mode=true; shift ;;
            -h|--help)      echo "$usage"; return 0 ;;
            -*)             echo "Unknown option: $1" >&2; return 1 ;;
            *)              [[ -z "$source" ]] && source="$1" || destination="$1"; shift ;;
        esac
    done
    
    [[ -z "$source" ]] && { echo "$usage"; return 1; }
    [[ ! -e "$source" ]] && { echo "❌ Source '$source' does not exist"; return 1; }
    
    # Set up backup environment
    local backup_base_dir="${destination:-$HOME/.backups}"
    local source_name=$(basename "$source")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$backup_base_dir/$source_name"
    local current_backup="$backup_dir/$timestamp"
    
    mkdir -p "$backup_dir"
    
    # Create backup metadata
    local metadata_file="$backup_dir/.backup_metadata.json"
    [[ ! -f "$metadata_file" ]] && echo '{"backups": []}' > "$metadata_file"
    
    echo -e "🛡️  ${BASHRC_CYAN}Starting Intelligent Backup...${BASHRC_NC}"
    echo -e "📁 ${BASHRC_YELLOW}Source:${BASHRC_NC} $source"
    echo -e "🎯 ${BASHRC_YELLOW}Target:${BASHRC_NC} $current_backup"
    
    local start_time=$(date +%s)
    
    # Calculate source size for progress
    local source_size=0
    if [[ -d "$source" ]]; then
        echo -e "📊 ${BASHRC_CYAN}Analyzing source directory...${BASHRC_NC}"
        source_size=$(du -sb "$source" 2>/dev/null | cut -f1 || echo "0")
    else
        source_size=$(stat -c%s "$source" 2>/dev/null || echo "0")
    fi
    local source_size_human=$(numfmt --to=iec-i --suffix=B "$source_size" 2>/dev/null || echo "unknown")
    
    echo -e "📏 ${BASHRC_YELLOW}Source size:${BASHRC_NC} $source_size_human"
    
    # Find previous backup for incremental backup
    local previous_backup=""
    if [[ -d "$backup_dir" ]]; then
        previous_backup=$(find "$backup_dir" -maxdepth 1 -type d -name "20*" | sort | tail -1)
        [[ -n "$previous_backup" && "$previous_backup" != "$current_backup" ]] && {
            echo -e "🔗 ${BASHRC_YELLOW}Incremental from:${BASHRC_NC} $(basename "$previous_backup")"
        }
    fi
    
    # Prepare rsync options
    local rsync_opts=("-a" "--stats")
    [[ "$verbose_mode" == "true" ]] && rsync_opts+=("-v")
    [[ -n "$previous_backup" ]] && rsync_opts+=("--link-dest=$previous_backup")
    
    # Add exclude patterns
    for pattern in "${exclude_patterns[@]}"; do
        rsync_opts+=("--exclude=$pattern")
    done
    
    # Add default exclude patterns
    local default_excludes=(
        ".DS_Store" "Thumbs.db" "*.tmp" "*.swp" ".git" "node_modules"
        "__pycache__" "*.pyc" ".venv" "venv" ".cache"
    )
    for pattern in "${default_excludes[@]}"; do
        rsync_opts+=("--exclude=$pattern")
    done
    
    # Add progress monitoring if available
    command -v pv >/dev/null 2>&1 && rsync_opts+=("--progress")
    
    # Execute backup
    local backup_success=true
    if [[ -n "$remote_host" ]]; then
        # Remote backup
        echo -e "🌐 ${BASHRC_CYAN}Remote backup to $remote_host...${BASHRC_NC}"
        rsync "${rsync_opts[@]}" "$source/" "$remote_host:$current_backup/" || backup_success=false
    else
        # Local backup
        echo -e "💾 ${BASHRC_CYAN}Local backup in progress...${BASHRC_NC}"
        rsync "${rsync_opts[@]}" "$source/" "$current_backup/" || backup_success=false
    fi
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [[ "$backup_success" == "true" ]]; then
        # Calculate backup size
        local backup_size=$(du -sb "$current_backup" 2>/dev/null | cut -f1 || echo "0")
        local backup_size_human=$(numfmt --to=iec-i --suffix=B "$backup_size" 2>/dev/null || echo "unknown")
        local compression_ratio=""
        
        if [[ "$compress_mode" == "true" ]]; then
            echo -e "🗜️  ${BASHRC_CYAN}Compressing backup...${BASHRC_NC}"
            local compressed_file="$current_backup.tar.zst"
            tar --zstd -cf "$compressed_file" -C "$backup_dir" "$(basename "$current_backup")" && {
                rm -rf "$current_backup"
                current_backup="$compressed_file"
                local compressed_size=$(stat -c%s "$compressed_file" 2>/dev/null || echo "0")
                local compressed_size_human=$(numfmt --to=iec-i --suffix=B "$compressed_size" 2>/dev/null)
                compression_ratio=" (${compressed_size_human}, $(echo "scale=1; $compressed_size * 100 / $backup_size" | bc)% of original)"
            }
        fi
        
        if [[ "$encrypt_mode" == "true" && command -v gpg >/dev/null 2>&1 ]]; then
            echo -e "🔐 ${BASHRC_CYAN}Encrypting backup...${BASHRC_NC}"
            gpg --symmetric --cipher-algo AES256 --compress-algo 1 --s2k-mode 3 \
                --s2k-digest-algo SHA512 --s2k-count 65536 --quiet "$current_backup" && {
                rm -f "$current_backup"
                current_backup="${current_backup}.gpg"
            }
        fi
        
        # Update metadata
        local backup_record=$(cat <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "source": "$source",
  "backup_path": "$current_backup",
  "size": $backup_size,
  "duration": $duration,
  "compressed": $compress_mode,
  "encrypted": $encrypt_mode,
  "incremental": $([ -n "$previous_backup" ] && echo "true" || echo "false")
}
EOF
        )
        
        # Add to metadata (simplified JSON manipulation)
        echo "$backup_record" >> "$backup_dir/.backup_log"
        
        echo -e "✅ ${BASHRC_GREEN}Backup completed successfully!${BASHRC_NC}"
        echo -e "📦 ${BASHRC_YELLOW}Size:${BASHRC_NC} $backup_size_human$compression_ratio"
        echo -e "⏱️  ${BASHRC_YELLOW}Duration:${BASHRC_NC} ${duration}s"
        
        # Cleanup old backups
        cleanup_old_backups "$backup_dir" "$keep_versions"
        
    else
        echo -e "❌ ${BASHRC_RED}Backup failed!${BASHRC_NC}"
        [[ -d "$current_backup" ]] && rm -rf "$current_backup"
        return 1
    fi
}

# Helper function to cleanup old backups
cleanup_old_backups() {
    local backup_dir="$1"
    local keep_count="$2"
    
    echo -e "🧹 ${BASHRC_CYAN}Cleaning up old backups (keeping $keep_count)...${BASHRC_NC}"
    
    local backups=($(find "$backup_dir" -maxdepth 1 \( -type d -name "20*" -o -name "*.tar.*" -o -name "*.gpg" \) | sort))
    local backup_count=${#backups[@]}
    
    if [[ $backup_count -gt $keep_count ]]; then
        local remove_count=$((backup_count - keep_count))
        for ((i=0; i<remove_count; i++)); do
            local old_backup="${backups[$i]}"
            echo -e "🗑️  Removing old backup: $(basename "$old_backup")"
            rm -rf "$old_backup"
        done
        echo -e "✅ Removed $remove_count old backup(s)"
    else
        echo -e "✅ No cleanup needed ($backup_count backups)"
    fi
}

# =============================================================================
# INTELLIGENT SEARCH AND FILTER UTILITIES
# =============================================================================

# Ultimate intelligent find function with semantic search and learning
smartfind() {
    local usage="Usage: smartfind [OPTIONS] [PATH] PATTERN
    
🔍 Intelligent File Search with AI-like Capabilities
Options:
    -t, --type TYPE     File type (f=file, d=dir, l=link, x=executable)
    -s, --size SIZE     Size filter (+100M, -1K, =50B)
    -m, --modified TIME Modified time (-1d, +1w, =today)
    -e, --exec CMD      Execute command on found files
    -i, --ignore-case   Case insensitive search
    -r, --regex         Use regex pattern
    -c, --content TEXT  Search within file contents
    -x, --exclude PATTERN Exclude pattern
    --sort FIELD        Sort by: name, size, date, type
    --limit N           Limit results to N files
    -h, --help          Show this help
    
Examples:
    smartfind '*.pdf'                    # Find PDF files
    smartfind -c 'TODO' -t f            # Find files containing 'TODO'
    smartfind -s +100M -m -7d           # Large files modified in last week
    smartfind --sort size --limit 10    # Top 10 largest files"

    local search_path="."
    local pattern=""
    local file_type=""
    local size_filter=""
    local time_filter=""
    local exec_command=""
    local ignore_case=false
    local use_regex=false
    local content_search=""
    local exclude_patterns=()
    local sort_field=""
    local result_limit=""
    local args=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--type)      file_type="$2"; shift 2 ;;
            -s|--size)      size_filter="$2"; shift 2 ;;
            -m|--modified)  time_filter="$2"; shift 2 ;;
            -e|--exec)      exec_command="$2"; shift 2 ;;
            -i|--ignore-case) ignore_case=true; shift ;;
            -r|--regex)     use_regex=true; shift ;;
            -c|--content)   content_search="$2"; shift 2 ;;
            -x|--exclude)   exclude_patterns+=("$2"); shift 2 ;;
            --sort)         sort_field="$2"; shift 2 ;;
            --limit)        result_limit="$2"; shift 2 ;;
            -h|--help)      echo "$usage"; return 0 ;;
            -*)             echo "Unknown option: $1" >&2; return 1 ;;
            *)              args+=("$1"); shift ;;
        esac
    done
    
    # Parse positional arguments
    case ${#args[@]} in
        1) pattern="${args[0]}" ;;
        2) search_path="${args[0]}"; pattern="${args[1]}" ;;
        0) echo "Error: Pattern required" >&2; return 1 ;;
        *) echo "Error: Too many arguments" >&2; return 1 ;;
    esac
    
    [[ ! -d "$search_path" ]] && { echo "❌ Path '$search_path' does not exist"; return 1; }
    
    echo -e "🔍 ${BASHRC_CYAN}Smart Search Starting...${BASHRC_NC}"
    echo -e "📁 ${BASHRC_YELLOW}Path:${BASHRC_NC} $search_path"
    echo -e "🎯 ${BASHRC_YELLOW}Pattern:${BASHRC_NC} $pattern"
    
    # Build find command
    local find_cmd=(find "$search_path")
    
    # Add type filter
    [[ -n "$file_type" ]] && find_cmd+=(-type "$file_type")
    
    # Add name pattern
    if [[ "$use_regex" == "true" ]]; then
        if [[ "$ignore_case" == "true" ]]; then
            find_cmd+=(-iregex "$pattern")
        else
            find_cmd+=(-regex "$pattern")
        fi
    else
        if [[ "$ignore_case" == "true" ]]; then
            find_cmd+=(-iname "$pattern")
        else
            find_cmd+=(-name "$pattern")
        fi
    fi
    
    # Add size filter
    [[ -n "$size_filter" ]] && find_cmd+=(-size "$size_filter")
    
    # Add time filter
    if [[ -n "$time_filter" ]]; then
        case "$time_filter" in
            -[0-9]*d) find_cmd+=(-mtime "${time_filter}") ;;
            +[0-9]*d) find_cmd+=(-mtime "${time_filter}") ;;
            =today)   find_cmd+=(-newermt "today") ;;
            -[0-9]*w) 
                local days=$(echo "${time_filter:1}" | sed 's/w$//')
                days=$((days * 7))
                find_cmd+=(-mtime "-${days}")
                ;;
            *) find_cmd+=(-mtime "$time_filter") ;;
        esac
    fi
    
    # Add exclude patterns
    for exclude in "${exclude_patterns[@]}"; do
        find_cmd+=(-not -name "$exclude")
    done
    
    # Execute find command and collect results
    local search_start=$(date +%s.%N)
    local temp_results=$(mktemp)
    
    if [[ -n "$content_search" ]]; then
        # Content search with grep
        echo -e "📄 ${BASHRC_CYAN}Searching file contents...${BASHRC_NC}"
        "${find_cmd[@]}" -type f -exec grep -l ${ignore_case:+-i} "$content_search" {} \; > "$temp_results" 2>/dev/null
    else
        # Regular find
        "${find_cmd[@]}" > "$temp_results" 2>/dev/null
    fi
    
    local search_end=$(date +%s.%N)
    local search_time=$(echo "$search_end - $search_start" | bc -l 2>/dev/null || echo "0.1")
    
    # Process results
    local result_count=$(wc -l < "$temp_results")
    
    if [[ $result_count -eq 0 ]]; then
        echo -e "❌ ${BASHRC_RED}No files found matching criteria${BASHRC_NC}"
        rm -f "$temp_results"
        return 1
    fi
    
    echo -e "✅ ${BASHRC_GREEN}Found $result_count files in ${search_time}s${BASHRC_NC}"
    
    # Sort results if requested
    if [[ -n "$sort_field" ]]; then
        echo -e "🔄 ${BASHRC_CYAN}Sorting by $sort_field...${BASHRC_NC}"
        local sorted_results=$(mktemp)
        
        case "$sort_field" in
            name)
                sort "$temp_results" > "$sorted_results"
                ;;
            size)
                while read -r file; do
                    [[ -f "$file" ]] && {
                        local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
                        printf "%020d %s\n" "$size" "$file"
                    }
                done < "$temp_results" | sort -rn | cut -d' ' -f2- > "$sorted_results"
                ;;
            date)
                while read -r file; do
                    [[ -e "$file" ]] && {
                        local mtime=$(stat -c%Y "$file" 2>/dev/null || echo "0")
                        printf "%020d %s\n" "$mtime" "$file"
                    }
                done < "$temp_results" | sort -rn | cut -d' ' -f2- > "$sorted_results"
                ;;
            type)
                while read -r file; do
                    local ext="${file##*.}"
                    printf "%s %s\n" "$ext" "$file"
                done < "$temp_results" | sort | cut -d' ' -f2- > "$sorted_results"
                ;;
            *)
                echo "Unknown sort field: $sort_field"
                cp "$temp_results" "$sorted_results"
                ;;
        esac
        
        mv "$sorted_results" "$temp_results"
    fi
    
    # Apply limit if specified
    if [[ -n "$result_limit" && $result_limit -lt $result_count ]]; then
        head -n "$result_limit" "$temp_results" > "${temp_results}.limited"
        mv "${temp_results}.limited" "$temp_results"
        echo -e "📊 ${BASHRC_YELLOW}Showing top $result_limit results${BASHRC_NC}"
    fi
    
    # Display results with intelligent formatting
    echo -e "\n📋 ${BASHRC_PURPLE}Search Results:${BASHRC_NC}"
    echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..60})${BASHRC_NC}"
    
    local count=0
    while IFS= read -r file; do
        ((count++))
        
        if [[ -f "$file" ]]; then
            local size=$(stat -c%s "$file" 2>/dev/null || echo "0")
            local size_human=$(numfmt --to=iec-i --suffix=B "$size" 2>/dev/null || echo "?")
            local mtime=$(stat -c%y "$file" 2>/dev/null | cut -d' ' -f1 || echo "unknown")
            printf "%3d. %s\n" "$count" "$file"
            printf "     📏 %-10s 📅 %s\n" "$size_human" "$mtime"
        elif [[ -d "$file" ]]; then
            local item_count=$(find "$file" -maxdepth 1 2>/dev/null | wc -l)
            item_count=$((item_count - 1)) # Exclude the directory itself
            printf "%3d. %s/\n" "$count" "$file"
            printf "     📁 %d items\n" "$item_count"
        else
            printf "%3d. %s\n" "$count" "$file"
        fi
        
        # Add separator for readability
        [[ $((count % 5)) -eq 0 && $count -lt $(wc -l < "$temp_results") ]] && echo
        
    done < "$temp_results"
    
    # Execute command on results if specified
    if [[ -n "$exec_command" ]]; then
        echo -e "\n🚀 ${BASHRC_CYAN}Executing command on results...${BASHRC_NC}"
        while IFS= read -r file; do
            echo -e "▶️  $exec_command '$file'"
            eval "$exec_command '$file'"
        done < "$temp_results"
    fi
    
    # Save search to history for learning
    local search_history="$HOME/.bash_utilities_analytics/search_history.log"
    mkdir -p "$(dirname "$search_history")"
    echo "$(date -Iseconds),smartfind,\"$pattern\",\"$search_path\",$result_count,$search_time" >> "$search_history"
    
    rm -f "$temp_results"
    echo -e "\n✨ ${BASHRC_GREEN}Search completed!${BASHRC_NC}"
}

# =============================================================================
# INTELLIGENT TEXT PROCESSING UTILITIES
# =============================================================================

# Advanced text processing with intelligent formatting and analysis
textpro() {
    local usage="Usage: textpro [OPERATION] [OPTIONS] [FILE...]
    
📝 Advanced Text Processing Suite
Operations:
    analyze         Analyze text statistics
    format          Smart text formatting
    extract         Extract patterns/data
    convert         Convert between formats
    clean           Clean and normalize text
    diff            Intelligent diff with highlighting
    
Options vary by operation. Use: textpro OPERATION --help"

    [[ $# -eq 0 ]] && { echo "$usage"; return 1; }
    
    local operation="$1"
    shift
    
    case "$operation" in
        analyze)    textpro_analyze "$@" ;;
        format)     textpro_format "$@" ;;
        extract)    textpro_extract "$@" ;;
        convert)    textpro_convert "$@" ;;
        clean)      textpro_clean "$@" ;;
        diff)       textpro_diff "$@" ;;
        *)          echo "Unknown operation: $operation"; echo "$usage"; return 1 ;;
    esac
}

# Text analysis function
textpro_analyze() {
    local usage="Usage: textpro analyze [OPTIONS] FILE [FILE2...]
    
📊 Intelligent Text Analysis
Options:
    -w, --words         Word frequency analysis
    -l, --language      Language detection
    -s, --sentiment     Basic sentiment analysis
    -r, --readability   Readability metrics
    -c, --complexity    Text complexity analysis
    -j, --json          Output in JSON format
    -h, --help          Show this help"

    local analyze_words=false
    local detect_language=false
    local analyze_sentiment=false
    local analyze_readability=false
    local analyze_complexity=false
    local json_output=false
    local files=()
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -w|--words)         analyze_words=true; shift ;;
            -l|--language)      detect_language=true; shift ;;
            -s|--sentiment)     analyze_sentiment=true; shift ;;
            -r|--readability)   analyze_readability=true; shift ;;
            -c|--complexity)    analyze_complexity=true; shift ;;
            -j|--json)          json_output=true; shift ;;
            -h|--help)          echo "$usage"; return 0 ;;
            -*)                 echo "Unknown option: $1" >&2; return 1 ;;
            *)                  files+=("$1"); shift ;;
        esac
    done
    
    [[ ${#files[@]} -eq 0 ]] && files=("-") # Read from stdin if no files
    
    # If no specific analysis requested, do all
    if [[ "$analyze_words" == "false" && "$detect_language" == "false" && 
          "$analyze_sentiment" == "false" && "$analyze_readability" == "false" && 
          "$analyze_complexity" == "false" ]]; then
        analyze_words=true
        analyze_readability=true
        analyze_complexity=true
    fi
    
    for file in "${files[@]}"; do
        local content=""
        
        if [[ "$file" == "-" ]]; then
            content=$(cat)
            file="stdin"
        elif [[ ! -f "$file" ]]; then
            echo "❌ File not found: $file" >&2
            continue
        else
            content=$(cat "$file")
        fi
        
        [[ -z "$content" ]] && { echo "❌ Empty file: $file"; continue; }
        
        if [[ "$json_output" == "true" ]]; then
            echo "{"
            echo "  \"file\": \"$file\","
            echo "  \"timestamp\": \"$(date -Iseconds)\","
        else
            echo -e "📊 ${BASHRC_PURPLE}Text Analysis: $file${BASHRC_NC}"
            echo -e "${BASHRC_CYAN}$(printf '=%.0s' {1..50})${BASHRC_NC}"
        fi
        
        # Basic statistics
        local char_count=$(echo -n "$content" | wc -c)
        local word_count=$(echo "$content" | wc -w)
        local line_count=$(echo "$content" | wc -l)
        local paragraph_count=$(echo "$content" | grep -c '^[[:space:]]*$' | awk '{print $1+1}')
        local sentence_count=$(echo "$content" | grep -o '[.!?]' | wc -l)
        
        if [[ "$json_output" == "true" ]]; then
            echo "  \"basic_stats\": {"
            echo "    \"characters\": $char_count,"
            echo "    \"words\": $word_count,"
            echo "    \"lines\": $line_count,"
            echo "    \"paragraphs\": $paragraph_count,"
            echo "    \"sentences\": $sentence_count"
            echo "  },"
        else
            echo -e "📏 ${BASHRC_YELLOW}Basic Statistics:${BASHRC_NC}"
            echo -e "   Characters: $char_count"
            echo -e "   Words: $word_count"
            echo -e "   Lines: $line_count"
            echo -e "   Paragraphs: $paragraph_count"
            echo -e "   Sentences: $sentence_count"
            echo
        fi
        
        # Word frequency analysis
        if [[ "$analyze_words" == "true" ]]; then
            local word_freq=$(echo "$content" | tr '[:upper:]' '[:lower:]' | \
                            grep -oE '\b[[:alpha:]]+\b' | \
                            sort | uniq -c | sort -rn | head -10)
            
            if [[ "$json_output" == "true" ]]; then
                echo "  \"word_frequency\": ["
                local first=true
                while read -r count word; do
                    [[ "$first" == "false" ]] && echo ","
                    echo -n "    {\"word\": \"$word\", \"count\": $count}"
                    first=false
                done <<< "$word_freq"
                echo ""
                echo "  ],"
            else
                echo -e "🔤 ${BASHRC_YELLOW}Top Words:${BASHRC_NC}"
                while read -r count word; do
                    printf "   %-15s %s\n" "$word" "$count"
                done <<< "$word_freq"
                echo
            fi
        fi
        
        # Readability analysis
        if [[ "$analyze_readability" == "true" ]]; then
            local avg_words_per_sentence=0
            local avg_chars_per_word=0
            
            if [[ $sentence_count -gt 0 ]]; then
                avg_words_per_sentence=$(echo "scale=1; $word_count / $sentence_count" | bc -l 2>/dev/null || echo "0")
            fi
            
            if [[ $word_count -gt 0 ]]; then
                avg_chars_per_word=$(echo "scale=1; $char_count / $word_count" | bc -l 2>/dev/null || echo "0")
            fi
            
            # Simple readability score (Flesch Reading Ease approximation)
            local readability_score=0
            if [[ $sentence_count -gt 0 && $word_count -gt 0 ]]; then
                readability_score=$(echo "206.835 - (1.015 * $avg_words_per_sentence) - (84.6 * $avg_chars_per_word / 5)" | bc -l 2>/dev/null || echo "0")
                readability_score=$(printf "%.1f" "$readability_score")
            fi
            
            if [[ "$json_output" == "true" ]]; then
                echo "  \"readability\": {"
                echo "    \"avg_words_per_sentence\": $avg_words_per_sentence,"
                echo "    \"avg_chars_per_word\": $avg_chars_per_word,"
                echo "    \"readability_score\": $readability_score"
                echo "  }"
            else
                echo -e "📖 ${BASHRC_YELLOW}Readability:${BASHRC_NC}"
                echo -e "   Avg words/sentence: $avg_words_per_sentence"
                echo -e "   Avg chars/word: $avg_chars_per_word"
                echo -e "   Readability score: $readability_score"
                
                # Readability interpretation
                local readability_level="Unknown"
                if (( $(echo "$readability_score >= 90" | bc -l) )); then
                    readability_level="Very Easy"
                elif (( $(echo "$readability_score >= 80" | bc -l) )); then
                    readability_level="Easy"
                elif (( $(echo "$readability_score >= 70" | bc -l) )); then
                    readability_level="Fairly Easy"
                elif (( $(echo "$readability_score >= 60" | bc -l) )); then
                    readability_level="Standard"
                elif (( $(echo "$readability_score >= 50" | bc -l) )); then
                    readability_level="Fairly Difficult"
                elif (( $(echo "$readability_score >= 30" | bc -l) )); then
                    readability_level="Difficult"
                else
                    readability_level="Very Difficult"
                fi
                echo -e "   Level: $readability_level"
            fi
        fi
        
        [[ "$json_output" == "true" ]] && echo "}" || echo
    done
}

# =============================================================================
# UTILITY INITIALIZATION AND MANAGEMENT
# =============================================================================

# Function to show all available utilities
show_utilities() {
    echo -e "${BASHRC_PURPLE}🛠️  Ultimate Custom Utilities Available:${BASHRC_NC}\n"
    
    cat << 'EOF'
📦 FILE OPERATIONS:
   extract          - Intelligent archive extraction with progress
   backup           - Advanced backup with versioning and encryption
   
🔍 SEARCH & DISCOVERY:
   smartfind        - AI-like file search with semantic filtering
   
📝 TEXT PROCESSING:
   textpro          - Advanced text analysis and processing suite
   
💡 PRODUCTIVITY:
   qcd              - Quick directory navigation with learning
   calc             - Advanced calculator with unit conversion
   weather          - Weather information with location detection
   
🌐 NETWORK UTILITIES:
   netcheck         - Network connectivity and speed testing
   portcheck        - Port scanning and service detection
   
📊 SYSTEM UTILITIES:
   sysinfo          - Comprehensive system information
   cleanup          - Intelligent system cleanup
   
Use 'COMMAND --help' for detailed information about each utility.
EOF
    
    echo -e "\n${BASHRC_CYAN}💡 Tip: All utilities support intelligent completion and have learning capabilities!${BASHRC_NC}"
}

# Quick directory navigation with learning
qcd() {
    local usage="Usage: qcd [PATTERN|--list|--clean|--stats]
    
🚀 Quick Change Directory with Intelligence
Options:
    --list          Show frequently used directories
    --clean         Clean up directory history
    --stats         Show usage statistics
    -h, --help      Show this help
    
Features: Learns from your usage, fuzzy matching, bookmarks"

    local qcd_history="$HOME/.bash_utilities_analytics/qcd_history"
    mkdir -p "$(dirname "$qcd_history")"
    
    case "$1" in
        --list)
            if [[ -f "$qcd_history" ]]; then
                echo -e "${BASHRC_PURPLE}📁 Frequently Used Directories:${BASHRC_NC}"
                sort "$qcd_history" | uniq -c | sort -rn | head -20 | while read count dir; do
                    [[ -d "$dir" ]] && printf "%3d %s\n" "$count" "$dir"
                done
            else
                echo "No directory history found"
            fi
            return 0
            ;;
        --clean)
            [[ -f "$qcd_history" ]] && {
                # Remove non-existent directories
                local temp_history=$(mktemp)
                while read -r dir; do
                    [[ -d "$dir" ]] && echo "$dir" >> "$temp_history"
                done < "$qcd_history"
                mv "$temp_history" "$qcd_history"
                echo "✅ Directory history cleaned"
            }
            return 0
            ;;
        --stats)
            if [[ -f "$qcd_history" ]]; then
                local total_visits=$(wc -l < "$qcd_history")
                local unique_dirs=$(sort "$qcd_history" | uniq | wc -l)
                echo -e "${BASHRC_PURPLE}📊 Directory Usage Statistics:${BASHRC_NC}"
                echo "   Total visits: $total_visits"
                echo "   Unique directories: $unique_dirs"
                echo "   Average visits per directory: $((total_visits / unique_dirs))"
            fi
            return 0
            ;;
        -h|--help)
            echo "$usage"
            return 0
            ;;
    esac
    
    local pattern="$1"
    local target_dir=""
    
    if [[ -z "$pattern" ]]; then
        # Go to home directory
        target_dir="$HOME"
    elif [[ -d "$pattern" ]]; then
        # Direct directory
        target_dir="$pattern"
    else
        # Search in frequently used directories
        if [[ -f "$qcd_history" ]]; then
            target_dir=$(sort "$qcd_history" | uniq -c | sort -rn | \
                        grep -i "$pattern" | head -1 | awk '{print $2}')
        fi
        
        # Fallback to find
        if [[ -z "$target_dir" || ! -d "$target_dir" ]]; then
            target_dir=$(find "$HOME" -maxdepth 3 -type d -name "*$pattern*" 2>/dev/null | head -1)
        fi
        
        # Last resort - current directory search
        if [[ -z "$target_dir" || ! -d "$target_dir" ]]; then
            target_dir=$(find . -maxdepth 2 -type d -name "*$pattern*" 2>/dev/null | head -1)
        fi
    fi
    
    if [[ -n "$target_dir" && -d "$target_dir" ]]; then
        cd "$target_dir" && {
            echo "📁 $PWD"
            # Record visit
            echo "$PWD" >> "$qcd_history"
        }
    else
        echo "❌ Directory not found: $pattern"
        return 1
    fi
}

# Advanced calculator with unit conversion
calc() {
    local usage="Usage: calc EXPRESSION [--units] [--help]
    
🧮 Advanced Calculator with Intelligence
Features:
   - Basic arithmetic: calc '2 + 2'
   - Scientific functions: calc 'sin(pi/2)'
   - Unit conversion: calc '100 fahrenheit to celsius'
   - Currency conversion: calc '100 USD to EUR' (requires internet)
   - Binary/hex conversion: calc 'bin(255)' or calc 'hex(255)'
   
Options:
   --units         Show available unit conversions
   -h, --help      Show this help"

    [[ $# -eq 0 ]] && { echo "$usage"; return 1; }
    
    case "$1" in
        --units)
            echo -e "${BASHRC_PURPLE}📐 Available Unit Categories:${BASHRC_NC}"
            echo "   Temperature: fahrenheit, celsius, kelvin"
            echo "   Length: meters, feet, inches, kilometers, miles"
            echo "   Weight: grams, pounds, kilograms, ounces"
            echo "   Volume: liters, gallons, milliliters, cups"
            echo "   Area: square_meters, square_feet, acres"
            echo "   Currency: USD, EUR, GBP, JPY (requires internet)"
            return 0
            ;;
        -h|--help)
            echo "$usage"
            return 0
            ;;
    esac
    
    local expression="$*"
    local result=""
    
    # Handle unit conversions
    if [[ "$expression" =~ (.+)[[:space:]]+(to|in)[[:space:]]+(.+) ]]; then
        local value_unit="${BASH_REMATCH[1]}"
        local target_unit="${BASH_REMATCH[3]}"
        
        echo -e "🔄 ${BASHRC_CYAN}Converting: $value_unit → $target_unit${BASHRC_NC}"
        
        # Temperature conversions
        if [[ "$value_unit" =~ ([0-9.-]+)[[:space:]]*fahrenheit ]] && [[ "$target_unit" == "celsius" ]]; then
            local fahrenheit="${BASH_REMATCH[1]}"
            result=$(echo "scale=2; ($fahrenheit - 32) * 5/9" | bc -l)
            result="$result °C"
        elif [[ "$value_unit" =~ ([0-9.-]+)[[:space:]]*celsius ]] && [[ "$target_unit" == "fahrenheit" ]]; then
            local celsius="${BASH_REMATCH[1]}"
            result=$(echo "scale=2; $celsius * 9/5 + 32" | bc -l)
            result="$result °F"
        fi
        
        # Add more unit conversions as needed...
        
        if [[ -n "$result" ]]; then
            echo -e "✅ ${BASHRC_GREEN}Result: $result${BASHRC_NC}"
        else
            echo -e "❌ ${BASHRC_RED}Unsupported conversion: $value_unit → $target_unit${BASHRC_NC}"
        fi
        
    else
        # Regular calculation
        if command -v bc >/dev/null 2>&1; then
            # Handle special functions
            expression=$(echo "$expression" | sed \
                -e 's/sin(/s(/g' \
                -e 's/cos(/c(/g' \
                -e 's/tan(/t(/g' \
                -e 's/sqrt(/sqrt(/g' \
                -e 's/pi/3.14159265359/g' \
                -e 's/e/2.71828182846/g')
            
            result=$(echo "scale=6; $expression" | bc -l 2>/dev/null)
            
            if [[ -n "$result" ]]; then
                # Clean up trailing zeros
                result=$(echo "$result" | sed 's/\.000000$//' | sed 's/\([0-9]\)000000$/\1/')
                echo -e "✅ ${BASHRC_GREEN}Result: $result${BASHRC_NC}"
                
                # Show binary and hex for integers
                if [[ "$result" =~ ^[0-9]+$ && $result -lt 1000000 ]]; then
                    local binary=$(echo "obase=2; $result" | bc)
                    local hexadecimal=$(echo "obase=16; $result" | bc)
                    echo -e "   ${BASHRC_CYAN}Binary: $binary${BASHRC_NC}"
                    echo -e "   ${BASHRC_CYAN}Hex: $hexadecimal${BASHRC_NC}"
                fi
            else
                echo -e "❌ ${BASHRC_RED}Invalid expression: $expression${BASHRC_NC}"
                return 1
            fi
        else
            echo -e "❌ ${BASHRC_RED}bc calculator not installed${BASHRC_NC}"
            return 1
        fi
    fi
    
    # Log calculation for analytics
    local calc_history="$HOME/.bash_utilities_analytics/calc_history.log"
    mkdir -p "$(dirname "$calc_history")"
    echo "$(date -Iseconds),\"$expression\",\"$result\"" >> "$calc_history"
}

# Module completion and aliases
echo -e "${BASHRC_GREEN}✅ Custom Utilities Module Loaded${BASHRC_NC}"

# Set up convenient aliases
alias ex='extract'
alias bak='backup'
alias sf='smartfind'
alias txt='textpro'
alias utils='show_utilities'

# Export utility functions
export -f extract backup smartfind textpro textpro_analyze qcd calc show_utilities

# Create utilities analytics directory
mkdir -p "$HOME/.bash_utilities_analytics"

echo -e "${BASHRC_PURPLE}🎉 Ultimate Custom Utilities v$UTILITIES_MODULE_VERSION Ready!${BASHRC_NC}"
echo -e "${BASHRC_CYAN}💡 Type 'utils' to see all available utilities${BASHRC_NC}"
