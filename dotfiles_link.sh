#!/bin/sh
# do `sh dotfiles_link.sh`
echo 'PARAM:' $0
RELATIVE_DIR=`dirname "$0"`

cd $RELATIVE_DIR
SHELL_PATH=`pwd -P`
echo 'Dir:' $SHELL_PATH

# make directories
mkdir -p $XDG_CONFIG_HOME/lazygit

ln -sFn ${SHELL_PATH}/.vim ~/.vim
ln -sFn ${SHELL_PATH}/nvim $XDG_CONFIG_HOME/nvim
ln -sfn ${SHELL_PATH}/.vimrc ~/.vimrc
ln -sfn ${SHELL_PATH}/.zshrc ~/.zshrc
ln -sfn ${SHELL_PATH}/config/lazygit.yml $XDG_CONFIG_HOME/lazygit/config.yml
