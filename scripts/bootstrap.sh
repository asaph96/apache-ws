#!/bin/bash

# IMAGE=${1:-"ubuntu:noble"}
# DISTRO=${IMAGE%%:*} # -> ubuntu
# CODENAME=${IMAGE##*:} # -> noble
DISTRO=$(. /etc/os-release && echo "$NAME")               # -> ubuntu
CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME") # -> noble
ARCH=$(dpkg --print-architecture)                         # -> amd64

USERNAME=$(whoami)
INSTALL_SHELL=${1:-"zsh"}
SUPPORTED_SHELLS=("bash" "zsh" "nushell")

setup_dependencies() {
    case ${DISTRO,,} in
    ubuntu | debian)
        sudo apt update
        sudo apt install -y bat build-essential ca-certificates cmake \
            curl eza file gcc git jq libncurses-dev tzdata nala procps \
            unzip vim wget yq "$INSTALL_SHELL"
        ;;
    *)
        echo "Unsupported distro \"${DISTRO}\""
        exit 2
        ;;
    esac
}

setup_tools() {

    # Brew
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_path="/home/linuxbrew/.linuxbrew/bin"

    # Rust
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    . "$HOME/.cargo/env"
    rustup update

    # Docker
    case ${DISTRO,,} in
    ubuntu | debian)
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo \
            "deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
            $CODENAME stable" |
            sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
        sudo apt update
        sudo apt install -y containerd.io docker-buildx-plugin \
            docker-ce docker-ce-cli docker-compose-plugin
        ;;
    *)
        echo "Couldn't install Docker on distro \"${DISTRO}\", skipping"
        ;;
    esac
    sudo groupadd docker
    sudo usermod -aG docker "$USERNAME"

    # Tmux
    ${brew_path}/brew install -q tmux

    # Python
    ${brew_path}/brew install -q pyenv pipenv
    ${brew_path}/pyenv install 3.9 3.10 3.11 3.12
    ${brew_path}/pyenv global 3.10

    # NodeJs
    ${brew_path}/brew install -q fnm
    ${brew_path}/fnm install --lts

    ### Setup shell
    case ${INSTALL_SHELL,,} in
    zsh)
        sudo cp -r ~/setup/zsh/. ~/setup/common/. ~/
        sudo chown -R asaphdiniz:asaphdiniz ~/

        sudo chsh -s "$(which zsh)" "$(whoami)"
        ;;
    *)
        echo "Couldn't setup any shell, skipping"
        ;;
    esac
}

# shellcheck disable=SC2076
if [[ ! ${SUPPORTED_SHELLS[*]} =~ "${INSTALL_SHELL,,}" ]]; then
    echo "Unsupported shell \"${INSTALL_SHELL}\""
    exit 2
fi

setup_dependencies
setup_tools

# Post install

sudo rm -rf ~/setup
