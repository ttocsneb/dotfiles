#!/bin/bash

###################################################
#
# Process Arguments
#
###################################################

! getopt --test > /dev/null 
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
	echo 'getopt is outdated or not installed!'
	exit 1
fi

OPTIONS=hb:s
LONGOPT=branch:,help,ssh,silent

! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPT --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  # getopt couldn't parse options
  exit 2
fi

eval set -- "$PARSED"

# Parse options
export DOTFILES=${DOTFILES:-$HOME/.dotfiles}
DOTBRANCH=${DOTBRANCH:-master}
REMOTE="https://github.com/ttocsneb/dotfiles.git"
SILENT=NO
while true; do
  case "$1" in
    -h|--help)
      cat << EOF
Dotfiles Installer.  This script will install ttocsneb's dotfiles for you.
You will need tmux,zsh and neovim (vim is also acceptable)
Arguments:
  -h            --help            Print this help message
  -b BRANCH     --branch BRANCH   Pull from the specified git branch (master)
                                    Can also set \$DOTBRANCH
  -s            --ssh             Use ssh to pull instead of https
                --silent          Do not print unnecessary text
Positional Arguments:
  DIRECTORY                       Directory to install to (\$HOME/.dotfiles)
EOF
      exit 0
      ;;
    -b|--branch)
      DOTBRANCH="$2"
      shift 2
      ;;
    -s|--ssh)
      REMOTE="git@github.com:ttocsneb/dotfiles.git"
      shift
      ;;
    --silent)
      SILENT=YES
      shift
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

###################################################
#
# Functions
#
###################################################

BAR="=============================="
LIN="------------------------------"

function say {
  if [[ $SILENT != "YES" ]]; then
    echo $@
  fi
}

function tolow {
  echo $1 | tr '[:upper:]' '[:lower:]'
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
  say $BAR
  nvim_conf=${XDG_CONFIG_HOME:-$HOME/.config}/nvim
  mkdir -p $BACKUP_DOTFILES
  find ~ $nvim_conf -maxdepth 1 \
    -name .zshrc \
    -or -name .vimrc \
    -or -name .tmux.conf \
    -or -name init.vim \
    -print0 | xargs -0r mv -v -t $BACKUP_DOTFILES
  say $LIN
}

function link {
  echo Linking new dotfiles
  say $BAR
  ln -sv $DOTFILES/zsh/zshrc.lnk $HOME/.zshrc
  ln -sv $DOTFILES/tmux/tmux.conf.lnk $HOME/.tmux.conf
  ln -sv $DOTFILES/vim/vimrc $HOME/.vimrc 
  mkdir -pv $nvim_conf
  ln -sv $DOTFILES/vim/init.vim.lnk $nvim_conf/init.vim
  say $LIN
}

function migrate_i {
  CURVER=2

  dotConfig="$1"

  if ! version=$(< $dotConfig grep -Po '(?<=CONFIG_DOT_VER=)\d+'); then
    version=0
    return 0
  fi

  if [ -z $version ]; then
    $DOTFILES/bin/dotconfig
  elif [ $version -eq 0 ]; then
    echo Could not detect version :/  Reconfiguring
    $DOTFILES/bin/dotconfig
  elif [ $version -lt $CURVER ]; then
    echo Updating old configurations:
    while [ $version -lt $CURVER ]; do
      case "$version" in
        1)
          printf "\tAppending New Template"
          old_rc=$(cat $dotConfig)
          cat "$DOTFILES/drc.template" > $dotConfig
          echo "$old_rc" >> $dotConfig
          ;;
      esac
      ((version++))
    done
    sed -i "s/CONFIG_DOT_VER=.*/CONFIG_DOT_VER=$CURVER/g" $dotConfig
  fi
}

function migrate {
  migrated=NO
  if [ -e "$HOME/.dotrc" ]; then
    migrate_i "$HOME/.dotrc"
    migrated=YES
  fi
  if [ -e "$DOTFILES/dotrc" ]; then
    migrate_i "$DOTFILES/dotrc"
    migrated=YES
  fi
  if [ $migrated == "NO" ]; then
    $DOTFILES/bin/dotconfig
  fi
}

function update {
  # Return Codes:
  # 0 - Success: Continue with install
  # 1 - Success: Stop install
  # 2 - Fail: Write permissions
  # 3 - Fail: Install cancelled
  if [ -d $DOTFILES/.git ]; then
    if ! [ -w "$DOTFILES/.git" ]; then
      say "You do not have permission to update dotfiles"
      return 2
    fi
    cd $DOTFILES
    # Check for updates
    git fetch
    branch="$(git branch | grep \* | cut -d ' ' -f2-)"
    if ! git merge-base --is-ancestor "origin/$branch" HEAD; then
      echo There is an update to Dotfiles!
      read -rp "Do you want to update? (y/N): " cont
      if is_yes "$cont"; then
        echo Updating dotfiles
        say $BAR
        if ! [[ $(git status -u -s) == "" ]]; then
          echo Saving local changes
          pop=YES
          git -c user.name=temp -c user.email=temp@temp.com stash
        fi
        git pull
        git submodule update --remote --merge
        if [[ $POP == "YES" ]]; then
          echo Restoring local changes
          git stash pop
        fi
        migrate
        say $LIN
        echo Successfully updated dotfiles
      fi
    else
      migrate
    fi
    return 1
  elif [ -d $DOTFILES ]; then
    echo "'$DOTFILES' already exists!"
    cat <<-EOF
If you wan to change the install directory for dotfiles, you can set the
'DOTFILES' variable before running this command"
EOF
    read -rp "Would you like me to delete '$DOTFILES' for you? (y/N): " delet
    if is_yes "$delet"; then
      rm -r $DOTFILES
      return 0
    fi
    echo "Stopping install"
    return 3
  fi
}

###################################################
#
# Check for Updates
#
###################################################
update
RET=$?
if [ $RET -ne 0 ]; then
  if [ $RET -ne 3 ]; then
    # Link the dotfiles if success or write permission error
    if ! [[ $(readlink "$HOME/.zshrc") == "$DOTFILES/zsh/zshrc.lnk" ]]; then
      echo "dotfiles isn't linked to your home directory."
      read -rp "Should I link it for you? (Y/n): " linked
      if ! is_no "$linked"; then
        backup
        link
      fi
    fi
  fi
  exit 0
fi

##################################################
#
# Check if Install directory is OK
#
##################################################
read -rp "Installing Dotfiles on the $DOTBRANCH branch to '$DOTFILES' Is that ok? [Y/n] " install_ok

if is_no $install_ok; then
  cat <<-EOF
Stopping installation..

To change the install location, either set \$DOTFILES before running the script
or pass the install location as a parameter
EOF
  exit 1
fi

##################################################
#
# Backup existing dotfiles
#
##################################################
backup

##################################################
#
# Check for necessary packages
#
##################################################
packages=("zsh" "tmux" "nvim" "git")
to_install=()
for package in ${packages[@]}; do
  if ! hash $package &> /dev/null; then
    to_install+=("$package")
  fi
done

use_vim="no"
vim="nvim"
if [[ "${to_install[*]}" =~ "nvim" ]]; then
  # Remove nvim from the install list
  to_install=(${to_install[@]/nvim/})
  read -rp "neovim isn't installed.  Should I use vim instead? (Y/n)" use_vim
  if is_no "$use_vim"; then
    # We want to use nvim, so add neovim (the package name) back to to_install
    to_install+=("neovim")
  else
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

##################################################
#
# Clone Dotfiles
#
##################################################
echo Cloning dotfiles
say $BAR
git clone -b $DOTBRANCH --single-branch --depth=1 $REMOTE $DOTFILES
cd $DOTFILES

echo Installing Oh-My-Zsh
say $BAR
export ZSH=$DOTFILES/zsh/oh-my-zsh
export RUNZSH=no
ohmyzsh_remote=https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh
rm -r $DOTFILES/zsh/oh-my-zsh
sh -c "$(curl -fsSL $ohmyzsh_remote)"
rm $HOME/.zshrc
say $LIN

echo Cloning Submodules
say $BAR
git submodule init
git submodule update --remote
say $LIN
say $LIN

##################################################
#
# link Dotfiles
#
##################################################
link

##################################################
#
# Install Vim Plugins
#
##################################################
echo Installing vim plugins
$vim +PluginInstall +qall

migrate

echo Done!

##################################################
#
# Run Shell
#
##################################################
read -rp "Should I run your new shell? (Y/n): " changeshell
if ! is_no "$changshell"; then
  exec zsh -l
else
  echo "Restart your shell, or run '$new_shell'"
fi
