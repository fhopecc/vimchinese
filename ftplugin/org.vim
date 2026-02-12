vim9script

# 防止重複載入
if exists("b:did_ftplugin_org")
    finish
endif
b:did_ftplugin_org = 1

setlocal nocursorline # 多文字高亮編輯行不習慣
setlocal wrap # 中文自然段較長啟用自動 wrap
setlocal expandtab      
setlocal shiftwidth=2   
setlocal softtabstop=2  
setlocal tabstop=2

# 依視窗寛度自動斷行，j k 移動以視窗行為主而非實際行
noremap <buffer> j gj
noremap <buffer> k gk
noremap <buffer> gj j
noremap <buffer> gk k

# J -> 不加空格連接下行，以符合中文無空格文法。
noremap <buffer> J gJ
noremap <buffer> gJ J

def ToHTML()
    w!
    AsyncRun py -m zhongwen.org -f %
enddef
map <buffer> <leader>e <cmd>call <sid>ToHTML()<cr>

def ToDOCX(count: number)
    w!
    var cmd = "AsyncRun py -m zhongwen.org  -w -n " .. count .. " -f %"
    execute cmd 
enddef
# :ToDOCX -> 轉成 docx 檔
command -buffer -nargs=? ToDOCX ToDOCX(empty(<q-args>) ? 0 : str2nr(<q-args>))

def ShowTodos()
    var cmd = "AsyncRun py -m zhongwen.org -t -d " .. g:wpath
    if hostname() == 'HLAO-013'
        cmd = "AsyncRun py -m zhongwen.org -t -d " .. g:wpath .. " D:\\審計\\11_兼辦資訊"
    endif
    execute cmd
enddef
command -buffer ShowTodos ShowTodos()

def! g:PickOrgDate(): string
    py3 << EOS
from zhongwen.時 import 擇日
pick_org_date = f'{擇日():%Y-%m-%d %a}'
EOS
    return py3eval("pick_org_date")
enddef
command -buffer PickOrgDate echo PickOrgDate()
inoremap <buffer> <LocalLeader>d <c-r>=PickOrgDate()<cr>

def! Agenda()
    python3 << EOF
from zhongwen.org import 排日程
from pathlib import Path
import socket
import vim
# 這裡放入你之前寫好的 get_agenda_as_string 函數邏輯
# 為了範例簡潔，這裡模擬一個回傳字串

ds = Path(r'g:\我的雲端硬碟')
if socket.gethostname() == 'LAPTOP-6J3H5COA':
    ds = [Path(r'g:\我的雲端硬碟')]

# 執行函數並將結果存入一個 python 變數
agenda_data = 排日程(ds)
EOF
    # 2. 在 Vim 中開啟新 Buffer
    enew  # 開啟一個垂直分割的視窗 (或用 :enew)
    setlocal buftype=nofile    # 虛擬 Buffer，不對應實體檔案
    setlocal bufhidden=wipe    # 當 Buffer 被關閉時自動銷毀
    setlocal noswapfile        # 不產生交換檔
    setlocal filetype=org      # 讓 Vim 或是插件辨認這是 Org 格式

    # 3. 將 Python 變數的內容寫入 Buffer
    python3 << EOF
# 將 python 變數轉為 list (按行分割) 後寫入當前 buffer
lines = agenda_data.split('\n')
vim.current.buffer[:] = lines
EOF
    echo "Agenda 已更新"
enddef
command -buffer Agenda Agenda()
