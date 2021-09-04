{ config, lib, pkgs, ... }:

{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
    "experimental-features = nix-command flakes";

  users.users.mikeyobrien = {
    name = "mikeyobrien";
    home = "/Users/mikeyobrien";
  };
}
