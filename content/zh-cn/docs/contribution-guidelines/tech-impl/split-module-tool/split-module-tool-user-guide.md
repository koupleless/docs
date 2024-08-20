---
title: 6.5.4.1 半自动化拆分工具使用指南
date: 2024-05-13T10:28:32+08:00
weight: 541
---

# 背景
从大单体 SpringBoot 应用中拆出 Koupleless 模块时，用户拆分的学习和试错成本较高。用户需要先从服务入口分析要拆出哪些类至模块，然后根据 Koupleless 模块编码方式改造模块。

为了降低学习和试错成本，KouplelessIDE 插件提供半自动化拆分能力：分析依赖，并自动化修改。

# 快速开始
## 1. 安装插件
从 IDEA 插件市场安装插件 KouplelessIDE：

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/install-idea-plugin.jpg">
</div>

## 2. 配置 IDEA

确保 IDEA -> Preferences -> Builder -> Compiler 的 “User-local build process heap size” 至少为 4096

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/change-heap-size.jpg">
</div>

## 3. 选择模块

步骤一：用 IDEA 打开需要拆分的 SpringBoot 应用，在面板右侧打开 ServerlessSplit

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/open-right-plugin.jpg">
</div>

步骤二：按需选择拆分方式，点击“确认并收起”

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/commit-description.jpg">
</div>

## 4. 依赖分析

在拆分时，需要分析类和Bean之间的依赖。可以通过插件可视化依赖关系，由业务方决定某个类是否要拆分到模块中。

步骤一：点击激活

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/activate.jpg">
</div>

步骤二：拖拽服务入口至模块，支持跨层级拖拽

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/drag.jpg">
</div>

拖拽结果：

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/drag-result.jpg">
</div>

步骤三：拖拽“待分析文件”，点击分析依赖，查看**类/Bean的依赖关系**，如下图：

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/drag-to-analyse.jpg">
</div>

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/click-analyse-dependency.jpg">
</div>

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/analyse-dependency-result.jpg">
</div>

其中，各图标表示：

| 图标    |含义| 用户需要的操作                                                                                                                         |
|-------|----------------|---------------------------------------------------------------------------------------------------------------------------------|
| ![in-module-icon.jpg](/docs/contribution-guidelines/split-module-tool/imgs/in-module-icon.jpg) |已在模块| 无需操作                                                                                                                            |
| ![can-move-to-module.jpg](/docs/contribution-guidelines/split-module-tool/imgs/can-move-to-module.jpg) |可移入模块| 拖拽至模块 ![can-move-to-module-action.jpg](/docs/contribution-guidelines/split-module-tool/imgs/can-move-to-module-action.jpg)      |
| ![recommend-to-analyse-icon.jpg](/docs/contribution-guidelines/split-module-tool/imgs/recommend-to-analyse-icon.jpg) |建议分析被依赖关系| 拖拽至分析  ![recommend-to-analyse-action.jpg](/docs/contribution-guidelines/split-module-tool/imgs/recommend-to-analyse-action.jpg) |
| ![warning-icon.jpg](/docs/contribution-guidelines/split-module-tool/imgs/warning-icon.jpg) |不应该移入模块| 鼠标悬停，查看该类被依赖情况 ![warning-icon.jpg](/docs/contribution-guidelines/split-module-tool/imgs/warning-icon.jpg) |

步骤四：根据提示，通过拖拽，一步步分析，导入需要的模块文件

## 5. 检测

点击初步检测，将提示用户此次拆分可能的问题，以及哪些中间件需要人工。

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/check.jpg">
</div>

打开下侧面板中 KouplelessIDE，查看提示。

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/check-result.jpg">
</div>


## 6. 拆分

点击开始拆分。

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/split.jpg">
</div>

打开下侧面板中 KouplelessIDE，查看提示。

<div style="text-align: center;">
    <img align="center" width="500" src="/docs/contribution-guidelines/split-module-tool/imgs/split-result.jpg">
</div>
