vim9script

g:input_buffer = ''

g:im_enabled = false

def g:ImHandler(key: string)
    if key == ' '  # 當按下空格鍵
        if len(g:input_buffer) > 0
            # 取得緩衝區的最後一個字元並插入
            var last_char = g:input_buffer[-1]
            feedkeys(last_char, 'n')
            清空緩衝區
            g:input_buffer = ''
        endif
    else  # 當按下其他鍵
        # 將字元加入緩衝區
        g:input_buffer ..= key
    endif

    # 顯示緩衝區內容，提供視覺回饋
    echom "Current Buffer: " .. g:input_buffer
enddef

def g:HandleInput(c: number): string
    if g:im_enabled
        # 將按鍵傳給 ImHandler 處理
        g:ImHandler(nr2char(c))
        # 回傳空字串，阻止 Vim 立即插入按鍵
        return ''
    else
        # 回傳按鍵本身，讓 Vim 正常插入
        return nr2char(c)
    endif
enddef

# 切換輸入法狀態的函數
def g:ToggleIM(): string
    g:im_enabled = !g:im_enabled
    if g:im_enabled
        echom "自訂輸入法已啟用 (Custom Input Method ENABLED)"
    else
        echom "英文輸入法已啟用 (English Input Method ENABLED)"
        # 當切換回英文模式時，清空緩衝區
        g:input_buffer = ''
    endif
    # 這行回傳空字串，防止 <C-_> 插入任何字元
    return ''
enddef

# 重新映射所有的可列印字元，將它們導向 HandleInput 函數
# inoremap <expr> <C-r>=HandleInput(getchar())

# 使用 <C-_> 來切換輸入法開關
# 這裡使用 <C-_> 組合鍵，但實際運作可能因終端機而異
inoremap <C-_> <C-r>=ToggleIM()<CR>
