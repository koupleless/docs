---
title: 6.6.2 ModuleControllerV2 Scheduling Principles
date: 2024-07-18T11:24:33+08:00
description: Koupleless ModuleControllerV2 Architecture Design
weight: 910
---

## Brief Introduction

Module Controller V2 leverages the multi-tenant capabilities of Virtual Kubelet to map bases as Nodes in K8S. By defining modules as Pods, it reuses the K8S scheduler and various controllers to quickly build module operation and scheduling capabilities.

## Base <-> VNode Mapping

Module Controller V2 implements base discovery through Tunnel, mapping it as a Node via Virtual Kubelet. Such Nodes are referred to as VNodes.

Upon base discovery, the configured Metadata and Network information are read. Metadata includes Name and Version, while Network includes IP and Hostname.

Metadata becomes Label information on the VNode to identify base details. Network information becomes the VNode's network configuration. Future module pods scheduled onto the base will inherit the VNode's IP for configuring Services, etc.

A VNode will also contain the following key information:
```yaml
apiVersion: v1
kind: Node
metadata:
  labels:
    base.koupleless.io/stack: java # Currently default, future support for more languages
    virtual-kubelet.koupleless.io/component: vnode # vnode marker
    virtual-kubelet.koupleless.io/env: dev # vnode environment marker
    vnode.koupleless.io/name: base # Name from base Metadata configuration
    vnode.koupleless.io/tunnel: mqtt_tunnel_provider # Current tunnel ownership of the base
    vnode.koupleless.io/version: 1.0.0 # Base version number
  name: vnode.2ce92dca-032e-4956-bc91-27b43406dad2 # vnode name, latter part is UUID from the base maintenance pipeline
spec:
  taints:
  - effect: NoExecute
    key: schedule.koupleless.io/virtual-node # vnode taint to prevent regular pod scheduling
    value: "True"
  - effect: NoExecute
    key: schedule.koupleless.io/node-env # node env taint to prevent non-current environment pod scheduling
    value: dev
status:
  addresses:
  - address: 127.0.0.1
    type: InternalIP
  - address: local
    type: Hostname
```

## Module <-> Pod Mapping

Module Controller V2 defines a module as a Pod in the K8S system, allowing for rich scheduling capabilities through Pod YAML configuration.

A module Pod YAML configuration is as follows:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-single-module-biz1
  labels:
    virtual-kubelet.koupleless.io/component: module # Necessary to declare pod type for module controller management
spec:
  containers:
    - name: biz1 # Module name, must strictly match the artifactId in the module's pom
      image: https://serverless-opensource.oss-cn-shanghai.aliyuncs.com/module-packages/stable/biz1-web-single-host-0.0.1-SNAPSHOT-ark-biz.jar # jar package address, supports local file, http/https link
      env:
        - name: BIZ_VERSION # Module version configuration
          value: 0.0.1-SNAPSHOT # Must strictly match the version in the pom
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms: # Base node selection
          - matchExpressions:
              - key: base.koupleless.io/stack # Future multi-language support
                operator: In
                values:
                  - java
              - key: vnode.koupleless.io/version # Base version filtering
                operator: In
                values:
                  - 1.0.0 # Module may only be schedulable to certain versions of bases; if restricted, this field is required.
              - key: vnode.koupleless.io/name # Base name filtering
                operator: In
                values:
                  - base # Module may only be schedulable to certain specific bases; if restricted, this field is required.
  tolerations:
    - key: "schedule.koupleless.io/virtual-node" # Ensure the module can be scheduled onto a base vnode
      operator: "Equal"
      value: "True"
      effect: "NoExecute"
    - key: "schedule.koupleless.io/node-env" # Ensure the module can be scheduled onto a base node in a specific environment
      operator: "Equal"
      value: "test"
      effect: "NoExecute"
```

The above example shows only the basic configuration. Additional configurations can be added to achieve richer scheduling capabilities, such as adding Pod AntiAffinity in Module Deployment scenarios to prevent duplicate module installations.

<br/>