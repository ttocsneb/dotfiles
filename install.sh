#!/bin/bash

export DOTFILES=${DOTFILES:-$HOME/.dotfiles}

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

function backup {
  BACKUP_DOTFILES=${BACKUP_DOTFILES:-$HOME/.original-dotfiles}
  echo Backing up old dotfiles into $BACKUP_DOTFILES
  echo ====================
  nvim_conf=${XDG_CONFIG_HOME:-$HOME/.config}/nvim
  mkdir -p $BACKUP_DOTFILES
  find ~ $nvim_conf -maxdepth 1 \
    -name .zshrc \
    -or -name .vimrc \
    -or -name .tmux.conf \
    -or -name init.vim \
    | xargs -r mv -v -t $BACKUP_DOTFILES
  echo --------------------
}

function link {
  echo Linking new dotfiles
  echo ====================
  ln -sv $DOTFILES/zsh/zshrc.lnk $HOME/.zshrc
  ln -sv $DOTFILES/tmux/tmux.conf.lnk $HOME/.tmux.conf
  ln -sv $DOTFILES/vim/vimrc $HOME/.vimrc 
  if is_no "$use_vim"; then
    mkdir -pv $nvim_conf
    ln -sv $DOTFILES/vim/init.vim.lnk $nvim_conf/init.vim
  fi
  echo --------------------
}

if [ -d $DOTFILES/.git ]; then
  cd $DOTFILES
  # Check for updates
  git fetch
  branch="$(git branch | grep \* | cut -d ' ' -f2-)"
  if ! git merge-base --is-ancestor "origin/$branch" HEAD; then
    echo There is an update to Dotfiles!
    read -p "Do you want to update? (y/N): " cont
    if is_yes "$cont"; then
      echo Updating dotfiles
      echo ====================
      if ! [[ $(git status -u -s) == "" ]]; then
        pop=YES
        git stash
      fi
      git pull
      git submodule update --remote --merge
      if [[ $POP == "YES" ]]; then
        git stash pop
      fi
      echo --------------------
      echo Successfully update dotfiles
    fi
  fi
  if ! [[ $(readlink "$HOME/.zshrc") == "$DOTFILES/zsh/zshrc.lnk" ]]; then
    echo "dotfiles isn't linked to your home directory."
    read -p "Should I link it for you? (Y/n): " linked
    if ! is_no "$linked"; then
      backup
      link
    fi
  fi
  exit 0
elif [ -d $DOTFILES ]; then
  echo "'$DOTFILES' already exists!"
  echo "If you wan to change the install directory for dotfiles, you can set the 'DOTFILES' variable before running this command"
  read -p "Would you like me to delete '$DOTFILES' for you? (y/N): " delet
  if is_yes "$delet"; then
    rm -r $DOTFILES
  else
    echo "Stopping install"
    exit 0
  fi
fi

backup

packages=("zsh" "tmux" "nvim")
to_install=()
for package in ${packages[@]}; do
  if ! hash $package &> /dev/null; then
    to_install+=("$package")
  fi
done

use_vim="no"
vim="nvim"
if [[ " ${to_install[@]} " =~ " nvim " ]]; then
  read -p "neovim isn't installed.  Should I use vim instead? (Y/n)" use_vim
  if ! is_no "$use_vim"; then
    tmp=(${to_install[@]})
    to_install=()
    for el in ${to_install[@]}; do
      if [[ "$el" != "nvim" ]]; then
        to_install+=("$el")
      fi
    done
    vim="vim"
  fi
fi

if [ ${#to_install[@]} -gt 0 ]; then
  echo "Please install the following packages before installing"
  for package in ${to_install[@]}; do
    printf "\t$package\n"
  done
  exit 1
fi

echo Cloning dotfiles
echo ====================
git clone --depth=1 https://github.com/ttocsneb/dotfiles.git $DOTFILES
cd $DOTFILES
git submodule init
git submodule update --remote
echo --------------------

# echo Installing Oh-My-Zsh
# echo ====================
# ZSH=$DOTFILES/zsh/oh-my-zsh/
# RUNZSH=no
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# rm $HOME/.zshrc
# echo --------------------

link

if ! is_no "$use_vim"; then
  echo disabling neovim
  sed -i -e '/vim*=/ s/^#*\s*/# /' $DOTFILES/zsh/aliases.sh
fi

echo Installing vim plugins
$vim +PluginInstall +qall

echo Making sure \$DOTFILES stays correct
sed -i -e "s|\$HOME/.dotfiles|$DOTFILES|g" $DOTFILES/zsh/zshrc.lnk

# Setup the tmux files
$DOTFILES/tmux/setup.sh

read -p "Would you like to use PowerLevel9k? [Y/n] " pl9k
if is_no "$pl9k"; then
  echo Changing theme from PowerLevel9k to ttocsneb
  sed -i -e '/ttocsneb.zsh/ s/^#*\s*//' $DOTFILES/zsh/zshrc.lnk
  sed -i -e '/pl9k.zsh/ s/^#*\s*/# /' $DOTFILES/zsh/zshrc.lnk
fi

new_shell=$(which zsh)
echo "Changing shell to '$new_shell'"
echo ====================
chsh -s $new_shell
echo --------------------

echo Done!

read -p "Should I change your shell? (Y/n): " changeshell
if ! is_no "$changshell"; then
  $new_shell
else
  echo "Restart your shell, or run '$new_shell'"
fi
