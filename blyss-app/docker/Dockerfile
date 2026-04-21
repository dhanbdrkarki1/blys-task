ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-slim

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    bash \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir uv

WORKDIR /app
COPY pyproject.toml uv.lock* /app/
RUN UV_PROJECT_ENVIRONMENT=/opt/venv uv sync --extra dev

ENV PATH="/opt/venv/bin:${PATH}"
