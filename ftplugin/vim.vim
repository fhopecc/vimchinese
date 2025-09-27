vim9script

# 執行游標行
noremap <buffer> <leader>e :w!<cr>:so %<cr>
noremap <buffer> <leader>E :execute getline(".")<cr>

# 布署
map <buffer> <expr> <plug>deployvim ":w!<CR>:R cd " . g:wpath . "\\vimfiles&&inv d<CR>" 
map <buffer> <leader>D <plug>deployvim
