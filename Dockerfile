ARG IMAGE=ubuntu:noble

FROM ${IMAGE}

ARG USERNAME=asaphdiniz
ARG SHELL=zsh
ARG TZ="America/Sao_Paulo"

RUN <<"EOT" bash
    set -eux
    DISTRO=$(. /etc/os-release && echo "$NAME")

    case ${DISTRO,,} in
    ubuntu | debian)
        apt update
        apt install -y sudo adduser passwd
        ;;
    *)
        echo "Couldn't install user dependencies on distro \"${DISTRO}\", trying anyway"
        ;;
    esac

    echo adduser --disabled-password --gecos '' "${USERNAME}"
    adduser --disabled-password --gecos '' "${USERNAME}"
    adduser "${USERNAME}" sudo
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers

    printf "[user]\ndefault=%s\n" "${USERNAME}" >>/etc/wsl.conf
EOT

USER ${USERNAME}
WORKDIR /home/${USERNAME}/

COPY ./setup/. setup/

COPY ./scripts/bootstrap.sh  setup/bootstrap.sh
RUN setup/bootstrap.sh ${SHELL}

COPY ./scripts/init_shell.sh setup/init_shell.sh
RUN setup/init_shell.sh ${SHELL}
ENV TZ=${TZ}

# CMD [ "/bin/${SHELL}" ]
