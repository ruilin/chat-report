# Google Play 上架清单 — Chat Report

生成日期：2026-08-10 · 版本 1.1.0 (versionCode 3)

---

## 🔴 上架前必须解决（阻塞项）

### 1. API key 硬编码在客户端 —— 安全阻塞

`lib/config/api_key.dart` 里的 z.ai key 会被编译进 AAB。**任何人下载后反编译即可提取**，
然后用你的账号跑他自己的请求，账单算你的。R8 混淆**不能**保护字符串常量。

必须在公开发布前改成：客户端 → 你的后端 → z.ai，key 只存在于服务端。

> 内部测试轨道（Internal testing，最多 100 名指定测试者）可以先用当前构建，
> 风险可控；**封闭测试以上的任何轨道都不要用**。

### 2. 隐私政策需要公网 URL（中英各一份）

`PRIVACY_POLICY_EN.md` / `PRIVACY_POLICY_ZH.md` 已写好，但必须部署到可访问的 URL
才能填进 Play Console —— **该字段按语言分别填写**。
同时替换占位符：英文版的 `[CONTACT EMAIL]` `[COMPANY / DEVELOPER NAME]`、
中文版的 `[联系邮箱]` `[公司 / 开发者名称]`。

### 3. 开发者账号与身份验证

- Google Play 开发者账号一次性 $25
- 个人开发者需完成身份验证，并**提供公开显示的联系地址**
- 2023 年 11 月后创建的个人账号：封闭测试需 **20 名测试者持续 14 天**才能申请转生产
  （组织账号无此要求）—— 这会显著影响你的上线时间表，请提前拉人

---

## 🟡 强烈建议（影响过审或口碑）

| 项 | 说明 |
|---|---|
| Release 版完整链路未验证 | 本机手机直连 z.ai 不通，release 不允许明文回环代理，因此**分析链路只在 debug 版验证过**。请在网络正常的设备上跑一遍完整流程再提交 |
| 内容分级问卷 | 关系/情感解读内容，如实勾选。建议 Teen（13+）；不要勾选"约会""露骨内容" |
| 免责声明 | 商店描述已含"不是治疗/诊断"与"与任何消息服务无关联"两句，**请勿删除** |
| 免费层成本闸门 | 商业分析指出免费快读是最大成本项，上线前加频次限制 |
| 付费墙 / IAP | 当前深度解读全量展示，无法验证转化率。若本次仅测试可先不做 |

---

## ✅ 已完成

| 项 | 状态 |
|---|---|
| applicationId | `com.ruilin.chatreport` ⚠️ **首次上传后永久锁定，现在是最后可改的时机** |
| 应用名 | Chat Report |
| 版本 | 1.1.0 (versionCode 3) —— 由 `tool/release.sh` 自动递增 |
| 界面语言 | English / 简体中文 / 繁體中文，报告正文跟随界面语言；已声明 `localeConfig`（Android 13+ 可按 App 选语言） |
| 签名密钥 | `~/.android-keystores/chat-report-upload.jks`，密码在 `android/key.properties`（已 gitignore） |
| 签名验证 | AAB 已用 release key 签名（SHA256 `7B:07:A2:09:...`），非 debug key |
| AAB | `build/app/outputs/bundle/release/app-release.aab`（50.2MB，含调试符号；Play 剥离后用户下载约 10–15MB） |
| R8 混淆/资源压缩 | 已开启，已加 Flutter 插件 keep 规则，release 真机验证过启动、引导弹层、文件选择器 |
| INTERNET 权限 | 已加入 main manifest（release 不继承 debug manifest） |
| 明文流量 | 仅 debug 允许（开发代理用），release 强制 HTTPS |
| 商店图标 512 | `docs/store/play_icon_512.png`（语言无关，各语言复用） |
| 宣传图 1024×500 | `docs/store/feature_graphic_1024x500.png`（语言无关） |
| 手机截图 ×6 ×3 语言 | `en/` + `zh/` + `zh-Hant/`（1080×1920；各语言真实界面） |
| 商店文案 | `LISTING_EN.md`（默认）+ `LISTING_ZH.md` + `LISTING_ZH_HANT.md` |
| 隐私政策 | 三语 HTML 已提交至 `ruilin/resource` 仓库**待推送**（en / zh / zh-Hant，三页互链） |
| 版本日志 | `RELEASE_NOTES.md`（中英各一版，均在 500 字符上限内） |

---

## 🌐 多语言商店页设置

**默认语言：English (United States)** —— 创建 App 时选定，**之后不可更改**。

新增中文页：Play Console → *Store presence → Store listing → 右上角语言下拉 → Manage translations
→ Add your own translation → 选 **中文 (简体) – zh-CN***，然后逐字段粘贴 `LISTING_ZH.md`。

每种语言需**分别**填写：应用名称、简短说明、完整说明、截图、隐私政策 URL。
图标与宣传图全局共用，只传一次。

| 语言 | 代码 | 文案 | 截图 | 隐私政策 URL |
|---|---|---|---|---|
| English (US) — 默认 | `en-US` | `LISTING_EN.md` | `docs/store/en/` | `…/chatreport-privacy.html` |
| 中文（简体） | `zh-CN` | `LISTING_ZH.md` | `docs/store/zh/` | `…/chatreport-privacy-zh.html` |
| 中文（繁體）台灣 | `zh-TW` | `LISTING_ZH_HANT.md` | `docs/store/zh-Hant/` | `…/chatreport-privacy-zh-hant.html` |
| 中文（香港） | `zh-HK` | `LISTING_ZH_HANT.md`（同一份贴两次） | `docs/store/zh-Hant/` | 同上 |

URL 前缀：`https://ruilin.github.io/resource/`

> ⚠️ **`zh-TW` 与 `zh-HK` 在 Play Console 是两个独立语言，不会互相回退**。只建其中一个，
> 另一地区用户会看到英文页。香港是 WhatsApp 重点市场，建议两个都建。

> 未翻译的语言会自动回退到默认语言（英文），所以不必担心覆盖不到的地区。

> 截图为**各语言真实界面**（非英文界面配译文标题）—— 由 `tool/capture_shots.sh` 逐语言
> 采集原图，再经 `tool/gen_store_assets.py` 加标题带合成。

---

## 🔑 签名密钥 —— 读完再继续

```
密钥库：~/.android-keystores/chat-report-upload.jks
别名：  upload
密码：  见 android/key.properties（storePassword / keyPassword，同一个值）
```

**立刻做两件事：**

1. **备份密钥库文件和密码**到密码管理器 / 加密云盘。它不在 git 里（已 gitignore），
   Mac 挂了就没了。
2. 上传时**启用 Play App Signing**（默认开启）。这样这个 jks 只是"上传密钥"，
   万一丢失可以联系 Google 重置；若不启用则丢失 = 该 App 永远无法更新。

> 若你想用自己设定的密码，现在（首次上传前）重新生成即可：
> `keytool -genkey -v -keystore ~/.android-keystores/chat-report-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
> 然后同步更新 `android/key.properties`，重新跑 `tool/release.sh`。

---

## Data safety 表单填写（Play Console → App content → Data safety）

按当前实现如实填写：

**Does your app collect or share any of the required user data types?** → **Yes**

| 数据类型 | 收集 | 分享 | 目的 | 是否必需 |
|---|---|---|---|---|
| Messages → Other in-app messages | ✅ Collected | ❌ Not shared | App functionality | 用户可选（Optional）—— 仅在用户主动导入时 |

补充勾选：

- **Is this data processed ephemerally?** → **Yes**（分析完即删，不落库）
- **Is data encrypted in transit?** → **Yes**（HTTPS/TLS）
- **Can users request data deletion?** → 说明不保留数据、无账号；报告仅存本机
- 其余类别（位置、联系人、财务、设备 ID、广告 ID 等）→ 全部 **不收集**

> ⚠️ 一旦改成后端代理，如果后端会留日志，上面的 "ephemerally" 就要改口径 —— 表单必须与实际实现一致，Play 会抽查。

---

## 上传流程

**用 `tool/release.sh` 出包，不要直接跑 `flutter build appbundle`** ——
脚本会自动递增 versionCode（Play 拒绝重复的 versionCode），并校验签名主体：

```bash
tool/release.sh            # versionCode +1，versionName 不变（同版本重新打包）
tool/release.sh --patch    # 1.1.0 → 1.1.1
tool/release.sh --minor    # 1.1.0 → 1.2.0
```

脚本依次执行：递增版本 → `flutter analyze` → `flutter test` → 构建 AAB →
校验 versionCode/签名/体积，任一步失败即中止。产物在
`build/app/outputs/bundle/release/app-release.aab`。

Play Console 操作顺序：

1. Create app → 填名称/语言/免费或付费
2. **Internal testing** → Create new release → 上传 `app-release.aab`
3. App content：隐私政策 URL、Data safety、内容分级、目标受众、广告声明（选"无广告"）
4. Store listing：按语言粘贴 `LISTING_*.md` 的文案 + 上传对应语言的截图
5. 内部测试跑通后再逐步推 Closed → Open → Production

## 版本号规则

`pubspec.yaml` 的 `version: 1.1.0+3` = `versionName+versionCode`：

| | 含义 | 规则 |
|---|---|---|
| `1.1.0` | versionName | 用户可见，显示在商店页 |
| `3` | versionCode | Play 内部用，**每次上传必须比上次大**，永不回退 |

`tool/release.sh` 每次都会自动 +1 versionCode，所以正常情况下不需要手改。
跳号是无害的（比如构建了没上传），Play 只要求单调递增，不要求连续。

手动查看/修改：

```bash
python3 tool/bump_version.py --show    # 只看当前版本
python3 tool/bump_version.py           # 只 +1 versionCode
python3 tool/bump_version.py --minor   # 1.1.0 → 1.2.0，同时 +1 versionCode
```
