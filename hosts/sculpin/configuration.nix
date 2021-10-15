{ config, pkgs, lib, ... }:

with lib;
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sculpin"; # Define your hostname.
  time.timeZone = "America/Chicago";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens160.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    windowManager.bspwm.enable = true;
    displayManager = {
      lightdm.enable = true;
      defaultSession = "none+bspwm";
      lightdm.greeters.mini.enable = true;
      lightdm.greeters.mini.user = "mikeyobrien";
      sessionCommands = ''
        ${pkgs.open-vm-tools}/bin/vmware-user-suid-wrapper
      '';
    };
  };


  sound.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.initialPassword = "nixos";
  users.users.mikeyobrien = {
    isNormalUser = true;
    initialPassword = "nixos";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    vim 
    wget
    open-vm-tools
  ];

  systemd.services.vmware = {
    description = "VMWare Guest Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = "${pkgs.open-vm-tools}/bin/vmtoolsd";
  };

  services.udev.packages = [ pkgs.open-vm-tools ];

  security.wrappers.vmware-user-suid-wrapper = {
    setuid = true;
    owner = "root";
    group = "root";
    source = "${pkgs.open-vm-tools}/bin/vmware-user-suid-wrapper";
  };

  environment.etc.vmware-tools.source = "${pkgs.open-vm-tools}/etc/vmware-tools/*";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}

