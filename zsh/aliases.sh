#!/bin/bash

alias fs='du -bsh --apparent-size'
alias rcopy='rsync -ha --info=progress2'

alias disk="df -h | grep -E 'File|sd'"

alias dotupdate="$DOTFILES/update.sh"

alias urmumbiggay="echo no u"

if [[ $CONFIG_DOT_NEOVIM == "YES" ]]; then
  alias vim='nvim'
  alias vi='nvim'
fi
