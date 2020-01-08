#!/bin/bash

#!/bin/bash
function tolow {
  echo $(echo $1 | tr '[:upper:]' '[:lower:]')
}

function is_yes {
  lower="$(tolow $1)"
  [[ $lower == y* ]]
  return $?
}

function is_no {
  lower="$(tolow $1)"
  [[ $lower == n* ]]
  return $?
}

echo Configuring Dotfiles
echo ====================

read -p "Do you want to configure local or global config? [L/g]" conf
lower="$(tolow $conf)"
config="$HOME/.dotrc"
if [[ $lower == g* ]]; then
  config="$DOTFILES/dotrc"
fi

if [ -e "$config" ]; then
  echo "Backing up '$config' to $HOME/.original-dotfiles"
  mkdir -p "$HOME/.original-dotfiles"
  mv "$config" "$HOME/.original-dotfiles"
fi

printf "# vi:syntax=zsh\n\n# Dotfiles Config\n" > $config

if [ -z ${use_vim+x} ]; then
  if ! hash nvim &> /dev/null; then
    use_vim="yes"
  else
    use_vim="no"
  fi
fi

CONFIG_DOT_NEOVIM=YES
if ! is_no "$use_vim"; then
  echo disabling neovim
  CONFIG_DOT_NEOVIM=NO
fi
echo "CONFIG_DOT_NEOVIM=$CONFIG_DOT_NEOVIM" >> $config

read -p "Do you want automatically to check for dotfile updates? [Y/n] " update
CONFIG_UPDATE=NO
if ! is_no "$update"; then
  CONFIG_UPDATE=YES
fi
printf "CONFIG_DOT_UPDATE=$CONFIG_UPDATE\n\n" >> $config

read -p "Are you using NerdFonts? [y/N] " nerd

CONF_THEME='$DOTFILES/zsh/themes/ttocsneb.zsh'
CONFIG_NERD='NO'
if is_yes "nerd"; then
  CONFIG_NERD='YES'

  read -p "Would you like to use PowerLevel9k? [Y/n] " pl9k
  if ! is_no "$pl9k"; then
    echo Changing theme from PowerLevel9k to ttocsneb
    CONF_THEME='$DOTFILES/zsh/themes/pl9k.zsh'
  fi
fi
printf "source \"$CONF_THEME\"\n\nexport CONFIG_DOT_NERD=$CONFIG_NERD\n" >> $config 

echo --------------------

# Setup the tmux files
$DOTFILES/tmux/setup.sh "$config"
