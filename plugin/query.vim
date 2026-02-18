vim9script
# 諮詢
def Query(question: string)
    b:question = question
    py3 << EOF
from zhongwen.智 import 諮詢
import vim
問題 = vim.eval("b:question")
對話歷史 = '\n'.join(vim.current.buffer)
rs = 諮詢(問題, 對話歷史)
rs = ('user:\n'
      f'{問題}\n'
      'model:\n'
      f'{rs}'
     )
vim.current.buffer.append(rs.splitlines(), len(vim.current.buffer))
EOF
enddef
command! -nargs=1 Query Query(<q-args>)
