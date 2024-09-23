---
title: 6.6.2 ModuleControllerV2 调度原理
date: 2024-07-18T11:24:33+08:00
description: Koupleless ModuleControllerV2 架构设计
weight: 910
---

## 简要介绍

Module Controller V2 基于多租户 Virtual Kubelet 能力，实现将基座映射为 K8S 中的 Node，进而通过将 Module 定义为 Pod 实现对 K8S 调度器以及各类控制器的复用，快速搭建模块运维调度能力。

## 基座 <-> VNode 映射

Module Controller V2 通过 Tunnel 实现基座发现，基座发现后将会通过 Virtual Kubelet 将其伪装成 Node，以下称此类伪装的 Node 为 VNode。

基座发现时将读取基座中所配置的 Metadata 和 Network 信息，其中 Metadata 包含 Name 和 Version，Network 包含 IP 和 Hostname 信息。

Metadata 信息将变成 VNode 上的 Label 信息，用于标识基座信息， Network 信息将成为 VNode 的网络配置，未来调度到基座上的 module pod 将继承 VNode 的 IP， 用于配置 Service 等。

一个 VNode 还将包含以下关键信息：
```yaml
apiVersion: v1
kind: Node
metadata:
  labels:
    base.koupleless.io/stack: java # 目前为默认值，未来可能支持更多类型的编程语言
    virtual-kubelet.koupleless.io/component: vnode # vnode标记
    virtual-kubelet.koupleless.io/env: dev # vnode环境标记
    vnode.koupleless.io/name: base # 基座 Metadata 中的 Name 配置
    vnode.koupleless.io/tunnel: mqtt_tunnel_provider # 基座当前归属 tunnel
    vnode.koupleless.io/version: 1.0.0 # 基座版本号
  name: vnode.2ce92dca-032e-4956-bc91-27b43406dad2 # vnode name， 后半部分为基座运维管道所生成的 uuid
spec:
  taints:
  - effect: NoExecute
    key: schedule.koupleless.io/virtual-node # vnode 污点，防止普通 pod 调度
    value: "True"
  - effect: NoExecute
    key: schedule.koupleless.io/node-env # node env 污点，防止非当前环境 pod 调度
    value: dev
status:
  addresses:
  - address: 127.0.0.1
    type: InternalIP
  - address: local
    type: Hostname
```

## 模块 <-> Pod 映射

Module Controller V2 将模块定义为 K8S 体系中的一个 Pod，通过配置 Pod Yaml 实现丰富的调度能力。

一个模块 Pod 的 Yaml 配置如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-single-module-biz1
  labels:
    virtual-kubelet.koupleless.io/component: module # 必要，声明pod的类型，用于module controller管理
spec:
  containers:
    - name: biz1 # 模块名，需与模块 pom 中 artifactId 的配置严格对应
      image: https://serverless-opensource.oss-cn-shanghai.aliyuncs.com/module-packages/stable/biz1-web-single-host-0.0.1-SNAPSHOT-ark-biz.jar # jar包地址，支持本地 file，http/https 链接
      env:
        - name: BIZ_VERSION # 模块版本配置
          value: 0.0.1-SNAPSHOT # 需与 pom 中的 version 配置严格对应
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms: # 基座node选择
          - matchExpressions:
              - key: base.koupleless.io/stack # 未来多语言支持
                operator: In
                values:
                  - java
              - key: vnode.koupleless.io/version # 基座版本筛选
                operator: In
                values:
                  - 1.0.0 # 模块可能只能被调度到一些特殊版本的基座上，如有这种限制，则必须有这个字段。
              - key: vnode.koupleless.io/name # 基座名筛选
                operator: In
                values:
                  - base  # 模块可能只能被调度到一些特定基座上，如有这种限制，则必须有这个字段。
  tolerations:
    - key: "schedule.koupleless.io/virtual-node" # 确保模块能够调度到基座 vnode 上
      operator: "Equal"
      value: "True"
      effect: "NoExecute"
    - key: "schedule.koupleless.io/node-env" # 确保模块能够调度到特定环境的基座node上
      operator: "Equal"
      value: "test"
      effect: "NoExecute"
```

上面的样例只展示了最基本的配置，另外还可以添加任意配置以实现丰富的调度能力，例如在 Module Deployment 发布场景中，可另外添加 Pod AntiAffinity 以防止模块的重复安装。

<br/>
