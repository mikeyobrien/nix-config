{ config, options, lib, home-manager, ... }:

with lib;
{
  options = with types; {
    homeManagerPrograms = mkOption {
      type = attrs;
      description = "list of programs to enable";
    };
  };

  config = {
    programs = mkAliasDefinitions options.homeManagerPrograms;
  };
}
