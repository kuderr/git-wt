#!/usr/bin/env bash
# git-wt installer
# Usage: curl -fsSL https://raw.githubusercontent.com/kuderr/git-wt/main/install.sh | bash
#   or:  curl ... | bash -s -- --prefix /usr/local/bin

# shellcheck disable=SC2059  # intentional: ANSI color codes in printf format strings
set -euo pipefail

REPO="kuderr/git-wt"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}"

# Defaults
INSTALL_DIR="${HOME}/.local/bin"
INSTALL_COMPLETIONS=true

# Colors
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  GREEN=$'\033[0;32m' DIM=$'\033[2m' BOLD=$'\033[1m' RESET=$'\033[0m'
else
  GREEN='' DIM='' BOLD='' RESET=''
fi

# Parse flags
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)           INSTALL_DIR="$2"; shift 2 ;;
    --no-completions)   INSTALL_COMPLETIONS=false; shift ;;
    -h|--help)
      echo "Usage: install.sh [--prefix DIR] [--no-completions]"
      echo "  --prefix DIR        Install directory (default: ~/.local/bin)"
      echo "  --no-completions    Skip shell completion installation"
      exit 0
      ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# Download helper
download() {
  if command -v curl &>/dev/null; then
    curl -fsSL "$1"
  elif command -v wget &>/dev/null; then
    wget -qO- "$1"
  else
    echo "Error: curl or wget required" >&2
    exit 1
  fi
}

echo ""
printf "${BOLD}Installing git-wt...${RESET}\n\n"

# Install main script
mkdir -p "$INSTALL_DIR"
download "${BASE_URL}/bin/git-wt" > "${INSTALL_DIR}/git-wt"
chmod +x "${INSTALL_DIR}/git-wt"
printf "  ${GREEN}✓${RESET} Installed ${BOLD}git-wt${RESET} to %s\n" "${INSTALL_DIR}/git-wt"

# Install completions
if $INSTALL_COMPLETIONS; then
  # Bash completion
  bash_comp_dir="${HOME}/.local/share/bash-completion/completions"
  mkdir -p "$bash_comp_dir"
  download "${BASE_URL}/completions/git-wt.bash" > "${bash_comp_dir}/git-wt"
  printf "  ${GREEN}✓${RESET} Bash completions → %s\n" "${bash_comp_dir}/git-wt"

  # Zsh completion
  zsh_comp_dir="${HOME}/.local/share/zsh/site-functions"
  mkdir -p "$zsh_comp_dir"
  download "${BASE_URL}/completions/_git-wt" > "${zsh_comp_dir}/_git-wt"
  printf "  ${GREEN}✓${RESET} Zsh completions  → %s\n" "${zsh_comp_dir}/_git-wt"

  # Check if zsh fpath includes the completion dir
  if [[ "${SHELL:-}" == *"zsh"* ]]; then
    if ! zsh -c 'echo $fpath' 2>/dev/null | grep -q "site-functions"; then
      echo ""
      printf "  ${DIM}Add to ~/.zshrc for zsh completions:${RESET}\n"
      printf "  ${DIM}  fpath=(~/.local/share/zsh/site-functions \$fpath)${RESET}\n"
    fi
  fi
fi

# Check PATH
if ! echo ":${PATH}:" | grep -q ":${INSTALL_DIR}:"; then
  echo ""
  printf "  ⚠  %s is not in your PATH\n" "$INSTALL_DIR"
  printf "  Add to your shell profile:\n"
  printf "    ${DIM}export PATH=\"%s:\$PATH\"${RESET}\n" "$INSTALL_DIR"
fi

echo ""
printf "${GREEN}Done!${RESET} Run ${BOLD}git wt help${RESET} to get started.\n"
echo ""
