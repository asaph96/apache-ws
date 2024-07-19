#!/bin/bash

DISTRO=$(. /etc/os-release && echo "$NAME")
USERNAME=$1

case ${DISTRO,,} in
ubuntu | debian)
    apt update
    apt install -y sudo adduser passwd
    ;;
*)
    echo "Couldn't install user dependencies on distro \"${DISTRO}\", trying anyway"
    ;;
esac

adduser --disabled-password --gecos '' "${USERNAME}"
adduser "${USERNAME}" sudo
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

printf "[user]\ndefault=%s\n" "${USERNAME}" >>/etc/wsl.conf
