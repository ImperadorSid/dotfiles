" OPTIONS
" Let
let g:loaded_matchparen=1

" Set
set autochdir
set autoindent
set autoread
set clipboard=unnamedplus
set expandtab
set foldlevel=2
set hidden
set hlsearch
set ignorecase
set incsearch
set noshowmode
set noswapfile
set number
set shell=sh
set shiftwidth=2
set smartcase
set smartindent
set splitbelow
set splitright
set tabpagemax=100
set tabstop=2
set timeoutlen=300
set termguicolors
set wildmode=list:full

" MAPPINGS
" Source .vimrc
map <Leader>, :tabedit ~/.vimrc<CR>
map <Leader><lt> :source ~/.vimrc<CR>
map <Leader>s :set list!<CR>

" Disable arrow keys
map <Up> <Nop>
map <Down> <Nop>
map <Left> <Nop>
map <Right> <Nop>

" PLUGINS
" dag/vim-fish
filetype plugin indent on
autocmd FileType fish compiler fish | setlocal textwidth=80 | setlocal foldmethod=expr

" dracula/vim
packadd! dracula
colorscheme dracula

" jiangmiao/auto-pairs
let g:AutoPairsShortcutBackInsert='<Esc>b'
let g:AutoPairsShortcutFastWrap='<Esc>e'
let g:AutoPairsShortcutJump='<Esc>n'
let g:AutoPairsShortcutToggle='<Esc>p'

" vim-airline/vim-airline
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#formatter='unique_tail'
let g:airline_powerline_fonts=1

