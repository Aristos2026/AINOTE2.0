#!/data/data/com.termux/files/usr/bin/bash
# shellcheck disable=SC2012  # ls output is for humans reading the report
# Reports how the AINOTE 2 exposes notes and documents to other apps.
# Run inside Termux:  bash ~/.claude-ainote/scripts/inspect-device.sh
# Prints a summary and saves the full report to ~/ainote-report.txt
set -u

REPORT="$HOME/ainote-report.txt"
: > "$REPORT"
out() { printf '%s\n' "$*" | tee -a "$REPORT"; }
section() { out ""; out "===== $* ====="; }

if [ ! -d "$HOME/storage/shared" ]; then
  echo "Termux needs permission to see the tablet's storage."
  echo "A dialog will appear: tap Allow, then run this script again."
  termux-setup-storage
  exit 0
fi

section "Device"
out "model:   $(getprop ro.product.model 2>/dev/null) ($(getprop ro.product.device 2>/dev/null))"
out "android: $(getprop ro.build.version.release 2>/dev/null)  build: $(getprop ro.build.display.id 2>/dev/null)"

section "Top level of shared storage (/sdcard)"
ls -1 /sdcard 2>/dev/null | tee -a "$REPORT"

section "Folders that look note/document related"
for d in /sdcard/Documents /sdcard/Download /sdcard/Notes /sdcard/Note /sdcard/Books /sdcard/Office /sdcard/Fonts /sdcard/AINOTE* /sdcard/iflytek* /sdcard/iFLYTEK* /sdcard/Android/media/*; do
  [ -d "$d" ] || continue
  out ""
  out "--- $d"
  ls -la "$d" 2>/dev/null | head -25 | tee -a "$REPORT"
done

section "Files changed in the last 7 days (shows where exports land)"
find /sdcard -maxdepth 4 -type f -mtime -7 \
  ! -path '*/Android/data/*' ! -path '*/.thumbnails/*' ! -path '*/cache/*' 2>/dev/null \
  | head -40 | tee -a "$REPORT"

section "Installed apps related to notes"
{ pm list packages 2>/dev/null || cmd package list packages 2>/dev/null; } \
  | sed 's/^package://' | grep -iE 'iflytek|ainote|note|obsidian|markor|keep|onenote|notion|anthropic|termux' \
  | sort | tee -a "$REPORT"

section "Apps that can open .txt / .md / .docx (share targets)"
for m in text/plain text/markdown application/vnd.openxmlformats-officedocument.wordprocessingml.document application/pdf; do
  out "--- $m"
  cmd package query-activities -a android.intent.action.VIEW -t "$m" 2>/dev/null \
    | grep -oE 'packageName=[^ ]+' | sort -u | head -8 | tee -a "$REPORT"
done

section "AINOTE local API (needed by the /ainote skill)"
bash "$(dirname "$0")/ainote-api-check.sh" 2>&1 | tee -a "$REPORT"

section "Done"
out "Full report saved to $REPORT"
out "Send a screenshot of this output, or share the file (it is also at /sdcard if you run: cp $REPORT /sdcard/Download/)"
cp "$REPORT" /sdcard/Download/ainote-report.txt 2>/dev/null && out "Copied to /sdcard/Download/ainote-report.txt"
