vim9script

def SetupIM()
python3 << EOF
import vim
key = 'a'
設定行輸入按鍵對映 = f'inoremap <buffer> <expr> {key} <C-R>=PressKey("{key}")'
vim.command(設定行輸入按鍵對映)
vim.command('echom "設定完成"')
EOF
enddef

def g:PressKey(key: string): string
    echom "按下"
    echom key
    return 'b'
enddef

SetupIM()
