---
title: 核心代码结构
date: 2024-07-18T11:24:33+08:00
description: Koupleless ModuleController V2 核心代码结构
weight: 400
---

![code](../../../../../static/img/module-controller-v2/module-controller-v2-code.png)

代码结构参考上图，下面将对每个目录进行讲解：
1. cmd/main.go：为程序总入口
2. controller：存放控制面组件，目前包含base_register_controller，未来的Module对等部署Controller也将放在此目录下。
   1. base_register_controller: 包含基座生命周期管理以及多租户Virtual Kubelet的共享资源管理，监听模块Pod的生命周期事件，实现模块安装，更新，卸载等逻辑。
3. samples：存放样例Yaml，包含模块发布方式，rabc配置，module controller部署方式等
4. tunnel：基座运维管道支持，目前对Mqtt运维管道进行了支持，未来会对Http运维管道进行支持，用户也可以根据自己的业务需要开发相应的运维管道，需要对tunnel接口进行实现，并在base_register_controller初始化时进行注入即可。
5. virtual_kubelet：原Virtual Kubelet逻辑，包含node信息维护，pod信息维护等逻辑。
6. vnode：virtual node实现，可以通过实现PodProvider和NodeProvider实现自定义的node，目前对基座node处理逻辑进行了实现。

<br/>
<br/>
