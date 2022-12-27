# Dotfiles

# Requirements

## Ubunutu
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

## macOS
- [Nerd font]()

## windows
- [VisualStudio](https://visualstudio.microsoft.com/ja/vs/features/cplusplus/) to get C compilers.
- [chocolatey](https://chocolatey.org/)
- [Nerd font](https://www.nerdfonts.com/font-downloads)
    - `Hack Nerd Font` is recommended

# Installation

## macOS/Linux

### Install all

```bash
sh install.sh
sh dotfiles_link.sh
source ~/.bashrc or ~/.zshrc
```

### Install one by one

If you already have neovim.

```bash
sh install_ripgrep.sh
sh install_lazygit.sh
sh dotfiles_link.sh
source ~/.bashrc or ~/.zshrc
```

## Windows

1. install [VisualStudio](https://visualstudio.microsoft.com/ja/vs/features/cplusplus/) to get C compilers.
1. install chocolatey
1. install nodejs, go, rust as follows (With adminstrative privileges)
 ```cmd
 choco install nodejs go rust lazygit ripgrep
 ```
1. make symbolic link
 ```cmd
 dotfiles_link.bat
 ```

1. Run nvim on `x64 Native Tool command Prompt` (Installed with VisualStudio)


