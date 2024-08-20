---
title: 4.4.5 模块本地开发与调试
date: 2024-01-25T10:28:32+08:00
description: Koupleless 模块本地开发与调试
weight: 400
---

## Arkctl 工具安装

Arkctl 模块安装主要提供自动打包和部署能力，包括调用 mvn 命令自动构建模块为 jar 包，调用 arklet 提供的 api 接口进行完成部署。ArkCtl 安装方式可以参照文档：[arkctl 安装](../build_and_deploy.md) 的*本地环境开发验证*小节。

由于 Arkctl 部署其实是调用 API 的方式来完成的，如果不想使用命令行工具，也可以直接使用 Arklet [API 接口](/docs/contribution-guidelines/arklet/architecture) 完成部署操作。当然我们也提供了 telnet 的方式来部署模块，[详细可查看这里](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-telnet/)



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

<div style="text-align: center;">
    <img align="center" width="800" src="/img/arkctl-shell-starter.png">
</div>

### 模块本地调试

#### 模块与基座出于同一个 IDEA 工程中

因为 IDEA 工程里能看到模块代码，模块调试与普通调试没有区别。直接在模块代码里打断点，基座通过 debug 方式启动即可。

<div style="text-align: center;">
    <img align="center" width="900" src="/img/local_debug_base_and_biz_in_same_idea.png">
</div>

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

### 通过 arthas 查看运行时模块状态与信息

#### 获取所有 Biz 信息

```shell
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100
```

如：<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961335431-516ae20b-16c8-48f3-8241-43e414a9f988.png#clientId=ue9573504-0f91-4&from=paste&height=165&id=uf5756bf0&originHeight=330&originWidth=1792&originalType=binary&ratio=2&rotation=0&showTitle=false&size=75826&status=done&style=none&taskId=ue37b95ce-9ff0-4e2b-8c76-c4ac6d3c852&title=&width=896)
<a name="EXU39"></a>

#### 获取特定 Biz 信息

```shell
# 请替换 ${bizName}
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100 | grep ${bizName}  -A 4
```

如：<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961580662-719aa62b-735d-4443-8208-11f16dc74613.png#clientId=ue9573504-0f91-4&from=paste&height=87&id=u99973d00&originHeight=174&originWidth=1970&originalType=binary&ratio=2&rotation=0&showTitle=false&size=46592&status=done&style=none&taskId=ud87e82e9-b349-4c47-b6c2-a441f096de0&title=&width=985)
<a name="aQc2j"></a>

#### 获取特定 BizClassLoader 对应的 Biz 信息

```shell
# 请替换 ${BizClassLoaderHashCode}
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100 | grep ${BizClassLoaderHashCode}  -B 1 -A 3
```

如：<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961557440-865e8681-e5be-4e09-81da-ba1e93d6650f.png#clientId=ue9573504-0f91-4&from=paste&height=92&id=ue02744a4&originHeight=184&originWidth=2086&originalType=binary&ratio=2&rotation=0&showTitle=false&size=51618&status=done&style=none&taskId=u9423d30f-c7f2-45ca-baaa-70f1a358b7d&title=&width=1043)
