#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$ROOT/test-projects"

clone_if_missing () {
  local url="$1"
  local dir="$2"
  local commit="$3"
  if [[ ! -d "$dir/.git" ]]; then
    git clone --depth 1 --no-checkout "$url" "$dir" && \
    cd "$dir" && \
    git fetch origin "$commit" --depth 1 && \
    git checkout FETCH_HEAD && \
    git submodule update --init --recursive --depth 1
  else
    echo "$(basename "$dir") already exists, skipping clone"
  fi
}

clone_if_missing git@github.com:secure-software-engineering/phasar.git \
  "$ROOT/phasar" \
  "055babd2f0a24597b9f2a9953b42dabe1fcb22ec"

clone_if_missing git@github.com:SVF-tools/SVF.git \
  "$ROOT/SVF" \
  "197a6590bd9c695a9c3daf52622dea912ef9a002"

clone_if_missing git@github.com:seahorn/sea-dsa.git \
  "$ROOT/sea-dsa" \
  "8fc33bd29b878c8975e958da594e67ba02bb42f4"

clone_if_missing git@github.com:secure-software-engineering/PointerBench.git \
  "$ROOT/test-projects/PointerBench" \
  "master"

clone_if_missing git@github.com:SVF-tools/Test-Suite.git \
  "$ROOT/test-projects/PTABen" \
  "master"
