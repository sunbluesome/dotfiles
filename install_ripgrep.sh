#!/bin/sh

if [ "$(uname)" = 'Darwin' ]; then
    OS="macos"
    NAME='apple-darwin'
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
    OS="linux"
    NAME='unknown-linux-gnu'
else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
fi

if [ "$(uname -m)" = 'arm64' ]; then
    archtecture="aarch64"
else
    archtecture="x86_64"
fi

URL="https://github.com/BurntSushi/ripgrep/releases/download/14.0.3/ripgrep-14.0.3-${archtecture}-${NAME}.tar.gz"
FILENAME=${URL##*/}
FILENAME_WO_GZ=${FILENAME%.*}
FILENAME_WO_TARGZ=${FILENAME_WO_GZ%.*}
PATH_RIPGREP="${HOME}/bin/ripgrep"

# install neovim
if [ -z $PATH_RIPGREP ]; then
    echo "${PATH_RIPGREP} already exist"
else
    wget -P "ripgrep" "${URL}"
    tar -xzvf "ripgrep/${FILENAME}" -C "ripgrep"
    mkdir -p ${PATH_RIPGREP}
    mv "ripgrep/${FILENAME_WO_TARGZ}/rg" "${PATH_RIPGREP}"
    rm -rf "ripgrep*"
fi

# add path
if echo "${PATH_RIPGREP}" | grep -sq "${PATH}"; then
    echo "${PATH_RIPGREP} already exists in PATH"
else
    # add path
    if [ "$OS" = "macos" ]; then
        echo "# ripgrep" >> ${HOME}/.zshrc
        echo 'export PATH=$PATH:'$PATH_RIPGREP >> ${HOME}/.zshrc
    elif [ "$OS" = "linux" ]; then
        echo "# ripgrep" >> ${HOME}/.bashrc
        echo 'export PATH=$PATH:'$PATH_RIPGREP >> ${HOME}/.bashrc
    fi
fi
