#!/bin/bash
# do `bash dotfiles_link.sh`

# check OS
if [[ "$(uname)" == 'Darwin' ]]; then
    OS="macos"
elif [[ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]]; then
    OS="linux"
else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
fi

echo 'PARAM:' $0
RELATIVE_DIR=`dirname "$0"`

cd $RELATIVE_DIR
SHELL_PATH=`pwd -P`
echo 'Dir:' $SHELL_PATH

# XDG Base Directory Specification 
if [[ "$PATH" =~ "$XDG_CONFIG_HOME" ]];
then
    echo "${XDG_CONFIG_HOME} already exists in PATH"
else
    # add path
    if [[ ${OS} == "macos" ]]; then
        echo "# neovim" >> ${HOME}/.zshrc
        echo 'export XDG_CONFIG_HOME=$HOME/.config' >> ${HOME}/.zshrc
    elif [[ ${OS} == "linux" ]]; then
        echo "# neovim" >> ${HOME}/.bashrc
        echo 'export XDG_CONFIG_HOME=$HOME/.config' >> ${HOME}/.bashrc
    fi
fi

mkdir -p ${HOME}/.config
mkdir -p ${HOME}/.config/lazygit
ln -sFn ${SHELL_PATH}/nvim ${HOME}/.config/nvim
ln -sfn ${SHELL_PATH}/config/lazygit.yml ${HOME}/.config/lazygit/config.yml

for fname in ".vim" ".vimrc" ".zshrc"
do
    if [[ -z "~/${fname}" ]]; then
        echo "~/${fname} already exist"
    else
        ln -sFn ${SHELL_PATH}/${fname} ~/${fname}
    fi
done
