vim9script

def ToPressReleasePrompt()
    # 編輯內容轉資訊發布提問
    py3 << EOF 
from zhongwen.審計報告 import 轉譯資訊發布提問
from pyperclip import copy
import vim
content = '\n'.join(vim.current.buffer)
copy(轉譯資訊發布提問(content))
EOF
enddef
command! ToPressReleasePrompt ToPressReleasePrompt()
