---
title: 6.6.2 ModuleControllerV2 Scheduling Principles
date: 2024-07-18T11:24:33+08:00
description: Koupleless ModuleControllerV2 Architecture Design
weight: 910
---

## Brief Introduction

Module Controller V2 leverages the multi-tenant capabilities of Virtual Kubelet to map bases as Nodes in K8S. By defining modules as Pods, it reuses the K8S scheduler and various controllers to quickly build module operation and scheduling capabilities.

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/module-controller-struct.png"/>
</div>

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
    virtual-kubelet.koupleless.io/component: vnode # vnode marker
    virtual-kubelet.koupleless.io/env: dev # vnode environment marker
    base.koupleless.io/name: base # Name from base Metadata configuration
    vnode.koupleless.io/tunnel: mqtt_tunnel_provider # Current tunnel ownership of the base
    base.koupleless.io/version: 1.0.0 # Base version number
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
              - key: base.koupleless.io/version # Base version filtering
                operator: In
                values:
                  - 1.0.0 # Module may only be schedulable to certain versions of bases; if restricted, this field is required.
              - key: base.koupleless.io/name # Base name filtering
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

**Operations Workflow**

Based on the above structure and mapping relationships, we can leverage Kubernetes (K8S) native control plane components to fulfill diverse and complex module operation requirements.

The following illustrates the entire module operations workflow using the Deployment module as an example, with the base already initialized and mapped:

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/module_deployment_stage_1.png" />  
</div>

1. **Create the Module Deployment** (a native K8S Deployment, where the PodSpec within the Template defines module information). The Deployment Controller in the K8S ControllerManager will create a virtual Pod (vPod) according to the Deployment configuration. At this point, the vPod wasn't scheduled，with a status of Pending.

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/module_deployment_stage_2.png" />  
</div>

2. **K8S Scheduler** scans unscheduled vPods and schedules them onto appropriate virtual Nodes (vNodes) based on selector, affinity, taint/toleration configurations.

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/module_deployment_stage_3.png" />  
</div>

3. Upon detecting the completion of vPod scheduling, the **Module Controller** retrieves the module information defined within the vPod and sends installation commands to the base.

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/module_deployment_stage_4.png" />  
</div>


4. After the base completes the module installation, it synchronizes the module installation status with the Module Controller, which then translates the module status into Container Status and syncs it with Kubernetes.

5. Concurrently, the base continuously reports its health status. The Module Controller maps Metaspace capacity and usage to Node Memory, updating this information in Kubernetes. 

<br/>

## Implementation Logic

The core logic involved in the implementation is as follows:

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/roles.png" />  
</div>


Model definition and logical relationships:

<div style="text-align: center;">  
    <img align="center" width="800px" src="/img/module-controller-v2/impl_structure.png" />  
</div>

## how to debug

1. start module-controller test version in minikube, `serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/module-controller-v2:v2.1.4`, the image has been configured with [go-delve](https://github.com/go-delve/delve) remote debug environment, debug port is 2345

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: module-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: module-controller
  template:
    metadata:
      labels:
        app: module-controller
    spec:
      serviceAccountName: virtual-kubelet # 上一步中配置好的 Service Account
      containers:
        - name: module-controller
          image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/module-controller-v2:v2.1.4 # 已经打包好的镜像，镜像在 Module-controller 根目录的 debug.Dockerfile
          imagePullPolicy: Always
          resources:
            limits:
              cpu: "1000m"
              memory: "400Mi"
          ports:
            - name: httptunnel
              containerPort: 7777
            - name: debug
              containerPort: 2345
          env:
            - name: ENABLE_HTTP_TUNNEL
              value: "true"
```

2. Log in to the started container
```shell
kubectl exec module-controller-544c965c78-mp758 -it -- /bin/sh
```

3. Enter the container and start delve
```shell
dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec ./module_controller
```

4. Exit the container and set up port forwarding for port 2345
```shell
kubectl port-forward module-controller-76bdbcdd8d-fhvfd 2345:2345
```

5. Start remote debugging in Goland or IDEA, with Host as `localhost` and Port as `2345`.
