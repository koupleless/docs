---
title: 5.2 Module Release Operations Strategy
date: 2024-07-19T10:28:32+08:00
description: Koupleless Module Release Operations Strategy
weight: 600
---

## Operations Strategy

To achieve zero-downtime changes in the production environment, the module release operations leverage Kubernetes (K8S) native scheduling capabilities to provide secure and reliable update functionality. Users can deploy module Pods according to business requirements.

## Scheduling Strategy

**Dispersion Scheduling**: Achieved through native Deployment controls, with PodAffinity configurations facilitating dispersion scheduling.

## Peer and Non-Peer Deployment

Peer and non-peer deployment strategies can be realized by selecting different deployment methods.

### Peer Deployment

Two implementation methods are provided:

1. **Using DaemonSet**: Modules can be deployed as DaemonSets, where a DaemonSet controller automatically creates a module Pod for each **base node** upon its addition, ensuring peer deployment.
   > Note that DaemonSet rolling updates occur by uninstalling before reinstalling; choose based on actual business needs.

2. **Via Deployment**: Unlike DaemonSet, an additional component is required to maintain module replica count equivalent to the number of base nodes (under development, expected in the next release). Supports install-before-uninstall, avoiding backend traffic loss in a microservices architecture.
   > While Deployments strive for dispersion, they do not guarantee complete dispersion; modules might be deployed multiple times to the same base. For strong dispersion, add Pod anti-affinity settings in the Deployment, as shown below:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: test-module-deployment
    namespace: default
    labels:
        module-controller.koupleless.io/component: module-deployment
spec:
    replicas: 1
    revisionHistoryLimit: 3
    selector:
        matchLabels:
            module.koupleless.io/name: biz1
            module.koupleless.io/version: 0.0.1
    strategy:
        rollingUpdate:
            maxSurge: 30%
            maxUnavailable: 30%
        type: RollingUpdate
    template:
        metadata:
            labels:
                module-controller.koupleless.io/component: module
                module.koupleless.io/name: biz1
                module.koupleless.io/version: 0.0.1
        spec:
            containers:
            - name: biz1
              image: https://serverless-opensource.oss-cn-shanghai.aliyuncs.com/module-packages/test_modules/biz1-0.0.1-ark-biz.jar
              env:
              - name: BIZ_VERSION
                value: 0.0.1
            affinity:
                nodeAffinity:
                    requiredDuringSchedulingIgnoredDuringExecution:
                        nodeSelectorTerms:
                        - matchExpressions:
                          - key: base.koupleless.io/stack
                            operator: In
                            values: ["java"]
                          - key: base.koupleless.io/version
                            operator: In
                            values: ["1.0.0"] # If modules can only be scheduled to specific node versions, this field is mandatory.
                          - key: base.koupleless.io/name
                            operator: In
                            values: ["base"]
                podAntiAffinity: # Core configuration for dispersion scheduling
                    requiredDuringSchedulingIgnoredDuringExecution:
                    - labelSelector:
                        matchLabels:
                            module.koupleless.io/name: biz1
                            module.koupleless.io/version: 0.0.1
                      topologyKey: topology.kubernetes.io/zone
            tolerations:
            - key: "schedule.koupleless.io/virtual-node"
              operator: "Equal"
              value: "True"
              effect: "NoExecute"
```

### Non-Peer Deployment

Achieved by deploying modules as Deployments or ReplicaSets, with deployments based on the replica count setting.

## Batch Updates

The strategy for batch updates requires custom control logic. ModuleController V2 introduces a capability where, when different versions of the same-named module are installed sequentially on a base, the Pod of the earlier-installed module enters BizDeactivate status and transitions to the Failed phase. Exploit this logic to implement batch update strategies.

<br/>
<br/>
