# Changelog

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
