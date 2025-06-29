#!/bin/bash

# Set the absolute path of the dotfiles repo
START_DIR=$PWD
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color helpers
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RESET='\033[0m'

# Parse arguments
SKIP_DEPS=false
for arg in "$@"; do
  case $arg in
    --skip-deps)
      SKIP_DEPS=true
      shift
      ;;
  esac
done

if [ "$SKIP_DEPS" = false ]; then
  ### Installing dependencies
  echo -e "${CYAN}Installing dependencies...${RESET}"

  if [ -f /etc/os-release ]; then
      . /etc/os-release
      DISTRO=$ID
      echo -e "${GREEN}Detected distribution:${RESET} $DISTRO"
  else
      echo -e "${YELLOW}  Cannot determine distribution. /etc/os-release not found.${RESET}"
      exit 1
  fi

  case "$DISTRO" in
      arch|manjaro) 
          echo -e "${CYAN}Using pacman to install zsh...${RESET}"
          sudo pacman -Sy zsh --needed
          ;;
      debian|ubuntu|linuxmint)
          echo -e "${CYAN}Using apt to install zsh...${RESET}"
          sudo apt update && sudo apt install -y zsh
          ;;
      *)
          echo -e "${YELLOW}Unsupported distro: $DISTRO${RESET}"
          ;;
  esac

  ### Install Oh My Zsh
  echo -e "\n${CYAN}Installing Oh My Zsh...${RESET}"
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
      RUNZSH=no KEEP_ZSHRC=yes sh -c \
          "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else 
      echo -e "${GREEN}Oh My Zsh already installed${RESET}"
  fi
else
  echo -e "${YELLOW}Skipping dependency installation (--skip-deps)${RESET}"
fi

### Installing Custom Plugins
echo -e "\n${CYAN}🔌 Installing custom Zsh plugins...${RESET}"

ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"

# List of plugins and their Git URLs
declare -A plugins
plugins=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
  [zsh-nvm-lazy-load]="https://github.com/undg/zsh-nvm-lazy-load.git"
)

for name in "${!plugins[@]}"; do
  plugin_dir="$ZSH_CUSTOM/$name"
  if [ -d "$plugin_dir" ]; then
    echo -e "${YELLOW}🔁 Updating $name...${RESET}"
    git -C "$plugin_dir" pull --quiet
  else
    echo -e "${CYAN}⬇️  Cloning $name...${RESET}"
    git clone --quiet "${plugins[$name]}" "$plugin_dir"
  fi
  echo -e "${GREEN}✔ $name ready${RESET}"
done

### Dotfile linking
echo -e "\n${CYAN}📂 Copying Zsh dotfiles...${RESET}"
mkdir -p "$HOME/.zsh/config"

# Symlink the base dotfiles
ln -sf "$DOTFILES_DIR/zsh/.zshenv" "$HOME/.zshenv" \
    && echo -e "${GREEN}✔ Linked .zshenv${RESET}"

ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zsh/.zshrc" \
    && echo -e "${GREEN}✔ Linked .zsh/.zshrc${RESET}"

# Sync config folder contents
for file in "$DOTFILES_DIR/zsh/config/"*.zsh; do
  ln -sf "$file" "$HOME/.zsh/config/$(basename "$file")" \
    && echo -e "${GREEN}✔ Linked .zsh/config/$file${RESET}"
done

cd $START_DIR
echo -e "\n${GREEN}✔ Done! Start a new terminal or run \`zsh\`${RESET}"
