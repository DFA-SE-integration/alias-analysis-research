SHELL := /bin/bash
.ONESHELL:
.SHELLFLAGS := -euo pipefail -c

ROOT := $(abspath .)

DOCKER_IMAGE 		:= alias-analysis-ubuntu24
DOCKER_BOOTSTRAP    := scripts/docker/00_bootstrap_ubuntu24.sh

BUILD_PHASAR 		:= scripts/02_build_phasar.sh
BUILD_SVF    		:= scripts/02_build_SVF.sh
BUILD_SEADSA_14 	:= scripts/02_build_seadsa_llvm14.sh
BUILD_SEADSA_20 	:= scripts/02_build_seadsa_llvm20.sh

BUILD_TESTSUITE 	:= scripts/02_build_testsuite.sh
BUILD_SCALABILITY	:= scripts/02_build_scalability.sh

RUN_TSUITE_PHASAR	:= scripts/03_run_tsuite_phasar.sh
RUN_TSUITE_SDSA_14	:= scripts/03_run_tsuite_sdsa_llvm14.sh
RUN_TSUITE_SDSA_20	:= scripts/03_run_tsuite_sdsa_llvm20.sh
RUN_TSUITE_SVF     	:= scripts/03_run_tsuite_svf.sh

RUN_SCALABILITY		:= scripts/03_run_scalability.sh

ENVSH           	:= scripts/env.sh
REPORT			:= scripts/report.sh

# ---------------- GENERAL TARGETS ----------------

.PHONY: help doctor report

help:
	@echo "Targets:"
	@echo "Docker (Ubuntu 24 x86_64):"
	@echo "  make docker-image		- build image $(DOCKER_IMAGE)"
	@echo "  make docker-shell		- run interactive shell in container + mount ~/.ssh (repo mounted)"
	@echo "  make docker-run target=T 	- run 'make T' in container + mount ~/.ssh (e.g. target=all)"
	@echo ""
	@echo "General:"
	@echo "  make doctor			- sanity-check scripts exist"
	@echo ""
	@echo "Tools:"
	@echo "  make tools-all		- all tools"
	@echo "  make tools-phasar		- build phasar-cli"
	@echo "  make tools-seadsa		- build SeaDSA"
	@echo "  make tools-seadsa-llvm14	- build SeaDSA against clangir LLVM14"
	@echo "  make tools-seadsa-llvm20	- build SeaDSA against clangir LLVM20"
	@echo "  make tools-svf		- build SVF (wpa)"
	@echo ""
	@echo "Tests:"
	@echo "  make test-all			- all tests"
	@echo "  make test-testsuit		- build Test-Suite"
	@echo "  make test-scalability		- download bzip2 and build scalability .bc"
	@echo ""
	@echo "Run tests:"
	@echo "  make run-tsuite-phasar	- run phasar tool on test-suite binaries"
	@echo "  make run-tsuite-sdsa-llvm14	- run llvm14 seadsa on llvm14 test-suite binaries"
	@echo "  make run-tsuite-sdsa-llvm20	- run llvm20 seadsa on llvm20 test-suite binaries"
	@echo "  make run-tsuite-svf		- run svf tool on test-suite binaries"
	@echo "  make run-scalability		- run all tools on bzip2 (scalability test)"
	@echo ""
	@echo "Reports:"
	@echo "  make report			- report for tests results"
	@echo ""
	@echo "Clean:"
	@echo "  make clean-all		- clean all"
	@echo "  make clean-tools-builds	- remove tools build artifacts"
	@echo "  make clean-tests-builds	- remove tests build artifacts"
	@echo "  make clean-results		- remove tests running results artifacts"

doctor:
	@test -f "$(DOCKER_BOOTSTRAP)"
	@test -f "$(BUILD_PHASAR)"
	@test -f "$(BUILD_SEADSA_14)"
	@test -f "$(BUILD_SEADSA_20)"
	@test -f "$(BUILD_SVF)"
	@test -f "$(BUILD_TESTSUITE)"
	@test -f "$(BUILD_SCALABILITY)"
	@test -f "$(RUN_TSUITE_PHASAR)"
	@test -f "$(RUN_TSUITE_SDSA)"
	@test -f "$(RUN_TSUITE_SVF)"
	@test -f "$(RUN_SCALABILITY)"
	@echo "OK: all scripts present"

report:
	bash "$(REPORT)"

# ---------------- DOCKER (Ubuntu 24 x86) ----------------

.PHONY: docker-image docker-shell docker-run

docker-image:
	docker build -t "$(DOCKER_IMAGE)" -f "$(ROOT)/Dockerfile" "$(ROOT)"

docker-shell: docker-image
	docker run --rm -it -v "$(ROOT):/workspace" -v "$(ROOT)/clangir-glibc-arm64/build:/tmp/llvm-build" -v "$(HOME)/.ssh:/root/.ssh:ro" -w /workspace "$(DOCKER_IMAGE)"

docker-run: docker-image
	docker run --rm -v "$(ROOT):/workspace" -v "$(ROOT)/clangir-glibc-arm64/build:/tmp/llvm-build" -v "$(HOME)/.ssh:/root/.ssh:ro" -w /workspace "$(DOCKER_IMAGE)" make $(target)

# ---------------- TOOLS ----------------

.PHONY: tools-all tools-phasar tools-seadsa tools-seadsa-llvm14 tools-seadsa-llvm20 tools-svf

tools-all: tools-phasar
tools-phasar:
	bash "$(BUILD_PHASAR)"

tools-all: tools-seadsa-llvm14
tools-seadsa: tools-seadsa-llvm14
tools-seadsa-llvm14:
	bash "$(BUILD_SEADSA_14)"

tools-all: tools-seadsa-llvm20
tools-seadsa: tools-seadsa-llvm20
tools-seadsa-llvm20:
	bash "$(BUILD_SEADSA_20)"

tools-all: tools-svf
tools-svf:
	bash "$(BUILD_SVF)"

# ---------------- TESTS ----------------

.PHONY: test-all test-testsuit test-scalability

test-all: test-testsuit
test-testsuit:
	bash "$(BUILD_TESTSUITE)"

test-all: test-scalability
test-scalability:
	bash "$(BUILD_SCALABILITY)"

# ---------------- RUN TESTS ----------------

.PHONY: run-tsuite run-tsuite-svf run-tsuite-phasar run-tsuite-sdsa run-tsuite-sdsa-llvm20

run-tsuite: run-tsuite-phasar
run-tsuite-phasar:
	bash "$(RUN_TSUITE_PHASAR)"

run-tsuite: run-tsuite-sdsa-llvm14
run-tsuite-sdsa-llvm14:
	bash "$(RUN_TSUITE_SDSA_14)"

run-tsuite: run-tsuite-sdsa-llvm20
run-tsuite-sdsa-llvm20:
	bash "$(RUN_TSUITE_SDSA_20)"

run-tsuite: run-tsuite-svf
run-tsuite-svf:
	bash "$(RUN_TSUITE_SVF)"

.PHONY: run-scalability

run-scalability:
	bash "$(RUN_SCALABILITY)"

# ---------------- CLEAN ----------------

.PHONY: clean-all clean-tools-builds clean-tests-builds clean-results

clean-all: clean-tools-builds
clean-tools-builds:
	rm -rf "$(ROOT)/phasar/build" "$(ROOT)/sea-dsa/build" "$(ROOT)/sea-dsa-llvm20/build" "$(ROOT)/SVF/build"

clean-all: clean-tests-builds
clean-tests-builds:
	rm -rf "$(ROOT)/tests/Test-Suite/build" "$(ROOT)/tests/scalability/build"

clean-all: clean-results
clean-results:
	rm -rf "$(ROOT)/results"
