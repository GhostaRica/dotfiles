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