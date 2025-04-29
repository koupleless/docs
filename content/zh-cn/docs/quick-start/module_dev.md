---
title: 2.1 模块开发
date: 2024-01-25T10:28:32+08:00
description: Koupleless 快速开始
weight: 210
---

本上手指南主要介绍动态合并部署模式，用于省资源与提高研发效率。如果你只是想节省资源，可以使用[静态合并部署](/docs/tutorials/module-development/static-merge-deployment/)。本上手指南使用官网的 [tomacat sample](https://github.com/koupleless/samples/tree/main/springboot-samples/web/tomcat) 进行演示：
1. 

## 预先准备

### 研发工具

- jdk 8
- maven v3.9.0+
- git 
- [arkctl](https://github.com/koupleless/arkctl/releases) v0.2.1+, 安装方式请查看[这里](/docs/tutorials/module-development/module-dev-arkctl/#arkctl-工具安装)

## 代码下载

```
git clone git@github.com:koupleless/samples.git
```


这个仓库包含了多个框架的 samples，基座和模块都在同一个代码仓库里，如图所示

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/quick-start/tomcat-sample-structure.png" />  
</div>

## 导入 springboot-samples 工程到编译器

1. 导入 springboot-samples，有两种方式导入工程到编译器
- 方式一：导入 samples 到编译器，然后选择 springboot-samples 子目录的 pom 为 maven 工程 
- 方式二：直接导入 springboot-samples 到编译器，此时自动将 springboot-samples 导入为 maven 工程

2. 执行如下命令构建 springboot-samples/web/tomcat 基座与两个模块

```shell
mvn -pl web/tomcat/biz1-web-single-host,web/tomcat/biz2-web-single-host -am clean package -DskipTests
```

如果构建失败，请检查 maven 版本是否 >= 3.9.x（可将公共 bundle 自动 install），构建完之后可以看到模块打出的模块 jar 包

<div style="text-align: center;">  
    <img align="center" width="400px" src="/img/quick-start/ark-jar-list.png" />  
</div>

## 本地环境启动验证
1. 启动基座，按照普通应用启动即可
2. 安装模块1

```shell
arkctl deploy /xxx/path/to/biz1-web-single-host/target/biz1-web-single-host-0.0.1-SNAPSHOT-ark-biz.jar
```
2. 安装模块2

```shell
arkctl deploy /xxx/path/to/biz2-web-single-host/target/biz2-web-single-host-0.0.1-SNAPSHOT-ark-biz.jar
```
3. 测试验证


```shell
curl http://localhost:8080/biz1/
```

执行 curl 命令返回 `hello to /biz1 deploy`

```shell
curl http://localhost:8080/biz2/
```

执行 curl 命令返回 `hello to /biz2 deploy`

## 更多实验请查看 samples 用例

[点击此处](https://github.com/koupleless/samples/tree/master/)
