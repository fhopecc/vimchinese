vim9script

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

command InstallYaHeiFont <cmd>py3 安裝雅黑混合字型()

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
