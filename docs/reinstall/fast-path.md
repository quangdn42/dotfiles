# Fast Path: Resume OpenCode First

This is an optional branch of [`manual.md`](manual.md), not a separate starting
point. It installs the minimum software, imports the current restore-planning
session from the normal portable OpenCode export backup, and resumes that
session inside the fresh dotfiles clone.

There is no separate handoff archive or handoff script. The resumed agent gets
its context from:

- The restored OpenCode conversation
- The final committed version of this repository
- The encrypted backup manifest and the checkboxes in `checklist.md`

Do not restore every application or data archive before using this path. Return
to [`manual.md`](manual.md) after the session resumes, or continue there
directly if the session export cannot be imported or OpenCode cannot be
started.

## Prerequisites

The pre-reset portion of [`manual.md`](manual.md) must already have produced
and verified:

- The final pushed dotfiles commit
- `opencode-exports.tar.zst.age` containing the recorded planning session
- `SHA256SUMS` and the final backup manifest
- An age private identity recoverable from Bitwarden

Do not use this optional branch if any prerequisite is missing.

## Procedure

### 1. Complete Minimal macOS Setup

1. Create the account with short name `quangdn`.
2. Do not use Migration Assistant.
3. Connect to the network.
4. Sign in to Bitwarden, Google Drive, and GitHub as needed.

Confirm the home path:

```sh
test "$HOME" = "/Users/quangdn" && printf 'home path is correct\n'
```

Stop if it is not `/Users/quangdn`.

### 2. Install Command Line Tools and Homebrew

```sh
xcode-select --install
```

After the Command Line Tools installer finishes:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 3. Install Only the Fast-Path Tools

```sh
brew install git gh age zstd jq anomalyco/tap/opencode
```

Do not apply the complete Brewfile yet.

### 4. Clone the Dotfiles Repository

```sh
gh auth login --web --git-protocol ssh
mkdir -p "$HOME/projects"
gh repo clone quangdn42/dotfiles "$HOME/projects/dotfiles"
git -C "$HOME/projects/dotfiles" status --short --branch
```

Confirm the clone contains the final commit recorded by the backup. Do not
replace it with the old checkout from `projects.tar.zst.age`.

### 5. Download and Verify the OpenCode Export Archive

Using a browser, download these items from the final Google Drive backup run:

- The exact timestamped `opencode-exports.tar.zst.age` archive
- `SHA256SUMS` and the backup manifest

Create the identity directory first:

```sh
mkdir -p "$HOME/.config/age" "$HOME/reinstall-recovery/opencode"
chmod 700 "$HOME/.config/age"
```

Retrieve the age private identity from Bitwarden and save it with a plain-text
editor at `~/.config/age/reinstall-key.txt`. Do not paste the private identity
into a shell command. Then run:

```sh
chmod 600 "$HOME/.config/age/reinstall-key.txt"

export AGE_IDENTITY="$HOME/.config/age/reinstall-key.txt"
export OPENCODE_ARCHIVE="$HOME/Downloads/<exact-opencode-exports-filename>"
```

Extract the matching line from `SHA256SUMS` and verify the archive before
decrypting it:

```sh
grep -F "  $(basename "$OPENCODE_ARCHIVE")" \
  "$HOME/Downloads/SHA256SUMS" > "$HOME/Downloads/opencode.sha256"
(cd "$HOME/Downloads" && shasum -a 256 -c opencode.sha256)
```

Stop if the result is not `OK`.

### 6. Extract the Portable Exports

List the archive first and confirm every path is relative, expected, and does
not contain a `..` traversal component:

```sh
age --decrypt --identity "$AGE_IDENTITY" "$OPENCODE_ARCHIVE" |
  zstd --decompress --stdout |
  tar -tf -
```

Only after reviewing the listing, extract it:

```sh
age --decrypt --identity "$AGE_IDENTITY" "$OPENCODE_ARCHIVE" |
  zstd --decompress --stdout |
  tar -xpf - -C "$HOME/reinstall-recovery/opencode"
```

Inspect the extracted manifest and locate the recorded planning session ID,
its JSON export, and its old project directory. The old directory must be
`/Users/quang-dang/projects/dotfiles`; its new directory is
`/Users/quangdn/projects/dotfiles`.

Keep the encrypted archive unchanged. Treat the extracted exports as sensitive
because they contain prompts, source excerpts, and command output.

### 7. Authenticate and Import the Planning Session

Authenticate with the provider/account used by the restored session:

```sh
opencode auth login
```

Set the values found in the encrypted export manifest, then import from the
fresh repository directory so OpenCode binds the session to the new path:

```sh
SESSION_ID='<recorded-session-id>'
SESSION_EXPORT="$HOME/reinstall-recovery/opencode/<path-to-session-export>.json"

cd "$HOME/projects/dotfiles"
jq -e --arg id "$SESSION_ID" \
  '.info.id == $id and (.messages | type == "array")' "$SESSION_EXPORT"
opencode import "$SESSION_EXPORT"
opencode --session "$SESSION_ID"
```

If the import reports a different session ID, use the imported ID it prints.
Do not import from the old path and do not create a `/Users/quang-dang`
compatibility symlink.

### 8. Continue with the Resumed Agent

The restored conversation should contain the planning history that led to the
current runbook. Send this message:

```text
We are on the fresh Mac after Erase All Content and Settings. Continue from
this restored reinstall-planning session. First read REINSTALL.md,
docs/reinstall/manual.md, docs/reinstall/checklist.md, and the final backup
manifest; inspect the Git and machine state; then continue at the first
incomplete checklist item. Do not mark a backup check complete without
evidence, overwrite the fresh dotfiles clone, delete an archive, or erase data
without explicit approval.
```

The agent can now apply the Brewfiles, deploy Stow, restore projects and data,
and import the remaining OpenCode, Zed, and Codex sessions.

## Import the Remaining OpenCode Sessions

For each remaining portable export, use its manifest mapping to determine the
restored project directory. Restore that project first, then import from its
new path:

```sh
cd "/Users/quangdn/<mapped-project-directory>"
opencode import "$HOME/reinstall-recovery/opencode/<session-export>.json"
```

Repeat for every export. Compare the imported count with the encrypted
manifest and open representative sessions. Keep `opencode-raw.tar.zst.age`
untouched as an emergency fallback until the complete restore is accepted.

## Troubleshooting

### Session Does Not Appear

Run `opencode session list --format json` and use the ID returned by the
import. Confirm the JSON export's `.info.id` matches the manifest and that the
import command was run from `/Users/quangdn/projects/dotfiles`.

### Import Fails

Confirm `opencode --version` against the version recorded in the encrypted
manifest. If the current release cannot import the export, install the recorded
version and retry against a fresh OpenCode data directory. Do not alter the
encrypted original while troubleshooting.

### Portable Export Cannot Be Recovered

Use [`manual.md`](manual.md) and the raw emergency procedure in
[`opencode.md`](opencode.md). Work on a copy of the raw database and preserve
the original encrypted archive.
