# =============================================================================
# Stage 1: Builder - Install dependencies and build exo-cuda
# =============================================================================
FROM nvidia/cuda:12.9.0-cudnn-devel-ubuntu24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        git \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone exo-cuda repository
RUN git clone --depth 1 https://github.com/Scottcjn/exo-cuda.git /app/exo-cuda

# Create venv and install dependencies
WORKDIR /app/exo-cuda
RUN python3 -m venv .venv \
    && . .venv/bin/activate \
    && pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -e . \
    && pip install --no-cache-dir --upgrade git+https://github.com/tinygrad/tinygrad.git

# =============================================================================
# Stage 2: Runtime - Minimal image with only runtime dependencies
# =============================================================================
FROM nvidia/cuda:12.9.0-cudnn-runtime-ubuntu24.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    EXO_HOME=/root/.cache/exo \
    VIRTUAL_ENV=/app/exo-cuda/.venv \
    PATH="/app/exo-cuda/.venv/bin:$PATH"

# Install runtime dependencies only
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-venv \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy the entire exo-cuda directory including venv from builder
COPY --from=builder /app/exo-cuda /app/exo-cuda

WORKDIR /app/exo-cuda

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose ports
# 52415: Default Web UI and ChatGPT-compatible API
# 8001: Alternative ChatGPT API port
# 5678: GRPC peer communication
EXPOSE 52415 8001 5678

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
