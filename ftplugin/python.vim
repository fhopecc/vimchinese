vim9script
## Python 檔案編輯按鍵定義 ##

## 單鍵 ##

## 雙鍵 ##

map <buffer> <leader>e <cmd>ExecutePython<cr>
map <buffer> <leader>t <cmd>TestPython<cr>


nnoremap gf <cmd>GotoFile<cr><c-w><c-o>
nnoremap <buffer> gd <cmd>GotoDefineFile<cr>

# 切換至目前編輯檔之目錄
# 查詢名稱說明
nnoremap <buffer> K <Cmd>ShowDocument<cr>


command! Cwd exe 'cd '.expand("%:p:h")   
command! -buffer ChangeWindow normal <c-w>w
command! -buffer MaxWindow normal <c-w>o

# 效能
def ProfilePython()
    w!
    topleft :terminal ++rows=10 cmd /c py -m cProfile -s cumtime %
enddef
map <buffer> <leader>P :call python#profile()<cr>

map <buffer> <leader>D <cmd>DeployPython<cr>

# 環境設定
map <buffer> <F7> :w!<CR>:belowright :terminal python % --setup<CR>  

# 顯示說明
def ShowDocument()
    py3 << trim EOS
import vim, jedi
f = vim.eval("expand('%')")
c = '\n'.join(vim.current.buffer)
script = jedi.Script(code=c, path=f)
_, l, c, *_ = map(lambda s: int(s), vim.eval('getcursorcharpos()'))
try:
    vim.vars['doclines']= '\n\n'.join([d.docstring() for d in script.goto(l, c, follow_imports=True)]).splitlines()
except (IndexError, AttributeError) as e: 
    vim.vars['doclines'] = []
EOS
    popup_atcursor(g:doclines, {
                   title: 'Docstring',
                   padding: [0, 1, 0, 1]
                  })
enddef  
command -buffer ShowDocument ShowDocument()

# 打包佈署
def DeployPython()
    w!
py3 << EOF
import vim
from zhongwen.python import 布署
from pathlib import Path
布署(Path(vim.current.buffer.name))
EOF
enddef
command -buffer DeployPython DeployPython()
