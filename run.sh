#!/bin/bash

docker run --rm -it \
  -v "$HOME/opencode-docker/container-data:/home/ubuntu/.local" \
  -v "$HOME/opencode-docker/container-data/config:/home/ubuntu/.config/opencode" \
  -v "$HOME/opencode-docker/projects:/workspace" \
  -w /workspace \
  -e PATH="/home/ubuntu/.opencode/bin:${PATH}" \
  opencode-ai:latest \
  opencode
