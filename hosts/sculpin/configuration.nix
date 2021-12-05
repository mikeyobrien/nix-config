{ config, pkgs, lib, ... }:

with lib;
with builtins;
{
  imports = [ ./hardware-configuration.nix ../../modules/vmware-guest.nix ];
  disabledModules = [ "virtualisation/vmware-guest.nix" ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  boot.kernelPackages =  pkgs.linuxPackages_5_14;

  boot.kernelPatches = [
    { 
      name = "efi-initrd-support";
      patch = null;
      extraConfig = ''
        EFI_GENERIC_STUB_INITRD_CMDLINE_LOADER y
      '';
    }
    {
      name = "fix-kernel-build";
      patch = null;
      extraConfig = ''
        DRM_SIMPLEDRM n
      '';
    }
  ];

  boot.kernelParams = ["root=/dev/sda1"];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  virtualisation.vmware.guest.enable = true;

  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "sculpin"; 
  time.timeZone = "America/Chicago";

  networking.useDHCP = false;
  networking.interfaces.ens160.useDHCP = true;
  i18n.defaultLocale = "en_US.UTF-8";

  modules.bspwm.enable = true;

  hardware.video.hidpi.enable = true;
  services.xserver.dpi = 220;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xlibs.xset}/bin/xset r rate 200 40
    ${pkgs.xorg.xrandr}/bin/xrandr -s '2560x1440'
  '';

  # home-manager
  modules.tmux.enable = true;
  modules.alacritty.enable = true;
  modules.neovim.enable = true;
  modules.emacs.enable = true;

  sound.enable = true;
  users.users.root.initialPassword = "nixos";
  users.users.mikeyobrien.shell = pkgs.fish;

  # services.xserver.displayManager.lightdm.greeters.mini.user = "mikeyobrien";

  environment.systemPackages = with pkgs; [
    vim
    wget
    open-vm-tools
    git
    gtkmm3
    gnumake
    xst
    mosh

    terraform
    terraform-ls
    kubernetes-helm
    kubectl
    (writeShellScriptBin "xrandr-2k" ''
      xrandr -s 2560x1440
    '')
    (writeShellScriptBin "xrandr-mbp" ''
      xrandr -s 2880x1800
    '')
  ];

  fonts.fonts = with pkgs; [
    nerdfonts
  ];

   # Shared folder to host works on Intel
  fileSystems."/mnt/host" = {
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    device = ".host:/";
    options = [
      "uid=1000"
      "gid=1000"
      "allow_other"
      "auto_unmount"
      "defaults"
    ];
  };

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

