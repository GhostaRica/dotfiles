autoload -U colors && colors

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

update-dotfiles() {
  local DOTFILES_DIR="$HOME/.dotfiles"

  if [[ -d "$DOTFILES_DIR" ]]; then
    echo "Updating dotfiles..."
    cd "$DOTFILES_DIR" || return
    git pull --quiet && echo "✅ Pulled latest changes"

    if [[ -x ./install.sh ]]; then
      echo "Re-running install.sh..."
      ./install.sh --skip-deps
    else
      echo "install.sh is missing or not executable"
    fi
  else
    echo "Dotfiles repo not found at $DOTFILES_DIR"
  fi
}

# Show disk space
sys::disk_space() {
  local current_space_mb=$(df / | tail -1 | awk '{print $4}')
  echo $((current_space_mb / 1024))
}

# Remove orphaned packages, excluding optionally required ones
clean_orphans() {
  echo "${CYAN}Removing unused packages...${RESET}"
  local unused_packages=$(pacman -Qdtq)
  while [[ -n "$unused_packages" ]]; do
    local to_remove=()
    for pkg in ${(f)unused_packages}; do
      local optional_info=$(pacman -Qi "$pkg" | grep "Optional For")
      if [[ "$optional_info" == "Optional For    : None" ]]; then
        to_remove+=("$pkg")
      else
        echo "${YELLOW}⚠️  $pkg is optionally required by:${RESET}"
        echo "$optional_info"
      fi
    done

    if [[ ${#to_remove[@]} -gt 0 ]]; then
      echo "${RED}Removing:${RESET} ${to_remove[@]}"
      sudo pacman -Rn "${to_remove[@]}" --noconfirm
      unused_packages=$(pacman -Qdtq)
    else
      echo "${GREEN}✅ No orphaned packages left to remove.${RESET}"
      break
    fi
  done
}

# Clear yay and pacman caches
clean_pac_caches() {
  echo "${CYAN}Cleaning yay and pacman cache...${RESET}"
  yay -Sc --noconfirm
}

# Vacuum journal logs
clean_journal() {
  echo "${CYAN}Cleaning journal logs...${RESET}"
  sudo journalctl --vacuum-time=2weeks --vacuum-size=100M
}

# Clean ~/.cache files not accessed in 14 days, excluding folders
clean_cache_files() {
  local ignored_folders=(
    "$HOME/.cache/yay"
    "$HOME/.cache/yarn"
  )

  # Build the exclude pattern for find
  local exclude_args=()
  for folder in "${ignored_folders[@]}"; do
    exclude_args+=(-not -path "${folder}/*")
  done

  echo -e "${RED}Deleting .cache files not accessed in 14+ days (excluding yay/yarn)...${NC}"

  # Delete files older than 14 days except ignored folders
  find "$HOME/.cache" "${exclude_args[@]}" -type f -atime +14 -delete

  echo -e "${CYAN}Deleting empty directories in ~/.cache...${NC}"
  find "$HOME/.cache" "${exclude_args[@]}" -type d -empty -delete

  echo -e "${GREEN}Finished cleaning ~/.cache.${NC}"
}

# Full cleanup runner
full_cleanup() {
  local start=$(sys::disk_space)
  echo "${CYAN}Initial disk space: ${GREEN}${start} MB${RESET}"

  clean_orphans
  clean_caches
  clean_journal
  # clean_old_cache  # Uncomment if you want it active

  local end=$(sys::disk_space)
  echo "${CYAN}Final disk space: ${GREEN}${end} MB${RESET}"
  echo "${CYAN}Saved: ${GREEN}$((end - start)) MB${RESET}"
}

compdef _functions clean_orphans
compdef _functions clean_pac_caches
compdef _functions clean_cache_files
compdef _functions clean_journal
compdef _functions full_cleanup
