SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

ROOT := $(abspath .)

DOCKER_BOOTSTRAP    := scripts/docker/00_bootstrap_ubuntu24.sh

RES_REPORT			:= scripts/results/report.sh

CHECKOUT     		:= scripts/01_checkout_sources.sh

BUILD_PHASAR 		:= scripts/02_build_phasar.sh
BUILD_SVF    		:= scripts/02_build_svf.sh
BUILD_SEADSA 		:= scripts/02_build_seadsa.sh

BUILD_TESTSUITE 	:= scripts/03_build_testsuite.sh
BUILD_PTRBENCH  	:= scripts/03_build_ptrbench.sh

RUN_SVF_TSUITE     	:= scripts/04_run_svf_tsuite.sh
RUN_PHASAR_TSUITE	:= scripts/04_run_phasar_tsuite.sh
RUN_SDSA_TSUITE		:= scripts/04_run_sdsa_tsuite.sh
ENVSH           	:= scripts/env.sh

DOCKER_IMAGE 		:= alias-analysis-ubuntu24

# ---------------- GENERAL TARGETS ----------------

.PHONY: help doctor checkout

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
	@echo "  make tools-all            - all tools"
	@echo "  make tools-phasar         - build phasar-cli"
	@echo "  make tools-seadsa         - build SeaDSA"
	@echo "  make tools-svf            - build SVF (wpa)"
	@echo ""
	@echo "Tests:"
	@echo "  make test-all             - all tests"
	@echo "  make test-testsuit        - build Test-Suite"
	@echo "  make test-ptrbench        - build PointerBench(C version)"
	@echo ""
	@echo "Run tests:"
	@echo "  make run-svf-tsuite       - run svf tool on test-suite binaries"
	@echo "  make run-phasar-tsuite    - run phasar tool on test-suite binaries"
	@echo "  make run-sdsa-tsuite	   - run seadsa tool on test-suite binaries"
	@echo ""
	@echo "Clean:"
	@echo "  make clean-all              - clean all"
	@echo "  make clean-tools            - remove tools projects(phasar, seadsa, svf)"
	@echo "  make clean-tools-builds     - remove tools build artifacts"
	@echo "  make clean-tests            - remove tests projects(Test-Suite, PointerBench)"
	@echo "  make clean-tests-builds     - remove tests build artifacts"
	@echo "  make clean-results          - remove tests projects *.bc files"

doctor:
	@test -f "$(DOCKER_BOOTSTRAP)"
	@test -f "$(CHECKOUT)"
	@test -f "$(BUILD_PHASAR)"
	@test -f "$(BUILD_SEADSA)"
	@test -f "$(BUILD_SVF)"
	@test -f "$(BUILD_TESTSUITE)"
	@test -f "$(BUILD_PTRBENCH)"
	@test -f "$(RUN_SVF_TSUITE)"
	@test -f "$(RUN_PHASAR_TSUITE)"
	@echo "OK: all scripts present"

checkout:
	bash "$(CHECKOUT)"

report:
	bash "$(RES_REPORT)" Test-Suite

# ---------------- DOCKER (Ubuntu 24 x86) ----------------

.PHONY: docker-image docker-shell docker-run

docker-image:
	docker build --platform linux/amd64 -t "$(DOCKER_IMAGE)" -f "$(ROOT)/Dockerfile" "$(ROOT)"

docker-shell: docker-image
	docker run --rm -it -v "$(ROOT):/workspace" -v "$(HOME)/.ssh:/root/.ssh:ro" -w /workspace "$(DOCKER_IMAGE)"

docker-run: docker-image
	docker run --rm -v "$(ROOT):/workspace" -v "$(HOME)/.ssh:/root/.ssh:ro" -w /workspace "$(DOCKER_IMAGE)" make $(target)

# ---------------- TOOLS ----------------

.PHONY: tools-all tools-phasar tools-seadsa tools-svf

tools-all: tools-phasar
tools-phasar: checkout
	bash "$(BUILD_PHASAR)"

tools-all: tools-seadsa
tools-seadsa: checkout
	bash "$(BUILD_SEADSA)"

tools-all: tools-svf
tools-svf: checkout
	bash "$(BUILD_SVF)"

# ---------------- TESTS ----------------

.PHONY: test-all test-testsuit test-ptrbench

test-all: test-testsuit
test-testsuit: checkout
	bash "$(BUILD_TESTSUITE)"

test-all: test-ptrbench
test-ptrbench: checkout
	bash "$(BUILD_PTRBENCH)"

# ---------------- RUN TESTS ----------------

.PHONY: run-svf-tsuite run-phasar-tsuite run-sdsa-tsuite

run-svf-tsuite:
	bash "$(RUN_SVF_TSUITE)"

run-phasar-tsuite:
	bash "$(RUN_PHASAR_TSUITE)"

run-sdsa-tsuite:
	bash "$(RUN_SDSA_TSUITE)" cs
	bash "$(RUN_SDSA_TSUITE)" butd-cs
	bash "$(RUN_SDSA_TSUITE)" bu
	bash "$(RUN_SDSA_TSUITE)" ci
	bash "$(RUN_SDSA_TSUITE)" flat

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

clean-all: clean-tests-builds
clean-tests-builds:
	rm -rf "$(ROOT)/tests/Test-Suite/build" "$(ROOT)/tests/PointerBench/build"

clean-all: clean-results
clean-results:
	rm -rf "$(ROOT)/results"
