# aliases
alias ll='ls -al'
alias la='ls -a'

# for iTerm2
export CLICOLOR=1
export TERM=xterm-256color

# Julia
export PATH="/Applications/Julia-1.3.app/Contents/Resources/julia/bin:$PATH"

# shell
export PS1='%n@%m:%c %# '

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
export PATH="/usr/local/opt/bzip2/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/bzip2/lib -L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/bzip2/include -I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# XDG Base Directory Specification
export XDG_CONFIG_HOME=$HOME/.config
mkdir -p $XDG_CONFIG_HOME

# node
export PATH=$HOME/.nodebrew/current/bin:$PATH

# pure
autoload -U promptinit; promptinit
prompt pure

# poetry
export PATH="/Users/inoue/.local/bin:$PATH"

# rust
export PATH="$HOME/.cargo/env:$PATH"

# neovim
export PATH=$PATH:~/bin/nvim-macos/bin

# ripgrep
export PATH=$PATH:/Users/inoue/bin/ripgrep

# lazygit
export PATH=$PATH:/Users/inoue/bin/lazygit

# starship
eval "$(starship init zsh)"
