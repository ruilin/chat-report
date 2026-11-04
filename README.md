# Chat Report

WhatsApp 聊天记录关系分析 App（Flutter）。导入/粘贴聊天记录 → 本地解析统计 → z.ai 两段式 LLM 分析 → 生成关系报告。

- 产品定义：[PRD.md](PRD.md)
- UI 设计稿：见 Claude Artifacts「Chat Report · UI 设计稿」

## 快速开始

```bash
# 1. 生成 API key 文件（已 gitignore；key 以 XOR 混淆存放，交互输入不回显）
dart run tool/obfuscate_key.dart
#    旧的明文 api_key.dart 不带参数运行即自动迁移；只想先编译可 cp api_key.example.dart

# 2. 运行
flutter pub get
flutter run          # Android 设备/模拟器；iOS 需安装 Xcode
```

## 架构

```
lib/
├── config/api_key.dart          # z.ai key（gitignored，见 example）
├── models/
│   ├── chat_data.dart           # 消息、参与者、关系类型
│   ├── metrics.dart             # 本地统计结果
│   └── report.dart              # 报告渲染模型
├── services/
│   ├── whatsapp_parser.dart     # 导出 txt 解析（多 locale 时间戳）
│   ├── metrics_engine.dart      # 纯本地统计（数字不经 LLM）
│   ├── zai_client.dart          # z.ai OpenAI 兼容客户端
│   └── analysis_pipeline.dart   # 两段式管线（见下）
├── screens/                     # home → setup → analyzing → report
├── widgets/charts.dart          # 分段条 / 情绪曲线 / 话题条
└── theme.dart                   # 设计规范落地（rose=你 / blue=对方）
```

### LLM 管线

| 阶段 | 模型 | 职责 |
|---|---|---|
| Stage 1 | `glm-4.5-flash` | 按月分块，并行产出结构化 JSON（情绪分/话题/金句/事件） |
| Stage 2 | `glm-4.5-flash` | 月度 JSON + 本地统计 → 叙事报告 JSON + 付费专题分析（需要时可在 `ZaiClient.reportModel` 改回 `glm-4.6`） |

两阶段都显式 `thinking: disabled`（GLM 默认思考会吃掉 max_tokens）。
量化指标（占比、回复延迟、次数）全部由 `metrics_engine` 本地计算，LLM 只解读数字。

## 测试

```bash
flutter test                        # 单元 + widget 测试（解析器 / 统计引擎）
dart run tool/pipeline_smoke.dart   # 端到端冒烟：真实调 z.ai（少量花费）
```

## 品牌与图标

- **App 名**：`Chat Report`（11 字符，iOS 桌面标签不截断）。
  ⚠️ 上架时 **App 名里不能出现 "WhatsApp"**（商标），只能放副标题/描述。
  建议商店副标题：`Chat analyzer & relationship insights`。
- **图标**：`python3 tool/gen_icon.py` 一键重新生成全部尺寸
  （iOS 15 个 + Android 传统 mipmap 5 个 + Android 自适应前景/背景）。
  设计：深紫渐变底 + 奶白对话气泡 + 玫瑰红情绪曲线，预览见 `docs/icon_preview.png`。
- **待办**：bundle id 仍为 `ai.undertone.undertone`，上架前建议同步改名（改后需卸载重装）。

## 出包（Google Play）

```bash
tool/release.sh          # 自动 +1 versionCode → analyze → test → 构建 AAB → 校验签名
tool/release.sh --minor  # 顺带升 versionName（1.1.0 → 1.2.0）
```

⚠️ **不要直接跑 `flutter build appbundle`** —— versionCode 不会自增，
上传会被 Play 以 "Version code N has already been used" 打回。

## 网络排障（手机连不上 z.ai 时）

`api.z.ai` 是境外域名。如果测试手机的网络直连不通（症状：分析卡住后报
「无法连接 z.ai」），开发期可以借 Mac 的网络：

```bash
python3 tool/dev_proxy.py            # Mac 上跑转发代理（监听 127.0.0.1:8899）
adb reverse tcp:8899 tcp:8899        # 手机 127.0.0.1:8899 → Mac
```

App 的端点列表（`lib/config/api_key.dart` 的 `zaiEndpoints`）默认包含
`http://127.0.0.1:8899/…`，直连失败会自动切换到代理，成功的端点会被记住。
仅 debug 版允许该明文回环流量；正式上线时后端代理会取代这一切。

## 已知边界（MVP）

- 群聊不支持（只取消息量前 2 的参与者）
- 超长月份分块截断至 1.2 万字符（中段抽稀待做）
- 分享卡片、IAP 付费墙未实现（报告深读暂全量展示）
- ⚠️ key 在客户端仅限开发期；上线前必须加薄后端代理，key 不下发
