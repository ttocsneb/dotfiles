#!/bin/bash


! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
	echo 'getopt is outdated or not installed!'
	exit 1
fi

OPTIONS=hb:
LONGOPT=branch:,help

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPT --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  # getopt couldn't parse options
  exit 2
fi

eval set -- "$PARSED"

# Parse options
DOTBRANCH=${DOTBRANCH:-master}
DOTFILES=${DOTFILES:-$HOME/.dotfiles}
while true; do
  case "$1" in
    -h|--help)
      echo "Dotfiles Installer.  This script will install ttocsneb's dotfiles for you.  You will need tmux,zsh and neovim (vim is also acceptable)"
      printf "Arguments:\n\t-h\t\t--help\t\t\tPrint this help message\n\t-b <branch>\t--branch <branch> \tSet the git branch to pull from (default: master) Can set \$DOTBRANCH instead\nPositional Arguments:\n\t[install]\t\t\t\tDirectory to install to (default: \$HOME/.dotfiles) Can set \$DOTFILES instead\n"
      exit 0
      ;;
    -b|--branch)
      DOTBRANCH="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Programming Error"
      exit 3
      ;;
  esac
done
if [[ $# -ge 1 ]]; then
  DOTFILES="$1"
  shift
fi

# Install Functions
function tolow {
  echo $(echo $1 | tr '[:upper:]' '[:lower:]')
}

function is_yes {
  lower="$(tolow $1)"
  [[ $lower == y* ]]
  return $?
}

function is_no {
  lower="$(tolow $1)"
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
        git  -c user.name=temp -c user.email=temp@temp.com stash
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

# Check if Install directory is OK

read -p "Installing Dotfiles on the $DOTBRANCH branch to '$DOTFILES' Is that ok? [Y/n] " install_ok

if is_no $install_ok; then
  echo "Stopping installation.."
  echo "To change the install location, either set \$DOTFILES before running the script, or pass the install location as a parameter"
  exit 1
fi

# Backup existing dotfiles

backup

# Check for necessary packages

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
git clone -b $DOTBRANCH --single-branch --depth=1 https://github.com/ttocsneb/dotfiles.git $DOTFILES
cd $DOTFILES

export ZSH=$DOTFILES/zsh/oh-my-zsh
export RUNZSH=no
rm -r $DOTFILES/zsh/oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
rm $HOME/.zshrc

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

echo Installing vim plugins
$vim +PluginInstall +qall

if ! [[ -e "$HOME/.dotrc" || -e "$DOTFILES/dotrc" ]]; then
  "$DOTFILES/configure.sh"
fi

# new_shell=$(which zsh)
# echo "Changing shell to '$new_shell'"
# echo ====================
# chsh -s $new_shell
# echo --------------------

echo Done!

read -p "Should I run your new shell? (Y/n): " changeshell
if ! is_no "$changshell"; then
  exec zsh -l
else
  echo "Restart your shell, or run '$new_shell'"
fi
