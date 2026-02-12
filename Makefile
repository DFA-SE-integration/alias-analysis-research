SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

ROOT := $(abspath .)

DOCKER_BOOTSTRAP    := scripts/docker/00_bootstrap_ubuntu24.sh

CHECKOUT     := scripts/01_checkout_sources.sh
BUILD_PHASAR := scripts/02_build_phasar.sh
BUILD_SVF    := scripts/02_build_SVF.sh
BUILD_SEADSA := scripts/02_build_seadsa.sh
RUN_PTA         := scripts/06_run_phasar_pta.sh
RUN_SVF_PTA     := scripts/06_run_svf_pta.sh
RUN_SEADSA_PTA  := scripts/06_run_seadsa_pta.sh
ENVSH           := scripts/env.sh

DOCKER_IMAGE := alias-analysis-ubuntu24

# ---------------- GENERAL TARGETS ----------------

.PHONY: help doctor

help:
	@echo "Targets:"
	@echo "Docker (Ubuntu 24 x86_64):"
	@echo "  make docker-image         - build image $(DOCKER_IMAGE) (linux/amd64)"
	@echo "  make docker-shell	    - run interactive shell in container + mount ~/.ssh (repo mounted)"
	@echo "  make docker-run target=T  - run 'make T' in container + mount ~/.ssh (e.g. target=all)"
	@echo ""
	@echo "General:"
	@echo "  make doctor               - sanity-check scripts exist"
	@echo ""
	@echo "Tools:"
	@echo "  make all                  - checkout + all tools"
	@echo "  make phasar               - build phasar-cli"
	@echo "  make seadsa               - build SeaDSA"
	@echo "  make svf                  - build SVF (wpa)"
	@echo ""
	@echo "Clean:"
	@echo "  make clean-all            - clean all"
	@echo "  make clean-tools          - remove tools projects(phasar, seadsa, svf)"
	@echo "  make clean-tools-builds   - remove tools build artifacts"
	@echo "  make clean-tests          - remove tests projects(Test-Suite, PointerBench)"
	@echo "  make clean-results        - remove tests projects *.bc files"

doctor:
	@test -f "$(DOCKER_BOOTSTRAP)"
	@test -f "$(CHECKOUT)"
	@test -f "$(ENVSH)"
	@test -f "$(BUILD_PHASAR)"
	@test -f "$(BUILD_SEADSA)"
	@test -f "$(BUILD_SVF)"
	@echo "OK: all scripts present"

# ---------------- DOCKER (Ubuntu 24 x86) ----------------

.PHONY: docker-image docker-shell docker-run

docker-image:
	docker build --platform linux/amd64 -t "$(DOCKER_IMAGE)" -f "$(ROOT)/Dockerfile" "$(ROOT)"

docker-shell: docker-image
	docker run --rm -it -v "$(ROOT):/workspace" -v "$(HOME)/.ssh:/root/.ssh:ro" -w /workspace "$(DOCKER_IMAGE)"

docker-run: docker-image
	docker run --rm -v "$(ROOT):/workspace" -v "$(HOME)/.ssh:/root/.ssh:ro" -w /workspace "$(DOCKER_IMAGE)" make $(target)

# ---------------- TOOLS ----------------

.PHONY: all phasar seadsa svf

all: phasar
phasar:
	bash "$(BUILD_PHASAR)"

all: seadsa
seadsa:
	bash "$(BUILD_SEADSA)"

all: svf
svf:
	bash "$(BUILD_SVF)"

# ---------------- CLEAN ----------------

.PHONY: clean-all clean-tools clean-tools-builds clean-tests clean-results

clean-all: clean-tools
clean-tools:
	rm -rf "$(ROOT)/phasar" "$(ROOT)/sea-dsa" "$(ROOT)/SVF"

clean-all: clean-tools-builds
clean-tools-builds:
	rm -rf "$(ROOT)/phasar/build" "$(ROOT)/sea-dsa/build" "$(ROOT)/SVF/build"

clean-all: clean-tests
clean-tests:
	rm -rf "$(ROOT)/tests"

clean-all: clean-results
clean-results:
	rm -rf "$(ROOT)/results"
