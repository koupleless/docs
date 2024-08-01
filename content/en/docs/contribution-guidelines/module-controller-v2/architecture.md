---
title: ModuleControllerV2 Architecture
date: 2024-07-18T11:24:33+08:00
description: Koupleless ModuleControllerV2 Architecture
weight: 100
---

## Brief Introduction

ModuleControllerV2 is a Kubernetes (K8S) control plane component that leverages the capabilities of Virtual Kubelet to masquerade the **base** as a node within the K8S ecosystem and maps modules to containers in that context. This approach translates module operations into Pod management tasks, thereby enabling serverless module orchestration and scheduling within seconds, along with coordinated base maintenance, by harnessing Kubernetes' inherent Pod lifecycle management, its ability to invoke Pods, and existing controllers such as Deployments, DaemonSets, and Services.

## Background

The original Module Controller (hereafter referred to as MC) was designed based on Kubernetes Operator technology. In this model, the MC logically defined a separate, dedicated control panel for modules, isolating them from the **base**, and treated modules and bases as two distinct categories for individual operations. The **base** maintenance utilized native Kubernetes capabilities, while module management was handled through the operational logic encapsulated by the Operator.

While this architecture provided clear logical distinctions and separation of concerns between modules and bases, it also imposed several limitations:
1. It abstracted modules as a different category of entities compared to the base model, necessitating the MC to not only handle module loading and unloading on the base but also:
   - Sense all existing bases
   - Maintain base status (online state, module loading status, module load, etc.)
   - Maintain module status (online status, etc.)
   - Implement module scheduling logic based on business requirements

   This incurred substantial development and maintenance overhead, especially given the high costs associated with developing Operators for specific scenarios.
2. It hindered horizontal scalability of module capabilities and roles. Unlike common microservices architectures where services share similar roles, the Operator implementation segregated modules and bases at different abstraction levels, preventing interoperability. For instance, Koupleless's proposition that "modules can attach to bases as modules or operate independently as services" would, under the Operator architecture, require devising a new scheduling logic specifically for the latter scenario, involving custom maintenance of dependencies. Each new capability or role would thus entail extensive custom development, escalating costs.
3. It introduced modules as a novel concept, increasing the learning curve for users.

## Architecture

ModuleControllerV2 comprises the Virtual Kubelet Manager control plane component and the Virtual Kubelet component itself. The Virtual Kubelet component forms the core of Module Controller V2, responsible for mapping base services to a node and maintaining the status of Pods running on it. The Manager oversees base-related information, listens for base online/offline messages, monitors base health, and maintains the fundamental runtime environment for the Virtual Kubelet component.

### Virtual Kubelet

Virtual Kubelet (VK) follows the implementation outlined in the [official documentation](https://github.com/virtual-kubelet/virtual-kubelet?tab=readme-ov-file), summarized as a programmable Kubelet. Conceptually, VK acts as an interface defining a set of Kubelet standards. Implementing this interface allows for the creation of a custom Kubelet. Traditional Kubelets running on nodes in Kubernetes are instances of VK implementations, enabling control plane interaction with physical resources.

VK possesses the ability to impersonate a Node. To distinguish these VK-masqueraded Nodes from conventional ones, we refer to them as VNodes.

### Logical Structure

Within Koupleless's architecture, base services run within Pods managed and scheduled by Kubernetes onto actual nodes. Module scheduling needs align with base scheduling, leading to MC V2’s design where VK disguises base services as traditional K8S Nodes (Base VNodes) and modules as Pods (Module VPods). This introduces a secondary logical layer of Kubernetes managing VNodes and VPods.

Consequently, the overarching architecture features two logical Kubernetes clusters:
1. **Base Kubernetes:** Manages real Nodes (VMs/physical machines) and schedules base Pods to these Nodes.
2. **Module Kubernetes:** Maintains virtual VNodes (base Pods) and orchestrates Module VPods to these VNodes.

These "logical Kubernetes" clusters do not necessarily require separate physical deployments; with proper isolation, a single Kubernetes cluster can fulfill both roles.

This abstraction enables leveraging Kubernetes' native scheduling and management capabilities without additional framework development, facilitating:
1. Management of Base VNodes (a non-core function since they are inherently Pods in the underlying Kubernetes, which can maintain their state, but as Nodes, they carry additional metadata).
2. VPod management (core functionality encompassing module operations, scheduling, and lifecycle state maintenance).

### Multi-Tenant VK Architecture (VK-Manager)

Native VKs rely on Kubernetes Informers and ListWatch to monitor pod events on each vnode. However, this implies a separate listening setup per vnode, causing API Server pressure to escalate rapidly with the increase in bases, impeding horizontal scalability.

To address this, Module Controller V2, based on Virtual Kubelet, extracts the ListWatch component, monitoring events of a specific Pod type (in practice, Pods with certain labels), and internally forwards these events to the respective logical VNodes for processing. This reuse of Informer resources necessitates only local context maintenance in VNodes without standalone listeners, alleviating API Server strain.

Under multi-tenancy, Module Controller V2 includes:
1. **Base Registry:** Discovers base services via dedicated operational pipelines and manages VK contexts and data exchange.
2. **VK:** Maintains mappings between specific bases, nodes, and pods, overseeing their states and translating pod operations into corresponding module actions dispatched to the base.

### Sharded Multi-Tenant VK Architecture (Work in Progress)

A single-point Module Controller lacks disaster recovery capabilities and has evident scalability limits. Consequently, Module Controller V2 is being designed to incorporate a more resilient, disaster-tolerant, and horizontally scalable architecture, currently undergoing development and refinement.