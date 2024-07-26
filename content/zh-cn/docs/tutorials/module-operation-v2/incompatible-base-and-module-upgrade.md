---
title: 基座和模块不兼容发布
date: 2024-07-19T10:28:32+08:00
description: Koupleless 基座和模块不兼容发布
weight: 300
---

## 步骤  1

首先部署一个module的Deployment，其中Container指定为最新版本的模块代码包地址，nodeAffinity指定新版本基座的名称和版本信息。

此时，这一Deployment会创建出对应的Pod，但是由于还没有新版本的基座创建，因此不会被调度。

## 步骤  2

更新基座Deployment，发布新版本镜像，此时会触发基座的替换和重启，基座启动时会告知ModuleController V2控制器，会创建对应版本的node。

## 步骤  3

对应版本的基座node创建之后，K8S调度器会自动触发调度，将步骤1中创建的模块Pod调度到基座node上，进行新版本的模块安装，从而实现同时发布。

<br/>
<br/>
