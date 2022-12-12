#!/bin/bash
NVIM_URL="https://github.com/neovim/neovim/releases/download/v0.8.1/nvim-macos.tar.gz"
NVIM_HOME="${HOME}/bin/nvim-macos"

# install neovim
if [ -z $NVIM_HOME ]
then
    echo "${NVIM_HOME} already exist"
else
    wget $NVIM_URL
    xattr -c ./nvim-macos.tar.gz
    tar xzvf nvim-macos.tar.gz
    mkdir -p $NVIM_HOME
    mv nvim-macos $NVIM_HOME
    rm -rf nvim-macos*
fi

# add neovim path
if [[ "$PATH" =~ "$NVIM_HOME" ]];
then
    echo "${NVIM_HOME} already exists in PATH"
else
    # add path
    echo "\n# neovim" >> ${HOME}/.zshrc
    echo 'export PATH=$PATH:'$NVIM_HOME/bin >> ${HOME}/.zshrc
fi

