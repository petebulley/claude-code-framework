#!/bin/bash
# link.sh — Symlink framework skills and agents into the global Claude directories
#
# Usage:
#   bash link.sh            # Link everything, report what changed
#   bash link.sh --quiet    # Only report if something changed
#
# Safe to run at any time. Existing links are left alone, new ones are created,
# and broken links pointing back at this framework are pruned.
#
# Exit codes:
#   0 — done (whether or not anything changed)
#   1 — could not write to the Claude directory

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
FRAMEWORK_DIR=$(dirname "$SCRIPT_DIR")
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

QUIET=false
if [[ "${1:-}" == "--quiet" ]]; then
  QUIET=true
fi

if ! mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" 2>/dev/null; then
  echo "LINK FAILED: cannot create $CLAUDE_DIR/skills and $CLAUDE_DIR/agents"
  exit 1
fi

ADDED=()
RELINKED=()
PRUNED=()

# Link one source path into a destination directory under its own basename.
# Uses an explicit destination and -n so an existing symlink is replaced rather
# than followed (GNU ln would otherwise nest the new link inside it).
link_into() {
  local src="$1" dest_dir="$2"
  local name dest
  name=$(basename "$src")
  dest="$dest_dir/$name"

  # Leave anything that is not a symlink alone — it is the user's own file.
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    return 0
  fi

  local existing=""
  if [[ -L "$dest" ]]; then
    existing=$(readlink "$dest")
  fi

  if [[ "$existing" == "$src" ]]; then
    return 0
  fi

  ln -sfn "$src" "$dest"
  if [[ -z "$existing" ]]; then
    ADDED+=("$name")
  else
    # Was pointing somewhere else — a moved framework, or a name shared with
    # another skill source. Repointed, but say so rather than doing it quietly.
    RELINKED+=("$name")
  fi
}

for skill in "$FRAMEWORK_DIR"/.claude/skills/*/; do
  [[ -d "$skill" ]] || continue
  link_into "${skill%/}" "$CLAUDE_DIR/skills"
done

for agent in "$FRAMEWORK_DIR"/.claude/agents/*.md; do
  [[ -f "$agent" ]] || continue
  link_into "$agent" "$CLAUDE_DIR/agents"
done

# Prune broken links that point back into this framework — skills or agents
# that have been renamed or removed upstream.
for dir in "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents"; do
  for entry in "$dir"/*; do
    [[ -L "$entry" ]] || continue
    target=$(readlink "$entry")
    [[ "$target" == "$FRAMEWORK_DIR"/* ]] || continue
    [[ -e "$target" ]] && continue
    rm -f "$entry"
    PRUNED+=("$(basename "$entry")")
  done
done

if [[ ${#ADDED[@]} -eq 0 && ${#RELINKED[@]} -eq 0 && ${#PRUNED[@]} -eq 0 ]]; then
  if [[ "$QUIET" == false ]]; then
    echo "LINKED: everything already up to date."
  fi
  exit 0
fi

if [[ ${#ADDED[@]} -gt 0 ]]; then
  echo "LINKED: ${#ADDED[@]} new skill(s)/agent(s) available — ${ADDED[*]}"
fi

if [[ ${#RELINKED[@]} -gt 0 ]]; then
  echo "RELINKED: ${#RELINKED[@]} now point at this framework — ${RELINKED[*]}"
fi

if [[ ${#PRUNED[@]} -gt 0 ]]; then
  echo "PRUNED: ${#PRUNED[@]} removed upstream — ${PRUNED[*]}"
fi

exit 0
