#!/usr/bin/env bash
# git-wt aliases installer
# Usage: curl -fsSL https://raw.githubusercontent.com/kuderr/git-wt/main/aliases/install.sh | bash

# shellcheck disable=SC2059  # intentional: ANSI color codes in printf format strings
set -euo pipefail

REPO="kuderr/git-wt"
BRANCH="main"
URL="https://raw.githubusercontent.com/${REPO}/${BRANCH}/aliases/git-wt.sh"
INSTALL_DIR="${HOME}/.local/share/git-wt"
INSTALL_PATH="${INSTALL_DIR}/aliases.sh"

# Colors
if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
  GREEN=$'\033[0;32m' DIM=$'\033[2m' BOLD=$'\033[1m' RESET=$'\033[0m'
else
  GREEN='' DIM='' BOLD='' RESET=''
fi

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
printf "${BOLD}Installing git-wt aliases...${RESET}\n\n"

# Download aliases file
mkdir -p "$INSTALL_DIR"
download "$URL" > "$INSTALL_PATH"
printf "  ${GREEN}✓${RESET} Downloaded aliases to %s\n" "$INSTALL_PATH"

# Detect shell rc file
if [[ "${SHELL:-}" == *"zsh"* ]]; then
  RC_FILE="${HOME}/.zshrc"
elif [[ "${SHELL:-}" == *"bash"* ]]; then
  RC_FILE="${HOME}/.bashrc"
else
  RC_FILE=""
fi

# Add source line if not already present
if [[ -n "$RC_FILE" ]]; then
  if [[ -f "$RC_FILE" ]] && grep -qF "$INSTALL_PATH" "$RC_FILE" 2>/dev/null; then
    printf "  ${GREEN}✓${RESET} Already sourced in %s\n" "$RC_FILE"
  else
    printf '\n# git-wt aliases\nsource "%s"\n' "$INSTALL_PATH" >> "$RC_FILE"
    printf "  ${GREEN}✓${RESET} Added source line to %s\n" "$RC_FILE"
  fi
else
  echo ""
  printf "  Add to your shell profile:\n"
  printf "    ${DIM}source \"%s\"${RESET}\n" "$INSTALL_PATH"
fi

echo ""
printf "${GREEN}Done!${RESET} Restart your shell or run:\n"
printf "  ${DIM}source \"%s\"${RESET}\n" "$INSTALL_PATH"
echo ""
