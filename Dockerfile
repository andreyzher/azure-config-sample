FROM ubuntu:focal

ARG user=developer

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -yq && apt-get install -yq \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        openssh-client \
        python3 \
        python3-pip \
        python3-venv \
        python-is-python3 \
        software-properties-common \
        sudo && \
    (curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -) && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update -yq && apt-get install -yq terraform && \
    useradd -m -s /bin/bash -G root ${user} && \
    (echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer) && \
    rm -rf /var/lib/apt/lists/*

USER ${user}

ENV PATH="/home/${user}/venv/bin:${PATH}" \
    VIRTUAL_ENV="/home/${user}/venv" \
    PS1='(venv) \[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\u@\h:\w\$'

RUN sudo mkdir -pv -m 775 /work && \
    sudo chown -Rv ${user}:0 /work && \
    python3 -m venv $HOME/venv && \
    python3 -m pip install --no-cache -U pip wheel && \
    pip install --no-cache -U ansible

WORKDIR /work
