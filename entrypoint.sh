#!/bin/bash
set -e

# Activate virtual environment
source /app/exo-cuda/.venv/bin/activate

# Set default values for environment variables
DEBUG=${DEBUG:-0}
TINYGRAD_DEBUG=${TINYGRAD_DEBUG:-0}
EXO_HOME=${EXO_HOME:-/root/.cache/exo}
CHATGPT_API_PORT=${CHATGPT_API_PORT:-8001}

# Export environment variables for exo and tinygrad
export DEBUG
export TINYGRAD_DEBUG
export EXO_HOME

# Ensure CUDA is available to tinygrad
export CUDA=1

# Create EXO_HOME directory if it doesn't exist
mkdir -p "$EXO_HOME"

# Build exo command arguments
EXO_ARGS=(
    "--inference-engine" "tinygrad"
    "--chatgpt-api-port" "$CHATGPT_API_PORT"
    "--disable-tui"
)

# Add broadcast address if specified
if [ -n "$BROADCAST_ADDRESS" ]; then
    EXO_ARGS+=("--broadcast-address" "$BROADCAST_ADDRESS")
fi

# Add discovery config path if specified
if [ -n "$DISCOVERY_CONFIG_PATH" ]; then
    EXO_ARGS+=("--discovery-config-path" "$DISCOVERY_CONFIG_PATH")
fi

# Add any additional arguments passed to the container
if [ $# -gt 0 ]; then
    EXO_ARGS+=("$@")
fi

# Print startup information
echo "============================================"
echo "  exo-cuda container starting"
echo "============================================"
echo "  DEBUG:           $DEBUG"
echo "  TINYGRAD_DEBUG:  $TINYGRAD_DEBUG"
echo "  EXO_HOME:        $EXO_HOME"
echo "  CHATGPT_API_PORT: $CHATGPT_API_PORT"
echo "  CUDA:            $CUDA"
if [ -n "$BROADCAST_ADDRESS" ]; then
    echo "  BROADCAST_ADDRESS: $BROADCAST_ADDRESS"
fi
echo "  Command: exo ${EXO_ARGS[*]}"
echo "============================================"
echo ""

# Run exo with tinygrad backend
exec exo "${EXO_ARGS[@]}"
