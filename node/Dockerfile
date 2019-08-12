ARG UBUNTU_VERSION=18.04
FROM ubuntu:${UBUNTU_VERSION}

LABEL author="https://github.com/Xaroth"

USER root

ADD . /tmp/

ARG JUPYTERHUB_VERSION=1.0.0 
ARG NOTEBOOK_VERSION=6.0.0
ARG IPYKERNEL_VERSION=5.1.2
ARG TINI_VERSION=0.18.0

ARG NB_USER="jupyter"
ARG NB_GROUP="jupyter"
ARG NB_UID="900"
ARG NB_GID="900"

ENV JUPYTERHUB_VERSION=${JUPYTERHUB_VERSION}
ENV NOTEBOOK_VERSION=${NOTEBOOK_VERSION}
ENV IPYKERNEL_VERSION=${IPYKERNEL_VERSION}

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get -yq dist-upgrade && apt-get install -yq --no-install-recommends \
        curl \
        wget \
        bzip2 \
        libopenblas-base \
        libopenblas-dev \
        libblas3 \
        liblapack3 \
        gfortran \
        libatlas3-base \
        ca-certificates \
        locales \
        fonts-liberation \
        run-one \ 
        gpg-agent \
        build-essential \ 
        cython3 \
        python3-dev \
        python3-pip \
        python3-setuptools \
        software-properties-common \
    && groupadd -g $NB_GID $NB_GROUP \
    && useradd -m -s /bin/bash -N -g $NB_GID -u $NB_UID $NB_USER \
    && (curl -sL https://deb.nodesource.com/setup_12.x | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 bash -) \
    && apt-get update && apt-get install -yq --no-install-recommends \
        nodejs \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && cd /tmp && wget https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}-amd64.deb \
    && dpkg -i /tmp/tini_${TINI_VERSION}-amd64.deb \
    && (bash /tmp/environments.sh) \
    && apt-get remove -y \
        curl \
        wget \
        gfortran \
        libopenblas-dev \
        build-essential \
        software-properties-common \
        python3-dev \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /root/.cache /tmp/tini_${TINI_VERSION}-amd64.deb \
    && npm cache clean --force \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen

ENV LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    SHELL=/bin/bash

USER $NB_UID
VOLUME /notebooks

ENTRYPOINT ["tini", "-g", "--"]
CMD ["jupyterhub-singleuser", "--KernelSpecManager.ensure_native_kernel=False"]
