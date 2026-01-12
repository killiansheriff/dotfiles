# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                            SHELL FUNCTIONS                                ║
# ╚══════════════════════════════════════════════════════════════════════════╝
# Managed by chezmoi - edit source at ~/.local/share/chezmoi

# ─────────────────────────────────────────────────────────────────────────────
# Directory creation and navigation
# ─────────────────────────────────────────────────────────────────────────────
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# ─────────────────────────────────────────────────────────────────────────────
# File & Text utilities
# ─────────────────────────────────────────────────────────────────────────────
# Extract any archive
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.tar.xz)    tar xJf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Git utilities
# ─────────────────────────────────────────────────────────────────────────────
# Clone and cd into repo
gclone() {
    git clone "$1" && cd "$(basename "$1" .git)"
}

# cd to git repository root
groot() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$root" ]]; then
        cd "$root"
    else
        echo "Not in a git repository"
        return 1
    fi
}

# Interactive git add with fzf
gadd() {
    if command -v fzf &> /dev/null; then
        git status -s | fzf -m --preview 'git diff --color=always {2}' | awk '{print $2}' | xargs -r git add
    else
        git add -p
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Development utilities
# ─────────────────────────────────────────────────────────────────────────────
# Quick Python HTTP server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}

# Find process by name
psg() {
    ps aux | grep -v grep | grep -i "$1"
}

# Kill process by port
killport() {
    local port="$1"
    if [[ -z "$port" ]]; then
        echo "Usage: killport <port>"
        return 1
    fi
    lsof -ti :"$port" | xargs -r kill -9
    echo "Killed processes on port $port"
}

# ─────────────────────────────────────────────────────────────────────────────
# LaTeX compilation and cleanup (biber runs by default)
# ─────────────────────────────────────────────────────────────────────────────
texclean() {
    if [[ -z "$1" ]]; then
        echo "Usage: texclean <filename.tex> [options]"
        echo "Options:"
        echo "  --no-biber     Skip biber (bibliography processing)"
        echo "  -k, --keep     Keep auxiliary files (don't delete)"
        echo ""
        echo "By default, biber runs automatically for bibliography processing."
        echo ""
        echo "Examples:"
        echo "  texclean main.tex              # Compile with biber + cleanup"
        echo "  texclean main.tex --no-biber   # Skip biber"
        echo "  texclean main.tex --keep       # Keep aux files"
        return 1
    fi
    
    local texfile="$1"
    local basename="${texfile%.tex}"
    local run_biber=true
    local keep_aux=false
    
    # Parse options
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-biber)
                run_biber=false
                shift
                ;;
            -k|--keep)
                keep_aux=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                return 1
                ;;
        esac
    done
    
    echo "=== Compiling LaTeX document: $texfile ==="
    
    # First compilation
    pdflatex -interaction=nonstopmode "$texfile" > /dev/null 2>&1
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && [[ $exit_code -ne 1 ]]; then
        echo "❌ First compilation failed with exit code $exit_code"
        return $exit_code
    fi
    
    # Run biber by default
    if [[ "$run_biber" == true ]]; then
        echo "Running biber..."
        biber "$basename" 2>&1 | grep -E "(ERROR|WARN)" || echo "✓ Biber completed"
    fi
    
    # Second compilation for cross-references
    echo "Running second pass..."
    pdflatex -interaction=nonstopmode "$texfile" > /dev/null 2>&1
    
    # Third compilation to ensure everything is resolved
    echo "Running third pass..."
    pdflatex -interaction=nonstopmode "$texfile" > /dev/null 2>&1
    
    # Clean up auxiliary files unless --keep is specified
    if [[ "$keep_aux" == false ]]; then
        echo "Cleaning auxiliary files..."
        find . -name "*.aux" -type f -delete 2>/dev/null
        rm -f "${basename}.log" "${basename}.out" "${basename}.toc" \
              "${basename}.lof" "${basename}.lot" "${basename}.bcf" \
              "${basename}.run.xml" "${basename}.blg" "${basename}.bbl" \
              "${basename}.fls" "${basename}.fdb_latexmk" \
              "${basename}.synctex.gz" 2>/dev/null
    fi
    
    # Show final status
    echo ""
    echo "=== Compilation Complete ==="
    if [[ -f "${basename}.pdf" ]]; then
        local size=$(ls -lh "${basename}.pdf" | awk '{print $5}')
        echo "✓ PDF generated: ${basename}.pdf ($size)"
    else
        echo "❌ PDF not generated"
        return 1
    fi
    
    if [[ "$keep_aux" == false ]]; then
        echo "✓ Auxiliary files cleaned"
    else
        echo "✓ Auxiliary files kept"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Weather (using wttr.in)
# ─────────────────────────────────────────────────────────────────────────────
weather() {
    local location="${1:-}"
    curl -s "wttr.in/${location}?format=3"
}

# ─────────────────────────────────────────────────────────────────────────────
# Chezmoi helpers
# ─────────────────────────────────────────────────────────────────────────────
# Edit chezmoi source and apply
czedit() {
    chezmoi edit "$@" && chezmoi apply
}

# ─────────────────────────────────────────────────────────────────────────────
# Slurm (HPC job scheduler)
# ─────────────────────────────────────────────────────────────────────────────

# Watch a specific job
swatch() {
    if [[ -z "$1" ]]; then
        echo "Usage: swatch <job_id>"
        return 1
    fi
    watch -n 5 "squeue -j $1"
}

# Show job details
sdetail() {
    if [[ -z "$1" ]]; then
        echo "Usage: sdetail <job_id>"
        return 1
    fi
    scontrol show job "$1"
}

# Show detailed job efficiency/resources
sjobinfo() {
    if [[ -z "$1" ]]; then
        echo "Usage: sjobinfo <job_id>"
        return 1
    fi
    echo "=== Job Details ==="
    scontrol show job "$1"
    echo ""
    echo "=== Resource Usage ==="
    sacct -j "$1" --format=JobID,JobName,Partition,AllocCPUS,State,ExitCode,Elapsed,MaxRSS,MaxVMSize,AveRSS
    echo ""
    if command -v seff &> /dev/null; then
        echo "=== Efficiency ==="
        seff "$1"
    fi
}

# Tail the output of the most recent job
stail() {
    local pattern="${1:-slurm-*.out}"
    local latest=$(ls -t $pattern 2>/dev/null | head -1)
    if [[ -n "$latest" ]]; then
        echo "Tailing: $latest"
        tail -f "$latest"
    else
        echo "No output files matching '$pattern' found"
    fi
}

# Show node info for a partition
snodes() {
    local partition="${1:-}"
    if [[ -n "$partition" ]]; then
        sinfo -p "$partition" -N -l
    else
        sinfo -N -l
    fi
}

# Quick interactive job (useful for debugging)
sinteract() {
    local nodes="${1:-1}"
    local time="${2:-01:00:00}"
    local partition="${3:-}"
    
    echo "Requesting interactive session: $nodes node(s), $time"
    if [[ -n "$partition" ]]; then
        srun -N "$nodes" -t "$time" -p "$partition" --pty bash
    else
        srun -N "$nodes" -t "$time" --pty bash
    fi
}

# Show recent job history
shist() {
    local days="${1:-7}"
    sacct -u "$USER" \
        --starttime="$(date -d "$days days ago" +%Y-%m-%d 2>/dev/null || date -v-${days}d +%Y-%m-%d)" \
        --format=JobID,JobName%20,Partition,State,ExitCode,Elapsed,Start,End \
        | head -50
}
