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


# 定義一個函數，用來建立並顯示懸浮視窗
def ShowInputPopup()
    popup_clear()
    var content = [
        'Hello, Vim!',
        '這是一個用 vim9script 建立的',
        '懸浮視窗範例。',
        '',
        '按 q 鍵或 Esc 即可關閉。'
    ]

    # 設定懸浮視窗的選項，所有選項都放在一個字典裡
    var options = {title: '我的彈出式視窗', 
                   border: [], 
                   line: 5,
                   col: 10,                   
                   width: 35,                  
                   height: 6,                  
                   close_command: 'q',         
                   maxheight: 10,              
    }

    var popup_id = popup_create(['a', 'b'], options)

    echom '已建立一個 ID 為 ' .. popup_id .. ' 的懸浮視窗。'
enddef

# 呼叫函數，執行程式碼
# ShowInputPopup()
