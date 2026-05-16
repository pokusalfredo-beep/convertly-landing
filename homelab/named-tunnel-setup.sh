#!/usr/bin/env bash
# One-shot setup for a Cloudflare *named* tunnel.
# Replaces the ephemeral quick-tunnel: the hostname stays stable across
# restarts, so the landing's curl example (https://convertly.io/v1/...)
# keeps working even after WSL sleeps.
#
# Prereqs:
#   - cloudflared installed (https://pkg.cloudflare.com/index.html)
#   - jq installed
#   - A domain on a Cloudflare-managed zone (TODO: register convertly.io)
#
# Usage: bash homelab/named-tunnel-setup.sh

set -euo pipefail

TUNNEL_NAME="convertly-api"
HOSTNAME="api.convertly.io"   # TODO: change if final domain differs
LOCAL_PORT="${CONVERTLY_PORT:-8000}"

# 1. Auth (opens browser; pick the zone that owns $HOSTNAME)
[ -f "$HOME/.cloudflared/cert.pem" ] || cloudflared tunnel login

# 2. Create the tunnel (idempotent: skip if already exists)
if ! cloudflared tunnel list -o json | jq -e ".[] | select(.name==\"$TUNNEL_NAME\")" >/dev/null; then
  cloudflared tunnel create "$TUNNEL_NAME"
fi

TUNNEL_ID=$(cloudflared tunnel list -o json | jq -r ".[] | select(.name==\"$TUNNEL_NAME\") | .id")

# 3. Point the DNS record at the tunnel
cloudflared tunnel route dns "$TUNNEL_NAME" "$HOSTNAME"

# 4. Write the ingress config
mkdir -p "$HOME/.cloudflared"
cat > "$HOME/.cloudflared/config.yml" <<EOF
tunnel: $TUNNEL_ID
credentials-file: $HOME/.cloudflared/$TUNNEL_ID.json
ingress:
  - hostname: $HOSTNAME
    service: http://localhost:$LOCAL_PORT
  - service: http_status:404
EOF

# 5. Install as a systemd service so it auto-starts and reconnects.
sudo cloudflared service install

echo "Named tunnel '$TUNNEL_NAME' routing $HOSTNAME -> localhost:$LOCAL_PORT"
echo "Verify: curl -I https://$HOSTNAME/healthz"
