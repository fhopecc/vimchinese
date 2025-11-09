vim9script

# 非同步執行程式
def AsyncRun(command: string)
    try
        var expanded_command = command->substitute('%', expand('%')->escape(' \'), 'g')
        var command_list = split(expanded_command)
        var msg: string = $"執行 {expanded_command}"
        var options = {
            'line': 1, 
            'col': (winwidth(0) - msg->strdisplaywidth()) / 2
        }
        var notify_popup_id = msg->popup_create(options)

        var outbuf = $"輸出({expanded_command->substitute('[ \\]', '_', 'g')}"
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
            'out_msg': 1, 
            'err_msg': 1, 
            'exit_cb': (j, e) => AsyncRunCallback(expanded_command, outbuf, notify_popup_id, j, e)
        }
        var job = job_start(command_list, job_options)
        if job->job_status() == 'fail'
            notify_popup_id->popup_close() 
            var err_msg = $"{command}執行失敗！"
            err_msg->popup_notification({})
        endif
    catch
        echom 'AsyncRun發生錯誤：'
        echom v:throwpoint
        echom v:errmsg
    endtry
enddef
command! -nargs=1 AsyncRun call <sid>AsyncRun(<q-args>)

def AsyncRunCallback(command: string, outbuf: string, notify_popup_id: number, job: job, status: number)
    try
        const ls = bufnr(outbuf)->getbufline(1, '$')
        var linecount = bufnr(outbuf)->getbufinfo()[0].linecount
        if len(join(ls, '')) > 0
            var ln: number = 0
            for l in ls
                ln = ln + 1
                iconv(l, 'cp950', 'utf-8')->setbufline(bufnr(outbuf), ln)
            endfor
            execute 'buf ' .. outbuf

            # 刪除所有自定義 ID (> 3) 的高亮匹配
            var matches = getmatches()
            for m in matches
                if m.id > 3
                    matchdelete(m.id)
                endif
            endfor

            var total_lines = 0
            const out = bufnr(outbuf)->getbufline(1, '$')
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
    catch 
        echom 'AsyncRunCallback發生錯誤：'
        echom v:throwpoint
        echom v:errmsg
    finally
        notify_popup_id->popup_close() 
    endtry
enddef
