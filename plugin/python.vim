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

        var msg = '執行' .. fnamemodify(py, ':t') .. '……'
        var options = {
            'line': 1, 
            'col': (winwidth(0) - msg->strlen()) / 2
        }
        var notify_popup_id = msg->popup_create(options)

        var out_name = '輸出' .. '(' .. fnamemodify(py, ':t') .. ')'
        var command_list = ['py', '-u', py]
        var job_options = {
            'out_io': 'buffer',
            'err_io': 'buffer', 
            'out_name': out_name, 
            'err_name': out_name, 
            'out_msg': 0, 
            'err_msg': 0, 
            'exit_cb': (j, e) => ExecutePythonCallback(out_name, notify_popup_id, j, e)
        }
        try
            bufnr(out_name)->deletebufline(1, bufnr(out_name)->getbufinfo()[0].linecount)
        catch
            # 不存在輸出 buf 之錯誤，待 job 之後建置，不作任何事。
        endtry
        var job = job_start(command_list, job_options)
    catch
        echom 'ExecutePython發生錯誤：'
        echom v:throwpoint
        echom v:errmsg
    endtry
enddef
command! ExecutePython call ExecutePython()

def ExecutePythonCallback(out_name: string, notify_popup_id: number, job: job, status: number)
    try
        const ls = bufnr(out_name)->getbufline(1, '$')
        var out = []
        if len(join(ls, '')) > 0
            for l in ls
                const decoded_l = iconv(l, 'cp950', 'utf-8')
                out->add(decoded_l)
            endfor
            setbufline(bufnr(out_name), 1, [])
            setbufline(bufnr(out_name), 1, out)
            execute 'buf ' .. out_name

            # 刪除所有自定義 ID (> 3) 的高亮匹配
            var matches = getmatches()
            for m in matches
                if m.id > 3
                    matchdelete(m.id)
                endif
            endfor

            var total_lines = 0
            for line_text in out
                total_lines += 1 
                if line_text->match('Error') >= 0
                    matchaddpos('LineNr', [total_lines], 10, -1, { 'bufnr': bufnr(out_name) })
                endif
            endfor
            setlocal hlsearch
            search('File .\+, line \d\+', 'wb')
            nmap <buffer> ]] <cmd>/File .\+, line \d\+<cr>
            nmap <buffer> [[ <cmd>?File .\+, line \d\+<cr>
        endif
        notify_popup_id->popup_close() 
    catch 
        echom 'ExecutePythonCallback發生錯誤：'
        echom v:throwpoint
        echom v:errmsg
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
