# Markdown Quick Edit

[English](README.md) · 繁體中文 · [简体中文](README.zh-CN.md)

**打開 Markdown 檔案，快速修改，儲存後繼續工作。**

Markdown Quick Edit 是一款輕巧的 macOS 原生應用程式，適合更新筆記、修正一行文字，或隨手補上一個想法。只有一個簡潔的小視窗、可直接編輯的 Markdown 原始文字，以及「Save」儲存按鈕。以 Swift 和 AppKit 開發，無第三方依賴，不需要帳戶，不發送網絡請求，也沒有常駐背景服務。最初的 Apple Silicon 版本在磁碟上約佔 144 KB；實際大小會隨編譯環境而異。

## 開始使用

需要 macOS 和 Apple Command Line Tools；如尚未安裝，可執行 `xcode-select --install`。編譯目標為 macOS 13 或以上。應用程式已在 Apple Silicon 上測試；編譯腳本亦會在 Intel Mac 上選用 Intel 目標，但該配置尚未測試。

```sh
git clone https://github.com/HyperfocuSam/markdown-quick-edit.git
cd markdown-quick-edit
chmod +x build.sh
./build.sh --install
```

腳本會編譯、進行本機簽署、執行自我測試，再安裝到 `~/Applications/Markdown Quick Edit.app`。若已有安裝版本，腳本會保留原有應用程式。請先結束舊版本，再透過 Finder，以 `dist/` 中的新版本取代它。

如只想編譯而不安裝，執行 `./build.sh`。輸出位置為 `dist/Markdown Quick Edit.app`。本專案以原始碼形式發佈；本機編譯使用 ad-hoc 簽署，並非 Developer ID 簽署，也未經 Apple 公證。

## 直接開啟 Markdown 檔案

在 Finder 選取一個 `.md` 檔案，選擇「取得資訊（Get Info）→ 打開檔案的應用程式（Open with）→ Markdown Quick Edit → 全部更改（Change All…）」。之後按兩下 Markdown 檔案，即可直接編輯。如果 macOS 將其他副檔名視為不同類型，可為該副檔名重複設定。應用程式宣告支援 `.md`、`.markdown` 和 `.mdown`；安裝不會自動更改你的預設編輯器。

亦可先開啟應用程式，選擇「File → Open…」，或將 Markdown 檔案拖放到應用程式上。

## 快速修改的小視窗

| 操作 | 快捷鍵 |
| --- | --- |
| 儲存 | ⌘S，或按 Save |
| 儲存並關閉 | ⌘Return |
| 關閉 | ⌘W |
| 搜尋 | ⌘F |
| 開啟檔案 | ⌘O |
| 新增文件 | ⌘N |
| 另存新檔 | ⇧⌘S |
| 還原／重做 | ⌘Z／⇧⌘Z |

關閉尚未儲存的文件時，會提示你儲存、捨棄變更或取消。最後一個視窗關閉後，應用程式便會結束。編輯器顯示 Markdown 原始文字，不提供排版預覽。應用程式介面目前為英文；使用說明提供三種語言版本。

## 文字處理

支援 UTF-8，以及附有位元組順序標記（BOM）的 UTF-16，包含中文與表情符號。既有的 BOM，以及一致的 LF、CRLF 或 CR 換行格式，都會保留。儲存未修改的文字時，會保留原始位元組。若檔案混用多種換行格式，編輯後儲存會統一為 LF。不支援或無效的編碼會被拒絕開啟，避免無聲地遺失字元。

智慧型引號、智慧型破折號、自動文字取代及拼字修正均已停用。儲存透過 Apple 的 [NSDocument](https://developer.apple.com/documentation/appkit/nsdocument/) 機制明確執行；應用程式沒有啟用直接覆寫原檔的自動儲存功能。

## 編譯與驗證

每次編譯都會執行內建編碼測試。亦可手動再次執行：

```sh
"dist/Markdown Quick Edit.app/Contents/MacOS/MarkdownQuickEdit" --self-test
```

最初版本已透過原生介面測試：開啟檔案、編輯、按鈕及 ⌘S 儲存、在 Finder 按兩下重新開啟、取消未儲存關閉提示，以及儲存並關閉。亦已讀取磁碟檔案，確認 Unicode 內容和 CRLF 換行格式正確保留。外部程式同時修改檔案的衝突、崩潰復原及超大型檔案，尚未作獨立測試。

## 參與及分享

歡迎提交問題、範圍明確的小型 Pull Request，以及文件翻譯。回報問題時，請說明 macOS 版本、硬件架構、重現步驟及預期行為。如問題由特定檔案引起，請使用不含敏感資料的小型範例。

請保持應用程式專注於快速編輯 Markdown；變更行為時，亦請同步更新三份 README。你可以按照 [MIT 授權條款](LICENSE) 使用、修改及分享本專案。

由 [Sam Wong](https://github.com/HyperfocuSam) 建立。
