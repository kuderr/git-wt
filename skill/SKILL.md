---
name: git-wt
description: Fast git worktree manager. Use when the user wants to create, list, switch between, or clean up git worktrees. Handles parallel development workflows, AI agent isolation, and multi-branch work.
---

# git-wt — Git Worktree Manager

Manages isolated git worktrees stored globally at `~/.git-wt/<repo>/<name>/`.

## When to Use

- User wants to work on multiple branches simultaneously
- User needs isolated directories for parallel AI agent work
- User asks about worktrees or branching workflows
- User wants to fork a branch for experimentation

## Commands

### Create a worktree
```bash
git wt new                           # Auto-named (e.g., swift-jade)
git wt new my-feature                # Named
git wt new -b main hotfix            # Fork from specific branch
git wt new --copy-env experiment     # Copy .env* files
git wt new --no-branch scratch       # Detached HEAD
```

### Navigate
```bash
cd $(git wt path <name>)             # Jump into worktree
git wt open <name>                   # Open in Cursor/VS Code
```

### List & inspect
```bash
git wt list                          # Worktrees for current repo
git wt list-all                      # Worktrees across all repos
```

### Clean up
```bash
git wt rm <name>                     # Remove worktree + branch
git wt clean                         # Remove ALL worktrees for current repo
```

## Key Details

- Worktrees stored at `~/.git-wt/<repo>/<name>/` (outside the repo)
- Branches prefixed `wt/` by default (configurable via `GIT_WT_PREFIX`)
- `rm` also deletes the associated branch
- `clean` removes all managed worktrees and prunes

## Environment Variables

- `GIT_WT_HOME` — Root directory (default: `~/.git-wt`)
- `GIT_WT_PREFIX` — Branch prefix (default: `wt`)

## Workflow: Parallel Agent Work

```bash
# Create isolated worktree for a task
git wt new --copy-env auth-refactor

# Work in it
cd $(git wt path auth-refactor)

# When done, clean up
git wt rm auth-refactor
```
