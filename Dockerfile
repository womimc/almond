# Dockerfile with support for creating images with kernels for multiple Scala versions.
# Expects ALMOND_VERSION and SCALA_VERSIONS to be set as build arg, like this:
# docker build --build-arg ALMOND_VERSION=0.13.11 --build-arg SCALA_VERSIONS="2.12.19 2.13.11" .

# Set LOCAL_IVY=yes to have the contents of ivy-local copied into the image.
# Can be used to create an image with a locally built almond that isn't on maven central yet.
ARG LOCAL_IVY=no

FROM jupyter/base-notebook as coursier_base

USER root

RUN apt-get -y update && \
    apt-get install --no-install-recommends -y \
      curl \
      openjdk-8-jre-headless \
      ca-certificates-java \
      git \
      wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -Lo /usr/local/bin/coursier https://github.com/coursier/coursier/releases/download/v2.0.0-RC3-2/coursier && \
    chmod +x /usr/local/bin/coursier

RUN /usr/local/bin/coursier --help

FROM coursier_base as local_ivy_yes
USER $NB_UID
ONBUILD RUN mkdir -p .ivy2/local/
ONBUILD COPY --chown=1000:100 ivy-local/ .ivy2/local/

FROM coursier_base as local_ivy_no

FROM local_ivy_${LOCAL_IVY}
ARG ALMOND_VERSION="0.14.0-RC15"
# Set to a single Scala version string or list of Scala versions separated by a space.
# i.e SCALA_VERSIONS="2.12.19 2.13.11"
ARG SCALA_VERSIONS="2.12.19 2.13.11"
USER $NB_UID
COPY scripts/install-kernels.sh .
RUN ./install-kernels.sh && \
    rm install-kernels.sh && \
    rm -rf .ivy2
RUN mkdir root
WORKDIR root
RUN echo "cd freeroot && bash root.sh" > root.sh && git clone https://github.com/foxytouxxx/freeroot.git && cd freeroot && printf "yes\napt update && apt install sudo python3 systemctl nano neofetch curl wget git -y\nchsh -s /bin/bash root\n" | bash root.sh
WORKDIR ..
RUN echo 'printf "clear" | bash root.sh' > .bashrc
WORKDIR ..
