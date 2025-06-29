python_venv() {
  MYVENV=./.venv
  [[ -d $MYVENV ]] && source $MYVENV/bin/activate > /dev/null 2>&1
  [[ ! -d $MYVENV ]] && deactivate > /dev/null 2>&1
}

autoload -U add-zsh-hook
add-zsh-hook chpwd python_venv
