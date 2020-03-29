" Disable match parenthesis hightlighting
let g:loaded_matchparen=1

" Options
set autochdir
set autoindent
set autoread
set clipboard=unnamedplus
set expandtab
set hidden
set hlsearch
set ignorecase
set incsearch
set noswapfile
set number
set shiftwidth=2
set smartcase
set smartindent
set tabpagemax=100
set tabstop=2
set termguicolors
set wildmode=list:full

" Load and source .vimrc
map <Leader>, :edit ~/.vimrc<CR>
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

