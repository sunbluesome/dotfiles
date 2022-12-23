#!/bin/sh

if [ "$(uname)" = 'Darwin' ]; then
    OS="macos"
    FILENAME='Darwin'
elif [ "$(expr substr $(uname -s) 1 5)" = 'Linux' ]; then
    OS="linux"
    FILENAME='Linux'
else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
fi

URL="https://github.com/jesseduffield/lazygit/releases/download/v0.36.0/lazygit_0.36.0_${FILENAME}_x86_64.tar.gz"
FILENAME=${URL##*/}
FILENAME_WO_GZ=${FILENAME%.*}
FILENAME_WO_TARGZ=${FILENAME_WO_GZ%.*}
PATH_LAZYGIT="${HOME}/bin/lazygit"

echo $FILENAME
echo $FILENAME_WO_GZ
echo $FILENAME_WO_TARGZ
echo $PATH_LAZYGIT

# install neovim
if [ -z "$PATH_LAZYGIT" ]; then
    echo "${PATH_LAZYGIT} already exist"
else
    wget -P lazygit ${URL}
    # xattr -c ./${FILENAME}
    tar xzvf "lazygit/${FILENAME}" -C "lazygit"
    mkdir -p ${PATH_LAZYGIT}
    mv "lazygit/lazygit" ${PATH_LAZYGIT}
    rm -rf lazygit
fi

# add path
if echo "${PATH_LAZYGIT}" | grep -sq "${PATH}"; then
    echo "${PATH_LAZYGIT} already exists in PATH"
else
    # add path
    if [ "${OS}" == "macos" ]; then
        echo "# lazygit" >> ${HOME}/.zshrc
        echo 'export PATH=$PATH:'$PATH_LAZYGIT >> ${HOME}/.zshrc
    elif [ "${OS}" == "linux" ]; then
        echo "# lazygit" >> ${HOME}/.bashrc
        echo 'export PATH=$PATH:'$PATH_LAZYGIT >> ${HOME}/.bashrc
    fi
fi
