vim9script
##### 載入 python 模組 #####

py3 from chinese import *;設定首碼搜尋映射()
py3 from zhongwen.text import 字元切換, 翻譯, 查萌典
py3 from zhongwen.文 import geturl

##### 命令定義 #####
#====   單鍵   ====#

# 查中文字義、英詞中文譯詞、連結 URL 網頁。
nmap K <scriptcmd>GetWordDefine()<cr>

# 字元切換
nmap ~ <scriptcmd>SwitchChar()<cr>

#====   雙鍵   ====#

# 搜尋檔案
map <leader>f <cmd>Leaderf file --popup .<cr>

# 搜尋函數、變數等標記
map <leader>t <cmd>Leaderf bufTag --popup<cr>

# 搜尋緩衝
map <leader>b <cmd>Leaderf buffer --popup<cr>

# 搜尋最近檔案
map <leader>r <cmd>Leaderf mru --popup<cr>

# 最大化視窗
map <leader>o <c-w><c-o><cr> 

# 複製選取行至剪貼簿
map <leader>y "*yy

# 貼上剪貼簿資料
map <leader>p "*p

# Google 查詢游標關鍵字
map <leader>G :Google <cword><cr>

#====   參鍵   ====#

#====   多鍵   ====#
#
# 替換之後出現選取字串
vmap <leader>s y:.,$s/<c-r>"/

# 複製選取字串至剪貼簿
vmap <leader>y "*y

vmap K y<cmd>Google <c-r>"<cr>
# / 擴充搜尋選取項目
vnoremap / y/<c-r>"<cr>

command! YankLastMessages :let @1=execute('1messages')
command! -nargs=+ GTrans :call popup_atcursor(py3eval("翻譯('<args>')"), {})
vmap T y:GTrans <c-r>"<cr>
# command! -nargs=+ Def :call chinese#query('<args>')

# :Q -> 詢問谷歌雙子星模型
def QueryLLM(question: string)
b:question = question
python3 << EOF
from zhongwen.智 import 詢問
import vim
問題 = vim.eval("b:question")
r = 詢問(問題, 不輸出回答=True)
vim.vars['__chinese__response'] = r.splitlines()
EOF
@* = join(g:__chinese__response, "\n")
popup_clear(1)

var opts: dict<any> = {
    'title': '可捲動範例 (Ctrl-J/K 捲動, q 關閉)',
    'line': 5,            # 視窗起始行
    'col': 10,            # 視窗起始欄
    'padding': [1, 1, 0, 1],
    'border': [],
    'filter': funcref('BufferScrollFilter'),
    'scrollbar': v:true
}

call popup_create(g:__chinese__response, opts)
enddef
command! -nargs=+ Q call <sid>QueryLLM(<q-args>)

# :G -> 關鍵字查詢
command! -nargs=+ Google :!start "https://www.google.com/search?q=<args>"

# 捲動另個視窗
map <c-j> <c-w>w<c-e><c-w>w
map <c-k> :call win_execute(win_getid(winnr('j')), "normal! \<C-Y>")<cr>
map <leader>w <c-w>w

##### 命令函數定義 #####

# ~ 字元切換
def SwitchChar()
    var c = strcharpart(getline('.'), charcol('.') - 1, 1)
    echom c
    var sc = py3eval('字元切換("' .. c .. '")')
    exec 'normal cl' .. sc
enddef

# K -> 查中文字義、英詞中文譯詞、連結 URL 網頁。
def GetWordDefine()
    var WORD = expand('<cWORD>') # 含特殊字元關鍵字
    var keyword = WORD
    WORD = substitute(WORD, '"', '', 'g')
    WORD = substitute(WORD, "'", '', 'g')
    var word = expand('<cword>')
    var res = word # 結果

    # 取游標字元
    var char = strcharpart(getline('.'), charcol('.') - 1, 1)

    if WORD =~# '^\S\+://' # URL
        res = py3eval("geturl('" .. WORD .. "')")
        keyword = res
        var cmd = '!start ' .. res
        execute cmd
    elseif word =~# '^[A-Za-z]\+$' # 英語單詞
        keyword = word
        res = py3eval("翻譯('" .. word .. "')")
        popup_clear(1)
        call popup_atcursor(res, {})
    elseif char =~# '[\u3400-\u4DBF\u4E00-\u9FFF\uF900-\uFAFF\u20000-\u2FA1F]'
        keyword = char
        res = py3eval("查萌典('" .. char .. "')")
        popup_clear(1)
        call popup_atcursor(res, {})
    endif
    if type(res) == v:t_list
        res = join(res, "\n")
    endif
    @+ = res
    echo "查詢單詞" .. keyword .. "完成！"
enddef

def CopyMessageHistory(count: number = 10)
    # 執行 :messages 命令並將其輸出捕獲到一個新的暫存器 (register) 'a' 中
    # 命令 :redir @a 會將所有後續的輸出重定向到暫存器 'a'
    # 'silent' 確保這個過程不會在螢幕上閃爍輸出
    silent execute 'redir @a | messages | redir END'

    # 取得暫存器 'a' 的內容，它是一個包含多行訊息的字串
    var full_history: string = getreg('a')

    # 將字串按行分割成列表 (List)
    var history_lines: list<string> = split(full_history, "\n")

    # 移除首行 (通常是訊息歷史記錄的標題)
    var lines_to_copy: list<string> = history_lines[1 : -1]

    # 計算要複製的起始行號，確保不會超過總行數
    var start_index: number = len(lines_to_copy) - count
    if start_index < 0
        start_index = 0
    endif

    # 擷取最後 N 條訊息
    var last_n_messages: list<string> = lines_to_copy[start_index : -1]

    # 將這些訊息重新合併成一個字串，並設定到系統剪貼簿 (register '+')
    call setreg('+', join(last_n_messages, "\n"))
enddef
command! CopyMessages call <sid>CopyMessageHistory()

def BufferScrollFilter(winid: number, key: string): number
    # 判斷按鍵類型
    if key ==# "\<C-j>"  # Ctrl + J: 向下捲動
        # 使用 feedkeys 模擬 Normal 模式的向下捲動 (Ctrl-E)
        # 'n' 模式確保按鍵作用於 Normal 模式，而 't' 模式則立即執行。
        feedkeys("\<C-e>", 'nt')
        return 1 # 傳回 1 表示按鍵已被處理
    elseif key ==# "\<C-k>"  # Ctrl + K: 向上捲動
        # 使用 feedkeys 模擬 Normal 模式的向上捲動 (Ctrl-Y)
        feedkeys("\<C-y>", 'nt')
        return 1 # 傳回 1 表示按鍵已被處理
    elseif key ==# "q" # 按 Q 關閉視窗
        popup_close(winid)
        return 1
    endif
    return 0
enddef

##### 選項設定 #####
set bufhidden=hide # 隱藏 Buffer 時不卸載，以保留狀態(如折疊資訊)。
set guifont=Microsoft_YaHei_Mono:h16 # 中文字型

# 提升效能
set nobackup # 不產製備份檔
set noswapfile # 不創建臨時交換文件
set nowritebackup # 编輯不需要備份文件
set noundofile # 不創建撤銷文件
set showtabline=0 # 不顯示分頁欄

# 精簡介面
set guioptions-=m 
set guioptions-=T 
set guioptions-=r 
set shortmess+=c # 下方不顯示提示
set encoding=utf8
set expandtab
set tabstop=4
set shiftwidth=4
set backspace=indent,eol,start  # 插入模式倒退鍵能向後刪除

colorscheme koehler
filetype on 
syntax enable

# f 搜尋擴充
autocmd InsertEnter * set nohlsearch
autocmd CursorHold * set nohlsearch
hi Search guibg=Red 
