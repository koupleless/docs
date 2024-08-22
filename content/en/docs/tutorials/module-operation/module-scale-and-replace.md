---
title: Module Scaling and Replacement
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Scaling and Replacement
weight: 400
draft: true
---


## Module Scaling
To scale a module, modify the replicas field of the ModuleDeployment CR and reapply it. For example:
```bash
kubectl apply -f koupleless/module-controller/config/samples/module-deployment_v1alpha1_moduledeployment.yaml --namespace yournamespace
```
Replace deployment_v1alpha1_moduledeployment.yaml with the path to your ModuleDeployment definition YAML file, and yournamespace with your namespace. Here's the complete content of module-deployment_v1alpha1_moduledeployment.yaml:
```yaml
apiVersion: koupleless.alipay.com/v1alpha1
kind: ModuleDeployment
metadata:
  labels:
    app.kubernetes.io/name: moduledeployment
    app.kubernetes.io/instance: moduledeployment-sample
    app.kubernetes.io/part-of: module-controller
    app.kubernetes.io/managed-by: kustomize
    app.kubernetes.io/created-by: module-controller
  name: moduledeployment-sample
spec:
  baseDeploymentName: dynamic-stock-deployment
  template:
    spec:
      module:
        name: provider
        version: '1.0.2'
        url: http://koupleless.oss-cn-shanghai.aliyuncs.com/module-packages/stable/dynamic-provider-1.0.2-ark-biz.jar
  replicas: 2  # Note: Modify the number of replicas here to scale the module instances
  operationStrategy:
    upgradePolicy: installThenUninstall
    needConfirm: true
    useBeta: false
    batchCount: 2
  schedulingStrategy: # Customize scheduling strategy here
    schedulingPolicy: Scatter  
```

If you want to customize the module deployment operation strategy (such as grouping, beta, pause, etc.), you can configure the operationStrategy and schedulingStrategy. For more details, refer to [Module Deployment Operation Strategy](/docs/tutorials/module-operation/operation-and-scheduling-strategy/).<br />The example demonstrates using kubectl, but modifying the ModuleDeployment CR directly via the K8S API server achieves the same result.


Module Replacement
To replace a module in the Kubernetes cluster, delete the Module CR resource. For example:
```bash
kubectl delete yourmodule --namespace yournamespace
```
Replace yourmodule with the name of your Module CR entity (metadata name of Module), and yournamespace with your namespace. The example demonstrates using kubectl, but deleting a Module CR directly via the K8S API server achieves the same result.


<br/>
<br/>
