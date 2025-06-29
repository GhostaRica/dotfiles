ultra_delete() {
  local SCRIPT="$HOME/.dotfiles/scripts/ultra_delete.sh"

  if [[ ! -x "$SCRIPT" ]]; then
    echo "❌ ultra_delete.sh not found or not executable at $SCRIPT"
    return 1
  fi

  if [[ -z "$1" ]]; then
    echo "Usage: ultra_delete <directory> [--dry-run]"
    return 1
  fi

  "$SCRIPT" "$@"
}