# Alternative: run the binary directly in Termux (no Ubuntu)

The Ubuntu container adds about 1 GB and a little overhead. A lighter but less proven option is the
community project [claude-code-android](https://github.com/ferrumclaudepilgrim/claude-code-android),
which downloads Anthropic's `linux-arm64` binary, verifies it against the release manifest, patches
its ELF interpreter to Termux's `glibc-runner`, and wraps it in an auto-updating launcher.

```bash
pkg install -y curl
curl -fsSL https://raw.githubusercontent.com/ferrumclaudepilgrim/claude-code-android/main/install.sh -o install.sh
bash install.sh
```

Trade-offs compared with this kit's Ubuntu approach:

| | Ubuntu container (this kit) | Patched binary |
| --- | --- | --- |
| Uses Anthropic's installer unmodified | yes | no, binary is patched |
| Auto-updates | Claude Code's own | project's wrapper, daily check |
| Disk | about 1.5 GB | about 300 MB |
| Speed | proot overhead on file-heavy work | native |
| Tools available to Claude's Bash tool | full Ubuntu apt | Termux packages |
| Maintainer | Anthropic + Ubuntu | one volunteer, not affiliated |

Do not install both on the same device; they both want to own the `claude` command. Run
`bash ~/.claude-ainote/scripts/uninstall.sh` first if switching.

Historical note: before April 2026 `npm install -g @anthropic-ai/claude-code` shipped a JavaScript CLI
that ran on Termux's Node.js. The package now installs the same native binary as the installer, so
that route no longer works on Android.
