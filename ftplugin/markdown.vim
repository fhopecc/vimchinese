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

def Post(): void
    w!
    AsyncRun py -m fhopecc.洄瀾打狗人札記 -p %
enddef
# 公布至洄瀾打狗人網站
command! Post Post()

# 審核意見轉通知
def ToInform()
    py3 << EOF
from zhongwen.文 import 審核意見轉通知
import vim
vim.current.line = 審核意見轉通知(vim.current.line)
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

def ExportToPPTX()
    # 1. 自動儲存當前檔案
    silent write

    # 2. 獲取當前檔案路徑資訊
    var full_path = expand('%:p')        # 完整絕對路徑
    var extension = expand('%:e')        # 副檔名
    var base_name = expand('%:p:r')      # 不含副檔名的完整路徑
    var pptx_path = base_name .. '.pptx' # 目標 pptx 路徑

    if extension != 'md' && extension != 'markdown'
        echoerr "錯誤：目前檔案不是 Markdown 格式"
        return
    endif

    # 3. 執行 Pandoc 轉檔
    echo "正在轉檔為 PPTX..."
    # execute("silent :! pandoc % -F mermaid-filter.cmd -o " . pptx)
    # 增加 mermaid-filter
    var pandoc_cmd = printf('pandoc "%s" -o "%s"', full_path, pptx_path)
    var result = system(pandoc_cmd)

    # 檢查 pandoc 執行是否成功 (v:shell_error 為 0 表示成功)
    if v:shell_error != 0
        echoerr "Pandoc 執行失敗: " .. result
        return
    endif

    echo "轉檔完成：" .. pptx_path

    # 4. 根據作業系統自動開啟 PPTX
    var open_cmd = printf('start "" "%s"', pptx_path)

    if !empty(open_cmd)
        system(open_cmd)
    endif
enddef
command! -buffer ToPPTX call ExportToPPTX()
