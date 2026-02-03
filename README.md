# Alias / pointer analysis research

Research project for running pointer and alias analyses (PhASAR, SeaDSA, SVF) on benchmarks. The repo provides scripts to checkout tools and test projects, build with LLVM 14, and run PTA on bitcode.

## Requirements

- Ubuntu 24.04 (or compatible)
- LLVM 14 and build dependencies (see `scripts/00_bootstrap_ubuntu24.sh` or run `make bootstrap`)

## Quick start

```bash
make checkout    # clone phasar, SVF, sea-dsa, test-projects
make bootstrap   # install system deps (apt); run once or when deps change
make phasar      # build phasar-cli
make svf         # build SVF (wpa) — optional
make seadsa      # build SeaDSA — optional
```

To run a PTA on a bitcode file (after sourcing env and building the tool):

```bash
source scripts/env.sh
bash scripts/06_run_phasar_pta.sh /path/to/module.bc /path/to/out_dir
```

## Makefile commands

| Command | Description |
|--------|-------------|
| `make doctor` | Check that all scripts exist |
| `make bootstrap` | Install system dependencies (apt, Ubuntu 24.04) |
| `make checkout` | Clone phasar, SVF, sea-dsa, test-projects (PTABen, PointerBench) |
| `make phasar` | Build phasar-cli |
| `make svf` | Build SVF (wpa) |
| `make seadsa` | Build SeaDSA |
| `make env` | Verify env.sh can be sourced |
| `make all` | checkout + phasar |

**Docker (Ubuntu 24 x86_64)**

| Command | Description |
|--------|-------------|
| `make docker-image` | Build image alias-analysis-ubuntu24 (linux/amd64) |
| `make docker-shell` | Run interactive shell in container (repo mounted at /workspace) |
| `make docker-shell-ssh` | Same + mount ~/.ssh for git clone |
| `make docker-run target=T` | Run `make T` in container |
| `make docker-run-ssh target=T` | Same with ~/.ssh mounted |

**Clean**

| Command | Description |
|--------|-------------|
| `make clean-results` | Remove results/* |
| `make clean-builds` | Remove phasar build and *.bc under test-projects |
| `make clean-all` | clean-results + clean-builds |
| `make distclean` | clean-all + remove phasar and test-projects |

## Scripts

- **00_bootstrap_ubuntu24.sh** — install apt packages (build-essential, cmake, ninja, LLVM 14, boost, etc.).
- **01_checkout_sources.sh** — clone phasar, SVF, sea-dsa, PointerBench, PTABen (Test-Suite) into repo.
- **env.sh** — source before building or running 06_*: sets ROOT, PHASAR_CLI, SDSA_CLI, WPA_CLI, LLVM_BIN, PATH (LLVM 14). Bitcode: use `clang-14 -c -emit-llvm -o file.bc file.c` (or clang++-14 for C++).
- **03_build_phasar.sh** — build phasar with LLVM 14.
- **03_build_SVF.sh** — build SVF (Release) with LLVM 14.
- **03_build_seadsa.sh** — build SeaDSA with LLVM 14.
- **06_run_phasar_pta.sh** — run PhASAR PTA (anders, steens) on one bitcode file.
- **06_run_seadsa_pta.sh** — run SeaDSA PTA (cs, butd-cs, bu, ci, flat) on one bitcode file.
- **06_run_svf_pta.sh** — run SVF wpa (nander, sander, ander, etc.) on one bitcode file.

All `06_run_*_pta.sh` scripts take two arguments: `<module.bc>` and `<out_dir>`. They require the corresponding `*_CLI` to be set (via `source scripts/env.sh` after building).

## Environment variables (after `source scripts/env.sh`)

| Variable | Purpose |
|----------|---------|
| `PHASAR_CLI` | Path to phasar-cli binary |
| `SDSA_CLI` | Path to seadsa binary |
| `WPA_CLI` | Path to SVF wpa binary |
| `LLVM_BIN` | LLVM 14 bin directory (clang, opt, llvm-link, etc.) |
| `LLVM_CC_NAME`, `LLVM_CXX_NAME`, … | clang-14, clang++-14, llvm-link-14, llvm-ar-14 |
