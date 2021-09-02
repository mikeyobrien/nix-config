{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    withPython3 = true;
    plugins = with pkgs.vimPlugins; [
      vim-airline
      vim-airline-themes
      vim-startify
      vim-go
      vim-markdown
      vim-eunuch
      vim-nix
      vim-fireplace
      vim-fugitive
    ];
    extraConfig = ''
      let g:vim_home_path = "~/.config/nvim"

      let mapleader=" "
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

      execute "set directory=" . g:vim_home_path . "/swap"
      execute "set backupdir=" . g:vim_home_path . "/backup"
      execute "set undodir="   . g:vim_home_path . "/undo"
      set backup
      set undofile
      set writebackup

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
      nmap <leader>tcd :Tcd %:h<CR>| "requires Tcd Plugin

      nmap <silent> <leader>nix :e ~/.config/nix-macos/<CR>

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
    '';
  };
}
