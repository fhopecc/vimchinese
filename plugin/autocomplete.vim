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
# 補全函數
def Complete(findstart: number, base: string): any
    if findstart
        return col('.')
    endif

    py3 <<EOS
from zhongwen.文 import 取簡稱補全選項, 取英文單字補全選項, 取最近詞首
from zhongwen.法規 import 取法規補全選項
from zhongwen.檔 import 取檔名補全選項
import vim
import jedi
file = vim.eval("expand('%')")
cb = vim.current.buffer
text = '\n'.join(cb)
_a, lno, colno, _a, _a = map(lambda s: int(s), vim.eval('getcursorcharpos()'))
colno -= 1 # 插入模式游標欄數係插入新字元之位置，即游標之前字元數加1。
suggest = []
if vim.eval("&filetype") == 'python': 
    code = text
    script = jedi.Script(code, path=file)
    suggest += [{'word':c.complete, 'abbr':c.name, 'kind':c.type} for c in script.complete(lno, colno)]
if vim.eval("&filetype") == 'vim': 
    cl = vim.eval("getline('.')")
    completiontype = vim.eval("getcompletiontype(getline('.'))")
    if completiontype:
        cword = 取最近詞首(cl, colno) 
        vim.command(f"echom 'cword = {cword}'")
        cmd = f"getcompletion('{cword}', '{completiontype}')"
        vim.command(f"echom \"cmd = {cmd}\"")
        vimcomp = vim.eval(cmd)
        if vimcomp: 
            suggest += [{'word':s[len(cword):], 'abbr':s, 'kind':completiontype} for s in vimcomp]
suggest += 取法規補全選項(text, lno, colno)
suggest += 取簡稱補全選項(text, lno, colno)
suggest += 取英文單字補全選項(text, lno, colno)
suggest += 取檔名補全選項(text, lno, colno)
EOS
    return {'words': py3eval("suggest"), 'refresh': 'always'}
enddef
set completefunc=Complete
set completeopt-=preview
