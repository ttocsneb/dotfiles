#!/bin/bash

cd $DOTFILES

branch="$(git branch | grep \* | cut -d ' ' -f2-)"

echo Checking for updates in the $branch branch of dotfiles

bash -c "$(curl -fsSL https://raw.githubusercontent.com/ttocsneb/dotfiles/$branch/install.sh)"
