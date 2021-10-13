{ config, options, lib, home-manager, ... }:

with lib;
{
  options = with types; {
    home = {
      configFile = mkOption {
        type = attrs;
        description = "xdg config file";
      };
      file = mkOption {
        type = attrs;
        description = "home file";
      };
      dataFile = mkOption {
        type = attrs;
        description = "xdg home file";
      };

      packages = mkOption {
        type = listOf package;
        description = "packages"; 
      };
    };

    homeManagerPrograms = mkOption {
      type = attrs;
      description = "list of programs to enable";
    };
  };

  config = {
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      users.mikeyobrien = {
        imports = [ ../home ];
        home = {
          homeDirectory = "/home/mikeyobrien";
          username = "mikeyobrien";
          file = mkAliasDefinitions options.home.file;
          packages = mkAliasDefinitions options.home.packages;
        };
        xdg = {
          configFile = mkAliasDefinitions options.home.configFile;
          dataFile   = mkAliasDefinitions options.home.dataFile;
        };

        programs = mkAliasDefinitions options.homeManagerPrograms;
      };
    };
  };
}
