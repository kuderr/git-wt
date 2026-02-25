# git-wt shell aliases & functions
# Source this file in your .bashrc / .zshrc:
#   source ~/.git-wt/git-wt/aliases/git-wt.sh
#   — or wherever you keep this file —

# cd into a worktree by name
#   wtcd my-feature
wtcd() {
  local path
  path=$(git wt path "$1" 2>/dev/null) || { echo "error: worktree '$1' not found" >&2; return 1; }
  cd "$path" || return 1
}

# cd into the origin (main) repo from any worktree
#   wto
wto() {
  local path
  path=$(git wt origin 2>/dev/null) || { echo "error: not in a git repo" >&2; return 1; }
  cd "$path" || return 1
}

# Create a new worktree and cd into it
#   wtn my-feature
#   wtn                  (auto-generated name)
#   wtn -b main hotfix
wtn() {
  local output line path
  output=$(git wt new "$@") || return 1
  echo "$output"
  while IFS= read -r line; do
    if [[ "$line" == *"Path:"* ]]; then
      read -r path <<< "${line##*Path:}"
      break
    fi
  done <<< "$output"
  [[ -n "${path:-}" ]] && cd "$path" || return 1
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
  _wtrm()    { compadd -- $(git wt _names 2>/dev/null); }
  _wtopen()  { compadd -- $(git wt _names 2>/dev/null); }
  _wtpath()  { compadd -- $(git wt _names 2>/dev/null); }

  compdef _wtcd wtcd
  compdef _wtrm wtrm
  compdef _wtopen wtopen
  compdef _wtpath wtpath
elif [[ -n "${BASH_VERSION:-}" ]]; then
  # bash
  _wt_alias_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $(compgen -W "$(git wt _names 2>/dev/null)" -- "$cur") )
  }

  complete -F _wt_alias_complete wtcd
  complete -F _wt_alias_complete wtrm
  complete -F _wt_alias_complete wtopen
  complete -F _wt_alias_complete wtpath
fi
