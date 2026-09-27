# Drive the tablet from the Claude app

Claude Code's Remote Control mode runs on the tablet and shows up in the Claude app's Code tab, so you
type in the app and the tablet does the work: local folders, the Ubuntu tools, the AINOTE skill.

## One-off start

In Termux:

```bash
bash ~/.claude-ainote/scripts/remote-control.sh
```

The first run may ask you to confirm the login in a browser; follow the printed link. Then open the
Claude app, go to Code, and pick the tablet's session. Termux can go to the background; the script
holds a wake lock. It restarts Remote Control automatically if it stops.

## Start at boot, never open Termux again

1. Install the **Termux:Boot** add-on from https://f-droid.org/packages/com.termux.boot/ (same source
   as Termux itself; the two must come from the same source to work together). Open it once.
2. In Termux run:

   ```bash
   bash ~/.claude-ainote/scripts/enable-autostart.sh
   ```

3. Turn off battery optimisation for Termux and Termux:Boot: Android Settings, Apps, the app,
   Battery, Unrestricted.
4. Restart the tablet. About a minute after boot the tablet appears in the Claude app's Code tab.

Log of what the background service is doing: `~/remote-control.log` in Termux.

## Limits

- Android may still stop background work under memory pressure. If the tablet disappears from the
  app, open Termux once; the boot script also runs when Termux starts.
- The session's working folder is your Termux home. Ask Claude to work in `/sdcard/...` paths to
  reach files other apps can see.
