curl -fSsL https://raw.githubusercontent.com/ConnecttheCloud/my-ohmyposh/refs/heads/main/zsh/install.sh | bash 

`zsh`

# Backup .zshrc file if exist
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
echo "Backing up existing .zshrc to .zshrc.backup"
mv "$ZSHRC" "$ZSHRC.backup"
fi

curl -o ~/.zshrc https://raw.githubusercontent.com/ConnecttheCloud/my-ohmyposh/refs/heads/main/zsh/.zshrc

echo "Installation complete: type `zsh` to configure zsh and powerlevel 10k setup"
