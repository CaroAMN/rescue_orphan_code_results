#!/bin/bash
# =============================================================================
# run_scaling.sh
# Sequential scaling experiment for MATLAB pipeline
#
# Measures how total runtime scales when processing increasing numbers of
# samples (1 to 10) sequentially. Each configuration runs all samples one
# after another, with each sample running 2 monitored calls:
#   1. NM_config('process', 'sampleXX', true)  -> intensity + align + stitch
#   2. NM_config('count',   'sampleXX', true)  -> quantification
#
# This mirrors real-world sequential MATLAB usage and provides a baseline
# for comparison against Nextflow's native parallelised orchestration.
#
# Output structure:
#   BASE_OUTDIR/
#     scaling/
#       n01_samples/
#         sample01/
#           process_pipeline/   <- monitor output for steps 1-3
#           process_count/      <- monitor output for count
#       n02_samples/
#         sample01/
#           process_pipeline/
#           process_count/
#         sample02/
#           process_pipeline/
#           process_count/
#       ...
#       n10_samples/
#         ...
#     scaling_run.log           <- full timestamped log
#     scaling_summary.csv       <- total runtime per n_samples configuration
# =============================================================================

# --- Configuration -----------------------------------------------------------
BASE_OUTDIR="/mnt/ssd/performance_benchmark"
MONITOR_SCRIPT="./monitoring_script.sh"
MAX_SAMPLES=10

# Directory where MATLAB writes its pipeline outputs (hardcoded inside MATLAB).
# This directory is deleted after each n_samples configuration to prevent
# MATLAB from detecting existing outputs and skipping recomputation.
# WARNING: only this exact directory is deleted — nothing above it.
PIPELINE_OUTDIR="/mnt/ssd/performance_benchmark/pipeout"

# --- Logging -----------------------------------------------------------------
LOG_FILE=""

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

log_separator() {
    local line="$(printf '=%.0s' {1..60})"
    echo "$line"
    echo "$line" >> "$LOG_FILE"
}

# --- Signal handling ---------------------------------------------------------
cleanup() {
    echo ""
    log "Scaling experiment interrupted — cleaning up..."
    pkill -f monitoring_script.sh 2>/dev/null || true
    pkill -f matlab               2>/dev/null || true
    log "Stopped. Partial results saved in: $BASE_OUTDIR/scaling"
    exit 1
}
trap cleanup INT TERM

# --- Safe pipeline output cleanup --------------------------------------------
# Deletes ONLY the PIPELINE_OUTDIR directory and its contents.
# Multiple safeguards prevent accidental deletion of parent directories:
#   1. PIPELINE_OUTDIR must be non-empty
#   2. PIPELINE_OUTDIR must be an absolute path
#   3. PIPELINE_OUTDIR must not equal BASE_OUTDIR or any parent of it
#   4. The resolved path must start with BASE_OUTDIR (must be a child)
#   5. Requires explicit confirmation that the path ends with /pipeout
safe_cleanup_pipeout() {
    local target="$PIPELINE_OUTDIR"

    # Guard 1: must be non-empty
    if [ -z "$target" ]; then
        log "ERROR: PIPELINE_OUTDIR is empty — refusing to delete anything."
        exit 1
    fi

    # Guard 2: must be absolute path
    if [[ "$target" != /* ]]; then
        log "ERROR: PIPELINE_OUTDIR is not an absolute path: $target"
        exit 1
    fi

    # Guard 3: must not equal BASE_OUTDIR
    if [ "$target" = "$BASE_OUTDIR" ]; then
        log "ERROR: PIPELINE_OUTDIR equals BASE_OUTDIR — refusing to delete."
        exit 1
    fi

    # Guard 4: must be a direct child of BASE_OUTDIR (no going above)
    local expected_parent="$BASE_OUTDIR"
    local actual_parent
    actual_parent=$(dirname "$target")
    if [ "$actual_parent" != "$expected_parent" ]; then
        log "ERROR: PIPELINE_OUTDIR ($target) is not a direct child of BASE_OUTDIR ($BASE_OUTDIR) — refusing to delete."
        exit 1
    fi

    # Guard 5: must end with /pipeout
    if [[ "$target" != */pipeout ]]; then
        log "ERROR: PIPELINE_OUTDIR does not end with /pipeout — refusing to delete."
        log "       Target was: $target"
        exit 1
    fi

    # All guards passed — safe to delete
    if [ -d "$target" ]; then
        log "Cleaning up pipeline output dir: $target"
        rm -rf "$target"
        log "Cleanup complete."
    else
        log "Pipeline output dir does not exist, nothing to clean: $target"
    fi
}

# --- Preflight checks --------------------------------------------------------
preflight_checks() {
    local errors=0

    if [ ! -f "$MONITOR_SCRIPT" ]; then
        echo "ERROR: monitoring_script.sh not found at: $MONITOR_SCRIPT"
        errors=$((errors + 1))
    fi

    if [ ! -x "$MONITOR_SCRIPT" ]; then
        echo "ERROR: monitoring_script.sh is not executable. Run: chmod +x $MONITOR_SCRIPT"
        errors=$((errors + 1))
    fi

    if [ $errors -gt 0 ]; then
        echo "Aborting: $errors preflight check(s) failed."
        exit 1
    fi
}

# --- Run one sample ----------------------------------------------------------
# Runs both monitored calls for a single sample and returns total runtime in ms
run_sample() {
    local sample=$1        # e.g. "sample01"
    local sample_outdir=$2 # e.g. .../n03_samples/sample01

    local pipeline_outdir="$sample_outdir/process_pipeline"
    local count_outdir="$sample_outdir/process_count"

    log "    Sample $sample: running pipeline (intensity+align+stitch)..."
    bash "$MONITOR_SCRIPT" \
        -c "NM_config('process','$sample',true)" \
        -o "$pipeline_outdir"

    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: pipeline process failed for $sample (exit code $exit_code)"
        exit 1
    fi

    log "    Sample $sample: running count..."
    bash "$MONITOR_SCRIPT" \
        -c "NM_config('count','$sample',true)" \
        -o "$count_outdir"

    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log "ERROR: count process failed for $sample (exit code $exit_code)"
        exit 1
    fi

    log "    Sample $sample: complete."
}

# --- Extract realtime from trace file ----------------------------------------
get_realtime_ms() {
    local trace_file=$1
    grep '^realtime=' "$trace_file" | cut -d= -f2
}

# --- Run one n_samples configuration -----------------------------------------
run_configuration() {
    local n=$1
    local config_label=$(printf 'n%02d_samples' $n)
    local config_outdir="$BASE_OUTDIR/scaling/$config_label"

    log_separator
    log "Configuration: $n sample(s)"
    log "Output dir: $config_outdir"
    log_separator

    mkdir -p "$config_outdir"

    local config_start=$(date +%s%3N)

    # Run all n samples sequentially
    for i in $(seq 1 $n); do
        local sample=$(printf 'sample%02d' $i)
        local sample_outdir="$config_outdir/$sample"
        mkdir -p "$sample_outdir"

        log "  Processing $sample ($i of $n)..."
        run_sample "$sample" "$sample_outdir"
    done

    local config_end=$(date +%s%3N)
    local total_wall_ms=$(( config_end - config_start ))

    # Also sum individual process runtimes from trace files for reference
    local sum_process_ms=0
    for i in $(seq 1 $n); do
        local sample=$(printf 'sample%02d' $i)

        local pipeline_trace="$config_outdir/$sample/process_pipeline/matlab_trace.log"
        local count_trace="$config_outdir/$sample/process_count/matlab_trace.log"

        local pipeline_rt=0
        local count_rt=0

        [ -f "$pipeline_trace" ] && pipeline_rt=$(get_realtime_ms "$pipeline_trace")
        [ -f "$count_trace"    ] && count_rt=$(get_realtime_ms "$count_trace")

        sum_process_ms=$(( sum_process_ms + ${pipeline_rt:-0} + ${count_rt:-0} ))
    done

    # Convert to hours for logging
    local total_wall_h=$(awk "BEGIN {printf '%.4f', $total_wall_ms/3600000}")
    local sum_process_h=$(awk "BEGIN {printf '%.4f', $sum_process_ms/3600000}")

    log "Configuration $n samples complete."
    log "  Total wall time:       ${total_wall_ms} ms (${total_wall_h} h)"
    log "  Sum of process times:  ${sum_process_ms} ms (${sum_process_h} h)"

    # Append to summary CSV
    echo "$n,$total_wall_ms,$total_wall_h,$sum_process_ms,$sum_process_h" \
        >> "$BASE_OUTDIR/scaling_summary.csv"

    # Delete MATLAB pipeline outputs before next configuration
    # so MATLAB does not detect existing files and skip recomputation
    safe_cleanup_pipeout
}

# --- Main --------------------------------------------------------------------
main() {
    while getopts "m:o:h" opt; do
        case $opt in
            m) MAX_SAMPLES="$OPTARG" ;;
            o) BASE_OUTDIR="$OPTARG" ;;
            h)
                echo "Usage: $0 [-m max_samples] [-o output_dir]"
                echo "  -m  Maximum number of samples to test (default: 10)"
                echo "  -o  Base output directory (default: /mnt/ssd/performance_benchmark)"
                exit 0
                ;;
        esac
    done

    # Set up directories and logging
    mkdir -p "$BASE_OUTDIR/scaling"
    LOG_FILE="$BASE_OUTDIR/scaling_run.log"
    touch "$LOG_FILE"

    # Write CSV header
    echo "n_samples,total_wall_ms,total_wall_h,sum_process_ms,sum_process_h" \
        > "$BASE_OUTDIR/scaling_summary.csv"

    log_separator
    log "Scaling experiment started"
    log "Max samples:    $MAX_SAMPLES"
    log "Base output:    $BASE_OUTDIR"
    log "Monitor script: $MONITOR_SCRIPT"
    log_separator

    preflight_checks

    # Run configurations 1 sample up to MAX_SAMPLES
    for n in $(seq 1 $MAX_SAMPLES); do
        run_configuration $n
    done

    log_separator
    log "Scaling experiment complete."
    log "Summary CSV: $BASE_OUTDIR/scaling_summary.csv"
    log_separator

    # Print summary table to terminal
    echo ""
    echo "===== Scaling Summary ====="
    echo "n_samples | total_wall_h | sum_process_h"
    echo "----------|--------------|---------------"
    tail -n +2 "$BASE_OUTDIR/scaling_summary.csv" | while IFS=, read n twms twh spms sph; do
        printf "%-9s | %-12s | %s\n" "$n" "$twh" "$sph"
    done
}

main "$@"