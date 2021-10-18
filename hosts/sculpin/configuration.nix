{ config, pkgs, lib, ... }:

with lib;
with builtins;
{
  imports = [ ./hardware-configuration.nix ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.kernelPackages =  pkgs.linuxPackagesFor (pkgs.linux_5_14.override {
    argsOverride = rec {
      src = pkgs.fetchurl {
            url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
            sha256 = "0capilz3wx29pw7n2m5cn229vy9psrccmdspp27znhjkvwj0m0wk";
      };
      version = "5.14.11";
      modDirVersion = "5.14.11";
      };
  });

  boot.kernelParams = ["root=/dev/sda1"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sculpin"; 
  time.timeZone = "America/Chicago";

  networking.useDHCP = false;
  networking.interfaces.ens160.useDHCP = true;
  i18n.defaultLocale = "en_US.UTF-8";

  modules.bspwm.enable = true;

  hardware.video.hidpi.enable = true;
  services.xserver.dpi = 180;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xlibs.xset}/bin/xset r rate 200 40
    ${pkgs.xorg.xrandr}/bin/xrandr -s '2880x1800' 
  '';

  # home-manager
  modules.tmux.enable = true;
  modules.alacritty.enable = true;
  modules.neovim.enable = true;
  modules.emacs.enable = true;

  sound.enable = true;
  users.users.root.initialPassword = "nixos";
  users.users.mikeyobrien.shell = pkgs.fish;

  environment.systemPackages = with pkgs; [
    vim 
    wget
    open-vm-tools
    git
    gnumake
    xst
    mosh
  ];

  fonts.fonts = with pkgs; [
    nerdfonts
  ];

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.5";
    _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  };

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

