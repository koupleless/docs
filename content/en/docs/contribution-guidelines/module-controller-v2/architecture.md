---
title: ModuleControllerV2 Architecture Design
date: 2024-07-18T11:24:33+08:00
description: Coupling-Free ModuleControllerV2 Architecture Design
weight: 100
---

## Introduction
ModuleControllerV2 is a Kubernetes control plane component that leverages Virtual Kubelet capabilities. It masquerades the infrastructure as a node within the Kubernetes ecosystem and maps modules to containers in the Kubernetes context. This approach transforms module operations into pod management tasks, harnessing Kubernetes' built-in pod lifecycle management, orchestration capabilities, and existing controllers such as Deployments, DaemonSets, and Services. Consequently, it enables serverless module provisioning and scheduling within seconds, along with integrated infrastructure orchestration.

## Fundamental Architecture
The current architecture of ModuleControllerV2 encompasses two primary components: the Virtual Kubelet Manager control plane component and the Virtual Kubelet itself. The Virtual Kubelet component serves as the nucleus of ModuleControllerV2, tasked with projecting infrastructure services as a Kubernetes node and maintaining the state of pods running atop it. Meanwhile, the Manager component oversees infrastructure-related information, listens for infrastructure uptime and downtime notifications, monitors the health status of the infrastructure, and ensures the foundational runtime environment for the Virtual Kubelet components is maintained optimally.
<br/>