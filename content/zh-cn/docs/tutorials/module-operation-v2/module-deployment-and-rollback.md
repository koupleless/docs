---
title: 模块发布
date: 2024-07-19T10:28:32+08:00
description: Koupleless 模块发布
weight: 200
---

注意：当前 ModuleController v2 仅在 K8S 1.24 版本测试过，没有在其它版本测试，ModuleController V2依赖了部分K8S特性，K8S的版本不能低于V1.10。

## 模块发布

模块发布可以参考模块上线中，Deployment的发布方式。

## 模块回滚

由于与原生的Deployment兼容，因此可以采用Deployment的回滚方式实现模块回滚。

查看deployment历史。
```bash
kubectl rollout history deployment yourdeploymentname
```
回滚到指定版本
```bash
kubectl rollout undo deployment yourdeploymentname --to-revision=<TARGET_REVISION>
```

<br/>
<br/>
