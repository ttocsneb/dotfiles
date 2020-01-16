# dotfiles

| Service    | Master                         | Devel                        |
|------------|--------------------------------|------------------------------|
| CodeFactor | [![CodeFactor Master]][master] | [![CodeFactor Devel]][devel] |

[CodeFactor Master]: https://www.codefactor.io/repository/github/ttocsneb/dotfiles/badge/master
[master]: https://www.codefactor.io/repository/github/ttocsneb/dotfiles/master

[CodeFactor Devel]: https://www.codefactor.io/repository/github/ttocsneb/dotfiles/badge/devel
[devel]: https://www.codefactor.io/repository/github/ttocsneb/dotfiles/devel

Contains all of my dotfiles for neovim, zsh, and tmux.  Feel free to use this
and make your own changes, or even send pull requests. I don't know, I'm not
your dad :)

My dotfiles are heavily inspired by [nicknisi's dotfiles](https://github.com/nicknisi/dotfiles).

## Install

To install, run the following command:

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ttocsneb/dotfiles/master/install.sh)" --
```

### Install to a different location

by default, dotfiles is installed to `~/.dotfiles`; To change this, provide the directory as an argument

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ttocsneb/dotfiles/master/install.sh)" -- <directory>
```

### Install a different branch

If you would like to install from a different branch you can use this command

```sh
bash -c "$curl -fsSL https://raw.githubusercontent.com/ttocsneb/dotfiles/<branch>/install.sh" -- -b <branch>

# installing the devel branch
bash -c "$curl -fsSL https://raw.githubusercontent.com/ttocsneb/dotfiles/devel/install.sh" -- -b devel
```

Eventually, I will make it so you could install any branch from any other branch.

### Install using ssh instead of https

If you plan to make changes it is generally easier to use ssh than https

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ttocsneb/dotfiles/master/install.sh)" -- --ssh
```

### More information

you can always use the `-h` option to get help on options

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ttocsneb/dotfiles/master/install.sh)" -- -h
```

