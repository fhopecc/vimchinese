" 中文字型
set guifont=Microsoft_YaHei_Mono:h16

"f 搜尋擴充
autocmd InsertEnter * set nohlsearch
autocmd CursorHold * set nohlsearch
hi Search guibg=Red 
py3 from fhopecc.chinese import *;設定首碼搜尋映射()
nmap ~ :py3 光標字元切換()<cr>

" K 擴充
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
