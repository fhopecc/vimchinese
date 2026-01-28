vim9script

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
    var cmd = "AsyncRun py -m zhongwen.org -f % -d " .. count
    execute cmd 
enddef
# :ToDOCX -> 轉成 docx 檔
command -buffer -nargs=? ToDOCX ToDOCX(empty(<q-args>) ? 0 : str2nr(<q-args>))
