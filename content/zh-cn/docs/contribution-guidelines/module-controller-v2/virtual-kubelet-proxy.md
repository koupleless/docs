---
title: 6.6.4 Kubelet 代理
date: 2025-08-22T13:00:03+08:00
description: Koupleless Module Controller V2 Kubelet 代理
weight: 930
---

## Kubelet 代理

Kubelet 代理是 Module Controller V2 在 K8s 侧的增强功能，它允许用户通过 ``kubectl`` 工具直接与 Module Controller V2
交互，提供类似于 K8s 原生 Kubelet 的操作体验。

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/kubelet_proxy_sequence_diagram.png"/>
    <p>logs 命令示意图</p>
</div>

## 迭代计划

适配分两阶段进行：

- [x] 使用 proxy 代理方案，为部署在 Pod 基座中的模块提供 logs 能力 -> **已完成**
- [ ] 在保证语义的前提下，通过 tunnel 或 arklet 实现 logs 能力，完成平滑切换 -> **规划中**

## 注意事项

当前仅实现了 logs 能力，且基座必须部署在 K8s 集群中。
