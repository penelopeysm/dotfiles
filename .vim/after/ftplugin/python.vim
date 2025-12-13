let maplocalleader='\'

" PEP 8. Also helps with `gq`.
setlocal textwidth=79

" \m behaviour: run script without arguments
let $PYTHONUNBUFFERED=1
let g:asyncrun_open=15
nnoremap <silent><buffer> <localleader>m :w<CR>:AsyncRun -raw python %<CR>
nnoremap <silent><buffer> <localleader>q :call AsyncStopAndOrCloseQF()<CR>

" Terminate asyncrun job
function AsyncStopAndOrCloseQF()
    if g:asyncrun_status == "running"
        AsyncStop!
    endif
    cclose
endfunction

" Recalculate folds upon saving.
function RecalcFolds()
    call SimpylFold#Recache()
    FastFoldUpdate!
endfunction
autocmd BufWritePre <buffer> silent call RecalcFolds()

" Fix vim-slime python issues
" https://github.com/jpalardy/vim-slime/tree/main/ftplugin/python
let b:slime_bracketed_paste = 1
