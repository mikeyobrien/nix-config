{ config, pkgs, home-manager, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  modules.bspwm.enable = true;
  modules.tmux.enable = true;

  # home-manager modules
  modules.neovim.enable = true;
  modules.alacritty.enable = true;

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
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim
    wget
    firefox
    git
  ];

  fonts.fonts = with pkgs; [
    iosevka
  ];

  virtualisation.vmware.guest.enable = true;
  services.openssh.enable = true;

  system.stateVersion = "21.05"; 
}

