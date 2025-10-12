vim9script

map <leader>e <scriptcmd>ExecutePython<cr>
map <leader>T <scriptcmd>TestPython<cr>

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

# 執行編輯中腳本
def ExecutePython()
    try
        w!
        var command_list = ['py', '-u', expand('%')]
        var job_options = {
            'out_io': 'buffer',
            'err_io': 'buffer', 
            'exit_cb': funcref('ExecutePythonCallback')
        }
        g:errmsg = []
        g:out = []
        var job = job_start(command_list, job_options)
        g:popup_beval = popup_beval('執行' .. expand('%'), {})
    catch
        var errmsg = '執行' .. expand('%') .. "失敗，主要係發生" .. v:exception
        popup_notification(errmsg, {})       
    endtry
enddef
command! ExecutePython call ExecutePython()

def ExecutePythonCallback(job: job, status: number)
    var outbuf = job->ch_getbufnr('out')
    const ls = outbuf->getbufline(1, '$')
    var decoded_ls = []
    for l in ls
        const decoded_l = iconv(l, 'cp950', 'utf-8')
        decoded_ls->add(decoded_l)
    endfor
    setbufline(outbuf, 1, [])
    setbufline(outbuf, 1, decoded_ls)
    execute 'sbuf ' .. string(outbuf)

    var errbuf = job->ch_getbufnr('err')
    const els = errbuf->getbufline(1, '$')
    g:errs = []
    for l in els
        const decoded_el = iconv(l, 'cp950', 'utf-8')
        g:errs->add(decoded_el)
    endfor
    setbufline(errbuf, 1, [])
    setbufline(errbuf, 1, g:errs)
 
    py3 << EOS 
from zhongwen.python import 取錯誤位置清單
import vim
qf = 取錯誤位置清單(vim.eval('g:decoded_els')) 
EOS
    g:popup_beval->popup_close() 
    setqflist(py3eval('qf'))
    Leaderf quickfix --popup 
enddef

# 測試編輯中腳本
def TestPython()
    try
        w!
        py3 from zhongwen.python import find_testfile
        var testfile = py3eval("find_testfile(r'" .. expand('%') .. "')")
        var command_list = ['py', '-u', testfile]
        var job_options = {
            'out_io': 'buffer',
            'out_name': 'out',
            'err_io': 'buffer', 
            'err_name': 'err',
            # 'out_cb': funcref('OutCallback'),
            # 'err_cb': funcref('ErrCallback'),
            'exit_cb': funcref('ExecutePythonCallback')
        }
        g:errmsg = []
        var job = job_start(command_list, job_options)
        g:popup_beval = popup_beval('測試' .. expand('%'), {})
    catch
        var errmsg = '測試' .. expand('%') .. "失敗，主要係發生" .. v:exception
        popup_notification(errmsg, {})       
    endtry
enddef
command! TestPython call TestPython()

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
