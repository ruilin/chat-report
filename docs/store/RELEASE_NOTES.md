# Release notes（Play Console「此版本的新变化」）

**上限 500 字符 / 每种语言**，中英需**分别**填写。
位置：Play Console → *Release → 选轨道 → Create new release → Release notes*。

Play 在商店页的「What's new / 新变化」区块展示这段文字，是用户看到的第一句更新说明。

---

## v1.0.0（versionCode 1）— 首个版本

### English (en-US)

```
First release.

Chat Report turns an exported chat history into a real report about your relationship: a warmth score, who starts conversations and who replies faster, a month-by-month emotion curve, your top topics, chat personality tags, and a long-form reading with quotes and dates.

Every statistic is computed on your device. Text sent for AI interpretation is deleted as soon as your report is ready. Shared cards show initials only.
```

### 简体中文 (zh-CN)

```
首个版本。

Chat Report 把一份导出的聊天记录，变成关于这段关系的真报告：关系温度分、谁更主动、谁回得更快、逐月情绪曲线、话题分布、聊天人格标签，以及一篇附原文金句与日期的深度解读。

所有统计都在你的手机上算出；送去做 AI 解读的文本在报告生成后即刻删除；分享卡片只显示姓名首字母。

（应用界面目前为英文。）
```

---

## 写法要点

**首个版本**：介绍这个 App 是什么 + 最有说服力的一两个差异点（此处是"数字可追溯"与"隐私"）。
不要写"首次发布，欢迎使用"这种零信息量的话。

**后续版本**：写用户能感知的变化，不写内部重构。

| 别写 | 改写成 |
|---|---|
| 修复若干已知问题 | 修复了部分手机上导入 .txt 失败的问题 |
| 优化性能 | 分析速度提升约 40%，长对话不再超时 |
| UI 调整 | 报告页新增可点击的月份，查看当月摘要 |
| 升级依赖 / 重构代码 | （用户无感的改动就别写，留空比凑字数好） |

**与商店描述的分工**：描述讲"这个 App 是什么"（长期不变），版本日志讲"这次变了什么"（每次都换）。
别把描述整段复制过来。

**不要在此处出现 "WhatsApp"** —— 与应用名、描述保持一致口径，统一用「exported chat history / 导出的聊天记录」。

---

## 后续版本模板

复制下面这段，替换内容即可：

```
### vX.Y.Z（versionCode N）

**English (en-US)**
```
What's new:
• <用户能感知的变化一>
• <用户能感知的变化二>

<可选：一句话说明为什么这次更新值得装>
```

**简体中文 (zh-CN)**
```
本次更新：
• <用户能感知的变化一>
• <用户能感知的变化二>
```
```

> 提醒：每次上传 versionCode 必须递增（`pubspec.yaml` 里的 `version: 1.0.1+2`，
> `+` 后面就是 versionCode）。

---

## v1.1.0（versionCode 2）— 多语言

### English (en-US)

```
The app now speaks your language.

Chat Report is available in English, Simplified Chinese and Traditional Chinese — and your report is written in the same language as the app, not just the buttons. On Android 13 and later you can pick the language per app in system settings.
```

### 简体中文 (zh-CN)

```
应用现在会说你的语言了。

Chat Report 新增简体中文与繁体中文界面 —— 而且报告正文也会用同一种语言撰写，不只是按钮翻译。Android 13 及以上可在系统设置里为本应用单独选择语言。
```

### 繁體中文 (zh-TW / zh-HK)

```
應用程式現在會說你的語言了。

Chat Report 新增繁體中文與簡體中文介面 —— 而且報告內文也會以同一種語言撰寫，不只是按鈕翻譯。Android 13 以上可在系統設定中為本應用程式單獨選擇語言。
```
