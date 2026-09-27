#!/data/data/com.termux/files/usr/bin/bash
# Checks whether the AINOTE app on this tablet exposes its local OpenModel API,
# which the official /ainote skill needs. Run inside Termux:
#   bash ~/.claude-ainote/scripts/ainote-api-check.sh
set -u

PORT="${AINOTE_PORT:-46588}"
echo "== Probing the AINOTE OpenModel API on 127.0.0.1:$PORT"
for path in /open-model-note/health /open-model-schedule/health /open-model-common/health; do
  printf '%-32s ' "$path"
  if out=$(curl -s -m 3 -w ' [HTTP %{http_code}]' "http://127.0.0.1:$PORT$path" 2>&1); then
    echo "$out" | head -c 300; echo
  else
    echo "no answer (curl exit $?)"
  fi
done

echo
echo "== TCP ports something on this tablet is listening on"
# /proc/net/tcp lists sockets in hex; state 0A is LISTEN.
for f in /proc/net/tcp /proc/net/tcp6; do
  [ -r "$f" ] || continue
  awk 'NR>1 && $4=="0A" {split($2,a,":"); printf "%d\n", strtonum("0x" a[2])}' "$f" 2>/dev/null
done | sort -n | uniq | tr '\n' ' '; echo
echo "(if 46588 or another port belongs to AINOTE, the skill can use it: AINOTE_PORT=<port>)"

echo
echo "== iFLYTEK apps installed"
{ pm list packages 2>/dev/null || cmd package list packages 2>/dev/null; } | sed 's/^package://' | grep -iE 'iflytek|ainote' | sort
