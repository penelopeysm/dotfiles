set textwidth=92
setlocal nomodeline
let b:slime_bracketed_paste = 1

if has('nvim')
  lua vim.treesitter.start()
endif
