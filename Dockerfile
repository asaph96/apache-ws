ARG IMAGE=ubuntu:noble

FROM ${IMAGE}

ARG USERNAME=asaphdiniz
ARG SHELL=zsh
ARG TZ="America/Sao_Paulo"

COPY ./scripts/setup_user.sh /tmp/setup/setup_user.sh
RUN /tmp/setup/setup_user.sh ${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}/

COPY ./setup/. setup/

COPY ./scripts/bootstrap.sh  setup/bootstrap.sh
RUN  setup/bootstrap.sh ${SHELL}

COPY ./scripts/init_shell.sh setup/init_shell.sh
RUN setup/init_shell.sh ${SHELL}
ENV TZ=${TZ}

# CMD [ "/bin/${SHELL}" ]
