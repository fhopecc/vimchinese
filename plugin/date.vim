vim9script
py3 from zhongwen.時 import 擇日

def! g:PickDate(): string
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

def ChangeDate()
    var line = getline('.')
    var col = col('.')
    # 優化後的正則：匹配 YYYY-MM-DD 及其選配的星期
    var pattern = '\v\d{4}-\d{1,2}-\d{1,2}%(\s+[A-Za-z]+)?'
    
    # pos[0]: string, pos[1]: start_idx, pos[2]: end_idx
    var pos = matchstrpos(line, pattern, 0)
    
    # 檢查 pos[1] (開始位置) 而不是 pos[0] (字串內容)
    while pos[1] != -1
        # Vim 的 col 是 1-based，pos 索引是 0-based
        # 判斷游標是否落在該日期範圍內
        if col >= pos[1] + 1 && col <= pos[2]
            var new_date_str = py3eval('擇日().strftime("%Y-%m-%d %a")')
            # 確保有回傳值且不是錯誤訊息
            if !empty(new_date_str) && new_date_str !~ '^Error:' && new_date_str !~ '^Python Error:'
                var prefix = strpart(line, 0, pos[1])
                var suffix = strpart(line, pos[2])
                setline('.', prefix .. new_date_str .. suffix)
                echo "日期已更新"
            endif
            return
        endif
        # 繼續尋找下一個匹配項，從目前的結束位置之後開始
        pos = matchstrpos(line, pattern, pos[2])
    endwhile
    
    echo "未在游標下找到日期格式"
enddef

command! ChangeDate ChangeDate()
