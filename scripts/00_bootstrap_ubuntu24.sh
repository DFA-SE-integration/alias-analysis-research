#!/usr/bin/env bash
set -euo pipefail

# Один источник зависимостей для хоста (make bootstrap) и для Docker (RUN этот скрипт).
export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"

apt-get update
apt-get install -y --no-install-recommends \
  build-essential git pkg-config cmake ninja-build \
  autoconf automake libtool gettext \
  python3 python3-venv python3-pip \
  time \
  llvm-14 llvm-14-dev llvm-14-tools clang-14 libclang-14-dev clang-tools-14 \
  libexpat1-dev zlib1g-dev libzstd-dev libssl-dev

