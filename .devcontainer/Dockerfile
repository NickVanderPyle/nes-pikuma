FROM ubuntu:rolling

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ENV DEBIAN_FRONTEND=noninteractive

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --shell /bin/bash --home-dir /home/vscode --create-home --skel /etc/skel --gid $USER_GID vscode

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get -y install --no-install-recommends \
        ca-certificates \
        sudo \
        curl \
        git \
        unzip \
        build-essential \
        cc65

RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME
