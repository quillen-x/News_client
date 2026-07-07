# News Client

新浪微博、百度、知乎三大平台热搜/热榜实时聚合展示客户端。

<img width="960" alt="image" src="https://github.com/Jhinnn/News_client/assets/17973224/b13ef630-7237-466b-aeef-026ee3a887a3">

## 功能特性

- 三栏并排展示微博、知乎、百度实时热榜
- 启动时自动拉取数据，并每 10 分钟自动刷新
- 本地 SQLite 持久化存储，按日期分组展示历史记录
- 点击条目可跳转至对应平台搜索/详情页
- 桌面端（macOS / Windows / Linux）无边框窗口，适合常驻桌面使用

## 技术栈

| 类别 | 技术 |
| --- | --- |
| 框架 | Flutter 3.38.1（Dart 3.x） |
| 网络请求 | Dio |
| 本地存储 | sqflite |
| 桌面窗口 | window_manager |
| 列表分组 | grouped_list |
| 图片加载 | cached_network_image |
| 字体 | Noto Sans SC |

## 项目结构

```
lib/
├── main.dart                 # 应用入口，桌面窗口初始化
├── request/
│   └── api.dart              # 微博 / 知乎 / 百度 API 请求
├── models/                   # 数据模型
├── db/                       # SQLite 数据库与表操作
└── pages/
    ├── home_page.dart        # 主页，定时刷新与数据聚合
    └── news_page/            # 各平台热榜展示页
        ├── weibo_page.dart
        ├── zhihu_page.dart
        └── baidu_page.dart
```

## 快速开始

### 环境要求

- Flutter SDK >= 3.0.0（推荐使用 [FVM](https://fvm.app/) 管理版本）
- 本项目锁定 Flutter **3.38.1**（见 `.fvm/fvm_config.json`）

### 安装与运行

```bash
# 克隆项目
git clone <repo-url>
cd News_client

# 安装依赖（使用 FVM）
fvm flutter pub get

# macOS 桌面端运行
fvm flutter run -d macos

# 其他平台
fvm flutter run -d windows
fvm flutter run -d linux
fvm flutter run -d chrome
```

### 构建发布版

```bash
fvm flutter build macos
fvm flutter build windows
fvm flutter build linux
```

## 数据来源

| 平台 | 接口 |
| --- | --- |
| 微博 | `https://weibo.com/ajax/side/hotSearch` |
| 知乎 | `https://api.zhihu.com/topstory/hot-list` |
| 百度 | `https://top.baidu.com/api/board?platform=wise&tab=realtime` |

> 以上均为第三方公开接口，数据结构可能随时变更。若某平台数据为空，请检查接口是否仍可用。

## 说明

- 数据库文件位于桌面端应用沙盒目录，macOS 路径示例：
  `~/Library/Containers/com.example.dataStatistics/Data/Documents/statistics/hot.db`
- 本项目仅供学习交流，请勿用于商业用途
- 热榜数据版权归各平台所有

## License

MIT
