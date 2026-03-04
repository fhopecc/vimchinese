vim9script

def GotoLink()
    py3 <<EOS
from zhongwen.文 import 取行內連結
from pathlib import Path
import vim
import os
link = 取行內連結(vim.current.line)
if link['類型'] == '檔案連結':
    path = Path(vim.eval("expand('%:p:h')"))
    path = path / link['路徑']
    os.system(f'start {path}')
elif link['類型'] == 'URL':
    os.system(f'start {link['路徑']}')
EOS
    var link_type = py3eval("link['類型']")
    if link_type == '檔案搜尋連結'
        var path = py3eval("link['路徑']")
        var location = py3eval("link['定位點']")
        execute "edit +" ..  escape($'/{location}', ' ') .. " " .. fnameescape(path)
    endif
enddef
nnoremap gl <scriptcmd>GotoLink()<cr>
# ** [[file:01.1150302提供資料\花蓮縣消防局無人機作業手冊(1140110).doc][花蓮縣消防局無人機作業手冊]]
