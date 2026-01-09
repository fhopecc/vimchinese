vim9script

def DeploySnippets()
    w!
    var current_file = expand('%:p')
    if empty(current_file)
        echoerr "錯誤：目前沒有可複製的檔案"
        return
    endif
    # 取得 Vim 使用者目錄下的 plugin 路徑
    # 在 Linux/macOS 通常是 ~/.vim/plugin
    # 在 Windows 通常是 ~/vimfiles/plugin
    var plugin_dir = printf('%s/ultisnips', split(&packpath, ',')[0])
    # 確保 plugin 目錄存在 (若不存在則建立，755 權限)
    if !isdirectory(plugin_dir)
        mkdir(plugin_dir, 'p')
    endif
    # 設定目標檔案路徑 (保留原檔名)
    var dest_file = printf('%s/%s', plugin_dir, expand('%:t'))

    # 使用二進制模式讀取並寫入，以確保檔案完整性
    try
        var content = readfile(current_file, 'B')
        writefile(content, dest_file, 'b')
        call popup_notification('已布署' .. expand('%:t') .. '！', {})
    catch
        echoerr "布署失敗！"
    endtry
enddef
command! DeploySnippets call DeploySnippets()
