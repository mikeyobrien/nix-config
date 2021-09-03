{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  defaultUser = "mikeyobrien";
  syschdemd = import ./syschdemd.nix { inherit lib pkgs config defaultUser; };
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
  ];
  boot.isContainer = true;
  environment.etc.hosts.enable = false;
  environment.etc."resolv.conf".enable = false;
  environment.noXlibs = false;
  networking.dhcpcd.enable = false;

  # WSL is closer to a container than anything else

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs.fish.enable = true;

  users.users.${defaultUser} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  users.extraUsers.${defaultUser} = {
    shell = pkgs.fish;
  };  

  users.users.root = {
    shell = "${syschdemd}/bin/syschdemd";
    # Otherwise WSL fails to login as root with "initgroups failed 5"
    extraGroups = [ "root" ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Disable systemd units that don't make sense on WSL
  systemd.services."serial-getty@ttyS0".enable = false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;

  systemd.services.firewall.enable = false;
  systemd.services.systemd-resolved.enable = false;
  systemd.services.systemd-udevd.enable = false;

  # Don't allow emergency mode, because we don't have a console.
  systemd.enableEmergencyMode = false;
}
