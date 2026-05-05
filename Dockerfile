FROM docker.io/library/swift:bookworm

ENV TZ=Europe/Paris

ARG HTTP_PROXY
ENV http_proxy $HTTP_PROXY
ENV https_proxy $HTTP_PROXY

RUN apt-get update \
    && apt install vim libgsl-dev curl -y \
    && apt dist-upgrade -y && apt clean

RUN curl -LsSf https://astral.sh/uv/install.sh | sh

ARG USERNAME=swift
ARG USER_UID=1001
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

USER $USERNAME
WORKDIR /workdir
