#!/bin/bash

DOTFILES=${DOTFILES:-$HOME/.dotfiles}

if [ -d $DOTFILES/.git ]; then
  echo It seems that dotfiles is already installed.
  read -p "Do you want to update? (y/N): " cont
  if [[ $cont == "y" ]]; then
    echo Updating dotfiles
    echo ====================
    cd $DOTFILES
    git pull
    git submodule update --remote --merge
    echo --------------------
    echo Successfully update dotfiles
    exit 0
  else
    echo Not making any changes
    exit 0
  fi
elif [ -d $DOTFILES ]; then
  echo "'$DOTFILES' already exists!"
  echo "If you wan to change the install directory for dotfiles, you can set the 'DOTFILES' variable before running this command"
  read -p "Would you like me to delete '$DOTFILES' for you? (y/N): " delet
  if [[ $delet == "y" ]]; then
    rm -r $DOTFILES
  else
    echo "Stopping install"
    exit 0
  fi
fi

BACKUP_DOTFILES=${BACKUP_DOTFILES:-$HOME/.original-dotfiles}
echo Backing up old dotfiles into $BACKUP_DOTFILES
echo ====================
mkdir -p $BACKUP_DOTFILES
find ~ -maxdepth 1 \
  -name .zshrc \
  -or -name .vimrc \
  -or -name .tmux.conf \
  -print0 | xargs -0r mv -v -t $BACKUP_DOTFILES
vim_conf="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.vim"
if [ -f "$vim_conf" ]; then
  mv -v -t $BACKUP_DOTFILES $vim_conf
fi
echo --------------------


packages=("zsh" "tmux" "neovim")
to_install=()
for package in ${to_install[@]}; do
  if ! hash $package; then
    to_install+=("$package")
  fi
done

if [ ${#to_install[@]} -gt 0 ]; then
  read -p "Should I install the packages for you? (y/N)" install
  if [[ $install == "y" ]]; then
    echo "Can't yet install the packages :/"
    # TODO: Install packages
  else
    echo "Not all packages are installed! Please install the following packages"
  fi
  for package in ${to_install[@]}; do
    echo "\t$package"
  done
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

echo Linking new dotfiles
echo ====================
ln -s $DOTFILES/zsh/zshrc.link $HOME/.zshrc
ln -s $DOTFILES/tmux/tmux.conf.lnk $HOME/.tmux.conf
ln -s $DOTFILES/vim/init.vim.lnk $vim_conf
echo --------------------

echo Installing vim plugins
echo ====================
nvim +PluginInstall +qall
echo Done!
echo --------------------

echo "Restart your shell, or run 'source ~/.zshrc'"
