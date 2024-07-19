ARG IMAGE=ubuntu:noble

FROM ${IMAGE}

ARG USERNAME=asaphdiniz
ARG SHELL=zsh
ARG TZ="America/Sao_Paulo"

COPY ./scripts/setup_user.sh /root/setup_user.sh
RUN /root/setup_user.sh ${USERNAME}
RUN rm ~/setup/setup_user.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}/

COPY ./setup/. setup/

COPY ./scripts/bootstrap.sh  setup/bootstrap.sh
RUN  setup/bootstrap.sh ${SHELL}

COPY ./scripts/init_shell.sh setup/init_shell.sh
RUN setup/init_shell.sh ${SHELL}
ENV TZ=${TZ}

# CMD [ "/bin/${SHELL}" ]
