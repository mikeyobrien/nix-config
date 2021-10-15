{ options, config, lib, pkgs, ... }:

with lib;
let cfg = config.modules.tmux;
in {
  options.modules.tmux = {
    enable = mkEnableOption "tmux";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      tmux
      tmuxinator
      xsel
    ];

    homeManagerPrograms.tmux = {
      enable = true;
      terminal = "screen-256color";
      shortcut = "a";
      keyMode = "vi";
      baseIndex = 1;
      plugins = with pkgs; [
        tmuxPlugins.yank
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.power-theme
      ];
      extraConfig = builtins.readFile ../home/configs/tmux/tmux.conf;
    };
  };
}
