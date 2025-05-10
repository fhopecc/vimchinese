py3 from chinese import *;設定首碼搜尋映射()
py3 from zhongwen.text import 字元切換, 翻譯, 查萌典

def ScrollPopup(nlines: number)
    var winids = popup_list()
    if len(winids) == 0
        return
    endif

    # Ignore hidden popups
    var prop = popup_getpos(winids[0])
    if prop.visible != 1
        return
    endif

    var firstline = prop.firstline + nlines
    var buf_lastline = str2nr(trim(win_execute(winids[0], "echo line('$')")))
    if firstline < 1
        firstline = 1
    elseif prop.lastline + a:nlines > buf_lastline
        firstline = buf_lastline + prop.firstline - prop.lastline
    endif

    call popup_setoptions(winids[0], {'firstline': firstline})
enddef

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

" 輸入法自動切換
" 輸入法狀態提示，未開啓時為白色光標，開啓時橘色光標
"   如使用小狼亳輸入法，因其本身 vim 模式支援輸入法自動切換，以下可註解
" hi Cursor guifg=bg guibg=White gui=NONE  
" hi CursorIM guifg=NONE guibg=Orange gui=NONE  
" autocmd VimEnter * set imdisable
" autocmd InsertLeave * set imdisable
" autocmd InsertEnter * set noimdisable
" autocmd CmdlineEnter * set noimdisable
" autocmd TerminalOpen * set noimdisable

" nnoremap / :set noimdisable<cr>/

def ExtractAndNumberHeaders(level: number = 3): string
    # 驗證級別參數 (1-6)
    if level < 1 || level > 6
        echohl ErrorMsg
        echo "錯誤: 標題級別必須是 1-6 的數字"
        echohl None
        return ""
    endif

    var result: list<string> = []
    var cn_numbers = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十']
    var counter = 1
    var pattern = '^' .. repeat('#', level) .. '\s\+'

    for line in getline(1, '$')
        if line =~ pattern
            # 移除標記和空白
            var cleaned = substitute(line, pattern, '', '')

            # 添加中文序號
            var numbered = counter <= len(cn_numbers) 
                ? '('.cn_numbers[counter - 1].') '.cleaned
                : '('.string(counter).') '.cleaned

            add(result, numbered)
            counter += 1
        endif
    endfor

    return join(result, '；')
enddef

# 定義用戶命令
command! -nargs=? ExtractHeaders echo ExtractAndNumberHeaders(<args>)
command! -nargs=? -register CopyHeaders execute 'let @' .. escape(<q-reg>, '\"') .. ' = ExtractAndNumberHeaders(' .. (<q-args> ? <q-args> : '') .. ')'
