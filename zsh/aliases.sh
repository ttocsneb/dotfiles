#!/bin/bash

alias fs='du -bsh --apparent-size'
alias rcopy='rsync -ha --info=progress2'

alias disk="df -h | grep -E 'File|sd'"

alias dotupdate="$DOTFILES/update.sh"

alias tree="lesstree"

alias urmumbiggay="echo no u"

if [[ $CONFIG_DOT_NEOVIM == "YES" ]]; then
  alias vim='nvim'
  alias vi='nvim'
fi

function lesstree() {
  # Check if the function is being piped
  if [ -t 1 ]; then
    # Terminal

    # Check if the tree command is larger than the terminal window
    TREE=$("tree" -C $@)
    if [ $(echo $TREE | wc -l) -gt $(tput lines) ]; then
      # If it is larger, use less to allow scrolling
      echo $TREE | less -R
    else
      # Why use less, when the output is smaller than the terminal
      echo $TREE
    fi
  else
    # Pipe, output normal tree
    "tree" $@
  fi
}
