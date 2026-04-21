ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    bash \
    curl \
    tar \
    perl \
    wget \
    net-tools \
    vim \
    bash \
    build-essential \
    gcc \
    g++ \
    python3-dev \
    awscli \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ADD https://astral.sh/uv/install.sh /install.sh
RUN chmod -R 655 /install.sh && /install.sh && rm /install.sh

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app
