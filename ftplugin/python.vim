vim9script

command! -buffer ChangeWindow normal <c-w>w
command! -buffer MaxWindow normal <c-w>o

# 查詢名稱說明
nnoremap <buffer> K <Cmd>py3 from zhongwen.python_dev import 說明;說明()<cr>

# 查找函數
map <leader>c :set noimdisable<cr>:Leaderf function<cr>

# 至定義
nnoremap <buffer> gd <Cmd>py3 from zhongwen.python_dev import 至定義;至定義()<CR>

# 執行編輯中腳本
def ExecutePython()
    w!
    MaxWindow
    term_start('py ' .. expand('%'))
enddef
command! ExecutePython call ExecutePython()
map <buffer> <leader>e :ExecutePython<cr>

# 測試編輯中腳本
def TestPython()
    py3 from zhongwen.python_dev import find_testfile
    w!
    var testfile = py3eval("find_testfile(r'" .. expand('%') .. "')")
    MaxWindow
    call term_start('py ' .. testfile)
enddef
command! TestPython call TestPython()
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

# 打包佈署
def DeployPython()
    w!
py3 << EOF
import vim
from zhongwen.python_dev import 布署
from pathlib import Path
布署(Path(vim.current.buffer.name))
EOF
enddef
map <buffer> <leader>D :call python#deploy()<cr>

# 環境設定
map <buffer> <F7> :w!<CR>:belowright :terminal python % --setup<CR>  
