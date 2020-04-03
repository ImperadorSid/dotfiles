" Disable match parenthesis hightlighting
let g:loaded_matchparen=1

" Set options
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
set termguicolors
set wildmode=list:full

" Fish scripts
filetype plugin indent on
autocmd FileType fish compiler fish | setlocal textwidth=80 | setlocal foldmethod=expr

" AutoPairs
let g:AutoPairsShortcutToggle='<Esc>p'
let g:AutoPairsShortcutFastWrap='<Esc>e'
let g:AutoPairsShortcutJump='<Esc>n'
let g:AutoPairsShortcutBackInsert='<Esc>b'

" Load and source .vimrc
map <Leader>, :tabedit ~/.vimrc<CR>
map <Leader><lt> :source ~/.vimrc<CR>
map <Leader>s :set list!<CR>

" Disable arrow keys
map <Up> <Nop>
map <Down> <Nop>
map <Left> <Nop>
map <Right> <Nop>

" Dracula theme
packadd! dracula
colorscheme dracula

