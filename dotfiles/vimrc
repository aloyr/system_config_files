set fileencodings=utf-8
set encoding=utf-8
" pathogen - must come first ----------------------------------------------
call pathogen#infect()
call pathogen#helptags()
" crontab handling --------------------------------------------------------
au BufEnter /private/tmp/crontab.* setl backupcopy=yes
" important ---------------------------------------------------------------
set nocompatible                                      "don't behave like Vi
" moving around, searching and patterns -----------------------------------
set incsearch                             "shows search matches as you type
set showmatch                                     "jump to matching bracket
set smartcase                                          "if caps, watch case
set ignorecase                               "if all lowercase, ignore case 
" tags --------------------------------------------------------------------
" displaying text ---------------------------------------------------------
set number
set relativenumber 
set linebreak                                          "wraps between words
set scrolloff=1 
" syntax, highlighting and spelling ---------------------------------------
set hlsearch                                     "highlights search results
set background=light
set spell
" multiple windows --------------------------------------------------------
set hidden                               "allow to bg unsaved buffers, etc.
set laststatus=2                                   "always show status line
" multiple tab pages ------------------------------------------------------
" terminal ----------------------------------------------------------------
" using the mouse ---------------------------------------------------------
" printing ----------------------------------------------------------------
" messages and info -------------------------------------------------------
set showcmd                                       "show normal etc commands 
set ruler                                             "show cursor position
" selecting text ----------------------------------------------------------
" editing text ------------------------------------------------------------
set nrformats-=octal                  "0-prefixed numbers are still decimal
set backspace=indent,eol,start                          "proper backspacing
" tabs and indenting ------------------------------------------------------
set autoindent
set smartindent
set expandtab
set shiftwidth=2
set softtabstop=2
set tabstop=2
set shiftround                    "round > and < to multiples of shiftwidth
set list
set listchars=eol:¬,tab:▶·,trail:█,extends:▶,precedes:◀"
set cursorline
" folding -----------------------------------------------------------------
set foldmethod=marker
set foldmarker={{{,}}}
" diff mode ---------------------------------------------------------------
" mapping -----------------------------------------------------------------
set timeout                               "Fixes slow O inserts (all three)
set timeoutlen=1000
set ttimeoutlen=100
" reading and writing file ------------------------------------------------
set backup                                      "keep backup after o/w file
if &backupdir =~# '^\.,'
    let &backupdir = "~/.vim/lib/backup," . &backupdir
endif
" the swap file
" -------------------------------------------------------------------------
set swapfile
if &directory =~# '^\.,'
    let &directory = "~/.vim/lib/swap," . &directory
endif
" command line editing ----------------------------------------------------
set wildmenu
set wildmode=full
set undofile
if &undodir =~# '^\.\%(,\|$\)'
    let &undodir = "~/.vim/lib/undo," . &undodir
endif
" executing external commands ---------------------------------------------
" running make and jumping to errors --------------------------------------
" language specific -------------------------------------------------------
" various -----------------------------------------------------------------
set gdefault 
"set t_ti= t_te=                 "www.shallowsky.com/linux/noaltscreen.html
" gui setings -------------------------------------------------------------
if has("gui")
    set go-=T                                         "hide toolbar in mvim
    set guifont=inconsolata:h16
    set lines=65 columns=110
endif
" -------------------------------------------------------------------------
let g:solarized_termcolors=256
colorscheme solarized
filetype plugin indent on
syntax on
let mapleader=","
" mappings ----------------------------------------------------------------
map <silent> <c-n> :NERDTreeFocus<cr>
inoremap jjj 
nnoremap \ ,
nnoremap <leader>ev :tabe $MYVIMRC<cr>
nnoremap <leader>sv :so $MYVIMRC<cr>
nnoremap <leader><leader> <c-^>
nnoremap / /\v
vnoremap / /\v
nnoremap <leader><space> :noh<cr>
nnoremap Y y$
nnoremap & :&&<cr>
" experimental mappings------------
nnoremap <tab> >>
nnoremap <s-tab> <<
vnoremap <tab> >
vnoremap <s-tab> <
" abbreviations -----------------------------------------------------------
cnoreabbrev W w
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev Q! q!
cnoreabbrev Tabe tabe
cnoreabbrev wrap set wrap
cnoreabbrev nowrap set nowrap
" autocommands ------------------------------------------------------------
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal g'\"" | endif
augroup vimscript
    autocmd!
    autocmd BufWritePost $MYVIMRC source $MYVIMRC
augroup END

augroup HTML
    autocmd!
    autocmd BufRead,BufWritePre *.html :normal gg=G
    autocmd FileType html nnoremap <buffer> <leader>c I<!--<esc>A--><esc>
augroup END

augroup Ruby
    autocmd!
    autocmd FileType ruby setlocal shiftwidth=2 softtabstop=2 tabstop=2
augroup END

augroup JavaScript
    autocmd!
    autocmd FileType javascript nnoremap <buffer> <leader>m :!node %<cr>
    autocmd FileType javascript nnoremap <buffer> <leader>c gI//<esc>
    autocmd FileType javascript vnoremap <buffer> <leader>c :normal gI//<esc>
augroup END

augroup Java
    autocmd!
    autocmd FileType java nnoremap <buffer> <leader>b :!javac %<cr>
    autocmd FileType java nnoremap <buffer> <leader>B :!javac *.java<cr>
    autocmd FileType java nnoremap <buffer> <leader>m :!java <c-r>=expand("%:t:r")<cr><cr>
    autocmd FileType java nnoremap <buffer> <leader>c I//<esc>
    autocmd FileType java vnoremap <buffer> <leader>c :normal gI//<esc>
augroup END

augroup CPP
    autocmd!
    autocmd FileType cpp nnoremap <buffer> <leader>b :!g++ %<cr>
    autocmd FileType cpp nnoremap <buffer> <leader>m :!./a.out<cr>
augroup END
" functions ---------------------------------------------------------------
function! Fix_markdown_for_tut()
    %s/\(<h\d\) id=["'].+['"]>/\1>/
    "%s/<pre><code>/[js]/
    "%s/<\/code>\(<\/pre>\)/[\/js]/
    %s/<pre><code>/<pre class="" name="code">
    %s/<\/code>\(<\/pre>\)/\1/
    "%s/<p><img/<div class="tutorial_image"><img/
    %s/<p>\(<img.*\/>\)<\/p>/<div class="tutorial_image">\1<\/div>
endfunction

command! Fm call Fix_markdown_for_tut()

function! InsertTabWrapper()
    " MULTIPURPOSE TAB KEY
    " Indent if we're at the beginning of a line. Else, do completion.
    " via https://github.com/garybernhardt/dotfiles/blob/master/.vimrc
    let col = col('.') - 1
    if !col || getline('.')[col - 1] !~ '\k'
        return "\<tab>"
    else
        return "\<c-p>"
    endif
endfunction
inoremap <tab> <c-r>=InsertTabWrapper()<cr>
inoremap <s-tab> <c-n>

function! OpenUrlUnderCursor()
    let url=matchstr(getline("."), '[a-z]*:\/\/[^ >,;]*')
    if url != ""
        silent exec "!open '".url."'" | redraw! 
    endif
endfunction
map <leader>o :call OpenUrlUnderCursor()<CR>
