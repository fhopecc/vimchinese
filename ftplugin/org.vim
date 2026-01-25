vim9script

def ToHTML()
    w!
    AsyncRun py -m zhongwen.org -f %
enddef
map <buffer> <leader>e <cmd>call <sid>ToHTML()<cr>
