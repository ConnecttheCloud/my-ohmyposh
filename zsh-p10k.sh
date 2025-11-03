#!/bin/bash
set -euo pipefail

# Basic checks
if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required. Install sudo or run this script as root."
  exit 1
fi

# Detect package manager (only handling apt here)
if command -v apt >/dev/null 2>&1; then
  PKG_UPDATE="sudo apt update"
  PKG_INSTALL="sudo apt install -y"
else
  echo "Unsupported package manager. Please adapt the script for your distro."
  exit 1
fi

# Update package list
echo "Updating package list..."
$PKG_UPDATE

# Ensure helper packages (install bat later with special handling)
echo "Installing required packages: zsh git curl wget unzip fontconfig ..."
$PKG_INSTALL zsh git curl wget unzip fontconfig || true

# Install bat (handle Debian/Ubuntu batcat name)
if ! command -v bat >/dev/null 2>&1; then
  if apt show bat >/dev/null 2>&1; then
    $PKG_INSTALL bat || true
  else
    $PKG_INSTALL batcat || true
    if command -v batcat >/dev/null 2>&1; then
      sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat || true
    fi
  fi
fi

# Verify installation
echo "Verifying zsh installation..."
zsh --version || true

# Set zsh as the default shell if not already
CURRENT_SHELL="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7 || echo "${SHELL:-}")"
if ! echo "$CURRENT_SHELL" | grep -q "zsh"; then
  echo "Setting zsh as the default shell..."
  chsh -s "$(command -v zsh)" || echo "chsh failed or requires password; set shell manually."
fi

echo "zsh installation steps complete. You may need to log out and log back in."

# Backup existing .zshrc if it exists
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    echo "Backing up existing .zshrc to .zshrc.backup"
    mv "$ZSHRC" "$ZSHRC.backup"
fi

# Create Alias File 
ALIAS_FILE="$HOME/.zsh_aliases"
echo "Creating alias file at $ALIAS_FILE..."
cat << EOF > "$ALIAS_FILE"
# Custom Aliases

alias ls='ls --color=auto'
#alias vim='nvim'
alias c='clear'
alias ll='ls -alth --color=auto'
alias va='vim $HOME/.zsh_aliases'
alias vcfg='vim $HOME/.zshrc'
alias pbpaste='xclip -selection clipboard -o'
alias topcpu='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head'
alias topmem='ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head'
EOF

# Install Nerd Fonts (Powerlevel10k requires a Nerd Font)
echo "Installing Nerd Fonts..."
NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/JetBrainsMono.zip"
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"
TMP_ZIP="/tmp/JetBrainsMono.zip"
if command -v wget >/dev/null 2>&1; then
  wget -q -O "$TMP_ZIP" "$NERD_FONT_URL"
else
  curl -sSL -o "$TMP_ZIP" "$NERD_FONT_URL"
fi
if [ -f "$TMP_ZIP" ]; then
  unzip -o "$TMP_ZIP" -d "$FONT_DIR"
  rm -f "$TMP_ZIP"
  find "$FONT_DIR" -type f -exec chmod 644 {} \; || true
  fc-cache -fv || true
  echo "Nerd Font installed or updated."
else
  echo "Failed to download Nerd Font. Please install a Nerd Font manually."
fi

echo "Creating new .zshrc from template..."
cat << EOF > "$ZSHRC"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname "$ZINIT_HOME")"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light MichaelAquilina/zsh-you-should-use
zinit light fdellwing/zsh-bat

# Add in snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::azure
zinit snippet OMZP::aws
zinit snippet OMZP::terraform
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found
zinit snippet OMZP::web-search

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
#zstyle ':completion:*' menu no
#zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
#zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Source aliases if present
[ -f "$HOME/.zsh_aliases" ] && source "$HOME/.zsh_aliases"

EOF

echo "Install complete. Start a new terminal or run 'exec zsh'. Then run 'p10k configure' to finish Powerlevel10k setup."







