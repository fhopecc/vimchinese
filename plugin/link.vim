vim9script

def GotoLink()
    py3 <<EOS
from zhongwen.文 import 取行內連結
import vim
link = 取行內連結(vim.current.line)
EOS
    var link_type = py3eval("link['類型']")
    if link_type == '檔案搜尋連結'
        var path = py3eval("link['路徑']")
        var location = py3eval("link['定位點']")
        execute "edit +" ..  escape($'/{location}', ' ') .. " " .. fnameescape(path)
    elseif link_type == 'URL'
        var URL = py3eval("link['路徑']")
        execute "!start " .. URL
    endif
enddef
command! GotoLink call GotoLink() 
nnoremap gl <cmd>GotoLink<cr>
