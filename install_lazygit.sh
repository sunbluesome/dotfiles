#!/bin/bash
URL="https://github.com/jesseduffield/lazygit/releases/download/v0.36.0/lazygit_0.36.0_Darwin_x86_64.tar.gz"
FILENAME=${URL##*/}
FILENAME_WO_GZ=${FILENAME%.*}
FILENAME_WO_TARGZ=${FILENAME_WO_GZ%.*}
PATH_LAZYGIT="${HOME}/bin/lazygit"

echo $FILENAME
echo $FILENAME_WO_GZ
echo $FILENAME_WO_TARGZ
echo $PATH_LAZYGIT

# install neovim
if [ -z $PATH_LAZYGIT ]
then
    echo "${PATH_LAZYGIT} already exist"
else
    wget ${URL}
    xattr -c ./${FILENAME}
    tar xzvf ${FILENAME}
    mkdir -p ${PATH_LAZYGIT}
    mv "lazygit" ${PATH_LAZYGIT}
    rm -rf ${FILENAME}*
fi

# add neovim path
if [[ "$PATH" =~ "$PATH_LAZYGIT" ]];
then
    echo "${PATH_LAZYGIT} already exists in PATH"
else
    # add path
    echo "\n# lazygit" >> ${HOME}/.zshrc
    echo 'export PATH=$PATH:'$PATH_LAZYGIT >> ${HOME}/.zshrc
fi
