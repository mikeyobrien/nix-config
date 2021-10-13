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
          vim-startify
          vim-go
          vim-markdown
          vim-eunuch
          vim-nix
          vim-fireplace
          vim-fugitive
          vim-terraform

          nvim-web-devicons
          nvim-colorizer-lua
          plenary-nvim
          telescope-nvim
          telescope-coc-nvim
          telescope-project-nvim
          hop-nvim
        ];
        extraConfig = ''
          let g:vim_home_path = "~/.config/nvim"
          let g:terraform_fmt_on_save = 1
          let g:startify_change_to_vcs_root = 0

          let mapleader=" "
          set cmdheight=2
          set termguicolors
          set mouse=a
          set autoread
          set backspace=2
          set hidden
          set laststatus=2
          set list
          set number
          set ruler
          set t_Co=256
          set scrolloff=999
          set showmatch
          set showmode
          set splitbelow
          set splitright
          set title
          set visualbell
          syntax on

          "execute "set directory=" . g:vim_home_path . "/swap"
          "execute "set backupdir=" . g:vim_home_path . "/backup"
          "execute "set undodir="   . g:vim_home_path . "/undo"

          inoremap jj <esc>

          " Shortcut to yanking to the system clipboard
          map <leader>y "*y
          map <leader>p "*p

          " using coc.nvim some servers have issues with backup files, see #649
          set nobackup
          set nowritebackup

          set undofile

          set updatetime=300
          set shortmess+=c

          " Use tab for trigger completion with characters ahead and navigate.
          " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
          " other plugin before putting this into your config.
          inoremap <silent><expr> <TAB>
                \ pumvisible() ? "\<C-n>" :
                \ <SID>check_back_space() ? "\<TAB>" :
                \ coc#refresh()
          inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

          inoremap <silent><expr> <c-space> coc#refresh()

          " Make <CR> auto-select the first completion item and notify coc.nvim to
          " format on enter, <cr> could be remapped by other vim plugin
          inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                        \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

          " Use `[g` and `]g` to navigate diagnostics
          " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
          nmap <silent> [g <Plug>(coc-diagnostic-prev)
          nmap <silent> ]g <Plug>(coc-diagnostic-next)

          " GoTo code navigation.
          nmap <silent> gd <Plug>(coc-definition)
          nmap <silent> gy <Plug>(coc-type-definition)
          nmap <silent> gi <Plug>(coc-implementation)
          nmap <silent> gr <Plug>(coc-references)

          " Use K to show documentation in preview window.
          nnoremap <silent> K :call <SID>show_documentation()<CR>


          function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
          endfunction

          set hlsearch
          set ignorecase
          set incsearch
          set smartcase

          set expandtab
          set tabstop=4
          set softtabstop=4
          set shiftwidth

          set wildmode=list:longest
          set wildignore+=.git,.gh,.svn
          set wildignore+=*.6
          set wildignore+=*.pyc
          set wildignore+=*.rbc
          set wildignore+=*.swp

          inoremap jj <esc>
          map j gj
          map k gk

          nmap <leader>cd :cd %:h<CR>
          nmap <leader>lcd :lcd %:h<CR>

          " Symbol renaming.
          nmap <leader>rn <Plug>(coc-rename)

          " Formatting selected code.
          xmap <leader>f  <Plug>(coc-format-selected)
          nmap <leader>f  <Plug>(coc-format-selected)

          nmap <silent> <leader>nix :e ~/.config/nix-macos/<CR>
          nmap <silent> <leader>vimrc :e ~/.config/nix-macos/home/neovim.nix<CR>


          " Easier split navigation
          nnoremap <C-j> <C-w>j
          nnoremap <C-k> <C-w>k
          nnoremap <C-h> <C-w>h
          nnoremap <C-l> <C-w>l

          " macos bugfix, C-h sent as backspace
          nnoremap <BC> <C-W>h

          " Remember cursor position
          augroup vimrc-remember-cursor-position
            autocmd!
            autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$"  ) | exe "normal! g`\"" | endif
          augroup END

          command! -nargs=0 Format :call CocAction('format')
          command! -nargs=? Fold :call CocAction('fold', <f-args>)
          command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')

          "mappings for CoCList
          " Mappings for CoCList
          " Show all diagnostics.
          nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
          " Manage extensions.
          nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
          " Show commands.
          nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
          " Find symbol of current document.
          nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
          " Search workspace symbols.
          nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
          " Do default action for next item.
          nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
          " Do default action for previous item.
          nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
          " Resume latest coc list.
          nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>


          " Telescope
          " lua require'telescope'.extensions.project.project{}
          lua require'telescope'.load_extension('coc')

          nnoremap <silent><leader>pF <cmd>lua require('telescope').extensions.project.project{}<cr>

          nnoremap <leader><leader> <cmd>Telescope git_files<cr>
          nnoremap <leader>ff <cmd>lua require('telescope.builtin').find_files()<cr>
          nnoremap <leader>fb <cmd>lua require('telescope.builtin').file_browser()<cr>
          nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>

          nnoremap <leader>sp <cmd>lua require('telescope.builtin').live_grep()<cr>
          nnoremap <leader>ss <cmd>lua require('telescope.builtin').grep_string()<cr>

          nnoremap <leader>bb <cmd>lua require('telescope.builtin').buffers()<cr>

          nnoremap <leader>gb <cmd>lua require('telescope.builtin').git_branches()<cr>
          nnoremap <leader>gc <cmd>lua require('telescope.builtin').git_commits()<cr>
          nnoremap <leader>gC <cmd>lua require('telescope.builtin').git_bcommits()<cr>
          nnoremap <leader>gs <cmd>lua require('telescope.builtin').git_status()<cr>
          nnoremap <leader>gS <cmd>lua require('telescope.builtin').git_stash()<cr>

          nnoremap <leader>t  <cmd>lua require('telescope.builtin').treesitter()<cr>

          nnoremap <leader>!  <cmd>lua require('telescope.builtin').command_history()<cr>

          nnoremap <leader>cr <cmd>Telescope coc references<cr>
          nnoremap <leader>ca <cmd>Telescope coc code_actions<cr>
          nnoremap <leader>ci <cmd>Telescope coc implementations<cr>
          nnoremap <leader>cd <cmd>Telescope coc definitions<cr>
          nnoremap <leader>ct <cmd>Telescope coc type_definitions<cr>
          nnoremap <leader>cm <cmd>Telescope coc mru<cr>k

          " nvim colorizer
          lua require'colorizer'.setup()

          "nvim web devicons
          lua require'nvim-web-devicons'.setup{ default = true; };

          " hop-nvim
          lua require'hop'.setup()
          nmap s <cmd>HopChar2<cr>
          nmap <leader>j <cmd>HopLine<cr>

          " tabs
          nnoremap <leader><tab><tab> <cmd>tabs<cr>
        '';
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
