#!/bin/bash

if [ "$(uname)" == 'Darwin' ]; then
    OS="macos"
    FILENAME='apple-darwin'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    OS="linux"
    FILENAME='unknown-linux-musl'
else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
fi

URL="https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-${FILENAME}.tar.gz"
FILENAME=${URL##*/}
FILENAME_WO_GZ=${FILENAME%.*}
FILENAME_WO_TARGZ=${FILENAME_WO_GZ%.*}
PATH_RIPGREP="${HOME}/bin/ripgrep"

# install neovim
if [ -z $PATH_RIPGREP ]
then
    echo "${PATH_RIPGREP} already exist"
else
    wget ${URL}
    tar xzvf ${FILENAME}
    mv ${FILENAME_WO_TARGZ} ${PATH_RIPGREP}
    rm -rf ${FILENAME}*
fi

# add path
if [[ "$PATH" =~ "$PATH_RIPGREP" ]];
then
    echo "${PATH_RIPGREP} already exists in PATH"
else
    # add path
    if [ $OS == "macos" ]; then
        echo "# ripgrep" >> ${HOME}/.zshrc
        echo 'export PATH=$PATH:'$PATH_RIPGREP >> ${HOME}/.zshrc
    elif [ $OS == "linux" ]; then
        echo "# ripgrep" >> ${HOME}/.bashrc
        echo 'export PATH=$PATH:'$PATH_RIPGREP >> ${HOME}/.bashrc
    fi
fi
