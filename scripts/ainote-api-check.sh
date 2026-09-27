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
echo "== Scanning every local port for anything that answers (takes up to a minute)"
# Android hides /proc/net/tcp from apps, so ask each port directly instead.
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PYSCAN'
import socket, concurrent.futures
def probe(port):
    s = socket.socket(); s.settimeout(0.25)
    try:
        return port if s.connect_ex(("127.0.0.1", port)) == 0 else None
    finally:
        s.close()
with concurrent.futures.ThreadPoolExecutor(max_workers=200) as ex:
    open_ports = sorted(p for p in ex.map(probe, range(1, 65536)) if p)
print("open ports:", " ".join(map(str, open_ports)) or "none")
for p in open_ports:
    s = socket.socket(); s.settimeout(1)
    try:
        s.connect(("127.0.0.1", p))
        s.sendall(b"GET /open-model-note/health HTTP/1.0\r\nHost: 127.0.0.1\r\n\r\n")
        head = s.recv(300).decode("utf-8", "replace").replace("\r", "").split("\n")
        print("  port %d: %s" % (p, head[0][:80]))
    except Exception as e:
        print("  port %d: no HTTP reply (%s)" % (p, type(e).__name__))
    finally:
        s.close()
PYSCAN
else
  echo "python3 not available in Termux; run: pkg install -y python  and rerun."
fi
echo "(if a port replies with HTTP and JSON mentioning open-model, rerun with AINOTE_PORT=<port>)"

echo
echo "== iFLYTEK apps installed"
{ pm list packages 2>/dev/null || cmd package list packages 2>/dev/null; } | sed 's/^package://' | grep -iE 'iflytek|ainote' | sort
