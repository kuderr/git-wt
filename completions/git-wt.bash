# bash completion for git-wt
# Source this file or place in ~/.local/share/bash-completion/completions/git-wt

_git_wt() {
  local cur prev subcmd
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  subcmd=""

  # Find the subcommand
  local i
  for ((i = 1; i < COMP_CWORD; i++)); do
    case "${COMP_WORDS[i]}" in
      -q|--quiet) continue ;;
      new|checkout|co|list|list-all|ls|rm|remove|path|cd|origin|open|adopt|clean|help|version|--version|-v)
        subcmd="${COMP_WORDS[i]}"
        break
        ;;
    esac
  done

  # Complete subcommands
  if [[ -z "$subcmd" ]]; then
    if [[ "$cur" == -* ]]; then
      COMPREPLY=($(compgen -W "-q --quiet --help --version" -- "$cur"))
    else
      COMPREPLY=($(compgen -W "new checkout list list-all adopt rm path origin open clean help version" -- "$cur"))
    fi
    return
  fi

  case "$subcmd" in
    rm|remove|path|cd|open)
      # Complete with existing worktree names
      local names
      names=$(git wt _names 2>/dev/null)
      if [[ -n "$names" ]]; then
        COMPREPLY=($(compgen -W "$names" -- "$cur"))
      fi
      ;;
    adopt)
      # Complete with directory paths
      COMPREPLY=($(compgen -d -- "$cur"))
      ;;
    new)
      case "$prev" in
        -b|--base)
          # Complete with branch names
          local branches
          branches=$(git branch --format='%(refname:short)' 2>/dev/null)
          COMPREPLY=($(compgen -W "$branches" -- "$cur"))
          ;;
        -p|--prefix)
          # User types custom prefix
          ;;
        *)
          if [[ "$cur" == -* ]]; then
            COMPREPLY=($(compgen -W "-b --base -p --prefix --no-branch --copy-env --copy-ai" -- "$cur"))
          fi
          ;;
      esac
      ;;
    checkout|co)
      if [[ "$cur" == -* ]]; then
        COMPREPLY=($(compgen -W "--copy-env --copy-ai" -- "$cur"))
      else
        # Complete with local + remote branch names
        local branches
        branches=$(git branch --all --format='%(refname:short)' 2>/dev/null)
        COMPREPLY=($(compgen -W "$branches" -- "$cur"))
      fi
      ;;
  esac
}

# Register for both `git-wt` and `git wt`
complete -F _git_wt git-wt
# Git subcommand completion (git discovers _git_wt automatically)
