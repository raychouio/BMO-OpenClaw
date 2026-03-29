#!/bin/bash
# Auto-backup ~/.openclaw to GitHub if there are changes

set -e

echo "=== $(date '+%Y-%m-%d %H:%M UTC') ==="

# --- Backup ~/.openclaw (main config & memories) ---
cd "$HOME/.openclaw"

# Pull latest; on merge conflicts, prefer origin/main (-X theirs)
git pull -X theirs origin main

# Check for changes (excluding workspace since it has its own git)
if git diff --quiet && git diff --cached --quiet && ! git status --porcelain | grep -v "^??.*workspace" | grep -q .; then
    echo "No changes in ~/.openclaw"
else
    git add -A
    git commit -m "Auto-backup $(date '+%Y-%m-%d %H:%M UTC')"
    git push origin main
    echo "~/.openclaw backed up"
fi

# --- Backup ~/projects/notes (knowledge base) ---
if [ -d "$HOME/projects/notes/.git" ]; then
    cd "$HOME/projects/notes"

    # Pull latest; on merge conflicts, prefer origin/main (-X theirs)
    git pull -X theirs origin main

    if ! git diff --quiet || ! git diff --cached --quiet || git status --porcelain | grep -q .; then
        git add -A
        git commit -m "Auto-backup $(date '+%Y-%m-%d %H:%M UTC')"
        git push origin main
        echo "~/projects/notes backed up"
    else
        echo "No changes in ~/projects/notes"
    fi
fi

echo "=== Backup complete ==="
