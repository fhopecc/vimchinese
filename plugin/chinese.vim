vim9script

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

# <leader>s -> 替換之後出現選取字串
vmap <leader>s y:.,$s/<c-r>"/

# <leader>y -> 複製選取字串至剪貼簿
vmap <leader>y "*y

# <leader>y -> 複製選取行至剪貼簿
map <leader>y "*yy

# <leader>p -> 貼上剪貼簿資料
map <leader>p "*p

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
nmap K <scriptcmd>GetWordDefine()<cr>
vmap K y<cmd>Google <c-r>"<cr>

# Google 關鍵字查詢
command! -nargs=+ Google :!start "https://www.google.com/search?q=<args>"
map ,g :Google<space>

py3 from chinese import *;設定首碼搜尋映射()
py3 from zhongwen.text import 字元切換, 翻譯, 查萌典
py3 from zhongwen.文 import geturl

command! InstallYaHeiFont <cmd>py3 安裝雅黑混合字型()

# 中文字型
set guifont=Microsoft_YaHei_Mono:h16

# f 搜尋擴充
autocmd InsertEnter * set nohlsearch
autocmd CursorHold * set nohlsearch
hi Search guibg=Red 

# ~ -> 字元切換
def SwitchChar()
    var c = strcharpart(getline('.'), charcol('.') - 1, 1)
    echom c
    var sc = py3eval('字元切換("' .. c .. '")')
    exec 'normal cl' .. sc
enddef
nmap ~ <scriptcmd>SwitchChar()<cr>

# T -> 單詞翻譯
command! YankLastMessages :let @1=execute('1messages')
command! -nargs=+ GTrans :call popup_atcursor(py3eval("翻譯('<args>')"), {})
map T yiw:GTrans <c-r>"<cr>
vmap T y:GTrans <c-r>"<cr>
# command! -nargs=+ Def :call chinese#query('<args>')

# / 擴充搜尋選取項目
vnoremap / y/<c-r>"<cr>

# ,z -> 詢問谷歌雙子星模型
def QueryLLM(question: string)
b:question = question
python3 << EOF
from zhongwen.智 import 詢問
import vim
問題 = vim.eval("b:question")
r = 詢問(問題)
vim.vars['__chinese__response'] = r
EOF
@* = g:__chinese__response
popup_clear(1)
call popup_atcursor(@*, {})
enddef
command! -nargs=? QLLM <scriptcmd>QueryLLM(<q-args>)
map ,z :QLLM<space>

# 最大化視窗
map <leader>o <c-w><c-o> 

set foldlevelstart=99

# 捲動另個視窗
map <c-j> <c-w>w<c-e><c-w>w
map <c-k> :call win_execute(win_getid(winnr('j')), "normal! \<C-Y>")<cr>
map <leader>w <c-w>w


