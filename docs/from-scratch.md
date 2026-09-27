# From scratch: Claude app + AINOTE skill on the tablet

Goal: talk to Claude in the Claude app on the AINOTE 2 and have it work with your notes through
iFLYTEK's `ainote` skill. Every command below is pasted into the Termux app on the tablet.

## A. Apps

1. **Claude app**: Play Store, search "Claude by Anthropic", install, sign in.
2. **Termux**: in the tablet's browser open https://github.com/termux/termux-app/releases/latest,
   download `termux-app_..._arm64-v8a.apk`, tap it, allow installing from the browser, install.
3. **Termux:Boot**: https://f-droid.org/packages/com.termux.boot/ , download the APK the same way,
   install, open it once so Android registers it.
4. Android Settings, Apps: set Battery to **Unrestricted** for Termux and Termux:Boot.

## B. Install Claude Code and the skill (about 20 minutes, keep Termux open)

5. Open Termux and paste:

   ```bash
   pkg install -y git && git clone https://github.com/Aristos2026/AINOTE2.0.git ~/.claude-ainote && bash ~/.claude-ainote/install.sh
   ```

   Wait for `Claude Code is installed.`

6. Sign Claude Code in: type `claude`, choose Light theme, choose your Claude account, copy the
   printed link into the browser, sign in, paste the code back if the browser shows one. Then
   press Ctrl+C twice to leave.

## C. Check whether the skill can connect on the tablet

7. Paste:

   ```bash
   bash ~/.claude-ainote/scripts/ainote-api-check.sh
   ```

   If the `/open-model-note/health` line shows text such as `enabled` or `status`, the AINOTE app on
   the tablet serves the connection the skill needs. If every line says "no answer", the tablet
   app does not, and the skill only works next to iFLYTEK's Windows or Mac desktop app. Either way,
   continue: the rest gives you Claude with full access to the tablet from the Claude app.

## D. Connect the tablet to the Claude app

8. Paste, follow any login link it prints, and leave it running:

   ```bash
   bash ~/.claude-ainote/scripts/remote-control.sh
   ```

9. Open the Claude app, Code tab. The tablet's session is listed. Open it and type, for example
   "list my notes from this week" (skill route) or "show me what is in my Download folder".

10. Back in Termux press Ctrl+C, then make it start by itself at boot:

    ```bash
    bash ~/.claude-ainote/scripts/enable-autostart.sh
    ```

11. Restart the tablet. About a minute after boot the tablet appears in the Claude app's Code tab
    without opening Termux.

## Daily use

Open the Claude app, Code, tap the tablet, type. If the tablet is missing from the list, open Termux
once and wait a moment.
