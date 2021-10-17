{ config, pkgs, lib, ... }:

with lib;
{
  imports = [ ./hardware-configuration.nix ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.kernelPackages = pkgs.linuxPackages_5_14;
  boot.kernelParams = ["root=/dev/sda1"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sculpin"; 
  time.timeZone = "America/Chicago";

  networking.useDHCP = false;
  networking.interfaces.ens160.useDHCP = true;
  i18n.defaultLocale = "en_US.UTF-8";

  modules.bspwm.enable = true;

  # home-manager
  modules.tmux.enable = true;
  modules.alacritty.enable = true;
  modules.neovim.enable = true;

  sound.enable = true;
  users.users.root.initialPassword = "nixos";

  environment.systemPackages = with pkgs; [
    vim 
    wget
    open-vm-tools
    git
    gnumake
  ];

  services.openssh.enable = true;
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}

