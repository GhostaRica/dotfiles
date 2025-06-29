ripmusic() {
    SCRIPT_DIR=~/Github/youtube-music-ripper
    source "$SCRIPT_DIR/.venv/bin/activate"
    trap deactivate EXIT
    (cd "$SCRIPT_DIR" && python launcher.py "$@")
}

update-dotfiles() {
  local DOTFILES_DIR="$HOME/.dotfiles"

  if [[ -d "$DOTFILES_DIR" ]]; then
    echo "📦 Updating dotfiles..."
    cd "$DOTFILES_DIR" || return
    git pull --quiet && echo "✅ Pulled latest changes"

    if [[ -x ./install.sh ]]; then
      echo "🔧 Re-running install.sh..."
      ./install.sh --skip-deps
    else
      echo "⚠️ install.sh is missing or not executable"
    fi
  else
    echo "❌ Dotfiles repo not found at $DOTFILES_DIR"
  fi
}

python_venv() {
  MYVENV=./.venv
  [[ -d $MYVENV ]] && source $MYVENV/bin/activate > /dev/null 2>&1
  [[ ! -d $MYVENV ]] && deactivate > /dev/null 2>&1
}

autoload -U add-zsh-hook
add-zsh-hook chpwd python_venv
