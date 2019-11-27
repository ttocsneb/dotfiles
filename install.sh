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
nvim_conf=${XDG_CONFIG_HOME:-$HOME/.config}/nvim
mkdir -p $BACKUP_DOTFILES
find ~ $nvim_conf -maxdepth 1 \
  -name .zshrc \
  -or -name .vimrc \
  -or -name .tmux.conf \
  -or -name init.vim \
  | xargs -r mv -v -t $BACKUP_DOTFILES
echo --------------------


packages=("zsh" "tmux" "nvim")
to_install=()
for package in ${packages[@]}; do
  if ! hash $package &> /dev/null; then
    to_install+=("$package")
  fi
done

if [ ${#to_install[@]} -gt 0 ]; then
  read -p "Should I install the packages for you? (y/N)" install
  if [[ $install == "y" ]]; then
    echo "Can't yet install the packages :/"
    # TODO: Install packages
  fi
  echo "Please install the following packages"
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

echo Linking new dotfiles
echo ====================
ln -sv $DOTFILES/zsh/zshrc.lnk $HOME/.zshrc
ln -sv $DOTFILES/tmux/tmux.conf.lnk $HOME/.tmux.conf
ln -sv $DOTFILES/vim/vimrc $HOME/.vimrc 
mkdir -pv $nvim_conf
ln -sv $DOTFILES/vim/init.vim.lnk $nvim_conf/init.vim
echo --------------------

echo Installing vim plugins
nvim +PluginInstall +qall

if [[ $DOTFILES != "$HOME/.dotfiles" ]]; then
  echo Making sure \$DOTFILES stays correct
  sed -i -e "s|\$HOME/.dotfiles|$DOTFILES|g" $DOTFILES/zsh/zshrc.lnk
fi

read -p "Would you like to use PowerLevel9k? [Y/n] " pl9k
if [[ $pl9k == n ]]; then
  echo Changing theme from PowerLevel9k to ttocsneb
  sed -i -e '/ttocsneb.zsh/ s/^#*\s*//' $DOTFILES/zsh/zshrc.lnk
  sed -i -e '/pl9k.zsh/ s/^#*\s*/# /' $DOTFILES/zsh/zshrc.lnk
fi
echo "Done!"
echo "Restart your shell, or run 'source ~/.zshrc'"
