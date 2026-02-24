---
name: git-wt
description: >
  Fast git worktree manager. Use when the user wants to create, list, switch
  between, or clean up git worktrees. Handles parallel development workflows,
  agent isolation, and multi-branch work.
allowed-tools: Bash(git wt *)
---

# git-wt — Git Worktree Manager

`git-wt` manages isolated git worktrees stored globally at `~/.git-wt/<repo>/<name>/`.
Worktrees live outside the repo — no `.gitignore` changes needed.

## Prerequisites

`git-wt` must be installed and in PATH. Verify with `git wt --version`.

If not installed, ask the user to install it from: https://github.com/kuderr/git-wt#install

## Commands Reference

### Create a worktree
```bash
git wt new                           # Auto-named (e.g., swift-jade)
git wt new my-feature                # Named
git wt new -b main hotfix            # Fork from specific branch
git wt new --copy-env experiment     # Copy .env* files into worktree
git wt new --no-branch scratch       # Detached HEAD (no branch created)
```

### Navigate to a worktree
```bash
cd $(git wt path <name>)             # Jump into worktree
git wt open <name>                   # Open in Cursor/VS Code/$EDITOR
```

### List worktrees
```bash
git wt list                          # Worktrees for current repo
git wt list-all                      # Worktrees across ALL repos
```

### Find the main repo
```bash
git wt origin                        # Print main repo path (from any worktree)
```

### Remove worktrees
```bash
git wt rm <name>                     # Remove worktree + delete its branch
git wt clean                         # Remove ALL worktrees for current repo
```

## Key Details

- **Storage**: `~/.git-wt/<repo>/<name>/` — outside the repo, globally managed
- **Branches**: prefixed `wt/` by default (e.g., `wt/my-feature`)
- **Naming**: auto-generates `adjective-noun` names if no name given
- **`rm`**: removes both the worktree directory and its git branch
- **`--copy-env`**: copies all `.env*` files from repo root (critical for dev servers)
- **`origin`**: prints main repo path — works from any worktree or main repo itself

## Environment Variables

- `GIT_WT_HOME` — Root directory for all worktrees (default: `~/.git-wt`)
- `GIT_WT_PREFIX` — Branch name prefix (default: `wt`)

## When to Use

Use `git wt new` when:
- Working on a separate task that needs isolation from current work
- Running parallel agents that each need their own repo copy
- Experimenting without affecting the current branch
- Needing to quickly switch context between features

Use `git wt new --copy-env` when:
- The project has `.env` files needed for the dev server to start
- The worktree needs the same configuration as the main repo

## Workflow: Parallel Agent Isolation

```bash
# Agent 1: create isolated worktree
git wt new --copy-env task-auth

# Agent 2: create another
git wt new --copy-env task-api

# Each agent works independently in their worktree
cd $(git wt path task-auth)

# When done
git wt rm task-auth
git wt rm task-api
```
