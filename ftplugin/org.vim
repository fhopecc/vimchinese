vim9script

setlocal expandtab      
setlocal shiftwidth=2   
setlocal softtabstop=2  
setlocal tabstop=2

def ToHTML()
    w!
    AsyncRun py -m zhongwen.org -f %
enddef
map <buffer> <leader>e <cmd>call <sid>ToHTML()<cr>

