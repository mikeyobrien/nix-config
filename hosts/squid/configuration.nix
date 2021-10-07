{ config, pkgs, ... }:

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

  networking.hostName = "squid";

  time.timeZone = "America/Chicago";

  networking.useDHCP = false;
  networking.interfaces.ens33.useDHCP = true;

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = true;
  services.xserver.windowManager.bspwm = {
    enable = true;
  };

  services.xserver.displayManager = {
    defaultSession = "none+bspwm";
    lightdm.enable = true;
    lightdm.greeters.mini.enable = true;
    lightdm.greeters.mini.user = "mikeyobrien";
  };
    
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

  virtualisation.vmware.guest.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "21.05"; 
}

