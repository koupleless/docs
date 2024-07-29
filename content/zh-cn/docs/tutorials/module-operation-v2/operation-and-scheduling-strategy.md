---
title: 模块发布运维策略
date: 2024-07-19T10:28:32+08:00
description: Koupleless 模块发布运维策略
weight: 600
---

## 运维策略

为了实现生产环境的无损变更，模块发布运维基于K8S的原生调度能力提供了安全可靠的变更能力。用户可以通过业务需要使用合适的模块Pod部署方式。

## 调度策略

**打散调度**：通过Deployment的原生控制方式实现，可以通过PodAffinity配置实现打散调度。

## 对等和非对等

可以通过选择不同的部署方式实现对等和非对等部署策略。

**对等部署**：

下面提供两种实现方式：

1. 可以通过将模块部署成为DaemonSet实现，这样每当一个基座node上线时，DaemonSet控制器就会自动为其创建模块Pod，实现对等部署。

    > 这里需要注意，DaemonSet的滚动更新是先卸后装，请结合业务实际需求进行选择。

2. 通过Deployment实现，相比DaemonSet，需要额外增加一个组件用于控制模块副本数与基座数量一致（正在建设中，预计下一个版本发布）。支持先装后卸，不会造成中台模式下基座流量损失。
   
    > 注意，Deployment虽然会尽量选择打散部署，但是并不能完全保证打散调度，可能会出现统一模块多次部署到同一个基座上，如果要实现强打散调度，需要在部署模块Deployment中添加Pod反亲和配置，示例如下：
   
```yaml
    apiVersion: apps/v1  # 指定api版本，此值必须在kubectl api-versions中
    kind: Deployment  # 指定创建资源的角色/类型
    metadata:  # 资源的元数据/属性
        name: test-module-deployment  # 资源的名字，在同一个namespace中必须唯一
        namespace: default # 部署在哪个namespace中
        labels:  # 设定资源的标签
            module-controller.koupleless.io/component: module-deployment # 资源类型标记， 用于module controller管理
    spec: # 资源规范字段
        replicas: 1
        revisionHistoryLimit: 3 # 保留历史版本
        selector: # 选择器
            matchLabels: # 匹配标签
                module.koupleless.io/name: biz1
                module.koupleless.io/version: 0.0.1
        strategy: # 策略
            rollingUpdate: # 滚动更新
                maxSurge: 30% # 最大额外可以存在的副本数，可以为百分比，也可以为整数
                maxUnavailable: 30% # 示在更新过程中能够进入不可用状态的 Pod 的最大值，可以为百分比，也可以为整数
            type: RollingUpdate # 滚动更新策略
        template: # 模版
            metadata: # 资源的元数据/属性
                labels: # 设定资源的标签
                    module-controller.koupleless.io/component: module # 必要，声明pod的类型，用于module controller管理
                    module.koupleless.io/name: biz1
                    module.koupleless.io/version: 0.0.1
            spec: # 资源规范字段
                containers:
                - name: biz1
                  image: https://serverless-opensource.oss-cn-shanghai.aliyuncs.com/module-packages/test_modules/biz1-0.0.1-ark-biz.jar
                  env:
                  - name: BIZ_VERSION
                    value: 0.0.1
                affinity:
                  nodeAffinity:
                    requiredDuringSchedulingIgnoredDuringExecution:
                      nodeSelectorTerms: # 基座node选择
                          - matchExpressions:
                            - key: base.koupleless.io/stack
                              operator: In
                              values:
                                  - java
                            - key: base.koupleless.io/version
                              operator: In
                              values:
                                  - 1.0.0 # 模块可能只能被调度到一些特殊版本的 node 上，如有这种限制，则必须有这个字段。
                            - key: base.koupleless.io/name
                              operator: In
                              values:
                              - base  # 模块可能只能被调度到一些特殊版本的 node 上，如有这种限制，则必须有这个字段。
                  podAntiAffinity: # 打散调度核心配置
                      requiredDuringSchedulingIgnoredDuringExecution:
                      - labelSelector:
                          matchLabels:
                              module.koupleless.io/name: biz1 # 与template中的label配置保持一致
                              module.koupleless.io/version: 0.0.1 # 与template中的label配置保持一致
                        topologyKey: topology.kubernetes.io/zone
                tolerations:
                  - key: "schedule.koupleless.io/virtual-node" # 确保模块能够调度到基座node上
                    operator: "Equal"
                    value: "True"
                    effect: "NoExecute"
```

**非对等部署**：可以通过将模块部署成为Deployment/ReplicaSet实现，此时将根据replica设置进行模块的部署。

## 分批更新

分批更新策略需要自行实现相关控制逻辑，ModuleController V2能够提供的能力是，当某个基座上先后安装同名不同版本的模块之后，安装时间较早的模块对应Pod会进入BizDeactivate状态，并进入Failed Phase。可结合这一逻辑实现分批更新逻辑。

<br/>
<br/>
