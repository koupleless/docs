---
title: Module Release
date: 2024-07-19T10:28:32+08:00
description: Koupleless Module Online and Offline Procedures
weight: 100
---

**Note:** The current ModuleController v2 has only been tested on Kubernetes (K8S) version 1.24, with no testing on other versions. ModuleController V2 relies on certain Kubernetes (K8S) features; thus, the K8S version must not be lower than V1.10.

## Module Release

ModuleController V2 supports deploying modules using any Pod deployment method, including but not limited to bare Pod deployment, Deployments, DaemonSets, and StatefulSets. Below, we demonstrate the release process using Deployment as an example; configurations for other methods can refer to the `template` configuration in Deployment:

```bash
kubectl apply -f samples/module-deployment.yaml --namespace yournamespace
```

The complete content is as follows:

```yaml
apiVersion: apps/v1  # Specifies the API version, which must be listed in `kubectl api-versions`
kind: Deployment  # Specifies the role/type of resource to create
metadata:  # Metadata/attributes of the resource
  name: test-module-deployment  # Name of the resource, must be unique within the same namespace
  namespace: default # Namespace where it will be deployed
spec:  # Specification field of the resource
  replicas: 1
  revisionHistoryLimit: 3 # Retains historical versions
  selector: # Selector
    matchLabels: # Matching labels
      app: test-module-deployment
  strategy: # Strategy
    rollingUpdate: # Rolling update
      maxSurge: 30% # Maximum additional replicas that can exist, can be a percentage or an integer
      maxUnavailable: 30% # Maximum number of Pods that can become unavailable during the update, can be a percentage or an integer
    type: RollingUpdate # Rolling update strategy
  template: # Template
    metadata: # Metadata/attributes of the resource
      labels: # Sets resource labels
        module-controller.koupleless.io/component: module # Required, declares Pod type for management by module controller
        # Unique ID for Deployment
        app: test-module-deployment-non-peer
    spec: # Specification field of the resource
      containers:
        - name: biz1 # Required, declares the module's bizName, must match the artifactId declared in pom.xml
          image: https://serverless-opensource.oss-cn-shanghai.aliyuncs.com/module-packages/stable/biz1-web-single-host-0.0.1-SNAPSHOT-ark-biz.jar
          env:
            - name: BIZ_VERSION # Required, declares module's biz_version, value must match the version declared in pom.xml
              value: 0.0.1-SNAPSHOT
      affinity:
        nodeAffinity: # Required, declares the base selector to ensure modules are scheduled onto designated bases
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: base.koupleless.io/stack
                    operator: In
                    values:
                      - java # Mandatory in a multi-language environment, specifies the tech stack
                  - key: base.koupleless.io/version
                    operator: In
                    values:
                      - 1.1.1 # Specified base version, mandatory, at least one required
                  - key: base.koupleless.io/name
                    operator: In
                    values:
                      - base  # Specified base bizName, mandatory, at least one required
      tolerations: # Required, allows pods to be scheduled onto base nodes
        - key: "schedule.koupleless.io/virtual-node"
          operator: "Equal"
          value: "True"
          effect: "NoExecute"
```

All configurations align with a regular Deployment, except for mandatory fields; additional Deployment configurations can be added for custom functionality.

## Checking Module Status

This requirement can be met by examining Pods with nodeName corresponding to the base's node. First, understand the mapping between base services and nodes.

In the design of Module Controller V2, each base generates a globally unique UUID at startup as the identifier for the base service. The corresponding node's Name includes this ID.

Additionally, the IP of the base service corresponds one-to-one with the node's IP, allowing selection of the corresponding base Node via IP.

Therefore, you can use the following command to view all Pods (modules) installed on a specific base and their statuses:

```bash
kubectl get pod -n <namespace> --field-selector status.podIP=<baseIP>
```

Or

```bash
kubectl get pod -n <namespace> --field-selector spec.nodeName=virtual-node-<baseUUID>
```

## Module Offline

Removing the module's Pod or other controlling resources in the K8S cluster completes the module offline process. For instance, in a Deployment scenario, you can directly delete the corresponding Deployment to offline the module:

```bash
kubectl delete yourmoduledeployment --namespace yournamespace
```

Replace _yourmoduledeployment_ with your ModuleDeployment name and _yournamespace_ with your namespace.

For customizing module release and operation strategies (such as grouping, Beta testing, pausing, etc.), refer to [Module Operation and Scheduling Strategies](/docs/tutorials/module-operation-v2/operation-and-scheduling-strategy/).

The demonstrated example uses `kubectl`; directly calling the K8S API Server to delete Deployment also achieves module group offline.

## Module Scaling

Since ModuleController V2 fully leverages K8S's Pod orchestration scheme, scaling only occurs on ReplicaSets, Deployments, StatefulSets, etc. Scaling can be implemented according to the respective scaling methods; below, we use Deployment as an example:

```bash
kubectl scale deployments/yourdeploymentname --namespace=yournamespace --replicas=3
```

Replace _yourdeploymentname_ with your Deployment name, _yournamespace_ with your namespace, and set the `replicas` parameter to the desired scaled quantity.

Scaling strategies can also be implemented through API calls.

## Module Replacement

In ModuleController v2, modules are tightly bound to Containers. To replace a module, you need to execute an update logic, updating the module's Image address on the Pod where the module resides.

The specific replacement method varies slightly depending on the module deployment method; for instance, directly updating Pod information replaces the module in-place, while Deployment executes the configured update strategy (e.g., rolling update, creating new version Pods before deleting old ones). DaemonSet also executes the configured update strategy but with a different logic – deleting before creating, which might cause traffic loss.

## Module Rollback

Being compatible with native Deployments, rollback can be achieved using Deployment's rollback method.

To view deployment history:

```bash
kubectl rollout history deployment yourdeploymentname
```

To rollback to a specific version:

```bash
kubectl rollout undo deployment yourdeploymentname --to-revision=<TARGET_REVISION>
```

## Other Operational Issues

### Module Traffic Service Implementation

A native Service can be created for the module, which can provide services only when the base and ModuleController are deployed within the same VPC.

As bases and ModuleController may not be deployed in the same VPC currently, interaction between them is realized through MQTT message queues. Base nodes integrate the IP of the Pod where the base resides, and module Pods integrate the IP of the base node. Therefore, when the base itself and ModuleController are not in the same VPC, the IP of the module is actually invalid, preventing external service provision.

A potential solution involves forwarding at the Load Balancer (LB) layer of the Service, redirecting the Service's traffic to the base service on the corresponding IP of the K8S where the base resides. Further evaluation and optimization of this issue will be based on actual usage scenarios.

### Incompatible Base and Module Release

1. Deploy a module's Deployment first, specifying the latest version of the module code package address in Container and the name and version information of the new version base in nodeAffinity.
   This Deployment will create corresponding Pods, but they won't be scheduled until new version bases are created.
2. Update the base Deployment to release the new version image, triggering the replacement and restart of the base. Upon startup, the base informs the ModuleController V2 controller, creating a corresponding version node.
3. After the creation of the corresponding version base node, the K8S scheduler automatically triggers scheduling, deploying the Pods created in step 1 onto the base node for installation of the new version module, thus achieving simultaneous release.
   
<br/>
<br/>