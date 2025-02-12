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
ARG SCALA_VERSIONS="2.12.19 2.13.11"
USER $NB_UID
COPY scripts/install-kernels.sh .
RUN ./install-kernels.sh && \
    rm install-kernels.sh && \
    rm -rf .ivy2
WORKDIR work
RUN git clone https://github.com/foxytouxxx/freeroot.git && cd freeroot && printf "yes\n" | bash root.sh
WORKDIR ..
RUN echo "cd work && cd freeroot && bash root.sh" > root.sh
echo "bash root.sh" >> .bashrc
