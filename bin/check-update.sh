#!/bin/bash
# check-update.sh — Check if the framework has updates available
#
# Usage:
#   bash check-update.sh          # Check for updates (silent if up to date)
#   bash check-update.sh --pull   # Check and pull updates if available
#
# Exit codes:
#   0 — up to date or updated successfully
#   1 — updates available (without --pull)
#   2 — update failed

set -euo pipefail

# Resolve framework root from this script's location
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
FRAMEWORK_DIR=$(dirname "$SCRIPT_DIR")

PULL=false
if [[ "${1:-}" == "--pull" ]]; then
  PULL=true
fi

# Bail silently if not a git repo
if ! git -C "$FRAMEWORK_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

# Bail silently if no remote configured
if ! git -C "$FRAMEWORK_DIR" remote get-url origin >/dev/null 2>&1; then
  exit 0
fi

# Fetch quietly — bail silently if offline
if ! git -C "$FRAMEWORK_DIR" fetch origin main --quiet 2>/dev/null; then
  exit 0
fi

LOCAL=$(git -C "$FRAMEWORK_DIR" rev-parse HEAD 2>/dev/null)
REMOTE=$(git -C "$FRAMEWORK_DIR" rev-parse origin/main 2>/dev/null)

# Up to date — exit silently
if [[ "$LOCAL" == "$REMOTE" ]]; then
  exit 0
fi

# Count commits behind
BEHIND=$(git -C "$FRAMEWORK_DIR" rev-list HEAD..origin/main --count 2>/dev/null)

# Get summary of what changed
CHANGES=$(git -C "$FRAMEWORK_DIR" log HEAD..origin/main --oneline --no-decorate 2>/dev/null)

if [[ "$PULL" == true ]]; then
  # Check for dirty working tree
  if ! git -C "$FRAMEWORK_DIR" diff --quiet 2>/dev/null || ! git -C "$FRAMEWORK_DIR" diff --cached --quiet 2>/dev/null; then
    echo "UPDATE FAILED: Framework has local changes. Please commit or stash them first."
    echo "  cd $FRAMEWORK_DIR && git stash"
    exit 2
  fi

  if git -C "$FRAMEWORK_DIR" pull origin main --quiet 2>/dev/null; then
    echo "UPDATED: Framework updated ($BEHIND new commit(s))."
    echo ""
    echo "$CHANGES"

    # A pull can add or remove skills and agents, which git cannot symlink into
    # the global Claude directories on its own. Reconcile them, quietly unless
    # something actually changed.
    if [[ -f "$SCRIPT_DIR/link.sh" ]]; then
      LINK_OUTPUT=$(bash "$SCRIPT_DIR/link.sh" --quiet 2>/dev/null) || true
      if [[ -n "$LINK_OUTPUT" ]]; then
        echo ""
        echo "$LINK_OUTPUT"
        echo ""
        echo "Restart Claude Code to pick up newly linked skills."
      fi
    fi
  else
    echo "UPDATE FAILED: git pull failed. Run manually:"
    echo "  cd $FRAMEWORK_DIR && git pull origin main"
    exit 2
  fi
else
  echo "UPDATE AVAILABLE: Framework is $BEHIND commit(s) behind."
  echo ""
  echo "$CHANGES"
  exit 1
fi
