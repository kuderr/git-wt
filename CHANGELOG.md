# Changelog

## [1.3.0] - 2026-02-25

### Added
- `--copy-ai` flag for `git wt new` — copies AI agent configs (`.claude/`, `.codex/`) into worktree
- AI session preservation on `git wt rm` — archives Claude Code sessions, syncs settings back to origin
- Extensible provider system (`GIT_WT_AI_PROVIDERS`) — add support for new AI tools by defining `_ai_copy_<name>` and `_ai_save_<name>` functions
- `GIT_WT_COPY_AI` environment variable to permanently enable AI integration
- `GIT_WT_AI_PROVIDERS` environment variable to control which AI tools are managed (default: `claude codex`)

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
