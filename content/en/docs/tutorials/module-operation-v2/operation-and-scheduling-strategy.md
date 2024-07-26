---
title: Module Release Operations Strategy
date: 2024-07-19T10:28:32+08:00
description: Koupleless Module Release Operations Strategy
weight: 600
---
## Operations Strategy
To achieve zero-downtime changes in the production environment, the module release operations leverage Kubernetes (K8S) native scheduling capabilities to provide secure and reliable update functionality. Users can deploy modules via suitable Pod configurations based on business requirements.

## Scheduling Strategy
**Distributed Scheduling**: Achieved through native Deployment controls, with PodAffinity configurations facilitating distributed scheduling.

## Peer and Non-Peer Deployment
Peer and non-peer deployment strategies can be realized by selecting different deployment methods.

**Peer Deployment**:
Two implementation methods are provided below:
1. Deploying the module as a DaemonSet ensures that whenever a **base node** comes online, the DaemonSet controller automatically creates a module Pod on it, implementing peer deployment.
   > Note that DaemonSet rolling updates follow a remove-before-install approach; choose according to actual business needs.
2. Using Deployment, unlike DaemonSet, may require an additional component to synchronize the number of module replicas with the **base** count (under development, expected in the next release). Supports install-before-remove, avoiding backend traffic loss.
   > Be aware that while Deployments strive for distributed scheduling, they do not guarantee complete dispersion. Instances may be deployed multiple times on the same **base**. To enforce strict distribution, add Pod anti-affinity settings in the Deployment, as shown:

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
                      values: ["1.0.0"] # If the module can only be scheduled to specific node versions, this field is mandatory.
                    - key: base.koupleless.io/name
                      operator: In
                      values: ["base"] # Mandatory if there are restrictions on node versions.
              podAntiAffinity: # Core configuration for distributed scheduling
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

**Non-Peer Deployment**: Achieved by deploying modules as Deployments/ReplicaSets, where the deployment is based on the replica count set.

## Batch Updates
The strategy for batch updates should be implemented independently. The ModuleController V2 facilitates that when modules with the same name but different versions are installed sequentially on a **base**, the Pod of the earlier installed module enters BizDeactivate status and moves to Failed Phase. This logic can be leveraged to implement batch update strategies.

<br/>
<br/>