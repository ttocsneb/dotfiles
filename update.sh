#!/bin/bash

cd $DOTFILES

branch="$(git branch | grep -Po '(?<=\* ).*')"

if git branch --all | grep -q "remotes/.*/$branch"; then
  echo Checking for updates in the $branch branch of dotfiles
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ttocsneb/dotfiles/$branch/install.sh)" -- --silent
fi
