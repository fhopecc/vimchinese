vim9script

def PressKey(key: string): string
    echom "按下"
    echom key
    return 'b'
enddef

def SetupIM()
python3 << EOF
import vim
key = 'a'
設定行輸入按鍵對映 = f'inoremap <buffer> <expr> {key} <C-R>=PressKey("{key}")'
vim.command(設定行輸入按鍵對映)
vim.command('echom "設定完成"')
EOF
enddef


# 游標顯示輸入彈窗
def ShowInputPopup()
    popup_clear()
    highlight InputPopup guibg=#282828 guifg=white
    highlight InputLine guifg=#98FB98 
    var title = '火'
    var content = [
        '1.火',
        '2.炎 火火',
    ]
    var width = 35 
    # 設定懸浮視窗的選項，所有選項都放在一個字典裡
    var options = {title: title, 
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

# ShowInputPopup()
