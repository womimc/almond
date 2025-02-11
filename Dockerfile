ARG LOCAL_IVY=no
FROM jupyter/base-notebook
USER root
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y \
      curl \
      openjdk-8-jre-headless \
      ca-certificates-java \
      git \
      wget \
      nano \
      systemctl \
      python3 \
      neofetch && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN usermod -aG sudo jovyan && \
    passwd -d jovyan && \
    echo "jovyan ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN passwd -d root
