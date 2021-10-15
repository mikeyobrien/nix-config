{ config, options, lib, home-manager, ... }:

with lib;
{
  options = with types; {

    user = mkOption {
      type = attrs;
      default = {};
    };

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
    user =
      let user = builtins.getEnv "USER";
          name = if elem user [ "" "root" ] then "mikeyobrien" else user;
      in {
        inherit name;
        description = "The primary user account";
        extraGroups = [ "wheel" ];
        isNormalUser = true;
        home = "/home/${name}";
        group = "users";
        uid = 1000;
      };

    users.users.${config.user.name} = mkAliasDefinitions options.user;
    nix = let users = [ "root" config.user.name ]; in {
      trustedUsers = users;
      allowedUsers = users;
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      users.mikeyobrien = {
        imports = [ ../home ];
        home = {
          username = "mikeyobrien";
          file = mkAliasDefinitions options.home.file;
          packages = mkAliasDefinitions options.home.packages;
          stateVersion = config.system.stateVersion;
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
