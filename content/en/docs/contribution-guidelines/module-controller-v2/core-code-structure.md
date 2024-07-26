---
title: Core Code Structure
date: 2024-07-18T11:24:33+08:00
description: Core Code Structure of Koupleless ModuleController V2
weight: 400
---

![code](../../../../../static/img/module-controller-v2/module-controller-v2-code.png)

Refer to the diagram above for the code structure. Below is an explanation of each directory:

1. **cmd/main.go**: Acts as the main entry point for the application.
2. **controller**: Houses control plane components, currently including `base_register_controller`, with future Peer Deployment Controllers for Modules also planned to reside here.
   - **base_register_controller**: Manages the lifecycle of the base infrastructure and shared resources for multi-tenant Virtual Kubelets. It listens for lifecycle events of module Pods, implementing logic for module installation, updating, and uninstallation.
3. **samples**: Contains sample YAML files illustrating module deployment methodologies, RBAC configurations, and deployment strategies for the module controller.
4. **tunnel**: Supports operational pipelines for the base infrastructure, currently accommodating MQTT-based pipelines, with plans to support HTTP pipelines in the future. Users can develop custom operational pipelines according to their business needs by implementing the tunnel interface and injecting it during the initialization of `base_register_controller`.
5. **virtual_kubelet**: Incorporates the original Virtual Kubelet logic, dealing with node information maintenance, pod management, among other functionalities.
6. **vnode**: Implements virtual nodes, enabling customization through implementation of `PodProvider` and `NodeProvider`. Currently, it realizes handling logic for base infrastructure nodes.

<br/>
<br/>