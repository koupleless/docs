---
title: 模块本地开发与调试
date: 2024-01-25T10:28:32+08:00
description: Koupleless 模块本地开发与调试
weight: 400
---

## Arkctl 工具安装
Arkctl 模块安装主要提供自动打包和部署能力，自动打包调用 mvn 命令构建模块 jar包，自动部署调用 [arklet](module-debug.md) 提供的 api 接口进行部署。如果不想使用命令行工具，也可以直接使用 arklet 提供的 api 接口发起部署操作。
安装方式可以参照文档：[arkctl 安装](../build_and_deploy.md) 的*本地环境开发验证*小节。

### 本地快速部署

你可以使用 arkctl 工具快速地进行模块的构建和部署，提高本地调试和研发效率。

#### 场景 1：模块 jar 包构建 + 部署到本地运行的基座中。

准备：

1. 在本地启动一个基座。
2. 打开一个模块项目仓库。

执行命令：

```shell
# 需要在仓库的根目录下执行。
# 比如，如果是 maven 项目，需要在根 pom.xml 所在的目录下执行。
arkctl deploy
```

命令执行完成后即部署成功，用户可以进行相关的模块功能调试验证。

#### 场景 2：部署一个本地构建好的 jar 包到本地运行的基座中。

准备：

1. 在本地启动一个基座。
2. 准备一个构建好的 jar 包。

执行命令：

```shell
arkctl deploy /path/to/your/pre/built/bundle-biz.jar
```

命令执行完成后即部署成功，用户可以进行相关的模块功能调试验证。

#### 场景 3: 部署一个本地还未构建的 jar 包到本地运行的基座中。

准备：
1. 在本地启动一个基座

执行命令：
```shell
arkctl deploy ./path/to/your/biz/
```

注意该命令适用于模块可以独立构建的（可以在biz目录里成功执行 mvn package 等命令），则该命令会自动构建该模块，并部署到基座中。
#### 场景 4: 在多模块的 Maven 项目中，在 Root 构建并部署子模块的 jar 包。

准备：

1. 在本地启动一个基座。
2. 打开一个多模块 Maven 项目仓库。

执行命令：

```shell
# 需要在仓库的根目录下执行。
# 比如，如果是 maven 项目，需要在根 pom.xml 所在的目录下执行。
arkctl deploy --sub ./path/to/your/sub/module
```

命令执行完成后即部署成功，用户可以进行相关的模块功能调试验证。

#### 场景 5: 模块 jar 包构建 + 部署到远程运行的 k8s 基座中。

准备:

1. 在远程已经运行起来的基座 pod。
2. 打开一个模块项目仓库。
3. 本地需要有具备 exec 权限的 k8s 证书以及 kubectl 命令行工具。

执行命令：

```shell
# 需要在仓库的根目录下执行。
# 比如，如果是 maven 项目，需要在根 pom.xml 所在的目录下执行。
arkctl deploy --pod {namespace}/{podName}
```

命令执行完成后即部署成功，用户可以进行相关的模块功能调试验证。

#### 场景 6： 如何更快的使用该命令
可以在 IDEA 里新建一个 Shell Script，配置好运行的目录，然后输入 arkctl 相应的命令，如下图即可。

<img src="/img/arkctl-shell-starter.png">

### 模块本地调试

#### 模块与基座出于同一个 IDEA 工程中
因为 IDEA 工程里能看到模块代码，模块调试与普通调试没有区别。直接在模块代码里打断点，基座通过 debug 方式启动即可。

![img.png](/img/local_debug_base_and_biz_in_same_idea.png)

#### 模块与基座在不同 IDEA 工程中
1. 基座启动参数里增加 debug 配置 `-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000`，然后启动基座
2. 模块添加 remote jvm  debug, 设置 host 为 localhost 
`-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000`
3. 模块里打断点
4. 这时候安装模块后就可以调试了

### 查看部署状态

#### 场景 1: 查询当前基座中已经部署的模块。

准备：

1. 在本地启动一个基座。

执行命令：

```shell
arkctl status
```

#### 场景 2: 查询远程 k8s 环境基座中已经部署的模块。

准备：

1. 在远程 k8s 环境启动一个基座。
2. 确保本地有 kube 证书以及有关权限。

执行命令：

```shell
arkctl status --pod {namespace}/{name}
```
