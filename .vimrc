" dein.vim settings
let s:dein_dir = expand('~/.cache/dein')
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein installation check
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . s:dein_repo_dir
endif

" begin settings
let s:toml_dir = expand('~/.vim')
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " .toml file
  if !isdirectory(s:toml_dir)
    call mkdir(s:toml_dir, 'p')
  endif

  " read toml and cache
  call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})
  call dein#load_toml(s:toml_dir . '/python.toml', {'lazy': 1})

  " end settings
  call dein#end()
  call dein#save_state()
endif

" plugin installation check
if dein#check_install()
  call dein#install()
endif

" plugin remove check
let s:removed_plugins = dein#check_clean()
if len(s:removed_plugins) > 0
  call map(s:removed_plugins, "delete(v:val, 'rf')")
  call dein#recache_runtimepath()
endif

" vim settings----------------------------------------
" fold method
set foldmethod=indent

" filer
filetype plugin on

" color scheme
let g:solarized_termcolors=16
syntax enable
set background=dark
colorscheme solarized
set mouse=a
set scrolloff=10
set number
" set relativenumber
nnoremap L :<C-u>setlocal relativenumber!<CR>

" key map
nnoremap j gj
nnoremap k gk
inoremap jk <Esc>
nnoremap Y y$

" window
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h

" clipboard
set clipboard+=unnamed

set fenc=utf-8
set nobackup
set noswapfile
set autoread
set hidden
set showcmd

" set cursorline
set virtualedit=onemore
set smartindent
set visualbell
set showmatch
set laststatus=2
set wildmode=list:longest

" edit
set list listchars=tab:\▸\-
set expandtab
set tabstop=4
set shiftwidth=4
set autoindent
set smartindent
set colorcolumn=120
set foldmethod=marker

" saving
" delete extra white space
autocmd BufWritePre * :%s/\s\+$//ge

" search settings
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>
