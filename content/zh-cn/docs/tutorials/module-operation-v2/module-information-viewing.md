---
title: 模块信息查看
date: 2024-07-19T10:28:32+08:00
description: Koupleless 模块信息查看
weight: 800
---

## 查看某个基座上所有安装的模块名称和状态

这一需求可以通过查看nodeName为基座对应node的Pod来实现。首先需要了解基座服务与node的对应关系。

在Module Controller V2的设计中，每一个基座会在启动时随机生成一个全局唯一的UUID作为基座服务的标识，对应的node的Name则将包含这一ID。

除此之外，基座服务的IP与node的IP是一一对应的，也可以通过IP来筛选对应的基座Node。

因此，可以通过以下命令查看某个基座上安装的所有Pod（模块），和对应的状态。

```bash
kubectl get pod -n <namespace> --field-selector status.podIP=<baseIP>
```
或
```bash
kubectl get pod -n <namespace> --field-selector spec.nodeName=virtual-node-<baseUUID>
```