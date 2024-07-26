---
title: 模块流量 Service
date: 2024-07-19T10:28:32+08:00
description: Koupleless 模块流量 Service
weight: 800
---

## 模块流量 Service 实现方案

可以通过创建原生Service的方式创建模块的Service，仅当基座与ModuleController部署在同一VPC中时才能够正常提供服务。

由于目前基座与ModuleController并不一定部署在同一个VPC下，两者之间通过MQTT消息队列实现交互。基座node会集成基座所在Pod的IP，模块所在Pod会集成基座node的IP，因此，当基座本身与ModuleController不属于同一个VPC的时候，这里模块的IP实际上是无效的，因此无法对外提供服务。

可能的解决方案是在Service上的LB层做转发，将对应Service的流量转发到基座所在K8S的对应IP的基座服务上。后续将根据实际使用情况对这一问题进行评估与优化。