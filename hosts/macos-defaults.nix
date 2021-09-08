{ config, lib, pkgs, ... }:

with builtins;
{
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
    "experimental-features = nix-command flakes";
  nixpkgs = {
    config.allowUnfree = true;
  };

  users.users.mikeyobrien = {
    name = "mikeyobrien";
    home = "/Users/mikeyobrien";
  };

  modules.brew = {
    enable = true;
    casks = [
      "iterm2"
      "docker"
    ];
    extraConfig = ''
      brew "emacs-plus@28", args: ["with-native-comp", "with-no-titlebar"]
    '';
  };

  services.yabai = {
    enable = true;
    package = pkgs.yabai;
    config = {
      mouse_follows_focus = "off";
      focus_follows_mouse = "off";
      window_placement = "second_child";
      window_topmost = "off";
      window_opacity = "off";
      window_opacity_duration = 0.0;
      window_shadow = "float";
      window_border = "off";
      window_border_radius = -1.0;
      active_window_border_topmost = "off";
      split_ratio = 0.50;
      auto_balance = "off";
      mouse_modifier = "fn";
      mouse_action1 = "move";
      mouse_action2 = "resize";
      layout = "bsp";
      top_padding = 2;
      bottom_padding = 2;
      left_padding = 2;
      right_padding = 2;
      window_gap = 2;
      window_most = "on";
    };

    extraConfig  = ''
      # Space labels
      yabai -m space 1 --label "Primary"
      yabai -m space 2 --label "Code"
      yabai -m space 3 --label "Float"
      yabai -m space 4 --label "Comm"
      yabai -m space 5 --label "Media"
      yabai -m space 6 --label "Secondary"

      # Unmanaged
      yabai -m rule --add label="Fantastical" app="^Fantastical$" title="^Fantastical$" manage=off
      yabai -m rule --add app="^System Preferences$" manage=off border=off
      yabai -m rule --add app="Finder" manage=off border=off


      yabai -m rule --add app="Emacs"               space=2
      yabai -m rule --add app="iTerm2"              space=2
      --space 3 layout float
    '';
  };

  services.skhd.enable = true;
  services.skhd.skhdConfig = builtins.readFile ../dotfiles/skhdrc;
}
