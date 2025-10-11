vim9script

map <c-j> <scriptcmd>SmartScrollDown<cr>
map <c-k> <scriptcmd>SmartScrollUp<cr>

# 向下捲動最新彈窗，如無捲動編輯視窗
def SmartScrollDown() 
    var last_popup_id: number = GetLastPopupId()
    if GetLastPopupId() != 0
        win_execute(GetLastPopupId(), "normal! \<C-E>")
    else
        execute "normal! \<C-E>"
    endif
enddef
command! SmartScrollDown :call SmartScrollDown()

# 向上捲動最新彈窗，如無捲動編輯視窗
def SmartScrollUp() 
    var last_popup_id: number = GetLastPopupId()
    if GetLastPopupId() != 0
        win_execute(GetLastPopupId(), "normal! \<C-Y>")
    else
        execute "normal! \<C-Y>"
    endif
enddef
command! SmartScrollUp :call SmartScrollUp()

# 取最新彈窗識別碼，無者為零
def GetLastPopupId(): number
    var last_winid: number = 0
    # 最新彈窗識別碼，即最大識別碼
    for winid in popup_list()
        if winid > last_winid
            last_winid = winid
        endif
    endfor
    return last_winid
enddef
# test code
# popup_clear()
# var line = 'line'
# var lines = []
# for i in range(80)
#     lines->add(string(i) .. line)
# endfor
# var winid = popup_dialog(lines, {})
# echom winid
# popup_clear()
