---
title: 6.6.4 Kubelet Proxy
date: 2025-08-22T13:00:03+08:00
description: Koupleless Module Controller V2 Kubelet Proxy
weight: 930
---

## Kubelet Proxy

The Kubelet Proxy is an enhanced feature of Module Controller V2 on the K8s side.
It allows users to interact directly with Module Controller V2 using the ``kubectl`` tool,
providing an operational experience similar to the native K8s Kubelet.

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/kubelet_proxy_sequence_diagram.png"/>
    <p>Logs command schematic</p>
</div>

## Iteration Plan

The adaptation will be carried out in two phases:

- [x] Use the proxy solution to provide logs capability for modules deployed in the Pod base -> **Completed**
- [ ] Ensure semantic consistency and implement logs capability through tunnel or arklet for smooth transition -> *
  *Planned**

## Notes

Currently, only the logs capability is implemented, and the base must be deployed in the K8s cluster.
