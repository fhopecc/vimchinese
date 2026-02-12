vim9script

def Agenda()
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
    setlocal filetype=org

    # 3. 將 Python 變數的內容寫入 Buffer
    python3 << EOF
# 將 python 變數轉為 list (按行分割) 後寫入當前 buffer
lines = agenda_data.split('\n')
vim.current.buffer[:] = lines
EOF
    echo "Agenda 已更新"
enddef
command Agenda Agenda()
