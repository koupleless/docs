---
title: 2. Quick Start  
date: 2024-01-25T10:28:32+08:00  
description: Koupleless Quick Start  
weight: 200
---
This quick start guide mainly introduces the dynamic merge deployment model, which is used to save resources and improve R&D efficiency. If you only want to save resources, you can use [static merge deployment](/docs/tutorials/module-development/static-merge-deployment/). This guide includes:
1. Base Access
2. Module Access
3. Module Development Verification
4. Module Deployment (not available yet, updates pending)

<div style="text-align: center;">  
    <img align="center" width="600px" src="/img/build_and_deploy.png" />  
</div>  

Video tutorials are also available, [click here to view](/docs/video-training/).

## Prerequisites

### Development Tools
- JDK 8, JDK 17, JDK 21+
- Maven v3.9.0+
- [arkctl](https://github.com/koupleless/arkctl/releases) v0.2.1+, installation instructions can be found [here](/docs/tutorials/module-development/module-dev-arkctl/#arkctl-工具安装)

### Operation and Maintenance Tools (not required for static merge deployment)
- Docker
- Kubectl
- K8s Cluster such as [minikube](https://minikube.sigs.k8s.io/docs/start/) v1.10+

## Base Access
[Refer to this link](/docs/tutorials/base-create/springboot-and-sofaboot)

## Module Access
[Refer to this link](/docs/tutorials/module-create/springboot-and-sofaboot)

## Local Environment Development Verification
[Check here](http://localhost:1313/docs/tutorials/module-development/module-dev-arkctl/#本地快速部署)

### Module Deployment Example with Minikube Cluster (not available yet, updates pending)

#### Step 1: Deploy Operation and Maintenance Component ModuleController
```shell  
kubectl apply -f xxx/xxx.yaml  
```  

#### Step 2: Publish Using Sample Base
1. Deploy the base to the K8s cluster, create a service for the base, exposing the port,  
   you can [reference here](https://github.com/koupleless/module-controller/blob/master/config/samples/dynamic-stock-service.yaml)
2. Execute `minikube service base-web-single-host-service` to access the base service

<div style="text-align: center;">  
    <img align="center" width="600px" alt="Microservice Evolution Cost" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/671/1694161452232-15aec134-3b2a-491f-9295-0c5f8f7341af.png#clientId=ue383ca9b-aa63-4&from=paste&height=443&id=ub3eb7eb8&originHeight=1318&originWidth=1626&originalType=binary&ratio=2&rotation=0&showTitle=false&size=168110&status=done&style=none&taskId=u07f60163-67e4-42fa-bc41-76e43a09c1f&title=&width=546" />  
</div>  

#### Step 3: Release the Module
There are two ways to release a module:
1. Directly deploy the local module jar package to the K8s cluster
```shell  
arkctl deploy ${path to the jar package} --pod ${namespace}/${podname}  
```  
2. Deploy and release via K8s module deployment  
   Create a module deployment and use `kubectl apply` to publish
```shell  
kubectl apply -f xxx/xxxxx/xx.yaml  
```  

#### Step 4: Test Verification

## For More Experiments, Please View Sample Cases
[Click here](https://github.com/koupleless/samples/tree/master/)  
