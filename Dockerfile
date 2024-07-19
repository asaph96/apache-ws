ARG IMAGE=ubuntu:noble

FROM ${IMAGE}

ARG USERNAME=asaphdiniz
ARG SHELL=zsh
ARG TZ="America/Sao_Paulo"

COPY --chmod=666 ./scripts/setup_user.sh /opt/setup_user.sh
RUN bash -c /opt/setup_user.sh ${USERNAME}
RUN rm /opt/setup_user.sh

USER ${USERNAME}
WORKDIR /home/${USERNAME}/

COPY ./setup/. setup/

COPY ./scripts/bootstrap.sh  setup/bootstrap.sh
RUN bash -c  setup/bootstrap.sh ${SHELL}

COPY ./scripts/init_shell.sh setup/init_shell.sh
RUN bash -c setup/init_shell.sh ${SHELL}
ENV TZ=${TZ}

# CMD [ "/bin/${SHELL}" ]
