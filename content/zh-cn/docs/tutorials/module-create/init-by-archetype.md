---
title: 4.2.2 使用 maven archtype 脚手架自动生成
date: 2024-01-25T10:28:32+08:00
weight: 300
---

模块的创建有四种方式，本文介绍第三种方式：
1. [大应用拆出多个模块](/docs/contribution-guidelines/split-module-tool/split-module-tool-intro/)
2. [存量应用改造成一个模块](/docs/tutorials/module-create/springboot-and-sofaboot/)
3. **[直接脚手架创建模块](/docs/tutorials/module-create/init-by-archetype/)**
4. [普通代码片段改造成一个模块](/docs/tutorials/module-create/main-biz/)

从脚手架里创建模块的方式比较简单，只需要在 idea 里创建工程里传入脚手架的 maven 坐标即可。

<div style="text-align: center;">
    <img align="center" width="300px" src="/docs/tutorials/imgs/created-by-archetype.png" />
</div>

```xml
<dependency>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-common-module-archetype</artifactId>
    <version>{koupleless.runtime.version}</version>
</dependency>
```

该脚手架创建出来的模块，已经集成模块打包插件和自动瘦身配置，可以直接打包成模块安装在基座上，或者本地直接独立启动。

