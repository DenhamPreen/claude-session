#!/usr/bin/env bash
# claude-session installer — symlinks bin/claude-session into a directory on your PATH.
set -euo pipefail

BIN_DIR="$(cd "$(dirname "$0")" && pwd)/bin"
TARGET_DIR="${CLAUDE_SESSION_INSTALL_DIR:-$HOME/.local/bin}"

for name in claude-session claude-session-title; do
  [ -f "$BIN_DIR/$name" ] || { echo "install: cannot find $BIN_DIR/$name" >&2; exit 1; }
done

mkdir -p "$TARGET_DIR"
for name in claude-session claude-session-title; do
  chmod +x "$BIN_DIR/$name"
  ln -sf "$BIN_DIR/$name" "$TARGET_DIR/$name"
  echo "Installed: $TARGET_DIR/$name -> $BIN_DIR/$name"
done

# Optional `cs` shorthand. Only install if the slot is free or already ours,
# so we never clobber a user's existing `cs` binary or alias.
SHORTHAND="$TARGET_DIR/cs"
WANT_TARGET="$BIN_DIR/claude-session"
if [ -L "$SHORTHAND" ] && [ "$(readlink "$SHORTHAND")" = "$WANT_TARGET" ]; then
  echo "Shorthand: $SHORTHAND -> $WANT_TARGET (already installed)"
elif [ -e "$SHORTHAND" ] || [ -L "$SHORTHAND" ]; then
  echo "Note: '$SHORTHAND' already exists and points elsewhere — skipping 'cs' shorthand."
  echo "      To install manually: ln -sf '$WANT_TARGET' '$SHORTHAND'"
else
  ln -s "$WANT_TARGET" "$SHORTHAND"
  echo "Installed shorthand: $SHORTHAND -> $WANT_TARGET"
fi

case ":$PATH:" in
  *":$TARGET_DIR:"*) ;;
  *) echo "Note: $TARGET_DIR is not on your PATH. Add this to your shell rc:"
     echo "  export PATH=\"$TARGET_DIR:\$PATH\"" ;;
esac

for dep in jq fzf claude; do
  command -v "$dep" >/dev/null || echo "Missing dependency: $dep"
done

echo
echo "Run:  claude-session            # pick a session  (or shorthand: cs)"
echo "      cs -y                     # resume with --dangerously-skip-permissions"
echo "      cs envio                  # filter sessions whose cwd contains 'envio'"
echo
echo "AI titles work out of the box (uses your local claude CLI auth)."
echo "For always-fresh titles, also run: ./install-hook.sh"
