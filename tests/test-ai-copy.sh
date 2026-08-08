#!/usr/bin/env bash
set -euo pipefail

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
[[ -f "${default_wt}/.claude/skills/reviewer/SKILL.md" ]]
[[ -f "${default_wt}/.claude/agents/reviewer.md" ]]
[[ -f "${default_wt}/.claude/settings.local.json" ]]
grep -q '^checked-out version$' "${default_wt}/.claude/agents/tracked.md"

mkdir -p "${origin}/team agent/hooks"
printf 'hook\n' > "${origin}/team agent/hooks/pre-tool.sh"

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none GIT_WT_AI_COPY_PATHS='.claude:team agent/hooks' \
    "$git_wt" new custom-copy >/dev/null
)

custom_wt="${wt_home}/sample-repo/custom-copy"
[[ -f "${custom_wt}/.claude/skills/reviewer/SKILL.md" ]]
[[ -f "${custom_wt}/team agent/hooks/pre-tool.sh" ]]

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none GIT_WT_AI_COPY_PATHS='' \
    "$git_wt" new no-project-copy >/dev/null
)

empty_wt="${wt_home}/sample-repo/no-project-copy"
[[ ! -e "${empty_wt}/.claude" ]]

mkdir -p "${test_root}/outside"
printf 'secret\n' > "${test_root}/outside/secret.txt"

(
  cd "$origin"
  env HOME="$test_home" GIT_WT_HOME="$wt_home" GIT_WT_COPY_ENV=false \
    GIT_WT_AI_PROVIDERS=none GIT_WT_AI_COPY_PATHS='../outside:.git' \
    "$git_wt" new unsafe-paths >"${test_root}/unsafe.out" 2>"${test_root}/unsafe.err"
)

unsafe_wt="${wt_home}/sample-repo/unsafe-paths"
[[ -f "${unsafe_wt}/.git" ]]
[[ ! -e "${unsafe_wt}/outside" ]]
[[ $(grep -c 'ignoring unsafe GIT_WT_AI_COPY_PATHS entry' "${test_root}/unsafe.err") -eq 2 ]]

printf 'AI project copy tests passed!\n'
