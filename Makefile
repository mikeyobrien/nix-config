HOSTNAME := $(shell basename $(shell hostname) .local)
HOST_OS := $(shell uname)
NIX_CONF := $(HOME)/.config/nix
NIX_DARWIN := $(HOME)/.config/nix-macos

env-args:
	@echo NIX_CONF=$(NIX_CONF)
	@echo NIX_DARWIN=$(NIX_DARWIN)
	@echo HOSTNAME=$(HOSTNAME)

clean:
	@echo Cleaning build directory...
	rm $(NIX_DARWIN)/result

build:
	@echo BUILD_ARG=$(NIX_DARWIN)/#darwinConfigurations.$(HOSTNAME).system
	@nix -v build $(NIX_DARWIN)/#darwinConfigurations.$(HOSTNAME).system

switch:
	@$(NIX_DARWIN)/result/sw/bin/darwin-rebuild switch --flake $(NIX_DARWIN)

rebuild-switch:
	@nixos-rebuild switch --flake "/etc/nixos#"

darwin-switch: build switch
