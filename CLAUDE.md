# CLAUDE.md

## Project Overview

**git-wt** — fast git worktree manager. Pure bash, zero dependencies.
Wraps `git worktree` into an ergonomic CLI: `git wt <command>`.

## Repository Structure

```
bin/git-wt              — main executable (bash script)
completions/
  git-wt.bash           — bash completions
  _git-wt               — zsh completions
skills/git-wt/SKILL.md  — AI agent skill file
install.sh              — curl-based installer
Makefile                — install/uninstall/lint/test targets
```

## Commands

`new`, `list`, `list-all`, `rm`, `path`, `origin`, `open`, `clean`, `help`, `version`

## Development Rules

- **Pure bash only** — no external dependencies beyond git and standard unix tools
- **ShellCheck clean** — run `shellcheck bin/git-wt` before committing; CI enforces this
- Worktrees stored globally at `~/.git-wt/<repo>/<name>/`
- Branch prefix: `wt/` by default (configurable via `GIT_WT_PREFIX`)

## When Adding a New Command

1. Add the `cmd_<name>()` function in `bin/git-wt`
2. Register it in the main dispatch `case` block at the bottom of `bin/git-wt`
3. Add to `usage()` help text
4. Update **both** completion files:
   - `completions/git-wt.bash`
   - `completions/_git-wt`
5. Update docs:
   - `README.md` — command table + relevant sections
   - `skills/git-wt/SKILL.md` — commands reference + key details
   - `CHANGELOG.md` — new version entry
6. Run `make lint` to verify shellcheck passes

## Lint & Test

```bash
make lint    # shellcheck bin/git-wt install.sh
make test    # smoke test: create, list, path, rm
```

## Commit Style

Conventional commits: `feat:`, `fix:`, `docs:`, `chore:`, etc.
Keep messages concise (1-2 sentences).
