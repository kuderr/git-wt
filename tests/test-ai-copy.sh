#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file() {
  if [[ ! -f "$1" ]]; then
    fail "expected file: $1"
  fi
}

assert_no_path() {
  if [[ -e "$1" || -L "$1" ]]; then
    fail "expected path to be absent: $1"
  fi
}

assert_content() {
  local expected="$1" file="$2"
  if [[ ! -f "$file" ]] || [[ $(<"$file") != "$expected" ]]; then
    fail "unexpected content in: $file"
  fi
}

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
git_wt="${repo_root}/bin/git-wt"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/git-wt-ai-copy.XXXXXX")
trap 'rm -rf "$test_root"' EXIT

origin="${test_root}/sample-repo"
test_home="${test_root}/home"
wt_home="${test_root}/worktrees"
mkdir -p "$origin" "$test_home"

git -C "$origin" init -q
git -C "$origin" config user.email "test@example.com"
git -C "$origin" config user.name "git-wt test"
mkdir -p "${origin}/.claude/agents"
printf 'tracked\n' > "${origin}/README.md"
printf 'checked-out version\n' > "${origin}/.claude/agents/tracked.md"
git -C "$origin" add README.md .claude/agents/tracked.md
git -C "$origin" commit -qm init
base_branch=$(git -C "$origin" branch --show-current)

# Target branches exercise destination symlink and file/directory conflicts.
git -C "$origin" switch -qc symlink-target
git -C "$origin" rm -qr .claude/agents
mkdir -p "${origin}/.claude"
ln -s "${test_root}/outside" "${origin}/.claude/agents"
git -C "$origin" add .claude/agents
git -C "$origin" commit -qm 'track symlink destination'

git -C "$origin" switch -q "$base_branch"
git -C "$origin" switch -qc file-target
git -C "$origin" rm -qr .claude/agents
mkdir -p "${origin}/.claude"
printf 'target file\n' > "${origin}/.claude/agents"
git -C "$origin" add .claude/agents
git -C "$origin" commit -qm 'track file destination'

git -C "$origin" switch -q "$base_branch"
git -C "$origin" branch checkout-target

mkdir -p "${origin}/.claude/skills/reviewer" "${origin}/.claude/agents"
printf 'origin modification\n' > "${origin}/.claude/agents/tracked.md"
printf 'skill\n' > "${origin}/.claude/skills/reviewer/SKILL.md"
printf 'agent\n' > "${origin}/.claude/agents/reviewer.md"
printf '{}\n' > "${origin}/.claude/settings.local.json"

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none "$git_wt" new default-copy >/dev/null
)

default_wt="${wt_home}/sample-repo/default-copy"
assert_file "${default_wt}/.claude/skills/reviewer/SKILL.md"
assert_file "${default_wt}/.claude/agents/reviewer.md"
assert_file "${default_wt}/.claude/settings.local.json"
assert_content 'checked-out version' "${default_wt}/.claude/agents/tracked.md"

mkdir -p "${origin}/team agent/hooks"
printf 'hook\n' > "${origin}/team agent/hooks/pre-tool.sh"

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none GIT_WT_AI_COPY_PATHS='.claude:team agent/hooks' \
    "$git_wt" new custom-copy >/dev/null
)

custom_wt="${wt_home}/sample-repo/custom-copy"
assert_file "${custom_wt}/.claude/skills/reviewer/SKILL.md"
assert_file "${custom_wt}/team agent/hooks/pre-tool.sh"

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none GIT_WT_AI_COPY_PATHS='' \
    "$git_wt" new no-project-copy >/dev/null
)

empty_wt="${wt_home}/sample-repo/no-project-copy"
assert_file "${empty_wt}/.claude/agents/tracked.md"
assert_no_path "${empty_wt}/.claude/settings.local.json"
assert_no_path "${empty_wt}/.claude/skills/reviewer/SKILL.md"

mkdir -p "${test_root}/outside"
printf 'secret\n' > "${test_root}/outside/secret.txt"

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none GIT_WT_AI_COPY_PATHS='../outside:./.git' \
    "$git_wt" new unsafe-paths >"${test_root}/unsafe.out" 2>"${test_root}/unsafe.err"
)

unsafe_wt="${wt_home}/sample-repo/unsafe-paths"
assert_file "${unsafe_wt}/.git"
assert_no_path "${unsafe_wt}/outside"
if [[ $(grep -c 'ignoring unsafe GIT_WT_AI_COPY_PATHS entry' "${test_root}/unsafe.err") -ne 2 ]]; then
  fail 'unsafe paths were not rejected'
fi

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none "$git_wt" new -b symlink-target symlink-safe >/dev/null
)

symlink_wt="${wt_home}/sample-repo/symlink-safe"
if [[ ! -L "${symlink_wt}/.claude/agents" ]]; then
  fail 'target-branch symlink was replaced'
fi
assert_no_path "${test_root}/outside/reviewer.md"

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none "$git_wt" new -b file-target file-conflict >/dev/null
)

file_wt="${wt_home}/sample-repo/file-conflict"
assert_content 'target file' "${file_wt}/.claude/agents"

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none "$git_wt" checkout checkout-target checkout-copy >/dev/null
)

checkout_wt="${wt_home}/sample-repo/checkout-copy"
assert_file "${checkout_wt}/.claude/skills/reviewer/SKILL.md"
assert_file "${checkout_wt}/.claude/settings.local.json"

printf 'AI project copy tests passed!\n'
