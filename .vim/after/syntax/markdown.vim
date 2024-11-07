" https://stackoverflow.com/a/34645680

" This fixes underscores appearing in MathJax.
syn region math start=/\$\$/ end=/\$\$/  " Display
syn match math '\$[^$].\{-}\$'           " Inline

" actually highlight the region we defined as "math"
hi link math Statement
