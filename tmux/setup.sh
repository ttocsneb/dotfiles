#!/bin/bash

function is_yes {
  lower=$(echo $1 | tr '[:upper:]' '[:lower:]')
  [[ $lower == y* ]]
  return $?
}

function is_no {
  lower=$(echo $1 | tr '[:upper:]' '[:lower:]')
  [[ $lower == n* ]]
  return $?
}

echo Setting up tmux
echo ====================

read -p "Should tmux use 256 colors? (Y/n)" colors
if is_no "$colors"; then
  sed -i -e '/nerdtheme.sh/ s/^#*\s*/# /' $DOTFILES/tmux/tmux.conf.lnk
  sed -i -e '/nerdtheme.sh/ s/^#*\s*//' $DOTFILES/tmux/tmux.conf.lnk
fi

function sed_themes {
  sed -i -e "$1" $DOTFILES/tmux/nerdtheme.sh
  sed -i -e "$1" $DOTFILES/tmux/ttocsnebtheme.sh
}

read -p "Should tmux display the battery? (y/N)" battery
if ! is_yes "$battery"; then
  sed_themes 's/\$tm_battery //'
fi

read -p "Should tmux display the current song? (y/N)" song
if ! is_yes "$song"; then
  sed_themes 's/\$tm_music //'
fi

echo --------------------
