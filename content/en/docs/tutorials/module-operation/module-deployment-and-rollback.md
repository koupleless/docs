---
title: Module Deployment
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Deployment
weight: 200
draft: true
---


## Module Deployment
Modify the ModuleDeployment.spec.template.spec.module.version field and ModuleDeployment.spec.template.spec.module.url field (optional) and reapply, you can achieve the group deployment of the new version module, for example:
```bash
kubectl apply -f koupleless/module-controller/config/samples/module-deployment_v1alpha1_moduledeployment.yaml --namespace yournamespace
```
Replace deployment_v1alpha1_moduledeployment.yaml with your ModuleDeployment definition yaml file, and yournamespace with your namespace. The complete content of module-deployment_v1alpha1_moduledeployment.yaml is as follows:
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
        version: '2.0.0'  # Note: Modify the version field from 1.0.2 to 2.0.0 here to achieve the group deployment of the new version module
        # Note: The url field can be modified to the new jar package address, or it can be left unchanged
        url: http://koupleless.oss-cn-shanghai.aliyuncs.com/module-packages/stable/dynamic-provider-1.0.2-ark-biz.jar
  replicas: 2
  operationStrategy:
    upgradePolicy: install_then_uninstall
    needConfirm: true
    grayTimeBetweenBatchSeconds: 0
    useBeta: false
    batchCount: 2
  schedulingStrategy:
    schedulingPolicy: scatter
```

If you want to customize the module deployment operation strategy, you can configure operationStrategy, specifically refer to [Module Deployment Operation Strategy](/docs/contribution-guidelines/module-controller/crd-definition).<br />The example demonstrates using the kubectl method, directly calling the K8S APIServer to modify the ModuleDeployment CR can also achieve group deployment.


## Module Rollback
Modify the ModuleDeployment.spec.template.spec.module.version field and ModuleDeployment.spec.template.spec.module.url field (optional) and reapply, you can achieve the group rollback deployment of the module.

<br/>
<br/>
