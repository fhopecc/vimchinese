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
def ShowMyPopup()
    # 懸浮視窗的文字內容，以列表形式呈現
    var content = [
        'Hello, Vim!',
        '這是一個用 vim9script 建立的',
        '懸浮視窗範例。',
        '',
        '按 q 鍵或 Esc 即可關閉。'
    ]

    # 設定懸浮視窗的選項，所有選項都放在一個字典裡
    var options = {
        title: '我的彈出式視窗',     # 視窗標題
        border: 'rounded',          # 邊框樣式：可選 'single', 'double', 'rounded'
        line: 5,                    # 視窗的起始行號（從螢幕頂部算起）
        col: 10,                    # 視窗的起始列號（從螢幕左邊算起）
        width: 35,                  # 視窗寬度
        height: 6,                  # 視窗高度
        close_command: 'q',         # 定義按 'q' 鍵即可關閉視窗
        maxheight: 10,              # 最大高度，防止內容過多時超出範圍
    }

    # 使用 popup_create() 函數來建立視窗
    # 第一個參數是文字內容 (List)，第二個參數是選項 (Dictionary)
    var popup_id = popup_create(content, options)

    # 顯示訊息，告知視窗 ID
    echom '已建立一個 ID 為 ' .. popup_id .. ' 的懸浮視窗。'
enddef

# 呼叫函數，執行程式碼
ShowMyPopup()
