vim9script

# 布署編輯程式碼
def DeployVIM()
    w!
    py3 << EOS
from invoke import Context
from tasks import deploy_vim
import vim
c = Context()
v = deploy_vim(c, vim.eval("expand('%')"))
EOS
    var msg: string = "布署" .. py3eval('v.name') .. "完成"
    msg->popup_notification({})
enddef
command! DeployVIM call DeployVIM()
