---
title: 6.5.3.2 Koupleless 三方包补丁指南
date: 2024-01-25T10:28:32+08:00
description: Koupleless 三方包补丁指南
weight: 1
---

# Koupleless 三方包补丁原理
Koupleless 是一种多应用的架构，而传统的中间件可能只考虑了一个应用的场景，故在一些行为上无法兼容多应用共存的行为，会发生共享变量污染、classLoader 加载异常、class 判断不符合预期等问题。

由此，在使用 Koupleless 中间件时，我们需要对一些潜在的问题做补丁，**覆盖掉原有中间件的实现**，使开源的中间件也能兼容多应用的模式。

‼️版本要求：koupleless-base-build-plugin 
- jdk8: >= 1.3.3
- jdk17: >= 2.2.8

目前，koupleless 的三方包补丁生效原理为：

![补丁生效原理](./patch-pipeline.jpg)

1. 在基座编译后、打包前， koupleless-base-build-plugin 插件会获取 adapter 配置文件，该文件中描述了 `符合版本范围的中间件依赖` 使用的补丁包，如：

```yaml
version: 1.2.3
adapterMappings:
  - matcher:
      groupId: org.springframework.boot
      artifactId: spring-boot
      versionRange: "[2.5.1,2.7.14]"
    adapter:
      artifactId: koupleless-adapter-spring-boot-logback-2.7.14
      groupId: com.alipay.sofa.koupleless
```
该配置文件的含义为：当基座依赖了 org.springframework.boot:spring-boot 版本范围在 [2.5.1, 2.7.14] 的版本时，则使用 koupleless-adapter-spring-boot-logback-2.7.14 版本为 1.2.3 的补丁包。

2. 获取基座所有使用的依赖，根据 adapter 配置文件过滤出该基座需要使用的所有补丁包；
3. 拉取补丁包，将补丁包中的文件拷贝到基座编译后的 target/classes 目录下。

其中，adapter 配置文件分两种：
- koupleless 管理的配置文件：在打包时，koupleless-base-build-plugin 插件会尝试拉取最新版本的 adapter 配置文件；如果拉取失败，则使用插件默认的配置文件。目前，由 koupleless 管理的开源三方包补丁在 [koupleless-adapter](https://github.com/koupleless/adapter) 仓库中，目前已有 20+ 个补丁包。
- 用户自定义的配置文件：用户可以自行在基座中添加 adapter 配置文件，该配置文件会和 koupleless 管理的通用配置文件同时生效。

# 怎么开发开源三方包的补丁包
👏 欢迎大家一起建设开源三方包补丁：
1. 开发补丁代码文件：复制需要补丁的文件，修改其中的代码，使其符合多应用的场景
2. 确认该补丁生效的依赖包版本范围（即：在该版本范围内，开源包的该代码文件完全相同），如，对于版本范围在：[2.5.1, 2.7.14] 的 org.springframework.boot:spring-boot 的 `org.springframework.boot.logging.logback.LogbackLoggingSystem` 文件都相同。
3. 在 [koupleless-adapter](https://github.com/koupleless/adapter) 仓库中，创建补丁包模块，如：`koupleless-adapter-spring-boot-logback-2.7.14`，在该模块中覆盖写需要补丁的文件，如：`org.springframework.boot.logging.logback.LogbackLoggingSystem`
4. 在 `koupleless-adapter-spring-boot-logback-2.7.14` 根目录下，创建 `conf/adapter-mappings.yaml` 文件，描述该补丁生效的匹配规则，并完成单测。
5. 提交 PR

以 `koupleless-adapter-spring-boot-logback-2.7.14` 补丁包为例，补丁包代码可见 [koupleless-adapter-spring-boot-logback-2.7.14](https://github.com/koupleless/adapter/tree/main/koupleless-adapter-spring-boot-logback-2.7.14)。

# 怎么开发内部二方包的补丁包
1. 开发补丁代码文件：复制需要补丁的文件，修改其中的代码，使其符合多应用的场景
2. 确认该补丁生效的依赖包版本范围（即：在该版本范围内，开源包的该代码文件完全相同），如，对于版本范围在：[2.5.1, 2.7.14] 的 org.springframework.boot:spring-boot 的 `org.springframework.boot.logging.logback.LogbackLoggingSystem` 文件都相同。
3. 开发补丁包模块，如：`koupleless-adapter-xxx-2.1.0`，在该模块中覆盖写需要补丁的文件，如：`com.xxx.YYY`，并打包发布为 jar 包。
4. 在基座的 `conf/ark/adapter-mapping.yaml` 中，添加该补丁包的依赖配置。