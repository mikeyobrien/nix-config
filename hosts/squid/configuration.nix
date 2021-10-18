{ config, pkgs, home-manager, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };



  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda"; # or "nodev" for efi only
  };

  # nixOS 
  modules.bspwm.enable = true;
  modules.tmux.enable = true;

  # home-manager modules
  modules = {
    neovim.enable = true;
    alacritty.enable = true;
  };

  programs.fish.enable = true;

  networking.hostName = "squid";
  time.timeZone = "America/Chicago";
  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;
  i18n.defaultLocale = "en_US.UTF-8";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.initialPassword = "nixos";
  users.users.mikeyobrien = {
    isNormalUser = true;
    initialPassword = "nixos";
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim
    wget
    firefox
    git
    openconnect

    python3
    pre-commit
    gcc
  ];

  fonts.fonts = with pkgs; [
    iosevka
    nerdfonts
  ];

  virtualisation.vmware.guest.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "21.05";
}

