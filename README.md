# nix-config

Flake based nix-config for linux based machines.

## Install
Retrieve and boot VM with nixos iso.

Set harddrive to SATA.
I am using 150GB disk space, half cpu cores, and half ram. (if there isn't enough ram, the install may fail).

Retrieve the ip and chpasswd for root to ssh from host machine.

Run,
```
NIXADDR=<vm-ipaddr> HOST=<squid|sculpin> vm/bootstrap
```

This should download the repository and install the flake.  
After the reboot, the system-configuration will be applied to the VM.  


## Hosts
- sculpin (aarch64)
- squid (x86)
- m1macbook (deprecated)
- nix-wsl (deprecated)
The nix-darwin hosts are in the process of being managed solely by home-manager, as the need for a declarative system configuration is less needed as I use Linux VMs for main dev.

## Home-Manager
For home-manager only configurations, this is an easy way to share a base set of packages + dotfiles between machines.

### Requirements
Install [Nix](https://nixos.org/manual/nix/stable/#ch-installing-binary)
Install [Home-Manager](https://github.com/nix-community/home-manager)

Enable flakes by adding,
```
mkdir -p ~/.config/nix/ && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Current systems
- mobrien-mbp19


