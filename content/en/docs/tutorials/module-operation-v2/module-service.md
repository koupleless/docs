---
title: Module Traffic Service
date: 2024-07-19T10:28:32+08:00
description: Koupleless Module Traffic Service
weight: 800
---
## Implementation Plan for Module Traffic Service
A native Service can be created to establish the Service for modules, which will function correctly only when the **base** and ModuleController are deployed within the same VPC.

Given that the **base** and ModuleController are not necessarily hosted within the same VPC, communication between them is facilitated through an MQTT message queue. The node of the **base** integrates the IP of the Pod where the **base** resides, while Pods hosting modules incorporate the IP of the **base** node. Consequently, when the **base** itself and the ModuleController do not belong to the same VPC, the IP of the module becomes effectively invalid, thereby preventing it from providing services externally.

A potential solution involves implementing traffic forwarding at the Load Balancer (LB) layer of the Service. This would entail redirecting traffic destined for the corresponding Service to the **base** service residing at the IP of the **base** within the K8S cluster where the **base** is hosted. Further assessment and optimization of this issue will be conducted based on actual usage scenarios.