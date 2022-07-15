def 首碼搜尋命令(char):
    from zhongwen.text import 首碼搜尋表示式
    import vim
    return 首碼搜尋表示式(char, ''.join(vim.current.buffer))

def 設定首碼搜尋映射():
    '語義與原本 fx 相同'
    import vim, string
    def cmdstr(mapmode, direction, char):
        f = 'f' if direction == "/" else "F"
        d = direction
        if mapmode == 'normal':
            return f'nn <expr> {f}{c} "{d}".py3eval("首碼搜尋命令(\'{c}\')")."<CR>:set hls<CR>"'
        if mapmode == 'operator-pending':
            return f'ono <expr> {f}{c} "{d}".py3eval("首碼搜尋命令(\'{c}\')")."\\\\@<=.<CR>:set hls<CR>"'
    for c in string.ascii_lowercase:
        vim.command(cmdstr('normal', "/", c))
        vim.command(cmdstr('operator-pending', "/", c))
        vim.command(cmdstr('normal', "?", c))
        vim.command(cmdstr('operator-pending', "?", c))
