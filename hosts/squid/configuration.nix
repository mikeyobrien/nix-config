{ config, pkgs, home-manager, ... }:

{
  imports = [
    ../defaults.nix
    ./hardware-configuration.nix
  ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

    # nixOS 
  modules.bspwm.enable = true;
  modules.tmux.enable = true;

  hardware.video.hidpi.enable = true;
  services.xserver.dpi = 244;
  # home-manager modules
  modules = {
    neovim.enable = true;
    alacritty.enable = true;
    emacs.enable = true;
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
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    firefox
    openconnect
    steam-run

    # dev tools
    ssm-session-manager-plugin
    git
    gron
    python3
    python38
    pre-commit
    gcc
    go
    terraform_0_14
    docker
  ];

  security.sudo.wheelNeedsPassword = false;

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

  virtualisation.vmware.guest.enable = true;
  virtualisation.docker.enable = true;
  services.openssh.enable = true;
  system.stateVersion = "21.05";
}

