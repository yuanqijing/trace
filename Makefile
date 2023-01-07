# Get the OS information from the system
OS := $(shell uname -s | tr A-Z a-z)
OS_LIST := linux darwin

ARCH := $(shell uname -m | sed 's/x86_64/amd64/')
ARCH_LIST := amd64

# Clang version to use for building the eBPF programs.
CLANG ?= clang-13
CFLAGS := -O2 -g -Wall -Werror $(CFLAGS)

# Obtain an absolute path to the directory of the Makefile.
# Assume the Makefile is in the root of the repository.
REPODIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
UIDGID := $(shell stat -c '%u:%g' ${REPODIR})


##@ Help
.PHONY: help
help: ## Display this help screen
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Build
.PHONY: builder-dev
builder-dev: ## Enter a docker build development environment
	docker run -it --rm \
		-v ${REPODIR}:/ebpf -w /ebpf \
		--env MAKEFLAGS \
		--env CFLAGS="-fdebug-prefix-map=/ebpf=." \
		--env HOME="/tmp" \
		${BUILDER_IMAGE_FULL_NAME} \
		/bin/bash

.PHONY: clean
clean: ## Clean the binary
	@rm -rf bin

##@ Go
.PHONY: deps
deps: ## Download dependencies
	@go mod tidy
	@go mod vendor

.PHONY: generate
generate: export BPF_CLANG := $(CLANG)
generate: export BPF_CFLAGS := $(CFLAGS)
generate: ## Generate code
	@cd pkg/ebpf && go generate ./...

# docker include common helpers required for building the docker image
include Makefile.dk

# vagrant include common helpers required for running vagrant
include Makefile.vg
