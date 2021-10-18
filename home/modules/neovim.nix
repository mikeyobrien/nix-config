{ options, config, lib, pkgs, ... }:


with lib;
let cfg = config.modules.neovim;
in {
  options.modules.neovim.enable = mkEnableOption "neovim";

  config = mkIf cfg.enable {
      home.file.".config/nvim/backup/.keep".text = "";
      home.packages = with pkgs; [
        rnix-lsp
        nodejs
        metals
        terraform-ls
      ];

      homeManagerPrograms.neovim = {
        enable = true;
        withPython3 = true;
        plugins = with pkgs.vimPlugins; [
          coc-nvim
          coc-pyright
          coc-go

          vim-airline
          vim-airline-themes
          vim-eunuch
          vim-fireplace
          vim-fugitive
          # vim-go
          vim-markdown
          vim-nix
          vim-startify
          vim-terraform
          vim-tmux-navigator

          nvim-web-devicons
          nvim-colorizer-lua
          nvim-treesitter
          plenary-nvim
          telescope-nvim
          telescope-coc-nvim
          telescope-project-nvim
          hop-nvim
        ];
        extraConfig = builtins.readFile ../configs/init.vim;
        coc = {
          enable = true;
          settings = {
            "suggest.noselect" = true;
            "suggest.enablePreview" = true;
            "suggest.enablePreselect" = false;
            languageserver = {
              nix = {
                command = "rnix-lsp";
                filetypes = [ "nix" ];
              };
              metals = {
                command = "metals-vim";
                rootPatterns = ["build.sbt"];
                filetypes = [ "scala" "sbt" ];
              };
              terraform = {
                command = "terraform-ls";
                args = [ "serve" ];
                filetypes = [ "terraform" "tf" ];
                initializationOptions = {};
              };
            };
          };
        };
      };
  };
}
