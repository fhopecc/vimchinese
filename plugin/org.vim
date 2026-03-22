vim9script

def GetOrgTimestamp(): string
    # 取得 org 時戳，形式如 2026-3-15 SUN 8:17。
    py3 import datetime
    return py3eval( "datetime.datetime.now().strftime('%Y-%m-%d %a %H:%M')")
enddef

def Schduled()
    py3 from zhongwen.時 import 擇日
    var schduled = 'SCHEDULED: ' .. py3eval('擇日().strftime("<%Y-%m-%d %a>")')
    append(line('.'), schduled)
enddef
command! Schduled Schduled()

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
    # 1. 向上搜尋最近的標題行 (以 * 開頭)
    # 'b': backward, 'W': 不迴繞, 'n': 不移動實際游標
    var title_lnum = search('^\*\+ ', 'bnW')

    if title_lnum == 0
        echo "尚無標題"
        return
    endif

    var title_line = getline(title_lnum)

    if title_line =~# '\<TODO\>'
        # 替換 TODO 為 DONE
        var new_title = substitute(title_line, '\<TODO\>', 'DONE', '')
        setline(title_lnum, new_title)
        
        # 標題下插入 CLOSED 時間戳記 (活躍轉不活躍 [])
        var closed_date = GetOrgTimestamp()
        var closed_line = "CLOSED: [" .. closed_date .. "]"
        append(title_lnum, closed_line)

        # 4. 處理原本的下一行 (原本是 title_lnum + 1，現在因為 append 變成 + 2)
        var sched_lnum = title_lnum + 2
        var sched_line = getline(sched_lnum)
        
        # 尋找 SCHEDULED 標記並將 <...> 轉換為 [...]
        if sched_line =~# 'SCHEDULED:'
            # 使用正則表達式捕獲括號內的內容並替換外框
            var new_sched = substitute(sched_line, '<\([^>]\+\)>', '[\1]', 'g')
            setline(sched_lnum, new_sched)
        endif
        
        echo "任務已標記完成"
    else
        echo "目前標題不含 TODO 狀態"
    endif
enddef
command! -bar MarkDone MarkDone()
