---
title: Module Online and Offline
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Online and Offline
weight: 100
---


## Module Online
To bring a module online in the Kubernetes cluster, create a ModuleDeployment CR resource. For example:
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
  replicas: 2
  operationStrategy:  # Customize deployment operation strategy here
    upgradePolicy: installThenUninstall
    needConfirm: true
    useBeta: false
    batchCount: 2
  schedulingStrategy: # Customize scheduling strategy here
    schedulingPolicy: Scatter
```

You can refer to the [ModuleDeployment CRD fields explanation ](/docs/contribution-guidelines/module-controller/crd-definition)for all the fields of ModuleDeployment. <br />If you want to customize the module deployment operation strategy (such as grouping, beta, pause, etc.), you can configure the operationStrategy and schedulingStrategy. For more details, refer to [Module Deployment Operation Strategy](../operation-and-scheduling-strategy).<br />The example demonstrates using kubectl, but creating a ModuleDeployment CR directly via the K8S API server achieves the same result.


Module Offline
To take a module offline in the Kubernetes cluster, delete the ModuleDeployment CR resource. For example:
```bash
kubectl delete yourmoduledeployment --namespace yournamespace
```
Replace yourmoduledeployment with the name of your ModuleDeployment (metadata name of ModuleDeployment), and yournamespace with your namespace. If you want to customize the module deployment operation strategy (such as grouping, beta, pause, etc.), you can configure the operationStrategy and schedulingStrategy. For more details, refer to [Module Deployment Operation Strategy](../operation-and-scheduling-strategy).<br />The example demonstrates using kubectl, but deleting a ModuleDeployment CR directly via the K8S API server achieves the same result.

<br/>
<br/>
