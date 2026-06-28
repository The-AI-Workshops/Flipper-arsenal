#!/usr/bin/env bash
# Flipper Zero community repo updater
# Run: bash update_all.sh
# Auto-update: see cron config (runs daily)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG="$REPO_ROOT/update_all.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() { echo "[$TIMESTAMP] $*" | tee -a "$LOG"; }

cd "$REPO_ROOT"

log "=== Flipper Zero repo update started ==="

# 1. Pull main repo
log "Pulling main repo (UberGuidoZ/Flipper)..."
git pull --ff-only 2>&1 | tee -a "$LOG" || log "WARNING: main pull failed (local changes?)"

# 2. Update all git submodules
log "Updating git submodules..."
git submodule update --init --recursive --remote 2>&1 | tee -a "$LOG" || log "WARNING: some submodules failed"

# 3. Update standalone cloned repos
update_repo() {
    local path="$1"
    local url="$2"
    local name="$3"

    if [ -d "$path/.git" ]; then
        log "Pulling $name..."
        git -C "$path" pull --ff-only 2>&1 | tee -a "$LOG" || log "WARNING: $name pull failed"
    elif [ -d "$path" ] && [ -z "$(ls -A "$path")" ]; then
        log "Cloning $name (first time)..."
        rmdir "$path"
        git clone "$url" "$path" 2>&1 | tee -a "$LOG"
    elif [ ! -d "$path" ]; then
        log "Cloning $name (first time)..."
        git clone "$url" "$path" 2>&1 | tee -a "$LOG"
    else
        log "Skipping $name (not a git repo, may have files)"
    fi
}

update_repo "$REPO_ROOT/Applications/Momentum-Apps"   "https://github.com/Next-Flip/Momentum-Apps.git"                 "Next-Flip/Momentum-Apps"
update_repo "$REPO_ROOT/Dev/flipper-zero-tutorials"   "https://github.com/jamisonderek/flipper-zero-tutorials.git"     "jamisonderek/tutorials"
update_repo "$REPO_ROOT/Resources/awesome-flipperzero""https://github.com/djsime1/awesome-flipperzero.git"             "djsime1/awesome-flipperzero"
update_repo "$REPO_ROOT/Sub-GHz/Community-DB"         "https://github.com/Zero-Sploit/FlipperZero-Subghz-DB.git"      "Zero-Sploit/SubGHz-DB"
update_repo "$REPO_ROOT/Sub-GHz/Bruteforce"           "https://github.com/tobiabocchi/flipperzero-bruteforce.git"      "tobiabocchi/bruteforce"

log "=== Update complete ==="
echo ""
echo "Log: $LOG"
