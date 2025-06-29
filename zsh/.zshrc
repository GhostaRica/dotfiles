# Load all config fragments
for config_file in "$ZDOTDIR/config/"*.zsh; do
  source "$config_file"
done



# Set the correct path for Oh My Zsh


# Syntax highlighting
if [[ -e $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Autosuggestions
if [[ -e $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi


# Oh My Zsh
plugins=(git zsh-nvm-lazy-load zsh-syntax-highlighting zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh
