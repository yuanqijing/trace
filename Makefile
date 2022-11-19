##@ Help
.PHONY: help
help: ## Display this help screen
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Build
BUILD_TARGET ?= all

OS := $(shell uname -s | tr A-Z a-z)
OS_LIST := linux darwin

# get current arch (replace x86_64 with amd64)
ARCH := $(shell uname -m | sed 's/x86_64/amd64/')
ARCH_LIST := amd64

.PHONY: get-apps
get-apps: ## Get all buildable apps
	@for app in $(shell ls cmd); do \
		echo $$app; \
	done

.PHONY: build
build: ## Build the binary
	@echo BUILD_TARGET=$(BUILD_TARGET)
	@if [ "$(BUILD_TARGET)" != "all" ]; then \
    	echo "Building $(BUILD_TARGET)"; \
    	make build-app APP=$(BUILD_TARGET); \
    else \
		for app in $(shell ls cmd); do \
			echo "Building $$app"; \
			make build-app APP=$$app; \
		done; \
	fi

.PHONY: build-app
APP ?= $(BUILD_TARGET)
build-app: ## Build the binary
	@if [ -d "cmd/$(APP)" ]; then \
		for os in $(OS_LIST); do \
			for arch in $(ARCH_LIST); do \
				echo "Building for $$os/$$arch... app: $(APP)"; \
				mkdir -p bin/$$os/$$arch; \
				GOOS=$$os GOARCH=$$arch go build -o bin/$$os/$$arch/$(APP) ./cmd/$(APP); \
			done; \
		done; \
	else \
		echo "App $(APP) not found"; \
	fi

.PHONY: clean
clean: ## Clean the binary
	@rm -rf bin

##@ Run
.PHONY: run
run: ## Run the binary
	@for app in $(shell ls cmd); do \
		echo "Running $$app..., OS: $(OS), ARCH: $(ARCH)"; \
		bin/$(OS)/$(ARCH)/$$app; \
	done

.PHONY: run-strace
run-strace: ## Run the binary with strace
	@for app in $(shell ls cmd); do \
		echo "Running $$app..., OS: $(OS), ARCH: $(ARCH)"; \
		mkdir -p output/strace/$(OS)/$(ARCH); \
		strace -f -o output/strace/$(OS)/$(ARCH)/$$app.log bin/$(OS)/$(ARCH)/$$app; \
		echo "Output: output/strace/$(OS)/$(ARCH)/$$app.log"; \
	done

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

