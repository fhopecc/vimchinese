vim9script

def Agenda()
    python3 << EOF
from zhongwen.org import 排日程
from pathlib import Path
import socket
import vim
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
    setlocal filetype=org

    # 3. 將 Python 變數的內容寫入 Buffer
    python3 << EOF
# 將 python 變數轉為 list (按行分割) 後寫入當前 buffer
lines = agenda_data.split('\n')
vim.current.buffer[:] = lines
EOF
    echo "Agenda 已更新"
enddef
command! Agenda Agenda()

def Post(): void
    w!
    AsyncRun py -m fhopecc.洄瀾打狗人札記 -p %
enddef
# 公布至洄瀾打狗人網站
command! Post Post()

def MarkDone()
    # 1. 向上搜尋最近的 TODO 標題行
    var task_start_num = search('^\*\+ TODO', 'bnW')
    if task_start_num == 0
        echo "找不到上方的 TODO 任務。"
        return
    endif

    # 2. 鎖定範圍：標題行 + 下一行 (時間戳記)
    var task_end_num = task_start_num + 1
    b:original_lines = getline(task_start_num, task_end_num)
    b:task_start = task_start_num
    b:task_end = task_end_num

    # 3. 透過 Python 介面處理
    python3 << EOF
try:
    from zhongwen.org import 標記完成
    import vim

    raw_lines = vim.eval("b:original_lines")
    
    updated_lines = 標記完成(raw_lines).split('\n')

    # 寫回 Vim Buffer
    start_idx = int(vim.eval("b:task_start")) - 1
    end_idx = int(vim.eval("b:task_end"))
    vim.current.buffer[start_idx:end_idx] = updated_lines
    
    print("任務已成功更新 (via import)。")
except Exception as e:
    print(f"錯誤: {str(e)}")
EOF
enddef
command! MarkDone MarkDone()
