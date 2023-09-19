#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\aliens.omp.json" | Invoke-Expression
#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\pixelrobots.omp.json" | Invoke-Expression
#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\blue-owl.omp.json" | Invoke-Expression
#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\mytheme.omp.json" |  Invoke-Expression

oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/ConnecttheCloud/my-ohmyposh/main/mytheme.omp.json'  |  Invoke-Expression


new-alias grep findstr
#FFEB3B



##ADD below line to configure for WSL Linux
#window_user="/mnt/c/users/shwe.linhtet.OCLMMLTAS54"
#eval "$(oh-my-posh --init --shell bash --config $window_user/AppData/Local/Programs/oh-my-posh/themes/mytheme.omp.json)"

##FOR GITBASH
#eval "$(oh-my-posh --init --shell bash --config $HOME/AppData/Local/Programs/oh-my-posh/themes/mytheme.omp.json)"
#eval "$(oh-my-posh --init --shell bash --config https://raw.githubusercontent.com/ConnecttheCloud/my-ohmyposh/main/mytheme.omp.json)"