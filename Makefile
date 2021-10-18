HOSTNAME := $(shell basename $(shell hostname) .local)
HOST_OS := $(shell uname)
NIX_CONF := $(HOME)/.config/nix
NIX_DARWIN := $(HOME)/.config/nix-macos

NIXADDR ?= unset
NIXPORT ?= 22

# Settings
NIXBLOCKDEVICE ?= sda


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

vm/bootstrap-base:
	ssh -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/$(NIXBLOCKDEVICE) -- mklabel gpt; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary 512MiB -8GiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary linux-swap -8GiB 100\%; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart ESP fat32 1MiB 512MiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- set 3 esp on; \
		mkfs.ext4 -L nixos /dev/$(NIXBLOCKDEVICE)1; \
		mkswap -L swap /dev/$(NIXBLOCKDEVICE)2; \
		mkfs.fat -F 32 -n boot /dev/$(NIXBLOCKDEVICE)3; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
  			boot.kernelPackages = pkgs.linuxPackages_5_14;\n \
			boot.kernelParams = [\"root=/dev/$(NIXBLOCKDEVICE)1\"];\n \
			services.openssh.passwordAuthentication = true;\n \
			services.openssh.permitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd; \
		reboot; \
	"

vm/bootstrap:
	ssh -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/$(NIXBLOCKDEVICE) -- mklabel gpt; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary 512MiB -8GiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart primary linux-swap -8GiB 100\%; \
		parted /dev/$(NIXBLOCKDEVICE) -- mkpart ESP fat32 1MiB 512MiB; \
		parted /dev/$(NIXBLOCKDEVICE) -- set 3 esp on; \
		mkfs.ext4 -L nixos /dev/$(NIXBLOCKDEVICE)1; \
		mkswap -L swap /dev/$(NIXBLOCKDEVICE)2; \
		mkfs.fat -F 32 -n boot /dev/$(NIXBLOCKDEVICE)3; \
		mount /dev/disk/by-label/nixos /mnt; \
		mkdir -p /mnt/boot; \
		mount /dev/disk/by-label/boot /mnt/boot; \
		nix-shell -p git --command 'git clone https://github.com/mikeyobrien/dotfiles /mnt/etc/nixos'; \
		nixos-generate-config --root /mnt; \
		mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/hosts/$(HOST)/hardware-configuration.nix; \
		rm /mnt/etc/nixos/configuration.nix; \
		rm /mnt/etc/nixos/flake.lock; \
		nix-shell -p git nixFlakes --run 'nixos-install --impure --flake /mnt/etc/nixos/#$(HOST)' && reboot; \
	"

.PHONY: clean default vm/bootstrap-base vm/bootstrap
