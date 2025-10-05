vim9script

# 使用者啟用 Tab 自動補全功能
if exists('g:SmartTabComplete')
    # 自動補全
    inoremap <expr> <tab> SmartTabComplete()
    # 選擇上個補全項目
    inoremap <expr> <s-Tab> pumvisible() ? '<C-P>' : "\<S-Tab>"
endif

# Tab 自動補全
def SmartTabComplete(): string
    # 1. 如果補全選單可見，按下 <Tab> 應選擇下一個補全項<C-N>
    if pumvisible()
        return "\<c-n>"
    endif

    # 2. 檢查游標前是否有非空白字元
    # getline('.')[col('.')-2] 是取得游標前一個字元
    # =~ '\k' 是檢查它是否為一個關鍵字字元 (keyword character)
    # 如果游標前面有可供補全的文字字首 (prefix)，就觸發補全
    if getline('.')[col('.') - 2]->match('\k') != -1
        # 觸發標準的插入模式補全 (從 'complete' 選項來源查找)
        # 這會彈出補全選單
        return "\<c-x>\<c-f>"
    endif
    # 3. 如果無選單見且游標前沒有文字)則插入 Tab 字元，在行首或對齊時很重要。
    return "\<tab>"
enddef
