vim9script
var input_buffer = ''
var input_method = ''

def g:PressLowerCaseLetters(key: string): string
    if input_method == 'cangjie'    
        if match(key, '\l') == 0 # key in [a..b]
            input_buffer = input_buffer .. key
            g:ShowInputPopup()
            return ''
        endif
    endif
    return key
enddef

# 輸入符號
def g:PressSymbols(key: string): string
    popup_clear()
    input_buffer = ''
    if input_method == 'cangjie'    
        if key == ','
            return '，'
        elseif key == '.'
            return '。'
        elseif key == '?'
            return '？'
        elseif key == ';'
            return '；'
        elseif key == ':'
            return '：'
        elseif key == '['
            return '「'
        elseif key == ']'
            return '」'
        endif
        return ''
    endif
    return key
enddef

# 空格鍵係出第一個候選字
def g:PressSpace(): string
    if input_method == 'cangjie'    
        py3 from zhongwen.文 import 倉頡檢字
        var candidate = py3eval('倉頡檢字("' .. input_buffer .. '")[0][0]')
        popup_clear()
        input_buffer = ''
        return candidate
    endif
    return ' '
enddef 
# Ctrl - 切換中英輸入法
def g:PressCtrlMinus(): string
    if input_method == ''
        input_method = 'cangjie'
        echom 'ascii -> canjie'
    else
        input_method = ''
        echom 'canjie -> ascii'
    endif
    UpdateStatus()
    return ''
enddef

# 更新輸入法狀態，倉頡輸入法光標為黃色，英文為綠色。
def UpdateStatus()
    if input_method == ''
        hi Cursor guibg=green ctermbg=green
    else
        hi Cursor guibg=yellow ctermbg=yellow
    endif
enddef

def g:SetupIM()
    set noshowmode
    set imdisable
python3 << EOF
import vim

設定行輸入按鍵對映 = f'inoremap <c-_> <c-r>=g:PressCtrlMinus()<cr>'
vim.command(設定行輸入按鍵對映)

for key in 'abcdefghijklmnopqrstuvwxyz':
    設定行輸入按鍵對映 = f'inoremap {key} <c-r>=g:PressLowerCaseLetters("{key}")<cr>'
    vim.command(設定行輸入按鍵對映)

for key in ',.?;:[]':
    設定行輸入按鍵對映 = f'inoremap {key} <c-r>=g:PressSymbols("{key}")<cr>'
    vim.command(設定行輸入按鍵對映)

設定行輸入按鍵對映 = f'inoremap <space> <c-r>=g:PressSpace()<cr>'
vim.command(設定行輸入按鍵對映)
EOF
    autocmd! InsertLeave
    autocmd InsertLeave * g:LeaveInsertMode()
    UpdateStatus()
enddef
command! SetupIM call g:SetupIM()

def g:LeaveInsertMode()
    popup_clear()
    input_buffer = ''
enddef

# 游標顯示輸入彈窗
def g:ShowInputPopup()
    py3 from zhongwen.文 import 倉頡檢字
    popup_clear()
    highlight InputPopup guibg=#282828 guifg=white
    highlight InputLine guifg=#98FB98 
    var candidates = py3eval('[f"{i+1}.{c[0]} {c[1:]}" for i, c in enumerate(倉頡檢字("' .. input_buffer .. '"))]')
    var content = candidates
    var width = 35
 
    # 設定懸浮視窗的選項，所有選項都放在一個字典裡
    var options = {title: candidates[0][4 :] .. '_ ',
                   line: winline() + 1,
                   col: wincol() - width / 4,                   
                   width: width,                  
                   height: 6,                  
                   highlight: 'InputPopup',
                   title_highlight: 'InputLine', 
                   maxheight: 10,              
    }

    var popup_id = popup_create(content, options)
    matchadd('InputLine', '\%1l', -1, popup_id)
    echom '已建立一個 ID 為 ' .. popup_id .. ' 的懸浮視窗。'
enddef

if !g:disableim
    SetupIM
endif
