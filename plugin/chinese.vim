py3 from chinese import *;設定首碼搜尋映射()
py3 from zhongwen.text import 字元切換, 翻譯, 查萌典

def! InstallYaHeiFont()
    py3 安裝雅黑混合字型()
enddef

" 中文字型
set guifont=Microsoft_YaHei_Mono:h16

"f 搜尋擴充
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

" D -> 查中文字義
command! -nargs=+ Def :call popup_atcursor(py3eval("查萌典('<args>')"), {})
map D yl:Def <c-r>"<cr>

" K 擴充
" Google 關鍵字查詢
command! -nargs=+ Google :!start "https://www.google.com/search?q=<args>"
map ,g :Google<space>

vmap K y:Google <c-r>"<cr>

" / 擴充搜尋選取項目
vnoremap / y/<c-r>"<cr>

" 輸入法自動切換
" 輸入法狀態提示，未开启時為白色光标，开启时橘色光标
hi Cursor guifg=bg guibg=White gui=NONE  
hi CursorIM guifg=NONE guibg=Orange gui=NONE  
autocmd VimEnter * set imdisable
autocmd InsertLeave * set imdisable
autocmd InsertEnter * set noimdisable
autocmd CmdlineEnter * set noimdisable
autocmd TerminalOpen * set noimdisable

nnoremap / :set noimdisable<cr>/
