def GotoLink()
    py3 <<EOS
from zhongwen.文 import 取行內連結
import vim
link = 取行內連結(vim.current.line)
EOS
    var path = py3eval("link['路徑']")
    var location = py3eval("link['定位點']")
    execute "edit +" ..  escape($'/{location}', ' ') .. " " .. fnameescape(path)
enddef
command! GotoLink call GotoLink() 
nnoremap gx <cmd>GotoLink<cr>
