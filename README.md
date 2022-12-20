# Dotfiles

## Scrpits for installation
1. install_neovim.sh
    - install neovim of stable version.
1. install_ripgrep.sh
1. install_lazygit.sh

## Installation
```bash
source install_neovim.sh
source install_repgrep.sh
source install_lazygit.sh
bash dotfiles_link.sh
```

## Requirements on Ubunutu
- build-essential
- nodejs
- npm

Those of them are required for language servers like pyright.  
To install nodejs and npm, execute commands as follows.

```bash
sudo apt-get install --no-install-recommends -y build-essential
curl -fsSl https://deb.nodesource.com/setup_16.x | bash -
sudo apt-get install --no-install-recommends -y nodejs
```

`npm` is automatically installed with nodejs.

If you want to install them into docker, please drop `sudo`.

