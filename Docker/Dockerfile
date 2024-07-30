from swift:latest
ARG USERNAME=swift
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME
RUN git clone https://github.com/spindynamics/spinswift.git
WORKDIR spinswift



