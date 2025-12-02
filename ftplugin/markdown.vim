vim9script

setlocal nocursorline # 多文字高亮編輯行不習慣
setlocal wrap # 中文自然段較長啟用自動 wrap

# 依視窗寛度自動斷行，j k 移動以視窗行為主而非實際行
noremap <buffer> j gj
noremap <buffer> k gk
noremap <buffer> gj j
noremap <buffer> gk k

# J -> 不加空格連接下行，以符合中文無空格文法。
noremap <buffer> J gJ
noremap <buffer> gJ J

# <leader>c -> 搜尋內容
map <buffer> <leader>c <cmd>Leaderf line --popup --no-auto-preview<cr>

# <leader>O -> 顯示目次
map <buffer> <leader>O <cmd>setlocal foldlevel=2<cr>

# <leader>e -> 網頁表達
map <buffer> <leader>e <cmd>call <sid>ToHTML()<cr>

# :ToDOCX -> 轉成 docx 檔
command -buffer ToDOCX call ToDOCX()

def ToDOCX()
    w!
    py3 << EOF
from zhongwen.office_document import markdown2docx
import vim
file = vim.eval('expand("%:p")')
markdown2docx(file)
EOF
enddef

def ToHTML()
    w!
    py3 << EOF
from zhongwen.markdown import 網頁表達
import vim
file = vim.eval('expand("%:p")')
網頁表達(file)
EOF
enddef

# 公布至洄瀾打狗人網站
command! Post AsyncRun py -m fhopecc.洄瀾打狗人札記 -p %

# 審核意見轉通知
def ToInform()
    py3 << EOF
from zhongwen.文 import 
EOF
enddef
command! -buffer ToInform call ToInform()

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
