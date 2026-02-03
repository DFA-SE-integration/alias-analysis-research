SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

ROOT := $(abspath .)

BOOTSTRAP    := scripts/00_bootstrap_ubuntu24.sh
CHECKOUT     := scripts/01_checkout_sources.sh
BUILD_PHASAR := scripts/03_build_phasar.sh
BUILD_SVF    := scripts/03_build_SVF.sh
BUILD_SEADSA := scripts/03_build_seadsa.sh
RUN_PTA         := scripts/06_run_phasar_pta.sh
RUN_SVF_PTA     := scripts/06_run_svf_pta.sh
RUN_SEADSA_PTA  := scripts/06_run_seadsa_pta.sh
ENVSH           := scripts/env.sh

DOCKER_IMAGE := alias-analysis-ubuntu24

.PHONY: help doctor bootstrap checkout phasar svf seadsa env \
        clean-results clean-builds clean-all \
        distclean \
        docker-image docker-shell docker-run docker-shell-ssh docker-run-ssh

help:
	@echo "Targets:"
	@echo "  make doctor               - sanity-check scripts exist"
	@echo "  make bootstrap            - apt deps (Ubuntu 24.04)"
	@echo "  make checkout             - clone phasar, SVF, sea-dsa, test-projects"
	@echo "  make phasar               - build phasar-cli"
	@echo "  make svf                  - build SVF (wpa)"
	@echo "  make seadsa               - build SeaDSA"
	@echo "  make env                  - verify env.sh can be sourced"
	@echo "  make all                  - checkout + phasar"
	@echo ""
	@echo "Docker (Ubuntu 24 x86_64):"
	@echo "  make docker-image         - build image $(DOCKER_IMAGE) (linux/amd64)"
	@echo "  make docker-shell     - run interactive shell in container + mount ~/.ssh (repo mounted)"
	@echo "  make docker-run-ssh target=T - run 'make T' in container + mount ~/.ssh (e.g. target=all)"
	@echo ""
	@echo "Clean:"
	@echo "  make clean-results        - remove results/*"
	@echo "  make clean-builds         - remove build artifacts (phasar, test-projects)"
	@echo "  make clean-all            - clean-results + clean-builds"
	@echo "  make distclean            - clean-all + remove checked-out sources"

doctor:
	@test -f "$(BOOTSTRAP)"
	@test -f "$(CHECKOUT)"
	@test -f "$(ENVSH)"
	@test -f "$(BUILD_PHASAR)"
	@test -f "$(BUILD_SVF)"
	@test -f "$(BUILD_SEADSA)"
	@test -f "$(RUN_PTA)"
	@test -f "$(RUN_SVF_PTA)"
	@test -f "$(RUN_SEADSA_PTA)"
	@echo "OK: all scripts present"

bootstrap:
	bash "$(BOOTSTRAP)"

checkout:
	bash "$(CHECKOUT)"

phasar:
	bash "$(BUILD_PHASAR)"

svf:
	bash "$(BUILD_SVF)"

seadsa:
	bash "$(BUILD_SEADSA)"

env:
	source "$(ENVSH)" >/dev/null
	echo "OK: env.sh sourced"

all: checkout phasar

# ---------------- DOCKER (Ubuntu 24 x86) ----------------
docker-image:
	docker build --platform linux/amd64 -t "$(DOCKER_IMAGE)" -f "$(ROOT)/Dockerfile" "$(ROOT)"

docker-shell: docker-image
	docker run --rm -it -v "$(ROOT):/workspace" -v "$(HOME)/.ssh:/root/.ssh:ro" -w /workspace "$(DOCKER_IMAGE)"

docker-run: docker-image
	docker run --rm -v "$(ROOT):/workspace" -v "$(HOME)/.ssh:/root/.ssh:ro" -w /workspace "$(DOCKER_IMAGE)" make $(target)

# ---------------- CLEAN TARGETS ----------------

clean-results:
	rm -rf "$(ROOT)/results"/*

clean-builds:
	rm -rf "$(ROOT)/phasar/build"
	find "$(ROOT)/test-projects" -name "*.bc" -delete 2>/dev/null || true

clean-all: clean-results clean-builds

distclean: clean-all
	rm -rf "$(ROOT)/phasar" "$(ROOT)/SVF" "$(ROOT)/test-projects"
