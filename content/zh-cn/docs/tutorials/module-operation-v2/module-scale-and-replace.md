---
title: 模块扩缩容与替换
date: 2024-07-19T10:28:32+08:00
description: Koupleless 模块扩缩容与替换
weight: 400
---


## 模块扩缩容
由于ModuleController V2完全复用了K8S的Pod编排方案，扩缩容只发生在ReplicaSet、Deployment、StatefulSet等部署方式上，扩缩容可以按照各自对应的扩缩容方式实现，下面以Deployment为例：
```bash
kubectl scale deployments/yourdeploymentname --namespace=yournamespace --replicas=3
```
其中 _yourdeploymentname_ 替换成您的 Deployment name，_yournamespace_ 替换成您的 namespace，replicas参数设置为希望扩/缩容到的数量。

也可以通过API调用实现扩缩容策略。

## 模块替换

在ModuleController v2中，模块与Container是强绑定的关系，如果想实现模块的替换，需要执行更新逻辑，更新模块所在Pod上的模块对应Image地址。

具体的替换方式随模块部署的方式不同而略有区别，例如，直接更新Pod信息会在原地进行模块的替换，Deployment会执行配置的更新策略（例如滚动更新，先创建新版本的Pod，再删除旧版本的Pod），DaemonSet也会执行配置的更新策略，与Deployment不同，DaemonSet是先删除后创建的逻辑，可能会造成流量损失。

<br/>
<br/>
