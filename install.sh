#!/usr/bin/env bash
# Installs this fleet's skills, instructions and plugins for the current user. Idempotent: run it
# after every pull. Each scope folder (universal/, claude/, …) lists in its `.targets` file the
# agents that get its skills; every skill is linked, not copied, so a pull updates it in place.
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

# Skills, by scope.
for scope in "$fleet"/*/; do
  scope="${scope%/}"
  [ -f "$scope/.targets" ] || continue
  for target in $(cat "$scope/.targets"); do
    dir="$(target_dir "$target")"
    for skill in "$scope"/*/; do
      skill="${skill%/}"
      link "$skill" "$dir/$(basename "$skill")"
    done
  done
done

# Skills from other people's repos (upstream.txt), fetched at the pinned commit rather than
# copied in: a skill only changes here when its commit is bumped.
cache="${XDG_CACHE_HOME:-$HOME/.cache}/fleet/upstream"
wanted=()
while read -r targets repo commit path; do
  [ -z "${targets:-}" ] || [[ "$targets" == \#* ]] && continue
  checkout="$cache/$repo"
  if [ ! -d "$checkout/.git" ]; then
    mkdir -p "$checkout"
    git -C "$checkout" init -q
    git -C "$checkout" remote add origin "https://github.com/$repo.git"
  fi
  if [ "$(git -C "$checkout" rev-parse -q --verify HEAD 2>/dev/null)" != "$commit" ]; then
    git -C "$checkout" fetch -q --depth 1 origin "$commit"
    git -C "$checkout" checkout -q --detach "$commit"
  fi
  [ -d "$checkout/$path" ] || { echo "upstream: $repo has no $path at $commit" >&2; continue; }
  for target in ${targets//,/ }; do
    dest="$(target_dir "$target")/$(basename "$path")"
    link "$checkout/$path" "$dest"
    wanted+=("$dest")
  done
done <"$fleet/upstream.txt"

# A skill removed from the fleet or from upstream.txt loses its link.
for target in claude codex agents; do
  dir="$(target_dir "$target")"
  [ -d "$dir" ] || continue
  for entry in "$dir"/*; do
    [ -L "$entry" ] || continue
    to="$(readlink "$entry")"
    if [[ "$to" == "$fleet"/* && ! -e "$entry" ]] ||
      [[ "$to" == "$cache"/* && ! " ${wanted[*]} " == *" $entry "* ]]; then
      rm "$entry"
      echo "removed $entry"
    fi
  done
done

# Global instructions: one file for every agent.
link "$fleet/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$fleet/AGENTS.md" "$HOME/.claude/CLAUDE.md"

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
