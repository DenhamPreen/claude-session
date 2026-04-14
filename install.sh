#!/usr/bin/env bash
# cproj installer — symlinks bin/cproj into a directory on your PATH.
set -euo pipefail

BIN_DIR="$(cd "$(dirname "$0")" && pwd)/bin"
TARGET_DIR="${CPROJ_INSTALL_DIR:-$HOME/.local/bin}"

for name in cproj cproj-title; do
  [ -f "$BIN_DIR/$name" ] || { echo "install: cannot find $BIN_DIR/$name" >&2; exit 1; }
done

mkdir -p "$TARGET_DIR"
for name in cproj cproj-title; do
  chmod +x "$BIN_DIR/$name"
  ln -sf "$BIN_DIR/$name" "$TARGET_DIR/$name"
  echo "Installed: $TARGET_DIR/$name -> $BIN_DIR/$name"
done

case ":$PATH:" in
  *":$TARGET_DIR:"*) ;;
  *) echo "Note: $TARGET_DIR is not on your PATH. Add this to your shell rc:"
     echo "  export PATH=\"$TARGET_DIR:\$PATH\"" ;;
esac

for dep in jq fzf claude; do
  command -v "$dep" >/dev/null || echo "Missing dependency: $dep"
done

echo
echo "Run:  cproj            # pick a session"
echo "      cproj -y         # resume with --dangerously-skip-permissions"
echo "      cproj envio      # filter sessions whose cwd contains 'envio'"
echo
echo "AI titles work out of the box (uses your local claude CLI auth)."
echo "For always-fresh titles, also run: ./install-hook.sh"
