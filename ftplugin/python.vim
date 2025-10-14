vim9script
## Python 檔案編輯按鍵定義 ##

## 單鍵 ##

## 雙鍵 ##

map <buffer> <leader>e <cmd>ExecutePython<cr>
map <buffer> <leader>t <cmd>TestPython<cr>


nnoremap gf <cmd>GotoFile<cr><c-w><c-o>
nnoremap <buffer> gd <cmd>GotoDefineFile<cr>

# 切換至目前編輯檔之目錄
# 查詢名稱說明
nnoremap <buffer> K <Cmd>ShowDocument<cr>


command! Cwd exe 'cd '.expand("%:p:h")   
command! -buffer ChangeWindow normal <c-w>w
command! -buffer MaxWindow normal <c-w>o

# 效能
def ProfilePython()
    w!
    topleft :terminal ++rows=10 cmd /c py -m cProfile -s cumtime %
enddef
map <buffer> <leader>P :call python#profile()<cr>

map <buffer> <leader>D <cmd>DeployPython<cr>

# 環境設定
map <buffer> <F7> :w!<CR>:belowright :terminal python % --setup<CR>  
