# This dockerfile is intended for testing new installs
from ubuntu:bionic
RUN apt-get update && \
      apt-get install -y --no-install-recommends neovim git tmux zsh \
      apt-get clean \ && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/dotfiles

COPY . .

CMD ["./install.sh", "/usr/src/dotfiles", "--no-vim-install"]

