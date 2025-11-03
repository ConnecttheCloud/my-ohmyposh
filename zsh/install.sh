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

# Installing Fabric AI
curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/scripts/installer/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/danielmiessler/Fabric/refs/heads/main/completions/setup-completions.sh | sh

# Copy Fabric completion file to a directory in your $fpath
mkdir -p ~/.zsh/completions
cp completions/_fabric ~/.zsh/completions/

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


echo "Install complete. Start a new terminal or run 'exec zsh'. Then run 'p10k configure' to finish Powerlevel10k setup."


`zsh`





