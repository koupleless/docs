---
title: 6.6.1 ModuleControllerV2 Architecture
date: 2024-07-18T11:24:33+08:00
description: Koupleless ModuleControllerV2 Architecture
weight: 910
---

## Brief Introduction

ModuleControllerV2 is a K8S control plane component based on the capabilities of Virtual Kubelet. It disguises the base as a node in the K8S system and maps the Module as a Container in the K8S system, thereby mapping Module operations to Pod operations. Utilizing K8S's Pod lifecycle management, scheduling, and existing controllers like Deployment, DaemonSet, and Service, it achieves second-level Serverless Module operation scheduling and base interaction capabilities.

## Background

The original Module Controller (hereafter referred to as MC) was designed based on K8S Operator technology.

In this mode, the original MC logically defines a separate Module control panel isolated from the base, handling operations for the base using K8S's native capabilities and Module operations through Operator-encapsulated logic.

While this method logically distinguishes between Module and base concepts, it also presents certain limitations:

1. Modules are abstracted differently from the base model. Therefore, the original MC not only needs to load/unload Modules on the base but also:
   1. Be aware of all current bases
   2. Maintain base status (online status, Module loading, Module load, etc.)
   3. Maintain Module status (online status, etc.)
   4. Implement appropriate Module scheduling logic as required

   This results in high development and maintenance costs. (High cost for Operator development per scenario)

2. Horizontal expansion of Module capabilities and roles is difficult. This implementation method is logically incompatible with traditional microservices architectures, where roles among services are similar. However, in the Operator implementation, Module and base abstraction levels differ, hindering interoperability.
   For example, in Koupleless's proposal: "Modules can either attach to the base or run independently as services." In the Operator architecture, achieving the latter requires custom scheduling logic and specific resource maintenance, leading to high development and maintenance costs for each new capability/role.

3. In this architecture, Module becomes a new concept, increasing learning costs for users from a product perspective.

## Architecture

ModuleControllerV2 currently includes the Virtual Kubelet Manager control plane component and the Virtual Kubelet component. The Virtual Kubelet component is the core of Module Controller V2, responsible for mapping base services as nodes and maintaining Pod states on them. The Manager maintains base-related information, monitors base online/offline status, and maintains the basic runtime environment for the Virtual Kubelet component.

### Virtual Kubelet

Virtual Kubelet is implemented with reference to the [official documentation](https://github.com/virtual-kubelet/virtual-kubelet?tab=readme-ov-file).

In summary, VK is a programmable Kubelet.

Just like in programming languages, VK is a Kubelet interface that defines a set of Kubelet standards. By implementing this VK interface, we can create our own Kubelet.

The Kubelet originally running on nodes in K8S is an implementation of VK, enabling K8S control plane to utilize and monitor physical resources on nodes by implementing abstract methods in VK.

Therefore, VK has the capability to masquerade as a Node. To distinguish between traditional Nodes and VK-masqueraded Nodes, we call VK-masqueraded Nodes as VNodes.

### Logical Structure

In the Koupleless architecture, base services run in Pods, scheduled and maintained by K8S, and run on actual nodes.

Module scheduling needs align with base scheduling. Thus, in MC V2 design, VK is used to disguise base services as traditional K8S Nodes, becoming base VNodes, while Modules are disguised as Pods, becoming module VPods. This logically abstracts a second layer of K8S to manage VNodes and VPods.

In summary, the overall architecture includes two logical K8S:
1. Base K8S: Maintains real Nodes (virtual/physical machines), responsible for scheduling base Pods to real Nodes.
2. Module K8S: Maintains virtual VNodes (base Pods), responsible for scheduling module VPods to virtual VNodes.

> These are called logical K8S because they do not necessarily need to be two separate K8S. With good isolation, the same K8S can perform both tasks.

This abstraction allows utilizing K8S's native scheduling and management capabilities without extra framework development, achieving:
1. Management of base VNodes (not a core capability since they are already Pods in the underlying K8S but contain more information as Nodes)
2. Management of VPods (core capability: including Module operations, Module scheduling, Module lifecycle status maintenance, etc.)

### Multi-Tenant VK Architecture

Native VK uses K8S's Informer mechanism and ListWatch to monitor pod events on the current VNode. This means each VNode requires its own monitoring logic. As the number of bases increases, API Server pressure grows rapidly, hindering horizontal scaling.

To solve this, Module Controller V2 extracts the ListWatch part of Virtual Kubelet, monitors events of specific Pods (those with certain labels in implementation), and forwards them to logical VNodes through in-process communication, reusing Informer resources. This way, each VNode only maintains local context without separate monitoring, reducing API Server pressure.

In the multi-tenant architecture, Module Controller V2 includes two core Modules:

1. Base Registration Center: Discovers base services via a specific operations pipeline and maintains VK context and data transmission.
2. VK: Maintains mappings between a specific base and node/pod, maintains node/pod states, and translates pod operations into corresponding Module operations for the base.

### Sharded Architecture

A single Module Controller lacks disaster recovery capabilities and has an obvious upper limit. Thus, Module Controller V2 requires a more stable architecture with disaster recovery and horizontal scaling capabilities.

In Module operations, the core concern is the stability of scheduling capabilities. Under the current Module Controller architecture, scheduling stability consists of two parts:

1. Stability of the dependent K8S
2. Base stability

The first point cannot be guaranteed at the Module Controller layer, so high availability of the Module Controller focuses only on base-level stability.

Additionally, Module Controller's load mainly involves monitoring and processing various Pod events, related to the number of Pods and bases under control. Due to K8S API Server's rate limits on a single client, a single Module Controller instance has an upper limit on simultaneous event processing, necessitating load sharding capabilities at the Module Controller level.

Thus, the sharded architecture of Module Controller addresses two core issues:

1. High availability of the base
2. Load balancing of Pod events

In the Module Controller scenario, Pod events are strongly bound to the base, making load balancing of Pod events equivalent to balancing the managed base.

To address the above issues, Module Controller builds native sharding capability on multi-tenant Virtual Kubelet. The logic is as follows:

1. Each Module Controller instance listens to the online information of all bases.
2. Upon detecting a base going online, each Module Controller creates corresponding VNode data and attempts to create a VNode node lease.
3. Due to naming conflicts of resources in K8S, only one Module Controller instance can successfully create a Lease, making its VNode the primary instance, while others become replicas, monitoring the Lease object and attempting to regain the primary role, **achieving VNode high availability**.
4. Once VNode successfully starts, it listens to Pods scheduled on it for interaction, while unsuccessful VNodes ignore these events, **achieving load sharding for the Module Controller**.

Thus, the architecture forms: multiple Module Controllers shard VNode loads based on Lease, and multiple Module Controllers achieve VNode high availability through multiple VNode data.

Furthermore, we aim for load balancing among Module Controllers, with approximately balanced numbers of bases for each.

To facilitate open-source users and reduce learning costs, we implemented a self-balancing capability based on K8S without introducing additional components:

1. Each Module Controller instance maintains its current workload, calculated as (number of VNodes currently managed / total number of VNodes). For example, if a Module Controller manages 3 VNodes out of 10, the actual workload is 3/10 = 0.3.
2. Upon starting, Module Controllers can specify a maximum workload level. The workload is divided into segments based on this parameter. For example, if the maximum workload level is set to 10, each workload level contains 1/10 of the range, i.e., workload 0-0.1 is defined as workload=0, 0.1-0.2 as workload=1, and so on.
3. In a sharded cluster configuration, before attempting to create a Lease, a Module Controller calculates its current workload level and waits according to the level. In this scenario, low workload Module Controllers attempt creation earlier, increasing success probability, achieving load balancing.

The process relies on K8S event broadcast mechanisms, with additional considerations depending on the operations pipeline selected during initial base onboarding:

1. MQTT Operations Pipeline: Since MQTT inherently supports broadcasting, all Module Controller instances receive MQTT onboarding messages without additional configuration.
2. HTTP Operations Pipeline: Due to HTTP's nature, a base only interacts with a specific Module Controller instance during onboarding, requiring other capabilities to achieve initial load balancing. In actual deployment, multiple Module Controllers are served through a proxy (K8S Service/Nginx, etc.), allowing load balancing strategies to be configured at the proxy layer for initial onboarding balance. 