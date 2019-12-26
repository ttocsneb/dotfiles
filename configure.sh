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

printf "# vi:syntax=zsh\n\n# Zsh Config\n" > $config

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

read -p "Do you want to check for dotfile updates? [Y/n] " update
CONFIG_UPDATE=NO
if ! is_no "$update"; then
  CONFIG_UPDATE=YES
fi
printf "CONFIG_DOT_UPDATE=$CONFIG_UPDATE\n\n" >> $config

read -p "Would you like to use PowerLevel9k? [y/N] " pl9k
CONF_THEME='$DOTFILES/zsh/themes/ttocsneb.zsh'
if is_yes "$pl9k"; then
  echo Changing theme from PowerLevel9k to ttocsneb
  CONF_THEME='$DOTFILES/zsh/themes/pl9k.zsh'
fi
printf "source \"$CONF_THEME\"\n\n# Tmux Config\n" >> $config 

echo --------------------

# Setup the tmux files
$DOTFILES/tmux/setup.sh "$config"
