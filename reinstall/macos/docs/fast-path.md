# Fast Path: Resume OpenCode First

This optional post-erase branch restores only the planning session before the
full Brewfile and data restore. Cross-erase execution state comes from remote
`resume.json`; the restored conversation supplies rationale, not live status.

## Prerequisites

Final pre-erase work must have produced and verified:

- The pushed dotfiles commit recorded by `resume.json`
- `opencode-exports.tar.zst.age` containing the planning session
- `manifest.json`, `SHA256SUMS`, and `resume.json`
- An age identity recoverable independently of the erased Mac

Do not use the fast path if any prerequisite is missing.

## Minimal Setup

Complete Setup Assistant with `/Users/quangdn`, skip Migration Assistant, then
install Command Line Tools and Homebrew:

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Install only fast-path dependencies:

```sh
brew install git gh jq rclone age zstd anomalyco/tap/opencode
gh auth login --web --git-protocol ssh
mkdir -p "$HOME/projects"
gh repo clone quangdn42/dotfiles "$HOME/projects/dotfiles"
```

## Recover Resume State

Configure the `gdrive` rclone remote, then recover the compact state. This
verifies the manifest/checksum digests and refuses the wrong dotfiles commit:

```sh
DOTFILES="$HOME/projects/dotfiles"
REINSTALL="$DOTFILES/reinstall/macos/bin/reinstall"
rclone config
"$REINSTALL" resume 'gdrive:mac-reinstall/<run-id>' '<independently-stored-manifest-sha256>'
```

Retrieve the age identity from Bitwarden with a text editor and restrict it:

```sh
mkdir -p "$HOME/.config/age"
chmod 700 "$HOME/.config/age"
chmod 600 "$HOME/.config/age/reinstall-key.txt"
```

## Download And Stage The Export

Download only the portable export archive into the resumed run and verify its
recorded checksum:

```sh
RUN_ID="$(cat "$HOME/.local/state/dotfiles-reinstall/active-run")"
RUN_DIR="$HOME/.local/state/dotfiles-reinstall/runs/$RUN_ID"
REMOTE="$(jq -r '.remote' "$RUN_DIR/run.json")"

rclone copyto "$REMOTE/opencode-exports.tar.zst.age" \
  "$RUN_DIR/downloads/opencode-exports.tar.zst.age"
grep -F '  opencode-exports.tar.zst.age' "$RUN_DIR/downloads/SHA256SUMS" \
  > "$RUN_DIR/downloads/opencode-exports.sha256"
(cd "$RUN_DIR/downloads" && shasum -a 256 -c opencode-exports.sha256)

"$REINSTALL" restore inspect opencode-exports
"$REINSTALL" restore stage opencode-exports
```

The structural inspection rejects unsafe paths and links before staged
extraction. Keep the encrypted archive unchanged.

## Import The Planning Session

Read the encrypted export manifest from staging, set the planning session ID,
and verify the mapped old directory is the previous dotfiles checkout:

```sh
EXPORT_ROOT="$RUN_DIR/staging/opencode-exports"
SESSION_ID="$(jq -r '.planning_session_id' "$EXPORT_ROOT/manifest.json")"
SESSION_EXPORT="$EXPORT_ROOT/exports/$SESSION_ID.json"
SOURCE_HOME="$(jq -r '.source_home' "$RUN_DIR/downloads/manifest.json")"

jq -e --arg id "$SESSION_ID" \
  '.info.id == $id and (.messages | type == "array")' "$SESSION_EXPORT"
jq -e --arg id "$SESSION_ID" --arg old_dotfiles "$SOURCE_HOME/projects/dotfiles" \
  '.sessions[] | select(.id == $id and .directory == $old_dotfiles)' \
  "$EXPORT_ROOT/manifest.json"
```

Reauthenticate instead of restoring old auth, then import from the new project
directory so OpenCode binds the session to `/Users/quangdn`:

```sh
opencode auth login
cd "$DOTFILES"
opencode import "$SESSION_EXPORT"
opencode --session "$SESSION_ID"
```

If import returns a new session ID, use the returned ID. Never create a
compatibility symlink for an old source home.

## Agent Handoff

Tell the resumed agent:

```text
Read reinstall/macos/handoff.json first, then run the tracked reinstall script's
status command. Remote resume state has already been verified. Execute only the
reported next action, preserve encrypted originals and the fresh dotfiles clone,
and stop for every human gate.
```

Continue the normal post-erase sequence with:

```sh
"$REINSTALL" status
"$REINSTALL" continue
```

Do not return to Reset and Setup Assistant or select the first unchecked
Markdown item. The run-state `next_action` is authoritative.
