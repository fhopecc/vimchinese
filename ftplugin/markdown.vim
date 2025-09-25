vim9script
# 繼承純文字模式
runtime! ftplugin/text.vim
py3 from fhopecc.洄瀾打狗人札記 import 張貼

#顯示目次
nmap <buffer> ;T :Toc<cr>

# nmap >> 0i> <esc>

g:vim_markdown_math = 1

# 臚列標題
def ListTitle(level: string): string
    g:_level = str2nr(level)
python3 << EOF
from zhongwen.文 import 臚列標題
import vim
buffer = '\n'.join(vim.current.buffer) 
titles = 臚列標題(buffer, vim.vars['_level'] )
vim.vars['_titles'] = titles
EOF
    append(line('.'), g:_titles)
    return g:_titles
enddef
command -nargs=1 ListTitle call ListTitle(<f-args>)

def ToHTML()
    w!
py3 << EOF
from zhongwen.markdown import 網頁表達
import vim
file = vim.eval('expand("%:p")')
網頁表達(file)
EOF
enddef
command ToHTML call ToHTML()
map <buffer> <leader>e :ToHTML<CR>

def IsInMath()
    for id in synstack(line("."), col("."))
        if synIDattr(id, "name") == "mkdMath"
            return v:true
        endif
    endfor
    return v:false
enddef

def ToPPT()
    w!
    let pptx = expand("%:p:r") . ".pptx"
    let powerpnt = "C:\\Program Files\\Microsoft Office\\root\\Office16\\POWERPNT.exe"
    if hostname() == 'HLAO1K-013OLD'
        let powerpnt = "C:\\Program Files\\Microsoft Office\\Office14\\POWERPNT.exe"
    endif
    " execute("silent :! pandoc % -F mermaid-filter.cmd -o " . pptx)
    execute("silent :! pandoc % -o " . pptx)
    execute("silent :! \"" . powerpnt . "\" /S " . pptx)
enddef
map <buffer> <leader>S :call markdown#2pptx()<CR>

def ToDOCX()
w!
py3 << EOF
from zhongwen.office_document import markdown2docx
import vim
file = vim.eval('expand("%:p")')
markdown2docx(file)
EOF
enddef

# 公布至洄瀾打狗人網站
def Post()
py3 << EOF
import vim
import logging
from pathlib import Path
file = vim.eval('expand("%:p")')
logging.getLogger().setLevel(logging.ERROR)
張貼(file)
logging.getLogger().setLevel(logging.INFO)
vim.command(f'echo "【{Path(file).stem}】已張貼至洄瀾打狗人。"')
EOF
enddef
map <buffer> <leader>P :call markdown#post()<CR>

# 游標關鍵字檢索
# nnoremap <buffer><expr> K ":G ".expand('<cword>')."<cr>"

# markdown 指令
# mn 新投影片
# m1 插入條列一
# m2 插入條列二
# m3 插入條列三
map <buffer> m0 <cmd>py3 import markdown;markdown.設定條列(0)<cr>
map <buffer> m1 <cmd>py3 import markdown;markdown.設定條列(1)<cr>
map <buffer> m2 <cmd>py3 import markdown;markdown.設定條列(2)<cr>
map <buffer> m3 <cmd>py3 import markdown;markdown.設定條列(3)<cr>

