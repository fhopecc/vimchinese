vim9script

nnoremap gf <cmd> GotoFile<cr><c-w><c-o>

nnoremap <buffer> gd <cmd>GotoDefineFile<cr>

# 切換至目前編輯檔之目錄
command! Cwd exe 'cd '.expand("%:p:h")   

command! -buffer ChangeWindow normal <c-w>w
command! -buffer MaxWindow normal <c-w>o

# 查詢名稱說明
nnoremap <buffer> K <Cmd>ShowDocument<cr>

# 查找函數
map <leader>c :set noimdisable<cr>:Leaderf function<cr>

map <buffer> <leader>e :ExecutePython<cr>

map <buffer> <leader>t :TestPython<cr>

# 交談式介面實驗
map <buffer> <leader>i :term ipython

def PythonNextterm()
    let name = bufnr('#')
    return name
enddef

def ExcutedPythonDone(channel_id: number, exit_status: number)
    if exit_status == 0
        echomsg "命令成功執行！"
        set filetype=pythontrace
    else
        echomsg "命令執行失敗，結束代碼：" .. exit_status
    endif
enddef

# 效能
def ProfilePython()
    w!
    topleft :terminal ++rows=10 cmd /c py -m cProfile -s cumtime %
enddef
map <buffer> <leader>P :call python#profile()<cr>

map <buffer> <leader>D <cmd>DeployPython<cr>

# 環境設定
map <buffer> <F7> :w!<CR>:belowright :terminal python % --setup<CR>  
