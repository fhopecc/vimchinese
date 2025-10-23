vim9script

def DeploySnippets()
    w!
    var cmd: string = "Copy! " .. g:GetUserVimfiles() .. '\ultisnips'
    execute(cmd) 
    call popup_notification('已布署' .. expand('%:t') .. '！', {})
enddef
command! DeploySnippets call DeploySnippets()
