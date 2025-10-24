vim9script

# 非同步執行程式
def AsynRun(command: list<string>)
    try
        var job_options = {
            'out_io': 'buffer',
            'err_io': 'buffer', 
            'out_name': '輸出', 
            'err_name': '輸出', 
            'exit_cb': funcref('AsynRunCallback')
        }
        try
            bufnr('輸出')->deletebufline(1, bufnr('輸出')->getbufinfo()[0].linecount)
        catch
            # 不存在輸出 buf 之錯誤，待 job 之後建置，不作任何事。
        endtry
        var job = job_start(command_list, job_options)
        var msg = '執行' .. expand('%') .. '……'
        var options = {
            'line': 1, 
            'col': (winwidth(0) - msg->strlen()) / 2
        }
        g:popup_execute_python = msg->popup_create(options)
    catch
        echom 'AsynRun發生錯誤：'
        echom v:throwpoint
        echom v:errmsg
    endtry
enddef
command! AsynRun call AsynRun()

def AsynRunCallback(job: job, status: number)
    try
        const ls = bufnr('輸出')->getbufline(1, '$')
        var out = []
        for l in ls
            const decoded_l = iconv(l, 'cp950', 'utf-8')
            out->add(decoded_l)
        endfor
        setbufline(bufnr('輸出'), 1, [])
        setbufline(bufnr('輸出'), 1, out)
        execute 'buf ' .. '輸出'
        g:popup_execute_python->popup_close() 
    catch 
        echom 'AsynRunCallback發生錯誤：'
        echom v:throwpoint
        echom v:errmsg
    endtry
enddef
