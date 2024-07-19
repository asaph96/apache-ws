#!/bin/bash

USERNAME=$(whoami)
INSTALL_SHELL=$1

case ${INSTALL_SHELL,,} in
    zsh)
        zsh -x /home/"${USERNAME}"/.zshrc
        ;;
    *)
        echo "Couldn't init shell \"${INSTALL_SHELL}\", skipping"
        ;;
esac