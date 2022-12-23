#!/bin/sh

if [[ $(uname) == 'Darwin' ]]; then
    OS="macos"
    FILENAME='nvim-macos'
elif [[ $(expr substr $(uname -s) 1 5) == 'Linux' ]]; then
    OS="linux"
    FILENAME='nvim-linux64'
else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
fi

NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/${FILENAME}.tar.gz"
NVIM_HOME="${HOME}/bin/${FILENAME}"

# install neovim
if [[ -z ${NVIM_HOME} ]]; then
    echo "${NVIM_HOME} already exist"
else
    wget "${NVIM_URL}"
    xattr -c "./${FILENAME}.tar.gz"
    tar xzvf "${FILENAME}.tar.gz"
    mkdir -p "${NVIM_HOME}"
    mv "${FILENAME}" "${HOME}/bin"
fi
rm -rf "${FILENAME}*"

# add neovim path
if [[ ${PATH} =~ ${NVIM_HOME} ]];
then
    echo "${NVIM_HOME} already exists in PATH"
else
    # add path
    if [[ ${OS} == macos ]]; then
        echo "# neovim" >> ${HOME}/.zshrc
        echo 'export PATH=$PATH:'${NVIM_HOME}/bin >> ${HOME}/.zshrc
    elif [[ ${OS} == "linux" ]]; then
        echo "# neovim" >> ${HOME}/.bashrc
        echo 'export PATH=$PATH:'${NVIM_HOME}/bin >> ${HOME}/.bashrc
    fi
fi

