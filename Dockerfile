# Use NVIDIA CUDA 12.9 with cuDNN and Ubuntu 24.04
FROM nvidia/cuda:12.9.0-cudnn-devel-ubuntu24.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    EXO_HOME=/root/.cache/exo

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
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --upgrade pip setuptools wheel

# Set working directory
WORKDIR /app

# Clone exo-cuda repository and install
RUN git clone --depth 1 https://github.com/Scottcjn/exo-cuda.git /app/exo-cuda \
    && cd /app/exo-cuda \
    && pip3 install -e .

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
# 52415: Web UI and ChatGPT-compatible API
# 5678: GRPC peer communication
EXPOSE 52415 5678

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
