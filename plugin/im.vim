vim9script
var input_popup = 0
var best_candidate = ''
var input_buffer = ''
var input_method = ''
var cmdline_input_buffer = ''
var cmdline_best_candidate = ''
var cmdline_input_method = ''
# 按下字根鍵即小寫字母鍵
def! g:PressLowerCaseLetters(key: string): string
    if input_method != '' || cmdline_input_method != ''
        if mode() == 'n'
            input_buffer = input_buffer .. key
        elseif mode() == 'c'
            cmdline_input_buffer = cmdline_input_buffer .. key
        endif
        ShowInputPopup()
        return ''
    endif
    return key
enddef
# 按下符號鍵
def! g:PressSymbols(key: string): string
    popup_clear()
    if input_method != '' || cmdline_input_method != ''
        if mode() == 'i'
            input_buffer = ''
        elseif mode() == 'c'
            cmdline_input_buffer = ''
        endif
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
        elseif key == '\'
            return '、'
        endif
        return ''
    endif
    return key
enddef

# 按下空格鍵，預設輸出最佳候選字
def! g:PressSpace(): string
    popup_clear()
    var c = ''
    if input_method != '' || cmdline_input_method != ''
        if mode() == 'i'
            input_buffer = ''
            c = best_candidate 
            best_candidate = ''
        elseif mode() == 'c'
            cmdline_input_buffer = ''
            c = cmdline_best_candidate 
            cmdline_best_candidate = ''
        endif
        if !empty(c)
           return c
        endif
    endif
    return ' '
enddef 

# 空格鍵係出第一個候選字
def! g:PressBackspace(): string
    if input_method != '' || cmdline_input_method != ''
        popup_clear()
        var c = ''
        if mode() == 'i'
            input_buffer = ''
            c = best_candidate 
            best_candidate = ''
        elseif mode() == 'c'
            cmdline_input_buffer = ''
            c = cmdline_best_candidate 
            cmdline_best_candidate = ''
        endif
        if !empty(c)
           return c
        endif
    endif
    return ' '
enddef 

# 切換中英輸入法
def g:SwitchIM()
    if input_method == ''
        input_method = 'cangjie'
    else
        input_method = ''
    endif
    UpdateStatus()
enddef
command! SwitchIM call g:SwitchIM()

# 命令視窗切換中英輸入法
def! g:CmdlineSwitchIM()
    var cmdline = getcmdline()
    SwitchIM
enddef
command! CmdlineSwitchIM call g:CmdlineSwitchIM()

# 離插入模式
def! g:LeaveInsertMode()
    # popup_clear()
    input_buffer = ''
enddef

# 進入命令列模式為英文輸入法
# 進入命令列模式會預設為英文輸入法
def! g:CmdlineEnter()
    # popup_clear()
    cmdline_input_buffer = ''
    cmdline_best_candidate = ''
    cmdline_input_method = ''
    UpdateStatus()
enddef

# 更新輸入法狀態，倉頡輸入法光標為黃色，英文為綠色。
def UpdateStatus()
    if input_method == ''
        hi Cursor guibg=green ctermbg=green
    else
        hi Cursor guibg=yellow ctermbg=yellow
    endif
enddef

def! g:SetupIM()

    set noshowmode # 插入模式之命令列不提示插入
    set imdisable # 禁用輸入法

    # 設定彈窗格式
    highlight Pmenu guibg=#282828 guifg=white
python3 << EOF
from zhongwen.文 import escape_vim_string
import vim

設定命令集 = []
設定命令集.append(f'inoremap <c-_> <c-O>:SwitchIM<cr>')
設定命令集.append(f'cnoremap <c-_> CmdlineSwitchIM<cr>')
設定命令集.append(f'noremap <c-_> :SwitchIM<cr>')

for key in 'abcdefghijklmnopqrstuvwxyz':
    設定命令集.append(f'inoremap {key} <c-r>=g:PressLowerCaseLetters("{key}")<cr>')
    設定命令集.append(f'cnoremap {key} <c-r>=g:PressLowerCaseLetters("{key}")<cr>')

for key in ',.?;:[]\\':
    設定命令集.append(f'inoremap {key} <c-r>=g:PressSymbols("{escape_vim_string(key)}")<cr>')
    設定命令集.append(f'cnoremap {key} <c-r>=g:PressSymbols("{escape_vim_string(key)}")<cr>')

設定命令集.append(f'inoremap <space> <c-r>=g:PressSpace()<cr>')
設定命令集.append(f'cnoremap <space> <c-r>=g:PressSpace()<cr>')
for 命令 in 設定命令集:
    vim.command(命令 )
EOF
    autocmd! InsertLeave
    autocmd InsertLeave * g:LeaveInsertMode()
    autocmd! CmdlineEnter
    autocmd CmdlineEnter * g:CmdlineEnter()
    UpdateStatus()
enddef
command! SetupIM call g:SetupIM()

# 於游標處顯示輸入彈窗
#
# 一、無候選字時，彈窗僅輸入行。
#
def ShowInputPopup()
    py3 from zhongwen.文 import 倉頡檢字
    var candidates = []
    var content = [] 
    if mode() == 'i'
        candidates = py3eval('[f"{i+1}.{c[0]} {c[1:]}" for i, c in enumerate(倉頡檢字("' .. input_buffer .. '"))]')
        content = candidates
        best_candidate = content[0][2 : 2]  
    elseif mode() == 'c'
        candidates = py3eval('[f"{i+1}.{c[0]} {c[1:]}" for i, c in enumerate(倉頡檢字("' .. cmdline_input_buffer .. '"))]')
        content = candidates
        cmdline_best_candidate = content[0][2 : 2]  
    endif
    var width = 35
    # 設定懸浮視窗的選項，所有選項都放在一個字典裡
    var options = {title: candidates[0][4 :] .. '_ ',
                   # line: winline() + 1,
                   # col: wincol() - width / 4,                   
                   # width: width,                  
                   # height: 6,                  
                   maxheight: 10,              
    }
    if index(popup_list(), input_popup) >= 0
        popup_settext(input_popup, content)       
        popup_setoptions(input_popup, options)       
    else
        input_popup = popup_atcursor(content, options)
    endif
    # matchadd('InputLine', '\%1l', -1, g:input_popup)
enddef
if !g:disableim
    SetupIM
endif
