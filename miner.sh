#!/data/data/com.termux/files/usr/bin/bash
set -e

INBOX="inbox"
TOKENS="tokens"
TICKETS="tickets"
LEDGER="LEDGER.md"

echo "[∞] Image token miner online"

for IMG in "$INBOX"/*; do
  [ -f "$IMG" ] || continue

  NAME=$(basename "$IMG")
  HASH=$(sha256sum "$IMG" | awk '{print $1}')
  SIZE=$(stat -c%s "$IMG")
  TYPE=$(file --mime-type "$IMG" | awk '{print $2}')

  TS=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

  # deterministic acceptance rules
  ACCEPT=1
  REASON=""

  if [[ ! "$TYPE" =~ image/ ]]; then
    ACCEPT=0
    REASON="not_an_image"
  elif [ "$SIZE" -lt 5000 ]; then
    ACCEPT=0
    REASON="image_too_small"
  fi

  if [ "$ACCEPT" -eq 1 ]; then
    TOKEN_FILE="$TOKENS/token_$HASH.json"

    cat << JSON > "$TOKEN_FILE"
{
  "type": "image_token",
  "status": "accepted",
  "timestamp": "$TS",
  "image_name": "$NAME",
  "mime": "$TYPE",
  "size_bytes": $SIZE,
  "sha256": "$HASH",
  "token_id": "🧱🧱🧱",
  "token_value": "🧱",
  "token_class": "🟪 assimilation",
  "notes": "Image accepted as research surface"
}
JSON

    echo >> "$LEDGER"
    echo "## TOKEN $TS" >> "$LEDGER"
    echo "- Image: $NAME" >> "$LEDGER"
    echo "- Hash: $HASH" >> "$LEDGER"
    echo "- Status: ACCEPTED" >> "$LEDGER"

    mv "$IMG" "$TOKENS/"

  else
    TICKET_FILE="$TICKETS/ticket_$HASH.json"

    cat << JSON > "$TICKET_FILE"
{
  "type": "image_ticket",
  "status": "rejected",
  "timestamp": "$TS",
  "image_name": "$NAME",
  "mime": "$TYPE",
  "size_bytes": $SIZE,
  "sha256": "$HASH",
  "reason": "$REASON",
  "ticket_id": "🎟️",
  "notes": "Image rejected but logged"
}
JSON

    echo >> "$LEDGER"
    echo "## TICKET $TS" >> "$LEDGER"
    echo "- Image: $NAME" >> "$LEDGER"
    echo "- Hash: $HASH" >> "$LEDGER"
    echo "- Status: REJECTED ($REASON)" >> "$LEDGER"

    mv "$IMG" "$TICKETS/"
  fi
done

git add .
git commit -m "∞ image token batch"
git push origin main
