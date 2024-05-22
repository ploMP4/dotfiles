# My dotfiles

This repository contains the dotfiles for my system

## Installation

You first need to install GNU stow

```
$ sudo pacman -S stow
```

Next clone the repository inside your `$HOME` directory and cd into it

```
$ git clone https://github.com/ploMP4/dotfiles.git ~/dotfiles
$ cd dotfiles
```

Finally symlink the dotfiles using GNU stow

```
$ stow .
```

_NOTE: `stow .` will symlink the files targeting it's parent directory, therefore it's required you clone the repo inside the `$HOME` directory._
