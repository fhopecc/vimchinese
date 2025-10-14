vim9script
### Python 檔案編輯相關函數及命令 ###

# 執行編輯中程式
def ExecutePython(pyname: string = '')
    try
        w!
        var py = pyname
        if py == ''
            py = expand('%')
        endif
        var command_list = ['py', '-u', py]
        var job_options = {
            'out_io': 'buffer',
            'err_io': 'buffer', 
            'out_name': '輸出', 
            'err_name': '輸出', 
            'exit_cb': funcref('ExecutePythonCallback')
        }
        bufnr('輸出')->deletebufline(1, bufnr('輸出')->getbufinfo()[0].linecount)
        var job = job_start(command_list, job_options)
        g:popup_execute_python = popup_dialog('執行' .. expand('%'), {})
    catch
        var errmsg = '執行' .. expand('%') .. "失敗，主要係發生" .. v:exception
        echom errmsg
    endtry
enddef
command! ExecutePython call ExecutePython()

def ExecutePythonCallback(job: job, status: number)
    try
        const ls = bufnr('輸出')->getbufline(1, '$')
        var out = []
        for l in ls
            const decoded_l = iconv(l, 'cp950', 'utf-8')
            out->add(decoded_l)
        endfor
        setbufline(bufnr('輸出'), 1, [])
        setbufline(bufnr('輸出'), 1, out)
        execute 'buf ' .. '輸出'

        py3 << EOS 
from zhongwen.python import 取錯誤位置清單
import vim
qf = 取錯誤位置清單(vim.buffers[int(vim.eval('bufnr("輸出")'))]) 
EOS
        g:popup_execute_python->popup_close() 
        setqflist(py3eval('qf'), 'r')
        Leaderf quickfix --popup 
   catch 
        var errmsg = '執行' .. expand('%') .. "失敗，主要係發生" .. v:exception
        echom errmsg
        # popup_notification(errmsg, {})       
   endtry
enddef

# 測試編輯中腳本
def TestPython()
    w!
    py3 from zhongwen.python import find_testfile
    var testfile = py3eval("find_testfile(r'" .. expand('%') .. "')")
    ExecutePython(testfile)
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
