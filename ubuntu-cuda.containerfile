# GPU compatable base image
ARG CUDA_VERSION=12.1.1
ARG UBUNTU_VERSION=22.04
FROM docker.io/nvidia/cuda:${CUDA_VERSION}-cudnn8-devel-ubuntu${UBUNTU_VERSION}

# Install system dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends curl git podman vim zsh \
    && rm -rf /var/lib/apt/lists/*

# Use remote podman
RUN echo "#\!/usr/bin/sh\n/usr/bin/podman -r \"\$@\"" | tee /usr/local/bin/podman \
    && chmod +x /usr/local/bin/podman

#Install gcloud cli
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends apt-transport-https ca-certificates gnupg \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# Install python
ARG DEFAULT_PYTHON=3.11
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && add-apt-repository -y ppa:deadsnakes \
    && apt-get update \
    && apt-get install -y --no-install-recommends python3.8-venv python3.9-venv python3.10-venv python3.11-venv \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python${DEFAULT_PYTHON} /usr/bin/python

# Install poetry
ENV POETRY_HOME=/usr/local/poetry
RUN curl -sSL https://install.python-poetry.org | python -
ENV PATH="${POETRY_HOME}/bin:${PATH}"

# Install rust
ENV RUSTUP_HOME=/usr/local/rustup CARGO_HOME=/usr/local/cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- --no-modify-path -y
ENV PATH="${CARGO_HOME}/bin:${PATH}"