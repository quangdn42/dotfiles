#!/bin/zsh

set -euo pipefail

typeset -gr TEST_DIR="${0:A:h}"
typeset -gr REINSTALL_DIR="${TEST_DIR:h}"
typeset -gr DOTFILES="${REINSTALL_DIR:h:h}"
typeset -gr REINSTALL="$REINSTALL_DIR/bin/reinstall"
typeset -gr HELPER="$REINSTALL_DIR/lib/reinstall_helper.py"

fail() {
  print -u2 -- "FAIL: $*"
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "expected file: $1"
}

assert_equals() {
  [[ "$1" == "$2" ]] || fail "expected '$2', got '$1'"
}

expect_failure() {
  "$@" >/dev/null 2>&1 && fail "command unexpectedly passed: $*"
  return 0
}

tty_run() {
  local input="$1"
  shift
  python3 "$TEST_DIR/pty_run.py" "$input" "$@" >/dev/null
}

tty_expect_failure() {
  local input="$1"
  shift
  set +e
  python3 "$TEST_DIR/pty_run.py" "$input" "$@" >/dev/null 2>&1
  local result=$?
  set -e
  (( result != 0 )) || fail "interactive command unexpectedly passed: $*"
}

for command in age age-keygen jq python3 rclone rsync shasum tar zstd; do
  command -v "$command" >/dev/null || fail "missing test dependency: $command"
done

zsh -n "$REINSTALL"
python3 -c 'compile(open(__import__("sys").argv[1]).read(), __import__("sys").argv[1], "exec")' "$HELPER"
jq -e '.schema_version == 1 and (.archives | length > 0)' "$REINSTALL_DIR/config/archives.json" >/dev/null

temporary="$(mktemp -d "${TMPDIR:-/tmp}/reinstall-tests.XXXXXX")"
trap 'rm -rf "$temporary"' EXIT

source_home="$temporary/source-home"
restore_home="$temporary/restore-home"
source_state="$temporary/source-state"
restore_state="$temporary/restore-state"
remote="$temporary/remote/run"
identity="$temporary/age-identity.txt"
config="$temporary/archives.json"
fixture_dotfiles="$temporary/dotfiles"
fixture_origin="$temporary/dotfiles-origin.git"

mkdir -p \
  "$source_home/projects/sample/node_modules/pkg" \
  "$source_home/projects/sample/.venv" \
  "$source_home/Downloads" \
  "$restore_home/projects/sample" \
  "$restore_home/projects/dotfiles" \
  "$temporary/remote"
print -- old > "$source_home/projects/sample/existing.txt"
print -- restored > "$source_home/projects/sample/new.txt"
print -- cache > "$source_home/projects/sample/node_modules/pkg/cache.txt"
print -- venv > "$source_home/projects/sample/.venv/state.txt"
print -- installer > "$source_home/Downloads/example.dmg"
print -- fresh > "$restore_home/projects/sample/existing.txt"
print -- fresh-dotfiles > "$restore_home/projects/dotfiles/README.md"
xattr -w com.dotfiles.reinstall-fixture preserved "$source_home/projects/sample/new.txt"

jq '{schema_version:1,naming:.naming,archives:[.archives[] | select(.id == "projects" or .id == "opencode-exports")]}
  | .archives |= map(if .id == "opencode-exports" then .requires_stopped = [] else . end)' \
  "$REINSTALL_DIR/config/archives.json" > "$config"
age-keygen -o "$identity" 2> "$temporary/age-keygen.log"
git init --bare "$fixture_origin" >/dev/null
git init -b main "$fixture_dotfiles" >/dev/null
print -- fixture > "$fixture_dotfiles/README.md"
git -C "$fixture_dotfiles" add README.md
git -C "$fixture_dotfiles" -c user.name=Fixture -c user.email=fixture@example.invalid commit -m fixture >/dev/null
git -C "$fixture_dotfiles" remote add origin "$fixture_origin"
git -C "$fixture_dotfiles" push -u origin main >/dev/null

expect_failure env \
  REINSTALL_HOME="$source_home" \
  REINSTALL_STATE_ROOT="$temporary/unsafe-state" \
  REINSTALL_ARCHIVES_CONFIG="$config" \
  REINSTALL_DOTFILES="$fixture_dotfiles" \
  "$REINSTALL" init ../unsafe
jq '.archives[0].id = "../unsafe"' "$config" > "$temporary/unsafe-config.json"
expect_failure python3 "$HELPER" validate-config \
  --config "$temporary/unsafe-config.json" --output "$temporary/unsafe-config-result.json"

typeset -a source_env restore_env
source_env=(
  REINSTALL_HOME="$source_home"
  REINSTALL_STATE_ROOT="$source_state"
  REINSTALL_ARCHIVES_CONFIG="$config"
  REINSTALL_AGE_IDENTITY="$identity"
  REINSTALL_REMOTE=":local:$remote"
  REINSTALL_DOTFILES="$fixture_dotfiles"
  REINSTALL_TARGET_HOME="$restore_home"
)
restore_env=(
  REINSTALL_HOME="$restore_home"
  REINSTALL_STATE_ROOT="$restore_state"
  REINSTALL_ARCHIVES_CONFIG="$config"
  REINSTALL_AGE_IDENTITY="$identity"
  REINSTALL_DOTFILES="$fixture_dotfiles"
)

env "${source_env[@]}" "$REINSTALL" init fixture
env "${source_env[@]}" "$REINSTALL" continue
tty_run d env "${source_env[@]}" "$REINSTALL" gate pass recovery_accounts
tty_run d env "${source_env[@]}" "$REINSTALL" gate pass recovery_age
env "${source_env[@]}" "$REINSTALL" continue
tty_run d env "${source_env[@]}" "$REINSTALL" gate pass cleanup_review

# Applying a plan whose candidate identity changed must fail.
print -- changed > "$source_home/projects/sample/node_modules/changed.txt"
cleanup_plan="$source_state/runs/fixture/plans/cleanup.json"
short_hash="$(cut -c1-12 "$cleanup_plan.sha256")"
tty_expect_failure "DELETE REGENERABLE CACHES $short_hash" \
  env "${source_env[@]}" "$REINSTALL" cleanup apply
[[ -d "$source_home/projects/sample/.venv" ]] || fail "failed cleanup partially removed another candidate"

env "${source_env[@]}" "$REINSTALL" cleanup replan
tty_run d env "${source_env[@]}" "$REINSTALL" gate pass cleanup_review
short_hash="$(cut -c1-12 "$cleanup_plan.sha256")"
tty_run "DELETE REGENERABLE CACHES $short_hash" \
  env "${source_env[@]}" "$REINSTALL" continue
[[ ! -e "$source_home/projects/sample/node_modules" ]] || fail "node_modules was not removed"
[[ ! -e "$source_home/projects/sample/.venv" ]] || fail ".venv was not removed"
assert_file "$source_home/Downloads/example.dmg"

env "${source_env[@]}" "$REINSTALL" continue
tty_run d env "${source_env[@]}" "$REINSTALL" gate pass archive_plan_review
env "${source_env[@]}" "$REINSTALL" backup create all

# Manual adapters reject structurally valid archives missing required content.
mkdir -p "$temporary/manual-bad" "$temporary/manual-good/exports"
print -- '{}' > "$temporary/manual-bad/manifest.json"
print -- '{"planning_session_id":"fixture","sessions":[]}' > "$temporary/manual-good/manifest.json"
print -- '{"info":{"id":"fixture"},"messages":[]}' > "$temporary/manual-good/exports/fixture.json"
tar -C "$temporary/manual-bad" -cpf - manifest.json |
  zstd --quiet --stdout |
  age --recipient "$(age-keygen -y "$identity")" --output "$temporary/manual-bad.tar.zst.age"
expect_failure env "${source_env[@]}" "$REINSTALL" backup register opencode-exports "$temporary/manual-bad.tar.zst.age"
tar -C "$temporary/manual-good" -cpf - manifest.json exports |
  zstd --quiet --stdout |
  age --recipient "$(age-keygen -y "$identity")" --output "$temporary/manual-good.tar.zst.age"
env "${source_env[@]}" "$REINSTALL" backup register opencode-exports "$temporary/manual-good.tar.zst.age"
env "${source_env[@]}" "$REINSTALL" backup upload all

# Existing remote evidence is immutable, not silently replaced.
cp "$remote/projects.metadata.json" "$temporary/projects.metadata.good"
print -- corrupt > "$remote/projects.metadata.json"
expect_failure env "${source_env[@]}" "$REINSTALL" backup upload projects
cp "$temporary/projects.metadata.good" "$remote/projects.metadata.json"
env "${source_env[@]}" "$REINSTALL" backup verify all

# Finalization rejects local metadata that no longer matches the archive.
cp "$source_state/runs/fixture/archives/projects.metadata.json" "$temporary/projects.metadata.local-good"
jq '.sha256 = "bad"' "$temporary/projects.metadata.local-good" \
  > "$source_state/runs/fixture/archives/projects.metadata.json"
expect_failure env "${source_env[@]}" "$REINSTALL" backup finalize
cp "$temporary/projects.metadata.local-good" "$source_state/runs/fixture/archives/projects.metadata.json"
env "${source_env[@]}" "$REINSTALL" backup finalize

archive="$source_state/runs/fixture/archives/projects.tar.zst.age"
assert_file "$archive"
assert_file "$remote/resume.json"
jq -e '[.members[].path | contains("node_modules")] | any | not' \
  "$source_state/runs/fixture/reports/projects.archive-listing.json" >/dev/null

# A corrupt local archive and a traversal payload must both fail validation.
cp "$archive" "$temporary/archive-good"
print -- corrupt >> "$archive"
expect_failure env "${source_env[@]}" "$REINSTALL" backup verify projects
cp "$temporary/archive-good" "$archive"

python3 - "$temporary/traversal.tar" <<'PY'
import io
import sys
import tarfile

with tarfile.open(sys.argv[1], "w") as archive:
    payload = b"escape"
    member = tarfile.TarInfo("../escape.txt")
    member.size = len(payload)
    archive.addfile(member, io.BytesIO(payload))
PY
expect_failure sh -c "python3 '$HELPER' validate-tar --archive-sha256 invalid --output '$temporary/traversal.json' < '$temporary/traversal.tar'"

manifest_sha="$(shasum -a 256 "$remote/manifest.json" | cut -d ' ' -f 1)"
expect_failure env "${restore_env[@]}" "$REINSTALL" resume ":local:$remote" \
  0000000000000000000000000000000000000000000000000000000000000000
[[ ! -e "$restore_state/runs/fixture" ]] || fail "failed resume left partial run state"
env "${restore_env[@]}" "$REINSTALL" resume ":local:$remote" "$manifest_sha"
expect_failure env \
  REINSTALL_HOME=/ \
  REINSTALL_STATE_ROOT="$restore_state" \
  REINSTALL_ARCHIVES_CONFIG="$config" \
  REINSTALL_AGE_IDENTITY="$identity" \
  REINSTALL_DOTFILES="$fixture_dotfiles" \
  "$REINSTALL" restore inspect projects
env "${restore_env[@]}" "$REINSTALL" restore download
env "${restore_env[@]}" "$REINSTALL" restore inspect all

# Staging is bound to the exact archive that passed structural inspection.
downloaded="$restore_state/runs/fixture/downloads/projects.tar.zst.age"
cp "$downloaded" "$temporary/downloaded-good"
print -- changed >> "$downloaded"
expect_failure env "${restore_env[@]}" "$REINSTALL" restore stage projects
cp "$temporary/downloaded-good" "$downloaded"
env "${restore_env[@]}" "$REINSTALL" restore stage all
mkdir -p "$restore_state/runs/fixture/staging/projects/projects/dotfiles"
print -- must-not-copy > "$restore_state/runs/fixture/staging/projects/projects/dotfiles/evil.txt"
env "${restore_env[@]}" "$REINSTALL" restore diff all
temporary_run="$restore_state/runs/fixture/run.json.partial"
jq '.next_action = "gate.restore_apply"' "$restore_state/runs/fixture/run.json" > "$temporary_run"
mv "$temporary_run" "$restore_state/runs/fixture/run.json"
tty_run d env "${restore_env[@]}" "$REINSTALL" gate pass restore_apply
tty_run "APPLY STAGED projects" env "${restore_env[@]}" "$REINSTALL" restore apply projects
assert_equals "$(<"$restore_home/projects/sample/existing.txt")" fresh
assert_equals "$(<"$restore_home/projects/sample/new.txt")" restored
assert_equals "$(xattr -p com.dotfiles.reinstall-fixture "$restore_home/projects/sample/new.txt")" preserved
assert_equals "$(<"$restore_home/projects/dotfiles/README.md")" fresh-dotfiles
[[ ! -e "$restore_home/projects/dotfiles/evil.txt" ]] || fail "restore added a file inside the fresh dotfiles clone"

handoff="$temporary/handoff.json"
env "${restore_env[@]}" "$REINSTALL" handoff "$handoff"
jq -e '.run_id == "fixture" and .next_action.command == "reinstall continue"' "$handoff" >/dev/null

# Human gates stop noninteractive runs and persist their blocked state.
gate_state="$temporary/gate-state"
env \
  REINSTALL_HOME="$source_home" \
  REINSTALL_STATE_ROOT="$gate_state" \
  REINSTALL_ARCHIVES_CONFIG="$config" \
  REINSTALL_AGE_IDENTITY="$identity" \
  REINSTALL_REMOTE=":local:$temporary/gate-remote" \
  REINSTALL_DOTFILES="$fixture_dotfiles" \
  REINSTALL_TARGET_HOME="$restore_home" \
  "$REINSTALL" init gate-fixture >/dev/null
env \
  REINSTALL_HOME="$source_home" \
  REINSTALL_STATE_ROOT="$gate_state" \
  REINSTALL_ARCHIVES_CONFIG="$config" \
  REINSTALL_AGE_IDENTITY="$identity" \
  REINSTALL_DOTFILES="$fixture_dotfiles" \
  "$REINSTALL" continue >/dev/null
set +e
env \
  REINSTALL_HOME="$source_home" \
  REINSTALL_STATE_ROOT="$gate_state" \
  REINSTALL_ARCHIVES_CONFIG="$config" \
  REINSTALL_DOTFILES="$fixture_dotfiles" \
  "$REINSTALL" continue </dev/null >/dev/null 2>&1
gate_result=$?
set -e
assert_equals "$gate_result" 20
assert_equals "$(jq -r '.gates.recovery_accounts.status' "$gate_state/runs/gate-fixture/run.json")" pending

gate_run="$gate_state/runs/gate-fixture/run.json"
jq '.next_action = "gate.final_acceptance" | .status = "active"' "$gate_run" > "$gate_run.partial"
mv "$gate_run.partial" "$gate_run"
retention_date="$(date -v+100d '+%Y-%m-%d')"
tty_run "RETAIN UNTIL $retention_date" env \
  REINSTALL_HOME="$source_home" \
  REINSTALL_STATE_ROOT="$gate_state" \
  REINSTALL_ARCHIVES_CONFIG="$config" \
  REINSTALL_DOTFILES="$fixture_dotfiles" \
  "$REINSTALL" gate pass final_acceptance
assert_equals "$(jq -r '.status' "$gate_run")" completed
assert_equals "$(jq -r '.retention_until' "$gate_run")" "$retention_date"

print -- "All reinstall fixture tests passed."
