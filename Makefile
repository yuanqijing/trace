# Get the OS information from the system
OS := $(shell uname -s | tr A-Z a-z)
OS_LIST := linux darwin

ARCH := $(shell uname -m | sed 's/x86_64/amd64/')  # get current arch (replace x86_64 with amd64)
ARCH_LIST := amd64

# Clang version to use for building the eBPF programs.
CLANG ?= clang-12
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
.PHONY: docker-dev
docker-dev: ## Enter a docker build development environment
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


##@ Docker
ALI_REGISTRY ?= registry.cn-hangzhou.aliyuncs.com
ALI_REGISTRY_NAMESPACE ?= pandora-io
ALI_REGISTRY_USER ?= "qijing89760"
ALI_REGISTRY_PASSWORD ?= "pandora12345"

IMAGE_NAME ?= tracer
IMAGE_TAG ?= $(GitCommit)
BUILDER_IMAGE_NAME ?= tracer-builder
BUILDER_IMAGE_TAG ?= v1.0.0

TRACER_IMAGE_FULL_NAME ?= $(ALI_REGISTRY)/$(ALI_REGISTRY_NAMESPACE)/$(IMAGE_NAME):$(IMAGE_TAG)
BUILDER_IMAGE_FULL_NAME ?= $(ALI_REGISTRY)/$(ALI_REGISTRY_NAMESPACE)/$(BUILDER_IMAGE_NAME):$(BUILDER_IMAGE_TAG)

.PHONY: login
login: ## Login to the registry
	@docker login -u $(ALI_REGISTRY_USER) -p $(ALI_REGISTRY_PASSWORD) $(ALI_REGISTRY)

.PHONY: push
push: login ## Push the tracer & builder image to the registry
	@docker push $(TRACER_IMAGE_FULL_NAME) && docker push $(BUILDER_IMAGE_FULL_NAME)

.PHONY: build-tracer
build-tracer: ## Build the docker image
	@docker build -t $(TRACER_IMAGE_FULL_NAME) .

.PHONY: build-builder
build-builder: ## build or download the builder.
	@if [ -z "$(shell docker images -q $(BUILDER_IMAGE_NAME))" ]; then \
  		cd builder/docker && docker build -t $(BUILDER_IMAGE_NAME) .; \
	fi;\
	echo "builder image is ready."

##@ Run


##@ Vagrant
VAGRANT_BOX ?= "generic/ubuntu2204"

.PHONY: vagrant-up
vagrant-up: ## Start the vagrant box
	@sed 's|config.vm.box = ".*"|config.vm.box = $(VAGRANT_BOX)|' Vagrantfile > Vagrantfile.tmp && mv Vagrantfile.tmp Vagrantfile
	vagrant up

.PHONY: vagrant-reload
vagrant-reload: ## Reload the vagrant box
	vagrant reload

.PHONY: vagrant-ssh
vagrant-ssh: ## SSH into the vagrant box, password: vagrant
	vagrant ssh -c "su"

.PHONY: vagrant-stop
vagrant-stop: ## Stop the vagrant box
	vagrant halt

.PHONY: vagrant-destroy
vagrant-destroy: ## Destroy the vagrant box
	vagrant destroy

.PHONY: vagrant-rm-box
vagrant-rm-box: ## Remove the vagrant box
	vagrant box remove $(VAGRANT_BOX)

