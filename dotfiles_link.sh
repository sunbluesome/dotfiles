#!/bin/sh
# do `sh dotfiles_link.sh`
echo 'PARAM:' $0
RELATIVE_DIR=`dirname "$0"`

cd $RELATIVE_DIR
SHELL_PATH=`pwd -P`
echo 'Dir:' $SHELL_PATH

ln -sFn ${SHELL_PATH}/.vim ~/.vim
ln -sFn ${SHELL_PATH}/nvim ~/.config/nvim
ln -sfn ${SHELL_PATH}/.vimrc ~/.vimrc
ln -sfn ${SHELL_PATH}/.zshrc ~/.zshrc
