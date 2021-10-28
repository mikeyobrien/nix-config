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

  services.yabai = {
    enable = false;
    package = pkgs.yabai;
    enableScriptingAddition = false;
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
      top_padding = 4;
      bottom_padding = 4;
      left_padding = 4;
      right_padding = 4;
      window_gap = 4;
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
      yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
      yabai -m rule --add label="System Preferences" app="^System Preferences$" title=".*" manage=off
      yabai -m rule --add label="App Store" app="^App Store$" manage=off
      yabai -m rule --add label="Activity Monitor" app="^Activity Monitor$" manage=off
      yabai -m rule --add app="Finder" manage=off border=off
      yabai -m rule --add app="VMware Fusion" manage=off
      yabai -m rule --add label="Software Update" title="Software Update" manage=off
      yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off

      yabai -m --space 3 layout float
    '';
  };


  fonts.fonts = with pkgs; [
    iosevka
    fira-code
    fira-code-symbols
    nerdfonts
    powerline-fonts
  ];

  services.skhd.enable = false;
  #services.skhd.skhdConfig = builtins.readFile ../dotfiles/skhdrc;
}
