---
title: Module Traffic Service
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Traffic Service
weight: 800
draft: true
---

## Introduction to ModuleService
In Kubernetes, [Service](https://kubernetes.io/docs/concepts/services-networking/service/) exposes a network application running on one or a set of Pods as a network service.
Modules also support Module-related Services, automatically creating a service to serve the module during module deployment, exposing the module installed on one or a group of Pods as a network service.
See: OperationStrategy.ServiceStrategy
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
  name: moduledeployment-sample-provider
spec:
  baseDeploymentName: dynamic-stock-deployment
  template:
    spec:
      module:
        name: provider
        version: '1.0.2'
        url: http://koupleless.oss-cn-shanghai.aliyuncs.com/module-packages/stable/dynamic-provider-1.0.2-ark-biz.jar
  replicas: 1
  operationStrategy:
    needConfirm: false
    grayTimeBetweenBatchSeconds: 120
    useBeta: false
    batchCount: 1
    upgradePolicy: install_then_uninstall
    serviceStrategy:
      enableModuleService: true
      port: 8080
      targetPort: 8080
  schedulingStrategy:
    schedulingPolicy: scatter
```
## Field Explanation
Explanation of the OperationStrategy.ServiceStrategy field:

|  | Field Explanation | Value Range   |
| --- | --- |---------------|
| EnableModuleService | Enable module service | true or false |
| Port | Exposed port | 1 to 65535    |
| TargetPort | Port to be accessed on the pod | 1 to 65535    |

## Example
```bash
kubectl apply -f koupleless/module-controller/config/samples/module-deployment_v1alpha1_moduledeployment_provider.yaml --namespace yournamespace
```
Automatically created service for the module
```yaml
apiVersion: v1
kind: Service
metadata:
  creationTimestamp: "2023-11-03T09:52:22Z"
  name: dynamic-provider-service
  namespace: default
  resourceVersion: "28170024"
  uid: 1f85e468-65e3-4181-b40e-48959a069df5
spec:
  clusterIP: 10.0.147.22
  clusterIPs:
  - 10.0.147.22
  externalTrafficPolicy: Cluster
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: http
    nodePort: 32232
    port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    module.koupleless.alipay.com/dynamic-provider: "true"
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}
```
