---
title: 2. 快速开始
date: 2024-01-25T10:28:32+08:00
description: Koupleless 快速开始
weight: 200
---

本上手指南主要介绍动态合并部署模式，用于省资源与提高研发效率。如果你只是想节省资源，可以使用[静态合并部署](/docs/tutorials/module-development/static-merge-deployment/)。本上手指南包含：

1. 基座接入
2. 模块接入
3. 模块开发验证
4. 模块部署上线（暂不可用，待更新）

<div style="text-align: center;">
    <img align="center" width="600px" src="/img/build_and_deploy.png" />
</div>

这里也提供了视频教程，[可点击此处查看](/docs/video-training/)。

## 预先准备

### 研发工具

- jdk 8, jdk 17, jdk21+
- maven v3.9.0+
- [arkctl](https://github.com/koupleless/arkctl/releases) v0.2.1+, 安装方式请查看[这里](/docs/tutorials/module-development/module-dev-arkctl/#arkctl-工具安装)

### 运维工具 (静态合并部署可不需要)
- docker
- kubectl
- k8s 集群如 [minikube](https://minikube.sigs.k8s.io/docs/start/) v1.10+

## 基座接入

[可参考此处](/docs/tutorials/base-create/springboot-and-sofaboot)

## 模块接入

[可参考此处](/docs/tutorials/module-create/springboot-and-sofaboot)

## 本地环境开发验证

[可查看这里](http://localhost:1313/docs/tutorials/module-development/module-dev-arkctl/#本地快速部署)

### 模块部署上线, 以 minikube 集群为例 (暂不可使用，待更新)

#### 第一步：部署运维组件 ModuleController

```shell
kubectl apply -f xxx/xxx.yaml
```

#### 第二步：使用样例基座发布
1. 基座部署到 k8s 集群中，创建基座的 service，暴露端口,
   可[参考这里](https://github.com/koupleless/module-controller/blob/master/config/samples/dynamic-stock-service.yaml)
2. 执行 minikube service base-web-single-host-service, 访问基座的服务

<div style="text-align: center;">
    <img align="center" width="600px" alt="微服务演进成本" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/671/1694161452232-15aec134-3b2a-491f-9295-0c5f8f7341af.png#clientId=ue383ca9b-aa63-4&from=paste&height=443&id=ub3eb7eb8&originHeight=1318&originWidth=1626&originalType=binary&ratio=2&rotation=0&showTitle=false&size=168110&status=done&style=none&taskId=u07f60163-67e4-42fa-bc41-76e43a09c1f&title=&width=546" />
</div>

#### 第三步：发布模块
有两种方式发布模块，
1. 直接部署本地模块 jar 包到 k8s 集群中

```shell
arkctl deploy ${模块构建出的 jar 包路径} --pod ${namespace}/${podname}
```

2.  通过 k8s 模块 deployment 部署上线
    创建模块 deployment，直接使用 kubectl apply 进行发布

```shell
kubectl apply -f xxx/xxxxx/xx.yaml
```

#### 第四步：测试验证


## 更多实验请查看 samples 用例

[点击此处](https://github.com/koupleless/samples/tree/master/)
