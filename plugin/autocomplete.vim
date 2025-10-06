vim9script
# 自動補全
inoremap <expr> <tab> SmartTabComplete()
# 選擇上個補全項目
inoremap <expr> <s-Tab> pumvisible() ? '<C-P>' : "\<S-Tab>"

# Tab 自動補全
def SmartTabComplete(): string
    # 1. 如果補全選單可見，按下 <Tab> 應選擇下一個補全項<C-N>
    if pumvisible()
        return "\<c-n>"
    endif

    if eval('UltiSnips#CanExpandSnippet()')
        return "\<c-r>=UltiSnips#ExpandSnippet()\<cr>"
    endif 
 
    var prefix: string = strcharpart(getline('.'), 0, col('.') - 1)
    # 如果無選單見且游標前沒有文字)則插入 Tab 字元，在行首或對齊時很重要。
    if prefix =~ '^\s*$'
        return "\<tab>"
    endif

    return "\<c-x>\<c-u>"
enddef
def Complete(findstart: number, base: string): any

    if findstart
        return col('.')
    endif
    py3 <<EOS
from zhongwen.法規 import 取法規補全選項
import vim
import jedi
suggest = []
file = vim.eval("expand('%')")
cb = vim.current.buffer
text = '\n'.join(cb)
_a, lno, colno, _a, _a = map(lambda s: int(s), vim.eval('getcursorcharpos()'))
suggest += 取法規補全選項(text, lno, colno)
line = cb[lno-1] 
colno = colno-1
if vim.eval("&filetype") == 'python': 
    code = text
    script = jedi.Script(code, path=file)
    suggest += [{'word':c.complete, 'abbr':c.name, 'kind':c.type} for c in script.complete(lno, colno)]
EOS
    return {'words': py3eval("suggest"), 'refresh': 'always'}
enddef
set completefunc=Complete
