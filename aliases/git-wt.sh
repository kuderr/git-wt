# git-wt shell aliases & functions
# Source this file in your .bashrc / .zshrc:
#   source ~/.git-wt/git-wt/aliases/git-wt.sh
#   — or wherever you keep this file —

# cd into a worktree by name
#   wtcd my-feature
wtcd() {
  local wt_path
  wt_path=$(git wt path "$1" 2>/dev/null) || { echo "error: worktree '$1' not found" >&2; return 1; }
  cd "$wt_path" || return 1
}

# cd into the origin (main) repo from any worktree
#   wto
wto() {
  local wt_path
  wt_path=$(git wt origin 2>/dev/null) || { echo "error: not in a git repo" >&2; return 1; }
  cd "$wt_path" || return 1
}

# Create a new worktree and cd into it
#   wtn my-feature
#   wtn                  (auto-generated name)
#   wtn -b main hotfix
wtn() {
  local output line wt_path
  output=$(git wt new "$@") || return 1
  echo "$output"
  while IFS= read -r line; do
    if [[ "$line" == *"Path:"* ]]; then
      read -r wt_path <<< "${line##*Path:}"
      break
    fi
  done <<< "$output"
  [[ -n "${wt_path:-}" ]] && cd "$wt_path" || return 1
}

# Check out an existing branch into a worktree and cd into it
#   wtco feature/login
#   wtco origin/fix/bug-42
#   wtco feature/login my-name
wtco() {
  local output line wt_path
  output=$(git wt checkout "$@") || return 1
  echo "$output"
  while IFS= read -r line; do
    if [[ "$line" == *"Path:"* ]]; then
      read -r wt_path <<< "${line##*Path:}"
      break
    fi
  done <<< "$output"
  [[ -n "${wt_path:-}" ]] && cd "$wt_path" || return 1
}

# Remove current worktree and cd back to origin
#   wtbye
wtbye() {
  local origin
  origin=$(git wt origin 2>/dev/null) || { echo "error: not in a git repo" >&2; return 1; }

  local cwd
  cwd=$(pwd -P)

  if [[ "$cwd" == "$origin" || "$cwd" == "$origin/"* ]]; then
    echo "error: already in origin repo, not in a worktree" >&2
    return 1
  fi

  local wt_home="${GIT_WT_HOME:-${HOME}/.git-wt}"
  local repo_name
  repo_name=$(basename "$origin")
  local wt_root="${wt_home}/${repo_name}"

  if [[ "$cwd" != "${wt_root}/"* ]]; then
    echo "error: not in a git-wt managed worktree" >&2
    return 1
  fi

  local wt_name="${cwd#"${wt_root}/"}"
  wt_name="${wt_name%%/*}"

  cd "$origin" || return 1
  git wt rm "$wt_name"
}

# List worktrees (current repo)
alias wtls='git wt list'

# List all worktrees (all repos)
alias wtla='git wt list-all'

# Remove a worktree
alias wtrm='git wt rm'

# Open worktree in editor
alias wtopen='git wt open'

# Remove all worktrees for current repo
alias wtclean='git wt clean'

# Print worktree path (for scripting)
alias wtpath='git wt path'

# --- Completions for aliases ---
if [[ -n "${ZSH_VERSION:-}" ]]; then
  # zsh: reuse git-wt completions for worktree-name arguments
  _wtcd()    { compadd -- $(git wt _names 2>/dev/null); }
  _wtn()     { _arguments '*:branch:_git_branch_names'; }
  _wtco()    { compadd -- $(git branch --all --format='%(refname:short)' 2>/dev/null); }
  _wtrm()    { compadd -- $(git wt _names 2>/dev/null); }
  _wtopen()  { compadd -- $(git wt _names 2>/dev/null); }
  _wtpath()  { compadd -- $(git wt _names 2>/dev/null); }

  compdef _wtcd wtcd
  compdef _wtco wtco
  compdef _wtrm wtrm
  compdef _wtopen wtopen
  compdef _wtpath wtpath
elif [[ -n "${BASH_VERSION:-}" ]]; then
  # bash
  _wt_alias_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(git wt _names 2>/dev/null)" -- "$cur") )
  }

  _wt_branch_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(git branch --all --format='%(refname:short)' 2>/dev/null)" -- "$cur") )
  }

  complete -F _wt_alias_complete wtcd
  complete -F _wt_branch_complete wtco
  complete -F _wt_alias_complete wtrm
  complete -F _wt_alias_complete wtopen
  complete -F _wt_alias_complete wtpath
fi
