#!/bin/bash
config=$1

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

read -p "Will your terminal support 256 colors? (Y/n)" colors
CONFIG_TM_THEME=ttocsnebtheme
TERM_TYPE=xterm
if ! is_no "$colors"; then
  TERM_TYPE=xterm-256color
  CONFIG_TM_THEME=nerdtheme
fi
echo "export TERM=\"$TERM_TYPE\"" >> $config
echo "export CONFIG_DOT_THEME=$CONFIG_TM_THEME" >> $config

read -p "Should tmux display the battery? (y/N)" battery
CONFIG_BATTERY=YES
if ! is_yes "$battery"; then
  CONFIG_BATTERY=NO
fi
echo "export CONFIG_DOT_BATTERY=$CONFIG_BATTERY" >> $config

read -p "Should tmux display the current song? (y/N)" song
CONFIG_MUSIC=YES
if ! is_yes "$song"; then
  CONFIG_MUSIC=NO
fi
echo "export CONFIG_DOT_MUSIC=$CONFIG_MUSIC" >> $config

echo --------------------
