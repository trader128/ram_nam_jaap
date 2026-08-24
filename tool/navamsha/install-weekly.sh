#!/bin/zsh
# Installs a weekly LaunchAgent that refreshes Ujjain panchang every Monday at 6:00.
# Requires tool/navamsha/.env with NAVAMSHA_API_KEY and GOOGLE_APPLICATION_CREDENTIALS.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ENV_FILE="$ROOT/tool/navamsha/.env"
NODE="$(command -v node)"
LABEL="com.bhakti.panchang-sync"
PLIST="$HOME/Library/LaunchAgents/${LABEL}.plist"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Create $ENV_FILE with:"
  echo "  NAVAMSHA_API_KEY=…"
  echo "  GOOGLE_APPLICATION_CREDENTIALS=$HOME/Downloads/bhakti-sawarun-firebase-adminsdk-….json"
  exit 1
fi

mkdir -p "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>
  <key>WorkingDirectory</key>
  <string>${ROOT}/tool/navamsha</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/zsh</string>
    <string>-lc</string>
    <string>set -a; source "${ENV_FILE}"; set +a; "${NODE}" "${ROOT}/tool/navamsha/sync.mjs"</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Weekday</key>
    <integer>1</integer>
    <key>Hour</key>
    <integer>6</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>${HOME}/Library/Logs/bhakti-panchang-sync.log</string>
  <key>StandardErrorPath</key>
  <string>${HOME}/Library/Logs/bhakti-panchang-sync.log</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
echo "Weekly panchang sync installed (Monday 6:00)."
echo "Log: $HOME/Library/Logs/bhakti-panchang-sync.log"
echo "Run once now: launchctl kickstart -k gui/$(id -u)/${LABEL}"
