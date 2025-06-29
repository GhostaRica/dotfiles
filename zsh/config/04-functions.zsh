ripmusic() {
    SCRIPT_DIR=~/Github/youtube-music-ripper
    source "$SCRIPT_DIR/.venv/bin/activate"
    trap deactivate EXIT
    (cd "$SCRIPT_DIR" && python launcher.py "$@")
}

python_venv() {
  MYVENV=./.venv
  [[ -d $MYVENV ]] && source $MYVENV/bin/activate > /dev/null 2>&1
  [[ ! -d $MYVENV ]] && deactivate > /dev/null 2>&1
}

autoload -U add-zsh-hook
add-zsh-hook chpwd python_venv
