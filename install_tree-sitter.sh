#!/bin/sh

if [ "$(uname)" = 'Darwin' ]; then
    OS="macos"
    FILENAME='macos'
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ]; then
    OS="linux"
    FILENAME='linux'
else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
fi

URL="https://github.com/tree-sitter/tree-sitter/releases/download/v0.20.7/tree-sitter-${FILENAME}-x64.gz"
FILENAME=${URL##*/}
FILENAME_WO_GZ=${FILENAME%.*}
PATH_TREESITTER="${HOME}/bin/tree-sitter"

echo $FILENAME
echo $FILENAME_WO_GZ
echo $PATH_TREESITTER

# install neovim
if [ -z "$PATH_TREESITTER" ]; then
    echo "${PATH_TREESITTER} already exist"
else
    wget -P tree-sitter ${URL}
    gzip -d "tree-sitter/${FILENAME}"
    mkdir -p ${PATH_TREESITTER}
    mv "tree-sitter/${FILENAME_WO_GZ}" ${PATH_TREESITTER}
    rm -rf tree-sitter
fi

# add path
if echo "${PATH_TREESITTER}" | grep -sq "${PATH}"; then
    echo "${PATH_TREESITTER} already exists in PATH"
else
    # add path
    if [ "${OS}" = "macos" ]; then
        echo "# tree-sitter" >> ${HOME}/.zshrc
        echo 'export PATH=$PATH:'$PATH_TREESITTER >> ${HOME}/.zshrc
    elif [ "${OS}" = "linux" ]; then
        echo "# tree-sitter" >> ${HOME}/.bashrc
        echo 'export PATH=$PATH:'$PATH_TREESITTER >> ${HOME}/.bashrc
    fi
fi
