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
    # 初始化一個全域變數，確保它是空的
    g:picked_date = ""

    python3 << EOF
import tkinter as tk
from tkcalendar import Calendar
from datetime import datetime
import vim

def start_picker():
    
    root = tk.Tk()
    root.title("Date Picker")
    # 視窗置頂
    root.attributes('-topmost', True)
    MY_FONT = ("Arial", 16)
    cal = Calendar(root, selectmode='day', date_pattern='y-mm-dd',
                   font=MY_FONT, 
                   headersfont=MY_FONT,
                   rowheight=40) # 增加行高以容納較大的字
    cal.pack(padx=20, pady=20)

    def on_ok():
        try:
            date_str = cal.get_date()
            date_obj = datetime.strptime(date_str, '%Y-%m-%d')
            res = date_obj.strftime('%Y-%m-%d %a')
            
            # 使用 vim.vars 確保變數能正確傳回 Vim
            vim.vars['picked_date'] = res
        except Exception as e:
            vim.vars['picked_date'] = f"Error: {str(e)}"
        
        # 徹底關閉 Tk 視窗與迴圈
        root.quit()
        root.destroy()

    # 點擊視窗右上角 X 關閉時也要處理
    root.protocol("WM_DELETE_WINDOW", lambda: root.destroy())

    btn = tk.Button(root, text="確定", command=on_ok)
    btn.pack(pady=5)
    
    # 綁定 Enter 鍵，注意 lambda 要能接收 event
    root.bind('<Return>', lambda e: on_ok())
    
    # 啟動迴圈
    root.mainloop()

try:
    start_picker()
except Exception as e:
    vim.vars['picked_date'] = f"Python Error: {str(e)}"
EOF

    # 取得 Python 寫入的結果
    var result = g:picked_date
    
    # 清理變數
    if exists('g:picked_date')
        unlet g:picked_date
    endif
    
    return result
enddef
command -buffer PickOrgDate echo PickOrgDate()
inoremap <buffer> <LocalLeader>d <c-r>=PickOrgDate()<cr>
