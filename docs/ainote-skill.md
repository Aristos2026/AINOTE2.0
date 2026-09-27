# The official /ainote skill

iFLYTEK publishes a Claude Code skill at https://github.com/iflyink/ainote. The kit installs it into
Claude Code on the tablet as `~/.claude/skills/ainote`, so `/ainote` is available in every session and
Claude also picks it up on its own when you talk about notes, folders, reminders or tasks.

## What it does

It does not read note files. It talks to a small web service the AINOTE app runs on the same machine,
called the OpenModel API, on port 46588. Through it Claude can:

- list, search and read your notes (handwritten notes come back as recognised text, recordings as
  transcripts, mind maps as outlines)
- create notes from Markdown, create folders, rename, move and delete
- view, create, update, complete and delete schedule events, reminders and tasks
- query "focus star" snippets

Writes sync through your AINOTE account, so a note Claude creates appears on the tablet.

## Where the service runs

According to iFLYTEK's announcement, the OpenModel API and its authorization link are features of the
**AINOTE Desktop App for Windows and Mac, version 3.1.0.6 or later** (August 2026 update). The
skill's own helper script only knows how to launch the Windows and macOS apps. Whether the Android
app on the tablet also serves the API is not documented. Test it:

```bash
bash ~/.claude-ainote/scripts/ainote-api-check.sh
```

- If `/open-model-note/health` answers with JSON, the tablet serves the API and `/ainote` works
  directly on the device.
- If nothing answers on any port, the tablet does not serve it. The skill still works, but from a
  Windows or Mac computer: install the AINOTE Desktop App there, sign in with the same account,
  generate the authorization link in its settings, install Claude Code and this skill on that
  computer, and your notes reach the tablet through sync.

## Authorization token

The skill passes a bearer token with every request (`--token`). The desktop app generates it as an
"authorization link". Give the token to Claude once per session, or export it before starting:

```bash
export TOKEN=...   # from the AINOTE app
claude
```

## Using it

Inside Claude Code, plain language is enough:

- "Show me my notes from this week and summarise them"
- "Create a note called Groceries with a checklist of ..."
- "Remind me tomorrow at 9am to call the dentist"
- "Move the note 'Q3 plan' into the Work folder"

Claude confirms before deleting, moving or renaming anything.
