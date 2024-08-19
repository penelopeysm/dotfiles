function! s:mdx() abort
    if !did_filetype()
        setfiletype markdown
    endif
endfunction

augroup mdx_ftd
    au BufRead,BufNewFile *.mdx call s:mdx()
augroup END
