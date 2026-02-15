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

# gl -> 至連結
noremap <buffer> gl <cmd>GotoLink<cr>

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
