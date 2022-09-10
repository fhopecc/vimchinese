" 中文字型
set guifont=Microsoft_YaHei_Mono:h16

"f 搜尋擴充
autocmd InsertEnter * set nohlsearch
autocmd CursorHold * set nohlsearch
hi Search guibg=Red 

py3 from chinese import *;設定首碼搜尋映射()
py3 from zhongwen.text import 字元切換, 翻譯

" ~ -> 字元切換
func! chinese#switch_char()
    let c = strcharpart(getline('.'), charcol('.')-1, 1)
    let sc = py3eval('字元切換("'.c.'")')
    exec 'normal cl'.sc
endfunc

nmap ~ :call chinese#switch_char()<cr>

" T -> 選詞翻譯
command! YankLastMessages :let @1=execute('1messages')
command! -nargs=+ GTrans :echom py3eval("翻譯('<args>')")
vmap T y:GTrans <c-r>"<cr>

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
