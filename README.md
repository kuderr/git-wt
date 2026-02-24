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

## Commands

| Command | Description |
|---------|-------------|
| `git wt new [name]` | Create a new worktree. Auto-generates a name if omitted. |
| `git wt list` | List all worktrees for the current repo with branch and status. |
| `git wt list-all` | List worktrees across **all** repos. |
| `git wt rm <name>` | Remove a worktree and delete its branch. |
| `git wt path <name>` | Print the worktree's absolute path. Use with `cd`. |
| `git wt open <name>` | Open the worktree in Cursor, VS Code, or `$EDITOR`. |
| `git wt clean` | Remove **all** worktrees for the current repo. |
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

Global flags:

| Flag | Description |
|------|-------------|
| `-q, --quiet` | Suppress non-essential output |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `GIT_WT_HOME` | `~/.git-wt` | Root directory for all worktrees |
| `GIT_WT_PREFIX` | `wt` | Branch name prefix |

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
- `git wt rm` removes the worktree directory **and** deletes the branch.
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

### Claude Code Skill

Copy `skill/SKILL.md` to your Claude Code skills directory:

```bash
mkdir -p ~/.claude/skills/git-wt
cp skill/SKILL.md ~/.claude/skills/git-wt/SKILL.md
```

This teaches Claude Code how and when to use `git wt` commands.

## Comparison

| | git-wt | [k1LoW/git-wt](https://github.com/k1LoW/git-wt) | [git-worktree-runner](https://github.com/coderabbitai/git-worktree-runner) | `git worktree` |
|---|---|---|---|---|
| Language | Bash | Go | Bash | C (built-in) |
| Dependencies | None | Go runtime | None | — |
| Global storage | ✅ `~/.git-wt/` | ❌ in-repo | ❌ in-repo | Manual |
| Auto-naming | ✅ adjective-noun | ❌ | ❌ | ❌ |
| .env copying | ✅ `--copy-env` | ❌ | ✅ | ❌ |
| Shell completions | ✅ bash + zsh | ✅ | ❌ | ✅ |
| Editor integration | ✅ Cursor/VS Code | ❌ | ✅ | ❌ |
| Install time | ~5 seconds | ~30 seconds | ~10 seconds | Built-in |

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
