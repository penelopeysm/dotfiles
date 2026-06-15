set textwidth=92
setlocal nomodeline
let b:slime_bracketed_paste = 1

if has('nvim')
  lua vim.treesitter.start()
endif

if executable('jlfmt')
    command! -range=% -nargs=* JF <line1>,<line2>!jlfmt <args>
endif
