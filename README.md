# git-wt

**Fast git worktree manager. Pure bash, zero dependencies.**

`git worktree` is powerful but verbose. `git-wt` wraps it into a workflow that just works — create isolated worktrees with a single command, auto-generated names, and global storage outside your repo.

```bash
$ git wt new
Creating worktree 'swift-jade' on branch 'wt/swift-jade' from 'main'...

Worktree ready:
  Path:   ~/.git-wt/myapp/swift-jade
  Branch: wt/swift-jade

  cd ~/.git-wt/myapp/swift-jade
```

## Why git-wt?

- **Pure bash** — no Go, Node, Python, or compiled binaries. Runs everywhere git does.
- **Global storage** — worktrees live in `~/.git-wt/`, not inside your repo. No `.gitignore` needed.
- **Auto-naming** — generates memorable `adjective-noun` names (e.g., `swift-jade`, `bold-reef`).
- **30-second install** — single curl command. Single file.
- **Dev-friendly** — copies `.env` files with `--copy-env` so your worktree is immediately runnable.
- **AI-agent ready** — built for parallel workflows with Claude Code, Codex, Cursor, and similar tools.

## Install

**One-liner:**

```bash
curl -fsSL https://raw.githubusercontent.com/kuderr/git-wt/main/install.sh | bash
```

**Clone + make:**

```bash
git clone https://github.com/kuderr/git-wt.git
cd git-wt
make install
```

**Manual:**

```bash
curl -o ~/.local/bin/git-wt https://raw.githubusercontent.com/kuderr/git-wt/main/bin/git-wt
chmod +x ~/.local/bin/git-wt
```

> Make sure `~/.local/bin` is in your `PATH`. The installer checks this automatically.

## Quick Start

```bash
cd ~/projects/myapp

# Create a worktree (auto-named, e.g. "swift-jade")
git wt new

# Create a named worktree
git wt new auth-refactor

# Jump into it
cd $(git wt path auth-refactor)

# See all worktrees
git wt list

# Open in your editor
git wt open auth-refactor

# Clean up when done
git wt rm auth-refactor
```

### Copying `.env` files

Worktrees are separate directories — your `.env` files (gitignored) won't be there.
Use `--copy-env` to copy all `.env*` files from the repo root into the new worktree:

```bash
git wt new --copy-env my-feature
# Copied .env
# Copied .env.local
```

This way your dev server starts immediately without missing config.

### AI session preservation

AI tools (Claude Code, Codex) store sessions and settings per project path. When a worktree is deleted, that data is normally lost. Use `--copy-ai` to preserve it:

```bash
# On create: copies .claude/settings.local.json and .codex/ into worktree
git wt new --copy-ai my-feature

# Work in the worktree — AI tools create sessions, you approve new commands...

# On rm: archives Claude sessions, syncs settings back to origin
git wt rm my-feature
#   Archived Claude sessions → .ai-sessions/my-feature/claude/
#   Synced .claude/settings.local.json → origin
```

**What happens:**
- **On create**: copies `.claude/settings.local.json` (approved commands) and `.codex/` (skills) into the worktree
- **On remove**: archives Claude Code sessions to `~/.git-wt/<repo>/.ai-sessions/<name>/`, copies settings back to origin

To enable this permanently:

```bash
export GIT_WT_COPY_AI=true  # add to ~/.zshrc or ~/.bashrc
```

The provider system is extensible — see `GIT_WT_AI_PROVIDERS` to control which AI tools are managed.

### External worktrees

git-wt can see and manage worktrees created outside of `git wt` (e.g., via `git worktree add`).
They show up in `git wt list` with an `[external]` tag, and `rm`/`path`/`open` work with them too:

```bash
# Created elsewhere
git worktree add ../my-hotfix main

# Visible in list
git wt list
#   my-hotfix   main   clean  [external]

# Adopt it — moves it under ~/.git-wt/ management
git wt adopt my-hotfix          # by name from list
git wt adopt ../my-hotfix       # or by path
```

After `adopt`, the worktree is managed by git-wt like any other.

## Commands

| Command | Description |
|---------|-------------|
| `git wt new [name]` | Create a new worktree. Auto-generates a name if omitted. |
| `git wt list` | List all worktrees for the current repo (managed + external). |
| `git wt list-all` | List managed worktrees across **all** repos. |
| `git wt adopt <name\|path> [name]` | Adopt an external worktree into git-wt management. |
| `git wt rm <name\|path>` | Remove a managed worktree and delete its branch. |
| `git wt path <name\|path>` | Print the worktree's absolute path. |
| `git wt origin` | Print the main repo path (works from any worktree). |
| `git wt open <name\|path>` | Open worktree in Cursor, VS Code, or `$EDITOR`. |
| `git wt clean` | Remove all **managed** worktrees for the current repo. |
| `git wt help` | Show help. |
| `git wt version` | Show version. |

## Options

Options for `git wt new`:

| Flag | Description |
|------|-------------|
| `-b, --base <branch>` | Branch to fork from (default: current branch) |
| `-p, --prefix <prefix>` | Branch prefix (default: `wt`) |
| `--no-branch` | Create with detached HEAD instead of a new branch |
| `--copy-env` | Copy `.env*` files from the repo root into the worktree |
| `--copy-ai` | Copy AI agent configs (`.claude/`, `.codex/`) and save sessions on rm |

Global flags:

| Flag | Description |
|------|-------------|
| `-q, --quiet` | Suppress non-essential output |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `GIT_WT_HOME` | `~/.git-wt` | Root directory for all worktrees |
| `GIT_WT_PREFIX` | `wt` | Branch name prefix |
| `GIT_WT_COPY_AI` | `false` | Always copy AI configs on new, save sessions on rm |
| `GIT_WT_AI_PROVIDERS` | `claude codex` | Space-separated list of AI providers to manage |

## Shell Completions

The installer sets up completions automatically. For manual setup:

**Bash:**

```bash
# Add to ~/.bashrc
source /path/to/git-wt/completions/git-wt.bash
```

**Zsh:**

```bash
# Add to ~/.zshrc (before compinit)
fpath=(~/.local/share/zsh/site-functions $fpath)
```

Completions support subcommands, flags, worktree names, and branch names.

## How It Works

```
~/.git-wt/                    ← GIT_WT_HOME
├── myapp/                    ← repo name (auto-detected)
│   ├── swift-jade/           ← worktree (branch: wt/swift-jade)
│   └── auth-refactor/        ← worktree (branch: wt/auth-refactor)
└── other-repo/
    └── bugfix/               ← worktree (branch: wt/bugfix)
```

- **Repo name** is detected from the working directory via `git rev-parse --show-toplevel`.
- **Branches** are prefixed with `wt/` by default (e.g., `wt/swift-jade`).
- **Names** are auto-generated from 50 adjectives × 48 nouns = 2,400 combinations.
- `git wt rm` only works on managed worktrees — removes the directory and deletes its branch. External worktrees must be adopted first.
- Works from inside a worktree — always resolves back to the main repo.

## AI Agent Integration

git-wt is designed for parallel AI agent workflows where each agent needs an isolated copy of the repo:

```bash
# Agent 1: working on auth
git wt new --copy-env auth-refactor

# Agent 2: working on API
git wt new --copy-env api-v2

# Agent 3: fixing tests
git wt new --copy-env fix-tests

# See everything
git wt list-all
```

### Finding the main repo

When working inside a worktree, use `origin` to get the path back to the main repository:

```bash
cd $(git wt path swift-jade)
git wt origin   # → /Users/you/projects/myapp
```

This works from the main repo too (prints its own path). Useful for scripts that need to reference the original repository.

### Agent Skill

git-wt ships with a [SKILL.md](skills/git-wt/SKILL.md) that teaches AI agents (Claude Code, Cursor, Windsurf, etc.) how and when to use `git wt` commands.

**Install via npx:**

```bash
npx skills add kuderr/git-wt
```

**Or manually:**

```bash
# Claude Code
mkdir -p ~/.claude/skills/git-wt
cp skill/SKILL.md ~/.claude/skills/git-wt/SKILL.md

# Cursor
mkdir -p .cursor/skills/git-wt
cp skill/SKILL.md .cursor/skills/git-wt/SKILL.md
```

## Comparison

| | git-wt | [k1LoW/git-wt](https://github.com/k1LoW/git-wt) | [git-worktree-runner](https://github.com/coderabbitai/git-worktree-runner) | [worktree](https://github.com/agenttools/worktree) | `git worktree` |
|---|---|---|---|---|---|
| Language | Bash | Go | Bash | Node | C (built-in) |
| Dependencies | None | Go runtime | None | Node.js | — |
| Global storage | ✅ `~/.git-wt/` | ❌ in-repo | ❌ in-repo | ❌ in-repo | Manual |
| Auto-naming | ✅ adjective-noun | ❌ | ❌ | ❌ | ❌ |
| .env copying | ✅ `--copy-env` | ❌ | ✅ | ❌ | ❌ |
| Shell completions | ✅ bash + zsh | ✅ | ❌ | ❌ | ✅ |
| Editor integration | ✅ Cursor/VS Code | ❌ | ✅ | ❌ | ❌ |
| Agent skill (SKILL.md) | ✅ `npx skills add` | ❌ | ❌ | ❌ | ❌ |
| AI session preservation | ✅ `--copy-ai` | ❌ | ❌ | ❌ | ❌ |
| Multi-agent workflows | ✅ | ❌ | ✅ | ✅ Claude-only | ❌ |
| Install time | ~5 seconds | ~30 seconds | ~10 seconds | ~15 seconds | Built-in |

## Known Issues

- **Warp Terminal**: Tab completions for `git wt` don't work. Warp uses its own completion engine and [doesn't delegate to shell completions](https://github.com/warpdotdev/Warp/discussions/434). Completions work correctly in Terminal.app, iTerm2, Ghostty, Kitty, and other terminals that use native zsh/bash completion.

## Uninstall

```bash
make uninstall
```

Or manually:

```bash
rm ~/.local/bin/git-wt
rm -rf ~/.git-wt  # removes all worktrees
```

## Contributing

Contributions welcome! Please run `shellcheck bin/git-wt` before submitting PRs.

## License

[MIT](LICENSE)
