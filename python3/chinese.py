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

def 安裝雅黑混合字型():
    import win32gui
    def callback(font, tm, fonttype, names):
        names.append(font.lfFaceName)
        return True
    fontnames = []
    hdc = win32gui.GetDC(None)
    win32gui.EnumFontFamilies(hdc, None, callback, fontnames)
    win32gui.ReleaseDC(hdc, None)
    字型已安裝 = "Microsoft YaHei Mono" in fontnames

    if 字型已安裝:
        print('雅黑混合字型已安裝！')
        return 
    from pathlib import Path
    font = Path(__file__).parent.parent / 'font' / 'MSYHMONO.ttf'
    cmd = f'''$FONTS = 0x14
$objShell = New-Object -ComObject Shell.Application
$objFolder = $objShell.Namespace($FONTS)
$objFolder.CopyHere("{font}")
'''
    import subprocess
    result = subprocess.run(["powershell", "-Command", cmd], capture_output=True)
    if result.returncode !=0:
        raise WindowsError(f'執行 powershell 發生錯誤：{result}；指令{cmd}')
    print(f'安裝雅黑混合字型完成!')
if __name__ == '__main__':
    安裝雅黑混合字型()
