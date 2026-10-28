# Markdown Quick Edit

[English](README.md) · [繁體中文](README.zh-TW.md) · 简体中文

**打开 Markdown 文件，快速修改，保存后继续工作。**

Markdown Quick Edit 是一款轻巧的 macOS 原生应用，适合更新笔记、修正一行文字，或随手补充一个想法。只有一个简洁的小窗口、可直接编辑的 Markdown 源文本，以及“Save”保存按钮。使用 Swift 和 AppKit 开发，无第三方依赖，不需要账户，不发送网络请求，也没有常驻后台服务。最初的 Apple Silicon 版本在磁盘上约占 144 KB；实际大小会随编译环境而变化。

## 开始使用

需要 macOS 和 Apple Command Line Tools；如尚未安装，可运行 `xcode-select --install`。编译目标为 macOS 13 或以上。应用已在 Apple Silicon 上测试；编译脚本也会在 Intel Mac 上选择 Intel 目标，但该配置尚未测试。

```sh
git clone https://github.com/HyperfocuSam/markdown-quick-edit.git
cd markdown-quick-edit
chmod +x build.sh
./build.sh --install
```

脚本会编译、进行本地签名、运行自检，再安装到 `~/Applications/Markdown Quick Edit.app`。如果已有安装版本，脚本会保留原有应用。请先退出旧版本，再通过 Finder，用 `dist/` 中的新版本替换它。

如只想编译而不安装，运行 `./build.sh`。输出位置为 `dist/Markdown Quick Edit.app`。本项目以源代码形式发布；本地编译使用 ad-hoc 签名，并非 Developer ID 签名，也未经 Apple 公证。

## 直接打开 Markdown 文件

在 Finder 中选中一个 `.md` 文件，选择“显示简介（Get Info）→ 打开方式（Open with）→ Markdown Quick Edit → 全部更改（Change All…）”。之后双击 Markdown 文件，即可直接编辑。如果 macOS 将其他扩展名视为不同类型，可为该扩展名重复设置。应用声明支持 `.md`、`.markdown` 和 `.mdown`；安装不会自动更改你的默认编辑器。

也可以先打开应用，选择“File → Open…”，或将 Markdown 文件拖放到应用上。

## 快速修改的小窗口

| 操作 | 快捷键 |
| --- | --- |
| 保存 | ⌘S，或点击 Save |
| 保存并关闭 | ⌘Return |
| 关闭 | ⌘W |
| 查找 | ⌘F |
| 打开文件 | ⌘O |
| 新建文档 | ⌘N |
| 另存为 | ⇧⌘S |
| 撤销／重做 | ⌘Z／⇧⌘Z |

关闭尚未保存的文档时，会提示你保存、放弃更改或取消。最后一个窗口关闭后，应用便会退出。编辑器显示 Markdown 源文本，不提供排版预览。应用界面目前为英文；使用说明提供三种语言版本。

## 文本处理

支持 UTF-8，以及带有字节顺序标记（BOM）的 UTF-16，包括中文和表情符号。已有的 BOM，以及一致的 LF、CRLF 或 CR 换行格式，都会保留。保存未修改的文本时，会保留原始字节。如果文件混用了多种换行格式，编辑后保存会统一为 LF。不支持或无效的编码会被拒绝打开，避免悄悄丢失字符。

智能引号、智能破折号、自动文本替换和拼写纠正均已禁用。保存通过 Apple 的 [NSDocument](https://developer.apple.com/documentation/appkit/nsdocument/) 机制显式执行；应用没有启用直接覆盖原文件的自动保存功能。

## 编译与验证

每次编译都会运行内置编码测试。也可以手动再次运行：

```sh
"dist/Markdown Quick Edit.app/Contents/MacOS/MarkdownQuickEdit" --self-test
```

最初版本已通过原生界面测试：打开文件、编辑、按钮及 ⌘S 保存、在 Finder 中双击重新打开、取消未保存关闭提示，以及保存并关闭。也已读取磁盘文件，确认 Unicode 内容和 CRLF 换行格式正确保留。外部程序同时修改文件的冲突、崩溃恢复及超大文件，尚未进行独立测试。

## 参与和分享

欢迎提交问题、范围明确的小型 Pull Request，以及文档翻译。报告问题时，请说明 macOS 版本、硬件架构、复现步骤及预期行为。如果问题由特定文件引起，请使用不含敏感信息的小型示例。

请保持应用专注于快速编辑 Markdown；更改行为时，也请同步更新三份 README。你可以按照 [MIT 许可证](LICENSE) 使用、修改和分享本项目。

由 [Sam Wong](https://github.com/HyperfocuSam) 创建。
