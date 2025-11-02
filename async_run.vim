vim9script

# 非同步執行程式
def AsynRun(command: string)
    try
        var command_list = split(command)
        var msg: string = $"執行 {command}"
        var options = {
            'line': 1, 
            'col': (winwidth(0) - msg->strdisplaywidth()) / 2
        }
        var notify_popup_id = msg->popup_create(options)

        var outbuf = $"輸出({command->substitute('[ \\]', '_', 'g')}"
        try
            bufnr(outbuf)->deletebufline(1, bufnr(outbuf)->getbufinfo()[0].linecount)
        catch
            # 不存在輸出 buf 之錯誤，待 job 之後建置，不作任何事。
        endtry
        var job_options = {
            'out_io': 'buffer',
            'err_io': 'buffer', 
            'out_name': outbuf, 
            'err_name': outbuf, 
            'out_msg': 0, 
            'err_msg': 0, 
            'exit_cb': (j, e) => AsynRunCallback(outbuf, notify_popup_id, j, e)
        }
        var job = job_start(command_list, job_options)
    catch
        echom 'AsynRun發生錯誤：'
        echom v:throwpoint
        echom v:errmsg
    endtry
enddef
command! -nargs=1 AsynRun call AsynRun(<q-args>)

def AsynRunCallback(outbuf: string, notify_popup_id: number, job: job, status: number)
    try
        const ls = bufnr(outbuf)->getbufline(1, '$')
        var out = []
        if len(join(ls, '')) > 0
            for l in ls
                const decoded_l = iconv(l, 'cp950', 'utf-8')
                out->add(decoded_l)
            endfor
            setbufline(bufnr(outbuf), 1, [])
            setbufline(bufnr(outbuf), 1, out)
            execute 'buf ' .. outbuf

            # 刪除所有自定義 ID (> 3) 的高亮匹配
            var matches = getmatches()
            for m in matches
                if m.id > 3
                    matchdelete(m.id)
                endif
            endfor

            var total_lines = 0
            for line_text in out
                total_lines += 1 
                if line_text->match('Error') >= 0
                    matchaddpos('LineNr', [total_lines], 10, -1, { 'bufnr': bufnr(outbuf) })
                endif
            endfor
            setlocal hlsearch
            search('File .\+, line \d\+', 'wb')
            nmap <buffer> ]] <cmd>/File .\+, line \d\+<cr>
            nmap <buffer> [[ <cmd>?File .\+, line \d\+<cr>
        endif
        notify_popup_id->popup_close() 
    catch 
        echom 'AsynRunCallback發生錯誤：'
        echom v:throwpoint
        echom v:errmsg
    endtry
enddef
