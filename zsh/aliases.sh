#!/bin/bash

alias fs='du -bsh --apparent-size'
alias rcopy='rsync -ha --info=progress2'

alias open='xdg-open'

alias disk="df -h | grep --color=never -E 'File|sd'"

alias dotupdate="$DOTFILES/update.sh"

alias lt="lesstree"
alias simpletree="lesstree --filelimit=20"
alias st="simpletree"

alias urmumbiggay="echo no u"

alias filetype='file -b --mime-type'
alias ft='findtext'
alias ml='maybeless'

if [[ $CONFIG_DOT_NEOVIM == "YES" ]]; then
  alias vim='nvim'
  alias vi='nvim'
fi

function lesstree() {
  # Check if the function is being piped
  if [ -t 1 ]; then
    # Terminal

    maybeless "tree" -C $@
  else
    # Pipe, output normal tree
    "tree" $@
  fi
}

