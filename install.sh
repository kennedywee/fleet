#!/usr/bin/env bash
# Installs this fleet's skills, upstream skills, instructions and plugins for the current user.
# Idempotent: run it after every pull. Each top-level folder with a SKILL.md is a skill, linked
# into Claude Code, Codex and Antigravity. Links, not copies, so a pull updates every skill in
# place.
#
#   ./install.sh            link everything, install missing plugins
#   ./install.sh --force    also replace skill folders that are real folders, not our links
set -euo pipefail

fleet="$(cd "$(dirname "$0")" && pwd)"
force=0
[ "${1:-}" = "--force" ] && force=1

target_dir() {
  case "$1" in
    claude) echo "$HOME/.claude/skills" ;;
    codex) echo "$HOME/.codex/skills" ;;
    agents) echo "$HOME/.agents/skills" ;;
    antigravity) echo "$HOME/.gemini/config/skills" ;;
    *) echo "unknown target '$1'" >&2; return 1 ;;
  esac
}

# Points `dest` at `src`. A link of ours is replaced; anything else is kept (or moved aside with
# --force), so running this on a computer with its own skills changes nothing it did not make.
link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ]; then
    [ "$(readlink "$dest")" = "$src" ] && return 0
    rm "$dest"
  elif [ -e "$dest" ]; then
    if [ "$force" = 1 ]; then
      mv "$dest" "$dest.bak.$(date +%s)"
    else
      echo "skip $dest: not a fleet link (--force moves it aside)" >&2
      return 0
    fi
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  echo "linked $dest"
}

# Skills: every top-level folder with a SKILL.md, for Claude Code, Codex and Antigravity.
for skill in "$fleet"/*/; do
  skill="${skill%/}"
  [ -f "$skill/SKILL.md" ] || continue
  for target in claude codex antigravity; do
    link "$skill" "$(target_dir "$target")/$(basename "$skill")"
  done
done

# A skill removed from the fleet: its link now points at nothing.
for target in claude codex agents antigravity; do
  dir="$(target_dir "$target")"
  [ -d "$dir" ] || continue
  for entry in "$dir"/*; do
    if [ -L "$entry" ] && [[ "$(readlink "$entry")" == "$fleet"/* ]] && [ ! -e "$entry" ]; then
      rm "$entry"
      echo "removed $entry"
    fi
  done
done

# Global instructions: one file for every agent.
link "$fleet/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$fleet/AGENTS.md" "$HOME/.claude/CLAUDE.md"

# Upstream skills: `source skill` per line, installed with `npx skills` and updated upstream.
# One copy goes to ~/.agents/skills, which Codex reads; ~/.claude/skills gets a link to it.
# Antigravity reads ~/.gemini/config/skills. npx reads no input, so the loop keeps every line.
if command -v npx >/dev/null 2>&1; then
  while read -r source skill; do
    [ -z "${source:-}" ] || [[ "$source" == \#* ]] && continue
    [ -e "$HOME/.agents/skills/$skill" ] && [ -e "$HOME/.claude/skills/$skill" ] &&
      [ -e "$(target_dir antigravity)/$skill" ] && continue
    npx -y skills add "$source" --skill "$skill" -g -a claude-code codex antigravity -y \
      </dev/null && echo "installed $skill"
  done <"$fleet/skills.txt"
else
  echo "npx not found: upstream skills skipped" >&2
fi

# Claude Code plugins: `plugin@marketplace` per line; marketplaces.txt says where each one is.
if command -v claude >/dev/null 2>&1; then
  installed="$(claude plugin list 2>/dev/null || true)"
  known="$(claude plugin marketplace list 2>/dev/null || true)"
  while read -r name source; do
    [ -z "${name:-}" ] || [[ "$name" == \#* ]] && continue
    grep -q "$name" <<<"$known" || claude plugin marketplace add "$source"
  done <"$fleet/marketplaces.txt"
  while read -r plugin; do
    [ -z "${plugin:-}" ] || [[ "$plugin" == \#* ]] && continue
    grep -q "${plugin%@*}" <<<"$installed" && continue
    claude plugin install --scope user "$plugin" && echo "installed $plugin"
  done <"$fleet/plugins.txt"
else
  echo "claude not found: plugins skipped" >&2
fi
