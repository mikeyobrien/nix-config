{ pkgs, ... }:

{
  # https://github.com/nix-community/home-manager/pull/2408
  environment.pathsToLink = [ "/share/zsh" ];

  users.users.mobrienv = {
    isNormalUser = true;
    home = "/home/mobrienv";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$75PXz5XJsYjicI7I$/A4kShCt2gmhAxji.lV8e/VKIUu5mkx.OedV/KUCOiSTbzzpM0hnVOzUKzZ4ULsjl8.S52q3Tqau8Me6iS7JH1";
  };
}
