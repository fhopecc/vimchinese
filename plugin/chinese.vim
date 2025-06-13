py3 from chinese import *;設定首碼搜尋映射()
py3 from zhongwen.text import 字元切換, 翻譯, 查萌典

def! InstallYaHeiFont()
    py3 安裝雅黑混合字型()
enddef

" 中文字型
set guifont=Microsoft_YaHei_Mono:h16

" f 搜尋擴充
autocmd InsertEnter * set nohlsearch
autocmd CursorHold * set nohlsearch
hi Search guibg=Red 

" ~ -> 字元切換
def! chinese#switch_char()
    var c = strcharpart(getline('.'), charcol('.') - 1, 1)
    echom c
    var sc = py3eval('字元切換("' .. c .. '")')
    exec 'normal cl' .. sc
enddef

nmap ~ :call chinese#switch_char()<cr>

" T -> 單詞翻譯
command! YankLastMessages :let @1=execute('1messages')
command! -nargs=+ GTrans :call popup_atcursor(py3eval("翻譯('<args>')"), {})
map T yiw:GTrans <c-r>"<cr>
vmap T y:GTrans <c-r>"<cr>

" K -> 查中文字義
def! chinese#query(c: string)
    echo c
    var r = py3eval("查萌典('" .. c .. "')")
    @r = join(r, '')
    popup_clear(1)
    call popup_atcursor(r, {})
enddef

command! -nargs=+ Def :call chinese#query('<args>')
nmap K yl:Def <c-r>"<cr>

" Google 關鍵字查詢
command! -nargs=+ Google :!start "https://www.google.com/search?q=<args>"
map ,g :Google<space>

vmap K y:Google <c-r>"<cr>

" / 擴充搜尋選取項目
vnoremap / y/<c-r>"<cr>

" ,z -> 詢問智譜大語言模型
def! chinese#query_llm(question: string)
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
command! -nargs=? QLLM :call chinese#query_llm(<q-args>)
map ,z :QLLM<space>
