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
      escapeTime = 0;
      shortcut = "a";
      keyMode = "vi";
      baseIndex = 1;
      aggressiveResize = true;
      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.yank;
          extraConfig = '' 
            set -g @yank_selection 'primary'
            bind-key -T copy-mode-vi 'v' send -X begin-selection
            bind-key -T copy-mode-vi 'r' send -X rectangle-toggle
            bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel
          '';
        }
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.power-theme
      ];
      extraConfig = builtins.readFile ../home/configs/tmux/tmux.conf;
    };
  };
}
