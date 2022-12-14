#!/bin/bash
URL="https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-apple-darwin.tar.gz"
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
    xattr -c ./${FILENAME}
    tar xzvf ${FILENAME}
    mv ${FILENAME_WO_TARGZ} ${PATH_RIPGREP}
    rm -rf ${FILENAME}*
fi

# add neovim path
if [[ "$PATH" =~ "$PATH_RIPGREP" ]];
then
    echo "${PATH_RIPGREP} already exists in PATH"
else
    # add path
    echo "\n# ripgrep" >> ${HOME}/.zshrc
    echo 'export PATH=$PATH:'$PATH_RIPGREP >> ${HOME}/.zshrc
fi
