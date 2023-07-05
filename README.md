% VIM 中文插件

VIM 中文插件係為輔助編輯中文文檔增加之功能。

# 指令設計原則

指令(command)係一組有限按鍵，引發特定功能。

## 指令擴充功能應與相容於舊有功能接近

為了能讓原粉兒(vimer)快速上手，
指令鍵相容舊有功能接近
如 K 命令係查詢光標之關鍵字之說明，
在中文模組則擴充成以 Google 查詢光標中文字義。

## 指令不要超過 3 個按鍵

依個人經驗，指令超過3個按鍵便不好記憶及操作，
所以原則指令不要超過 3 個按鍵。

## 指令有2個字以上最好其字母能由不同手操作

例如，gc鍵都是由左手輸入，不如;3先由右手按;再由左手按3好用。

## 重覆指令

要能支援重覆指令，即按下 . 能重覆上個指令。

# 字型

微軟雅黑+Consolas。

# 編輯

編輯物件由小自大列舉為字、詞、段及文。

## 切換字

原 ~ 鍵功能係對游標處字母進行大小寫切換，
中文套件依據各語文系統特性擴充，
如對中文字進行簡繁切換、
希臘字母參照拉丁字母進行大小寫切換、
日文假名進行平假名及片假名切換。

    a  <-> A
    σ  <-> Σ
    简 <-> 簡

## 數字遞增遞減

如游標處為數字，則可對其遞增遞減，
對應鍵如次：

鍵     功能
------ --------
ctrl-a 遞增數字
ctrl-x 遞減數字

## 重覆

每個編輯命令都可以重覆及復原，
重覆係使用.，復原係使用u，取消復原則使用 :re[do]。

指令       說明
---- --------------------
.    重覆上個編輯指令。
:&   重覆上個取代指令。

# 移動

## 搜尋詞

按*鍵以搜尋詞，即搜尋下個游標處之詞，
惟其斷詞僅針對英文或拉丁文自然以空格為詞界。

本套件將擴充能搜尋游標處之中文詞。

## 搜尋字

按f鍵再按字符鍵就會移動到下個按鍵表示的字符，
相較/搜尋係鍵入搜尋條件後，再按回車(Enter)執行，
減少一個按鍵動作，操作更簡捷。

本套件擴充搜尋字能併同搜尋中文字其倉頡碼首碼為a之字，
舉如按 fa 會移動至下個字母a，
或倉頡碼首碼為a之中文字，如旦(am)、是(amyo)也。

## 漸增搜尋

漸增搜尋最佳套件是 Leaderf。

# 查詢

## 查詢詞

拉丁文字一般以空白及標點為詞界，
對詞的操作主要仍為移動、編輯及查詢。

但對中文不以空白為明確詞界。

K 指令會查詢光標指示詞在目前檔案類型的說明，
如是 Python 檔案類型：

    import pandas
              ^
光標在 d 字母位置所在的詞為 pandas，
按下 K 即查詢 pandas 的模組說明。
對 K 預設查不到說明的詞，就自動用 google 查詢。

實作上先使用 jedi 查詢名稱之 docstring，
如找到就顯示，找不到就 google 該名稱 。

對中文使用者而言，這沒有作用，
因為中文不像英文自然以空白為詞的邊界，
所以中文詞必須依賴使用者明確選取，
通常查詢詞的說明最好的方法便是 google 這個詞，
我便定義 `{Visual}K` 為 google 選取的詞。 

## 查詢選取範圍

# 輸入

## 自動完成

自動完成是根據光標已輸入的片段自動完成輸入，
可以加快輸入並減少錯誤，通常分成展開片段及顯示自動完成建議，
前者是直接在輸入符合片段條件時展開，
後者係就已輸入的片段顯示自動完成建議，由使用者篩選使用之建議。

展開片段目前我使用的是 UlitiSnips 套件，
主要係能以我較熟悉的Python語言定義片段。

VIM 內建許多自動完成建議功能，
有依照關鍵字、檔案路徑、程式語言自動完成函數，
分別使用 i_C-x_C-n、i_C-x_C-f 及 i_C-x_C-o 等按鍵來觸發，
因為我不想記憶那麼多鍵，所以撰寫一個套件整合上述功能，
在輸入中按下 Tab 便會依據前後文判斷要使用那種自動完成，
如觸發自動完成建議顯示，則再按 Tab 鍵會選取下個建議，
Shift-Tab 鍵則選取上個建議。
如判斷程序如次：

1. 行前面皆是空白縮進4格。

2. 已輸入者是否可展開片段，如可即展開。

3. 已輸入者是否有程式語言自動完成函數，如有即顯示自動完成建議。

4. 已輸入者是否符合檔案路徑，如有即顯示檔案路徑自動完成建議。

5. 觸發顯示關鍵字自動完成建議。

## 括號自動完成

括號自動完成程序為輸入開括號，自動插入閉括號，
並將光標移至括號間，等待輸入參數；
但許多情形係輸入空括號表達函數呼叫如次：

    execute()

這時如果將光標移至括號間，還要多出動作將光標移至閉括號後，
不如就設計輸入閉括號，自動插入開括號，光標仍在閉括號後。

## 編輯

    <編輯> := <操作>(<對象>|<移動>)

vim指令是一個精簡表達文字編輯的語言，
每句編輯指令有兩個要素，操作及對象，
如刪除一個詞之編輯命令diw，
其中d表示刪除，iw表示對象為游標所在的詞。

## 操作

   <操作> := [dc]|gc|yS

常見的操作如：d(刪除)、c(修改)、gc(註解或反註解)、yS(加入指定括號)

## 文字對象

    <對象> := i[wpt"]

i開頭的對像表示其光標指示文字對象的裡面，
常見如：iw(詞內)、ip(段內)、i"(引號內)、it(html 標內)

## 移動

w => 向前至詞尾
f[字] => 前進到(forward)下個字
t[字] => 直到(till)下個字前
/[詞] => 找下個詞

## 文字對象與移動異同

文字對象係於光標前後都可選取，但是移動僅依光標特定方向移動。

## 儘可能使用文字對象而非移動範圍

以 diw 取代 dw會以一個詞為單元來編輯。

# 文件結構

使用 tagbar 插件看文件結構。

# 參考書籍

Learning Vim as a Language. Ben McCormick.
[vi 指令完整清單]https://hea-www.harvard.edu/~fine/Tech/vi.html
