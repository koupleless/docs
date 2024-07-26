---
title: ModuleControllerV2 架构设计
date: 2024-07-18T11:24:33+08:00
description: Koupleless ModuleControllerV2 架构设计
weight: 100
---

## 介绍
ModuleControllerV2 是一个 K8S 控制面组件，基于Virtual Kubelet能力，将基座伪装成K8S体系中的node，将模块映射为K8S体系中的Container，从而将模块运维映射成为Pod的运维，基于K8S包含的Pod生命周期管、调取，以及基于Pod的Deployment、DaemonSet、Service等现有控制器，实现了 Serverless 模块的秒级运维调度，以及与基座的联动运维能力。

## 基本架构

ModuleControllerV2 目前包含Virtual Kubelet Manager控制面组件和Virtual Kubelet组件。Virtuakl Kubelet组件是Module Controller V2的核心，负责将基座服务映射成一个node，并对其上的Pod状态进行维护，Manager维护基座相关的信息，监听基座上下线消息，关注基座的存活状态，并维护Virtual Kubelet组件的基本运行环境。

<br/>
