vim9script

# 顯示目次
map <buffer> <leader>O <cmd>setlocal foldlevel=2<cr>

# <leader>e -> 網頁表達
def ToHTML()
    w!
py3 << EOF

from zhongwen.markdown import 網頁表達
import vim
file = vim.eval('expand("%:p")')
網頁表達(file)
EOF
enddef
map <buffer> <leader>e <cmd>call <sid>ToHTML()<cr>

# <leader>P -> 公布至洄瀾打狗人網站
def Post()
    py3 << EOF
from fhopecc.洄瀾打狗人札記 import 張貼
from pathlib import Path
import logging
import vim
file = vim.eval('expand("%:p")')
logging.getLogger().setLevel(logging.ERROR)
張貼(file)
logging.getLogger().setLevel(logging.INFO)
vim.command(f'echo "【{Path(file).stem}】已張貼至洄瀾打狗人。"')
EOF
enddef
map <buffer> <leader>P <cmd>call <sid>Post()<cr>

# :ToDOCX -> 轉成 docx 檔
def ToDOCX()
w!
py3 << EOF
from zhongwen.office_document import markdown2docx
import vim
file = vim.eval('expand("%:p")')
markdown2docx(file)
EOF
enddef
command -buffer ToDOCX call ToDOCX()

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
command! -nargs=1 ListTitle call ListTitle(<f-args>)

# 游標是否位於數學公式範圍
def! g:IsInMath(): bool
    var ids: list<number> = synstack(line('.'), col('.'))
    var name: string     # <--- 變數改為 name (string 型別)

    # 迴圈遍歷所有的語法 ID
    for synid in ids
        # 直接取得語法名稱 (回傳 string)
        name = synIDattr(synid, 'name')

        # 檢查名稱是否為 'mkdMath'
        # 這裡也檢查了 name 是否為空字串 (即沒有語法名稱)
        if name == 'mkdMath'
            return true
        endif
    endfor
    return false
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

# markdown 指令
# m1 插入條列一
# m2 插入條列二
# m3 插入條列三
map <buffer> m0 <cmd>py3 import markdown;markdown.設定條列(0)<cr>
map <buffer> m1 <cmd>py3 import markdown;markdown.設定條列(1)<cr>
map <buffer> m2 <cmd>py3 import markdown;markdown.設定條列(2)<cr>
map <buffer> m3 <cmd>py3 import markdown;markdown.設定條列(3)<cr>
