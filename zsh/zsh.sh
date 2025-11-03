curl -fSsL https://raw.githubusercontent.com/ConnecttheCloud/my-ohmyposh/refs/heads/main/zsh/install.sh | bash 

# Backup .zshrc file if exist
# ZSHRC="$HOME/.zshrc"
# if [ -f "$ZSHRC" ]; then
# echo "Backing up existing .zshrc to .zshrc.backup"
# mv "$ZSHRC" "$ZSHRC.backup"
# fi

curl -o ~/.zshrc https://raw.githubusercontent.com/ConnecttheCloud/my-ohmyposh/refs/heads/main/zsh/.zshrc

echo 'Installation complete: type "zsh" and "chsh -s $(which zsh)" to configure zsh and powerlevel10k setup'
echo 'And then, type "fabric --setup" to setup Fabric AI'
