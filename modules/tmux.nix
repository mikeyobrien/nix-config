{ options, config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.tmux;
in {
  options.modules.tmux = {
    enable = mkEnableOption "tmux";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      tmux
      tmuxinator
    ];

    home.file.".tmux.conf".source = ../home/configs/tmux/tmux.conf;
  };
}
