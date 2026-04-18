# Changelog

## [1.6.0] - 2026-04-18

### Changed
- **`--copy-env` and `--copy-ai` are now on by default.** Previously opt-in via flag or `GIT_WT_COPY_*=true`; now opt-out via `--no-copy-env` / `--no-copy-ai` or `GIT_WT_COPY_*=false`. The "no .env files found" warning now only fires when `--copy-env` is passed explicitly.
- **Claude session preservation on `git wt rm` now merges sessions into the origin repo's Claude project directory** (`~/.claude/projects/<origin-encoded>/`) instead of archiving to `.ai-sessions/`. The `cwd` field inside every JSONL (including nested subagent files) is rewritten from the worktree path to the origin path so sessions appear in `/resume` when you're back in the main repo. Subagent JSONLs are covered too.

### Added
- `--no-copy-env` and `--no-copy-ai` flags on `new` and `checkout` — per-run opt-out.

### Fixed
- Claude project ID encoding — now replaces every non-alphanumeric character with `-` (matches Claude Code's own encoding). Previously only `/` was encoded, so the `.` in `~/.git-wt/...` caused the session directory lookup to miss and preservation was silently skipped.

## [1.5.0] - 2026-02-25

### Added
- `git wt checkout <branch> [name]` — check out an existing local or remote branch into a worktree
- Auto-detects remote tracking branches (e.g., `git wt checkout fix/bug-42` finds `origin/fix/bug-42`)
- Explicit remote refs supported (e.g., `git wt checkout origin/fix/bug-42`)
- `co` alias for `checkout` (like `git checkout` → `git co`)
- `wtco` shell alias — checkout + cd in one step
- `--copy-env` and `--copy-ai` flags supported for checkout

## [1.4.0] - 2026-02-25

### Added
- Shell aliases (`aliases/git-wt.sh`) — `wtcd`, `wto`, `wtn`, `wtls`, `wtla`, `wtrm`, `wtopen`, `wtclean`, `wtpath`
- `wtn` creates a worktree and `cd`s into it in one step
- `wtcd <name>` jumps into a worktree, `wto` jumps to the origin repo
- Tab completion for aliases (bash + zsh)

## [1.3.0] - 2026-02-25

### Added
- `--copy-ai` flag for `git wt new` — copies `.claude/settings.local.json` into worktree
- AI session preservation on `git wt rm` — archives Claude Code sessions, syncs settings back to origin
- Extensible provider system (`GIT_WT_AI_PROVIDERS`) — add support for new AI tools by defining `_ai_copy_<name>` and `_ai_save_<name>` functions
- `GIT_WT_COPY_AI` environment variable to permanently enable AI integration

## [1.2.0] - 2026-02-24

### Added
- `git wt adopt <name|path> [name]` — adopt an external worktree into git-wt management
- `git wt list` now shows external worktrees with `[external]` tag
- `path` and `open` now work with external worktrees (by basename or full path)
- `rm` on an external worktree gives a clear hint to `adopt` first

## [1.1.0] - 2026-02-24

### Added
- `git wt origin` command — print the main repo path from any worktree

## [1.0.0] - 2026-02-24

### Added
- Initial release
- Commands: `new`, `list`, `list-all`, `rm`, `path`, `open`, `clean`, `help`, `version`
- Auto-generated adjective-noun worktree names (2,400 combinations)
- Global worktree storage at `~/.git-wt/<repo>/<name>/`
- `.env` file copying with `--copy-env`
- Detached HEAD mode with `--no-branch`
- Configurable branch prefix with `-p/--prefix`
- Colored output (respects `NO_COLOR`)
- Shell completions for bash and zsh
- Curl one-liner installer
- Makefile with install/uninstall/lint targets
- Claude Code agent skill (`skill/SKILL.md`)
- ShellCheck CI workflow
