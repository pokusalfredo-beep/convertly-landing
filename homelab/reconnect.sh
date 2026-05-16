#!/usr/bin/env bash
# Band-aid: bring tailscale + cloudflared quick-tunnel back up after WSL sleep.
# Use this until named-tunnel-setup.sh is run (then the URL stays stable and
# this script becomes unnecessary).
#
# Usage: bash homelab/reconnect.sh
# Prints the new https://*.trycloudflare.com URL on success.

set -euo pipefail

LOCAL_PORT="${CONVERTLY_PORT:-8000}"  # TODO: confirm Convertly API port

sudo tailscale up --reset

pkill -f "cloudflared tunnel --url" 2>/dev/null || true

LOG=$(mktemp)
nohup cloudflared tunnel --url "http://localhost:${LOCAL_PORT}" --no-autoupdate >"$LOG" 2>&1 &

# Quick tunnels print the URL within ~3s of starting.
for _ in 1 2 3 4 5 6 7 8 9 10; do
  URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' "$LOG" | head -1 || true)
  [ -n "$URL" ] && break
  sleep 1
done

if [ -z "${URL:-}" ]; then
  echo "cloudflared did not report a URL within 10s. Check: $LOG" >&2
  exit 1
fi

echo "$URL"
