vim9script

# <leader>O -> 顯示目次
map <buffer> <leader>O <cmd>setlocal foldlevel=2<cr>

# <leader>e -> 網頁表達
map <buffer> <leader>e <cmd>call <sid>ToHTML()<cr>

# <leader>P -> 公布至洄瀾打狗人網站
map <buffer> <leader>P <cmd>call <sid>Post()<cr>

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

# 審核意見轉通知
def ToInform()
    %s/聲復\(本室.\+一案\)，謹擬具處理意見\(如說明二\)\?，簽請鑒核。/聲復\1，核復如說明二，請查照辦理見復。/ge
    %s/依據\(.\+函\)辦理。/復\1。/ge
    %s/旨案.\+，擬具處理意見如次：/核復事項：/ge
    %s/宜蘭縣政府/貴府/ge
    %s/宜蘭縣立殯葬管理所/貴場/ge
    %s/該府/貴府/ge
    %s/該場/貴場/ge
    %s/據復：/承復：/ge
    %s/擬復請/請/ge
    %s/擬復//ge
    %s/其餘通知事項.\+//ge
    %s/擬奉核可後，.\+//ge
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
