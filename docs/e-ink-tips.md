# E-ink, keyboard and battery tips

## Screen

- **Light theme.** The installer sets it. If Claude Code ever comes up dark, type `/theme` and choose
  Light. Dark themes ghost badly on e-ink.
- **Fewer redraws.** `config/settings.json` turns on `prefersReducedMotion` and turns off spinner
  tips, so the screen is not repainted every few hundred milliseconds while Claude thinks.
- **Try fullscreen rendering.** `/tui fullscreen` keeps the whole transcript inside one fixed frame
  and scrolls with PageUp/PageDown, which avoids the partial-refresh smear of terminal scrollback.
  Run it again to switch back. The setting persists.
- **Refresh mode.** In the AINOTE quick settings, pick the faster refresh mode while using Termux and
  switch back to the high-quality mode for reading. A full refresh (the tablet's refresh button)
  clears ghosting after a long session.
- **Font size.** Pinch to zoom in Termux, or add `font-size` to Termux's style settings via the
  Termux:Styling add-on. Around 14 to 16 pt is comfortable at 300 PPI.
- **Line width.** `maxProseWidth` is set to 80 so paragraphs stay narrow and readable in portrait.

## Keyboard

- **Extra keys row.** `config/termux.properties` adds two rows above the keyboard with Esc, Tab, Ctrl,
  Alt, arrows, Home/End and PgUp/PgDn. Esc cancels Claude, Tab completes, Ctrl+C interrupts, up/down
  recall history. Run `termux-reload-settings` after editing the file.
- **Newlines.** Enter sends. For a line break press Ctrl+J, or type `\` then Enter.
- **Bluetooth keyboard.** The tablet supports Bluetooth 5.4 keyboards; they work in Termux with no
  setup and are much faster than the stylus for coding.
- **Handwriting.** The AINOTE handwriting keyboard works in Termux like any text field. Slow for code,
  fine for short prompts.
- **Vim keys.** `/config` then Editor mode: vim, if you prefer modal editing in the prompt.

## Battery and background

- Termux processes are killed by Android when the app leaves the foreground for long. Before a long
  task run `termux-wake-lock` (undo with `termux-wake-unlock`) and keep Termux visible, or split the
  screen with the browser.
- Android 12 and later also limit "phantom" child processes. proot spawns several. If sessions die
  with `Killed` messages under load, disable the limit once over ADB from a computer:

  ```bash
  adb shell "settings put global settings_enable_monitor_phantom_procs false"
  ```

  This needs Developer options and USB debugging enabled on the tablet.
- Turn off Termux battery optimisation: Android Settings, Apps, Termux, Battery, Unrestricted.
