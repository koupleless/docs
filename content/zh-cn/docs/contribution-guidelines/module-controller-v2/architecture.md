---
title: 6.6.1 ModuleControllerV2 架构设计
date: 2024-07-18T11:24:33+08:00
description: Koupleless ModuleControllerV2 架构设计
weight: 910
---

## 简要介绍

ModuleControllerV2 是一个 K8S 控制面组件，基于Virtual Kubelet能力，将基座伪装成K8S体系中的node，将模块映射为K8S体系中的Container，从而将模块运维映射成为Pod的运维，基于K8S包含的Pod生命周期管、调取，以及基于Pod的Deployment、DaemonSet、Service等现有控制器，实现了 Serverless 模块的秒级运维调度，以及与基座的联动运维能力。

## 背景

原有的Module Controller（以下称之为MC）基于K8S Operator技术设计。
在这种模式下，原有的MC从逻辑上是定义了另外一套与基座隔离的，专用的模块控制面板，从逻辑上将模块与基座分成了两个相对独立的类别进行分别的运维，即基座的运维通过K8S的原生能力进行运维，模块运维通过Operator封装的运维逻辑进行运维。

这样的构建方法在逻辑上很清晰，对模块和基座的概念进行了区分，但是也带来了一定的局限性：
1. 首先由于逻辑上模块被抽象成了不同于基座模型的另一类代码，因此原来的MC除了要实现在基座上进行模块的加载、卸载以外，还需要：
   1. 感知当前所有的基座
   2. 维护基座状态（基座在线状态、模块加载情况、模块负载等）
   3. 维护模块状态（模块在线状态等）
   4. 根据业务需要实现相应的模块调度逻辑
   
    这将为带来巨大的开发与维护成本。（单场景的Operator开发成本高）

2. 模块能力与角色横向扩展困难。这种实现方式从逻辑上是与原先比较常见的微服务架构是相互不兼容的，微服务架构不同微服务之间的角色是相同的，然而在Operator的实现中，模块与基座的抽象层级是不同的，两者不能互通。
   以Koupleless所提出的：“模块既可以以模块的形式attach到基座上，也可以以服务的形式单独运行”为例，在Operator架构下，如果想实现后者的能力，就需要单独为这种需求定制一套全新的调度逻辑，至少需要定制维护特定的依赖资源，才能够实现，这样未来每需要一种新的能力/角色，都需要定制开发大量的代码，开发维护成本很高。（横向扩展的开发成本高）

3. 在这种架构下，模块成为了一种全新的概念，从产品的角度，会增大使用者的学习成本。

## 架构

ModuleControllerV2 目前包含Virtual Kubelet Manager控制面组件和Virtual Kubelet组件。Virtuakl Kubelet组件是Module Controller V2的核心，负责将基座服务映射成一个node，并对其上的Pod状态进行维护，Manager维护基座相关的信息，监听基座上下线消息，关注基座的存活状态，并维护Virtual Kubelet组件的基本运行环境。

### Virtual Kubelet

Virtual Kubelet参考了[官方文档](https://github.com/virtual-kubelet/virtual-kubelet?tab=readme-ov-file) 的实现

一句话做一个总结就是：VK是一个可编程的Kubelet。

就像在编程语言中的概念，VK是一个Kubelet接口，定义了一组Kubelet的标准，通过对VK这一接口进行实现，我们就可以实现属于我们自己的Kubelet。

K8S中原有的运行在Node上的Kubelet就是对VK的一种实现，通过实现VK中抽象的方法从而使得K8S控制面能够对Node上物理资源的使用与监控。

因此VK具有伪装成为Node的能力，为了区分传统意义上的Node和VK伪装的Node，下面我们将VK伪装的Node称为VNode。

### 逻辑结构

在Koupleless的架构中，基座服务运行在Pod中，这些Pod由K8S进行调度与维护，分配到实际的Node上运行。

对模块调度的需求实际上和基座的调度是一致的，因此在MC V2的设计中，使用VK将基座服务伪装成传统K8S中的Node，变成基座VNode，将模块伪装成Pod， 变成模块VPod，从逻辑上抽象出第二层K8S用于管理VNode和VPod。

综上，在整体架构中会将包含两个逻辑K8S：
1. 基座K8S：维护真实Node（虚拟机/物理机），负责将基座Pod调度到真实Node上
2. 模块K8S：维护虚拟VNode（基座Pod）， 负责将模块VPod调度到虚拟VNode上
   
> 之所以称之为逻辑K8S是因为两个K8S不一定需要是真实的两个分离的K8S，在隔离做好的情况下，可以由同一个K8S完成两部分任务。
   
通过这种抽象，我们就可以在不对框架做额外开发的前提下，复用K8S原生的调度和管理的能力实现：
1. 基座VNode的管理（非核心能力，因为其本身就是底层K8S中的一个Pod，可以由底层K8S来维护状态，但作为Node也将包含更多的信息）
2. VPod的管理（核心能力：包含模块运维，模块调度、模块生命周期状态维护等）

### 多租户VK架构（VK-Manager）

原生的VK基于K8S的Informer机制和ListWatch实现当前vode上pod事件的监听。但是这样也就意味着每一个vnode都需要启动一套监听逻辑，这样，随着基座数量的增加，APIServer的压力会增长的非常快，不利于规模的横向扩展。

为了解决这一问题，Module Controller V2基于Virtual Kubelet，将其中的ListWatch部分抽取出来，通过监听某一类Pod（具体实现中为包含特定label的Pod）的事件，再通过进程内通信的方式将事件转发到逻辑VNode上进行处理的方式实现Informer资源的复用，从而只需要在各VNode中维护本地上下文，而不需要启动单独的监听，降低APIServer的压力。

多租户架构下，Module Controller V2中将包含两个核心模块：

1. 基座注册中心：这一模块通过特定的运维管道进行基座服务的发现，以及VK的上下文维护与数据传递。
2. VK：VK保存着某个具体基座和node，pod之间的映射，实现对node和pod状态的维护以及将pod操作翻译成为对应的模块操作下发至基座。

### 分片多租户VK架构（WIP）

单点的Module Controller很显然缺乏容灾能力，并且单点的上限也很明显，因此Module Controller V2需要一套更加稳定，具备容灾和水平扩展能力的架构。

这一架构正在设计与完善过程中。

<br/>
