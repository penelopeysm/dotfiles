" Plugins {{{1
call plug#begin('~/.vim/plugged')

" Both vim and nvim
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-tbone'
Plug 'wellle/targets.vim'
Plug 'machakann/vim-sandwich'
Plug 'penelopeysm/edge'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'NLKNguyen/papercolor-theme'
Plug 'itchyny/lightline.vim'
Plug 'lervag/vimtex'
Plug 'itchyny/vim-haskell-indent'
Plug 'tmhedberg/SimpylFold'
Plug 'konfekt/FastFold'
Plug 'Vimjas/vim-python-pep8-indent'
Plug 'kana/vim-textobj-user'
Plug 'junegunn/vim-easy-align'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'purescript-contrib/purescript-vim'
Plug 'penelopeysm/vim-haskellFold'

" Both, but not vscode-nvim
if !exists('g:vscode')
    Plug 'tpope/vim-fugitive'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'skywind3000/asyncrun.vim'
    Plug 'quarto-dev/quarto-vim'
    Plug 'jpalardy/vim-slime'
endif

" Vim only
if !has('nvim')
    Plug 'tpope/vim-commentary'
    Plug '~/.vim/pack/plugins/start/vim-search-pulse'
endif

" Terminal nvim only
if has('nvim') && !exists('g:vscode')
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'hrsh7th/nvim-cmp'
    Plug 'numToStr/Comment.nvim'
    Plug 'JoosepAlviste/nvim-ts-context-commentstring'
    Plug 'neovim/nvim-lspconfig'
    Plug 'folke/trouble.nvim'
    Plug 'folke/lsp-colors.nvim'
    Plug 'quarto-dev/quarto-nvim'
    Plug 'jmbuhr/otter.nvim'
    Plug 'ldelossa/litee.nvim'
    Plug 'ldelossa/gh.nvim'
    Plug 'github/copilot.vim'
endif
call plug#end()
" }}}1

" Basic settings {{{1
set number                                " Enable line numbers
set autoindent                            " Automatically indent when starting a new line
set hidden                                " Don't unload buffers when switching to another
filetype plugin indent on                 " Enable filetype-specific plugins and indent scripts
syntax on                                 " Enable syntax highlighting
set backspace=indent,eol,start            " Make Backspace work at the start of a line
set splitright splitbelow                 " Default sides for split windows.
set display+=lastline                     " Show as much of the last line as possible
set shiftwidth=4 tabstop=4 expandtab      " Default indentation style
set ttimeoutlen=50                        " Timeout after hitting Esc, fixes a common tmux issue
set ignorecase smartcase                  " Make search case-insensitive if only small letters
set incsearch                             " Enable incremental search
set nohlsearch                            " Disable search highlighting (defalt in vim but not nvim)
set signcolumn=number                     " Show LSP outputs in place of line number
set cinkeys-=:                            " Stop automatic deindentation of labels
set completeopt-=preview                  " Don't show preview window when autocompleting
augroup vimrc-ishl
" This is adapted from `:h incsearch`, except that I changed /,\? to * to
" make it work with `:s` and other commands as well.
autocmd!
autocmd CmdlineEnter * :set hlsearch
autocmd CmdlineLeave * :set nohlsearch
augroup END
" Enable mouse, but disable mouse wheel scrolling
set mouse=nv
map <ScrollWheelUp> <Nop>
map <S-ScrollWheelUp> <Nop>
map <ScrollWheelDown> <Nop>
map <S-ScrollWheelDown> <Nop>
" }}}1

" Basic mappings {{{1
" Leader key
nnoremap <Space> <Nop>
let mapleader=" "
" I find I do this a lot
nnoremap <C-j> 3<C-e>
nnoremap <C-k> 3<C-y>
" Fold and unfold
nnoremap <Left> zm
nnoremap <Right> zr
" Syntax sync -- for long files where vim gets confused
nnoremap <leader>ssf :syntax sync fromstart<CR>
" Open directory containing current file
nnoremap <leader>ls :Explore<CR>
" Change current directory in window
function! LcdHere() abort
let curdir = expand('%:p:h')
execute 'lcd ' . curdir
echo 'changed local working dir to ' . curdir
endfunction
nnoremap <leader>lcd :call LcdHere()<CR>
" Easy system clipboard access with <Space><Space> {{{2
if has('clipboard')
vnoremap <leader><leader>p "*p
vnoremap <leader><leader>P "*P
vnoremap <leader><leader>y "*y
vnoremap <leader><leader>Y "*Y
vnoremap <leader><leader>c "*c
vnoremap <leader><leader>C "*C
vnoremap <leader><leader>d "*d
vnoremap <leader><leader>D "*D
vnoremap <leader><leader>s "*s
vnoremap <leader><leader>S "*S
nnoremap <leader><leader>p "*p
nnoremap <leader><leader>P "*P
nnoremap <leader><leader>y "*y
nnoremap <leader><leader>Y "*Y
nnoremap <leader><leader>c "*c
nnoremap <leader><leader>C "*C
nnoremap <leader><leader>d "*d
nnoremap <leader><leader>D "*D
nnoremap <leader><leader>s "*s
nnoremap <leader><leader>S "*S
elseif !empty($TMUX)
" no system clipboard, but can use tmux clipboard
" requires vim-tbone plugin, but note linewise copy/paste only
vnoremap <leader><leader>p :Tput<CR>
vnoremap <leader><leader>P :Tput<CR>
vnoremap <leader><leader>y :Tyank<CR>
vnoremap <leader><leader>Y :Tyank<CR>
nnoremap <leader><leader>p :Tput<CR>
nnoremap <leader><leader>P :Tput<CR>
nnoremap <leader><leader>yy :Tyank<CR>
nnoremap <leader><leader>Y :Tyank<CR>
endif
" }}}2
" Text motions for lines, cf. https://vi.stackexchange.com/q/6101/ {{{2
xnoremap il g_o^
onoremap il :normal vil<CR>
xnoremap al $o^
onoremap al :normal val<CR>
" }}}2
" <leader>[] to jump around quickfix / location list {{{2
function! QFLocListPrevNext(next) abort
" a:next should be +1 if going forward and -1 if going backwards
let l:winfo = getwininfo()

" Try quickfix list
let l:qf_open = !empty(filter(l:winfo, 'v:val.quickfix'))
if l:qf_open
    if a:next == +1 | cnext
    elseif a:next == -1 | cprev | endif
    return
end

" Try location list
let l:loc_open = !empty(filter(l:winfo, 'v:val.loclist'))
if l:loc_open
    if a:next == +1 | lnext
    elseif a:next == -1 | lprev | endif
    return
end
endfunction
nnoremap <silent> <leader>[ :call QFLocListPrevNext(-1)<CR>
nnoremap <silent> <leader>] :call QFLocListPrevNext(+1)<CR>
" }}}2
" :Tb for term below
if has('nvim')
    command Tb 20split | term
else
    command Tb below term ++rows=20
endif
" fix Reddit lists
nnoremap <leader>ll :g/^$/d<CR>:%norm0dw<CR>
" On-hands management
command! -range Ohs <line1>,<line2>! oh search
command! -range Ohr <line1>,<line2>w ! oh rm
" }}}1

" Basic autocmds {{{1
" Recognise TopSpin AU programmes as being C.
autocmd BufEnter /opt/topspin4.1.3/exp/stan/nmr/au/src/* :set filetype=c
autocmd BufEnter ~/genesis/scripts/au/* :set filetype=c
" Detect thesis files
autocmd BufReadPre ~/dphil/thesis/*.tex :let b:is_dphil_thesis=1
" Sum command
command! -range=% -nargs=1 Sum <line1>,<line2>!awk -F '|' '{print; sum+=$('<args>' + 1)} END {print sum}'
" }}}1

" Grep setup {{{1
" Slightly modified from
" https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
if executable('rg')
let &grepprg = 'rg --vimgrep '
" Grep in current directory, or other specified location
function RunGrep(...)
    " Note that the errorformat here is specialised to rg's output.
    let l:old_efm = &errorformat
    let &errorformat = '%f:%l:%c:%m'
    cgetexpr system(join([&grepprg] + a:000, ' '))
    let &errorformat = l:old_efm
    cwindow
endfunction
command! -nargs=+ -complete=file Grep call RunGrep(<f-args>)
" Grep within open buffers
function RunGrepInOpenBuffers(...)
    let l:old_efm = &errorformat
    let &errorformat = '%f:%l:%c:%m'
    let l:buffers = getbufinfo()
                \ ->map({_, val -> shellescape(val.name)})
                \ ->filter({_, val -> !empty(val)})
    let l:command = join([&grepprg] + a:000 + l:buffers, ' ')
    cgetexpr system(l:command)
    let &errorformat = l:old_efm
    cwindow
endfunction
command! -nargs=+ Bgrep call RunGrepInOpenBuffers(<f-args>)
endif
" }}}1

" Automatic parentheses generation {{{1
" Usage: put the line
"     inoremap <expr> <C-L><C-L> MkMatchparenMap()
" in whichever ftplugin file you want to use this in
function! MkMatchparenMap() abort
let l:open = getline('.')[-1:]
if l:open == '{'
    let l:close = '}'
elseif l:open == '['
    let l:close = ']'
elseif l:open == '('
    let l:close = ')'
else | return '' | endif
return "\<CR>" . l:close . "\<Esc>O"
endfunction " }}}1

" Function to get the top-level git directory {{{1
function! GitTopLevel() abort
    silent let output = system('git rev-parse --show-toplevel')
    return v:shell_error ? '' : trim(output)
endfunction
let g:git_top_level = GitTopLevel()
" }}}1

" Plugin settings and mappings {{{1
" vim-slime
let g:slime_target = 'tmux'
" easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" netrw
let g:netrw_liststyle = 1       " Use ls -al style by default
let g:netrw_localrmdir = 'rm -r'  " Allow netrw to delete nonempty directories
set laststatus=2 noshowmode     " Enable lightline and turn off Vim's default '--INSERT--' prompt.
let g:fastfold_minlines = 0     " Enable FastFold for all files
" Fzf {{{2
nnoremap <leader>f :Files<CR>
nnoremap <leader>b :Buffers<CR>
nnoremap <leader>g :GFiles<CR>
nnoremap <leader>r :Rg<CR>
" }}}2
" }}}1

let g:mycolor = 'edge'
" Colour scheme management {{{1
" Enable truecolor if available. This is a bit of a hacky check. Ideally we
" would check for $COLORTERM; however, this environment variable is not passed
" over SSH. Also, a quick check of the terminals I currently use show that the
" ones that don't support truecolor (macOS Terminal.app, Windows Terminal WSL)
" are labelled 'xterm-256colors', and those that do (macOS iTerm2) are
" labelled 'xterm'. Since $TERM is passed over SSH, this will reliably work.
if $TERM ==# "xterm"
    set termguicolors

    if $TERMCS ==# "light"
        set background=light

        " Vim-search-pulse default colours are meant for dark mode and look
        " horrendous on light mode, so we need to override them.
        let g:vim_search_pulse_color_list = ['#e4e4e4', '#dadada', '#d0d0d0', '#c6c6c6', '#bcbcbc'] 

        if !exists('g:mycolor') || g:mycolor == 'edge'
            colorscheme edge
            let g:lightline = {'colorscheme': 'edge'}
        elseif g:mycolor == 'one'
            colorscheme one
            let g:one_allow_italics = 1
        elseif g:mycolor == 'catppuccin'
            colorscheme catppuccin
            let g:lightline = {'colorscheme': 'catppuccin'}
        else
            echoerr 'Unrecognised g:mycolor "' . g:mycolor . '"'
        endif

        " Silly fix for a silly error https://github.com/neovim/neovim/issues/19362
        " If we don't check for nvim this gives a 'press enter to continue' prompt
        " every time vim9 is opened
        " But if we place this in nvim's init.vim it's too slow ¯\_(ツ)_/¯
        if has('nvim') | echo " " | endif

    else
        " Note that `sudo vim` doesn't pick up the $TERMCS envvar, so gets
        " thrown into dark mode. This can be fixed with sudo --preserve-env
        " if really necessary
        set background=dark
        let g:onedark_terminal_italics = 1
        colorscheme onedark
        let g:lightline = {'colorscheme': 'one'}
    endif
else  " somewhere else, e.g. WSL.
    set background=light
    colorscheme PaperColor
    let g:lightline = {'colorscheme': 'PaperColor'}
endif
set t_ut=""
" Detect light/dark mode automatically.
" Also set terminal escape codes for italic text.
if stridx(system("uname"), "Darwin") != -1  " if MacOS
    let g:tar_cmd = "/usr/local/bin/gtar"   " allow editing tarballs, requires homebrew gnu-tar
    set t_ZH=[3m
    set t_ZR=[23m
end
" Shortcut for highlighting test
command Hitest :source $VIMRUNTIME/syntax/hitest.vim
" Show syntax highlighting groups for word under cursor
nnoremap <leader>sp :call <SID>SynStack()<CR>
function! <SID>SynStack()
    if !exists("*synstack") | return | endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfunction
"}}}1

" vim: foldmethod=marker
