{ config, pkgs, lib, ... }: {
  imports = [
    ../modules/vmware-guest.nix
    ./defaults.nix
  ];

  # Disable the default module and import our override. We have
  # customizations to make this work on aarch64.
  disabledModules = [ "virtualisation/vmware-guest.nix" ];

  # Interface is this on M1
  networking.interfaces.ens160.useDHCP = true;

  # Lots of stuff that uses aarch64 that claims doesn't work, but actually works.
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnsupportedSystem = true;

  # This works through our custom module imported above
  virtualisation.vmware.guest.enable = true;
  users.users.root.initialPassword = "root";

  services.xserver.dpi = 220;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xset}/bin/xset r rate 200 40
    ${pkgs.xorg.xrandr}/bin/xrandr -s '2560x1440'
  '';
}
