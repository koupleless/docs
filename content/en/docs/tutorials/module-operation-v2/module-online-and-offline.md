---
title: Module Online & Offline Procedures
date: 2024-07-19T10:28:32+08:00
description: Procedures for Online and Offline of Koupleless Modules
weight: 100
---

**Note:** The current ModuleController v2 has only been tested with Kubernetes (K8S) version 1.24, and has not been validated on other versions. ModuleController V2 relies on certain Kubernetes features; thus, the Kubernetes version must not be lower than v1.10.

## Module Online Deployment

ModuleController V2 supports deploying modules using any Pod deployment method, including but not limited to bare Pod deployments, Deployments, DaemonSets, and StatefulSets. Below, we illustrate the module deployment process using Deployment as an example. Other methods can refer to the configuration within Deployment's template:

```bash
kubectl apply -f samples/module-deployment.yaml --namespace yournamespace
```

The complete content is as follows:

```yaml
apiVersion: apps/v1  # Specifies the API version, which must be listed in kubectl api-versions
kind: Deployment  # Specifies the role/type of resource to create
metadata:  # Metadata/attributes of the resource
  name: test-module-deployment  # Unique name of the resource within the same namespace
  namespace: default # Namespace where it will be deployed
spec: # Specification field of the resource
  replicas: 1
  revisionHistoryLimit: 3 # Retains historical versions
  selector: # Selector
    matchLabels: # Matching labels
      app: test-module-deployment
  strategy: # Strategy
    rollingUpdate: # Rolling update settings
      maxSurge: 30% # Maximum additional replicas allowed, can be a percentage or integer
      maxUnavailable: 30% # Maximum number of Pods that can be unavailable during updates, can be a percentage or integer
    type: RollingUpdate # Rolling update strategy
  template: # Template
    metadata: # Metadata/attributes of the resource
      labels: # Assigns labels to the resource
        module-controller.koupleless.io/component: module # Mandatory, declares pod type for management by the module controller
        app: test-module-deployment-non-peer # Unique identifier for the Deployment
    spec: # Specification field of the resource
      containers:
        - name: biz1 # Mandatory, declares the module's bizName, should match artifactId declared in pom
          image: https://serverless-opensource.oss-cn-shanghai.aliyuncs.com/module-packages/stable/biz1-web-single-host-0.0.1-SNAPSHOT-ark-biz.jar
          env:
            - name: BIZ_VERSION # Mandatory, declares module's biz_version, value should match version in pom
              value: 0.0.1-SNAPSHOT
      affinity:
        nodeAffinity: # Mandatory, declares base selectors to ensure modules are scheduled on designated bases
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: base.koupleless.io/stack
                    operator: In
                    values:
                      - java # Mandatory in a multi-language environment for specifying tech stacks
                  - key: base.koupleless.io/version
                    operator: In
                    values:
                      - 1.1.1 # Mandatory, specifies the base version, at least one required
                  - key: base.koupleless.io/name
                    operator: In
                    values:
                      - base  # Mandatory, specifies the base bizName, at least one required
      tolerations: # Mandatory, allows pods to be scheduled on base nodes
        - key: "schedule.koupleless.io/virtual-node"
          operator: "Equal"
          value: "True"
          effect: "NoExecute"
```

All configurations align with a standard Deployment, with mandatory fields specified. Additional Deployment configurations can be added for customization.

## Module Offline

To take a module offline in a K8S cluster, delete the module's Pod or controlling resource. For instance, in a Deployment scenario, you can directly delete the corresponding Deployment to offline the module:

```bash
kubectl delete yourmoduledeployment --namespace yournamespace
```

Replace _yourmoduledeployment_ with your ModuleDeployment name and _yournamespace_ with your namespace.

For customizing module release and operation strategies (e.g., grouping, Beta testing, pause), refer to [Module Release & Operation Strategies](/docs/tutorials/module-operation-v2/operation-and-scheduling-strategy/).

The demonstrated example uses `kubectl`; however, directly invoking the Kubernetes API Server to delete Deployments achieves the same result for module group shutdown.
<br/>
<br/>