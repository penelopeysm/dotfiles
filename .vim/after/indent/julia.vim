" note has to be in after/indent rather than after/ftplugin since
" ftplugin is loaded before the build-in indent files
if has('nvim')
    lua vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
endif
