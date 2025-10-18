vim9script

# K -> 查詢游標指令說明
noremap <buffer> K :h <c-r><c-w><cr>

# <leader>E 執行游標所在行指令
noremap <buffer> <leader>E :execute getline(".")<cr>

# <leader>e -> 執行編輯VIM指令檔
noremap <buffer> <leader>e :w!<cr>:so %<cr>

# <leader>D -> 布署VIM指令檔
noremap <buffer> <leader>D <cmd>DeployVIM
