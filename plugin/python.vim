vim9script
### Python 檔案編輯相關函數及命令 ###

# 執行編輯中程式
command! ExecutePython {
    w!
    AsyncRun py %
}

# 測試編輯中腳本
def TestPython()
    w!
    py3 from zhongwen.python import find_testfile
    var testfile = py3eval($"find_testfile(r'{expand('%')}')")
    var command: string = $'AsyncRun py {testfile}'
    execute command
enddef
command! TestPython call TestPython()

# 至檔案
def GotoFile()
    py3 << EOS
from zhongwen.檔 import 取文檔位置
import vim
line = vim.eval("getline('.')")
錯誤位置 = 取文檔位置(line)
vim.command(f"e! +{錯誤位置['列']} {錯誤位置['路徑']}")
# vim.command(f"echom +{錯誤位置['列']} {錯誤位置['路徑']}")
EOS
enddef
command! GotoFile call GotoFile()

# 至物件定義檔案
def GotoDefineFile()
py3 << EOS
import vim, jedi
f = vim.eval("expand('%')")
c = '\n'.join(vim.current.buffer)
script = jedi.Script(code=c, path=f)
_, l, c, *_ = map(lambda s: int(s), vim.eval('getcursorcharpos()'))
try:
    r = script.goto(l, c, follow_imports=True)[0]
    p = r.module_path
    l = r.line
    c = r.column
    vim.command(f"e +{l} {p}")
except (IndexError, AttributeError) as e: 
    pass
EOS
enddef
command! GotoDefineFile call GotoDefineFile()

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
command! ShowDocument call ShowDocument()

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
command! DeployPython call DeployPython()
