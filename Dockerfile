ARG CODENAME=noble

FROM ubuntu:${CODENAME}

ARG SHELL=zsh
ARG TZ="America/Sao_Paulo"
ARG USERNAME=temporary

ENV TZ=${TZ}

RUN <<"EOT" bash
    set -eux
    
    apt update
    apt install -y sudo adduser passwd

    echo adduser --disabled-password --gecos '' "${USERNAME}"
    adduser --disabled-password --gecos '' "${USERNAME}"
    adduser "${USERNAME}" sudo
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

    printf "[user]\ndefault=%s\n" "${USERNAME}" >>/etc/wsl.conf
EOT

USER ${USERNAME}
WORKDIR /home/${USERNAME}/

RUN <<"EOT" bash
    set -eux

    sudo apt-get update
    DEBIAN_FRONTEND=noninteractive sudo apt-get install -y bat build-essential ca-certificates cmake \
        curl eza file gcc git jq libncurses-dev tzdata nala procps libedit-dev \
        unzip vim wget yq "$SHELL"
EOT

RUN <<"EOT" bash
    set -eux
    
    # Rust
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    . "$HOME/.cargo/env"
    rustup update
EOT

RUN <<"EOT" bash
    set -eux

    CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME") # -> noble
    ARCH=$(dpkg --print-architecture)                         # -> amd64

    # Docker
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
    sudo groupadd docker || true
    sudo usermod -aG docker "${USERNAME}"
EOT

RUN <<"EOT" bash
    set -eux

    # Brew
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew_path="/home/linuxbrew/.linuxbrew/bin"

    # Tmux
    ${brew_path}/brew install -q tmux

    # Python
    ${brew_path}/brew install -q pyenv pipenv
    # ${brew_path}/pyenv install 3.9 3.10 3.11 3.12
    # ${brew_path}/pyenv global 3.10

    # NodeJs
    ${brew_path}/brew install -q fnm
    ${brew_path}/fnm install --lts
EOT

COPY ./setup/ /tmp/setup/

RUN <<"EOT" bash
    set -eux

    ### Setup shell
    sudo cp -r /tmp/setup/zsh/. /tmp/setup/common/. ~/
    sudo chown ${USERNAME}:${USERNAME} ~/.

    sudo chsh -s "$(which zsh)" "$(whoami)"
EOT

RUN sudo rm -rf /tmp/setup

RUN <<"EOT" bash
    set -eux
    
    echo "================= INIT ZSH ================="
    zsh -x /home/"${USERNAME}"/.zshrc
EOT

CMD [ "/bin/zsh" ]