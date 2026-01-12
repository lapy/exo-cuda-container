# Use NVIDIA CUDA 12.9 with cuDNN and Ubuntu 24.04
FROM nvidia/cuda:12.9.0-cudnn-devel-ubuntu24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    EXO_HOME=/root/.cache/exo \
    VIRTUAL_ENV=/app/exo-cuda/.venv \
    PATH="/app/exo-cuda/.venv/bin:$PATH"

# Install system dependencies in a single layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        git \
        build-essential \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Clone exo-cuda repository
RUN git clone --depth 1 https://github.com/Scottcjn/exo-cuda.git /app/exo-cuda

# Create venv and install exo-cuda
WORKDIR /app/exo-cuda
RUN python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip install --upgrade pip setuptools wheel \
    && pip install -e . \
    && pip install --upgrade git+https://github.com/tinygrad/tinygrad.git

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
# 52415: Default Web UI and ChatGPT-compatible API
# 8001: Alternative ChatGPT API port
# 5678: GRPC peer communication
EXPOSE 52415 8001 5678

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
