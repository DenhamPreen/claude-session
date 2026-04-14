#!/usr/bin/env bash
# Opt-in: add a Claude Code Stop hook that refreshes claude-session titles as sessions grow.
# Uses ~/.claude/settings.json. Idempotent — re-running is safe.
set -euo pipefail

command -v jq >/dev/null || { echo "install-hook: jq required" >&2; exit 1; }

TITLE_BIN="$(cd "$(dirname "$0")" && pwd)/bin/claude-session-title"
[ -x "$TITLE_BIN" ] || { echo "install-hook: $TITLE_BIN not executable" >&2; exit 1; }

SETTINGS="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"
mkdir -p "$(dirname "$SETTINGS")"
[ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"

# Back up once per install.
cp "$SETTINGS" "$SETTINGS.claude-session.bak.$(date +%s)"

CMD="$TITLE_BIN"

tmp=$(mktemp)
jq --arg cmd "$CMD" '
  .hooks //= {}
  | .hooks.Stop //= []
  | ( .hooks.Stop
      | map(select(
          (.hooks // []) | map(.command // "") | any(. == $cmd) | not
        )) ) as $clean
  | .hooks.Stop = ($clean + [{
      matcher: "",
      hooks: [{ type: "command", command: $cmd }]
    }])
' "$SETTINGS" > "$tmp"

mv "$tmp" "$SETTINGS"

echo "Stop hook registered in $SETTINGS"
echo "  command: $CMD"
echo
echo "Titles will now refresh automatically at the end of each Claude turn,"
echo "using your local Claude CLI subscription (no API key needed)."
echo
echo "To uninstall, edit $SETTINGS and remove the matching hooks.Stop entry."
