---
title: 2.2 模块运维
date: 2024-01-25T10:28:32+08:00
description: Koupleless 快速开始
weight: 210
---

本上手指南主要介绍基于 Module Controller V2 的模块运维。本上手指南包含：

1. 环境准备
2. Module Controller V2 部署
3. 测试基座准备
4. 模块发布与状态查看

# 环境准备

## K8S 环境部署

Module Controller V2 基于 K8S 构建模块运维能力，因此，首先需要准备一个基础 K8S 环境。

> **注意**: 目前 Module Controller 只支持 **arm64 / amd64** 的运行环境。

**如果已经有可用的 K8S 集群，请跳过本节。**

本地测试推荐使用 Minikube 快速在本地搭建 K8S。Minikube 是一个开源的本地 Kubernetes 搭建工具，能够帮助我们快速完成 K8S 各依赖组件的部署。

为了安装 Minikube，首先需要安装 Docker 运行环境：[Docker官方网站](https://www.docker.com/get-started/)

完成 Docker 安装并完成 Docker daemon 启动之后，我们就完成了所有 Minikube 的安装准备工作。

Minikube 的安装可以参考[官方文档](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download)

# Module Controller V2 部署

Module Controller V2 有两种部署方式：
1. 本地运行（需要配置 go 语言环境，不建议）
2. 镜像部署（建议）

接下来我们以镜像部署为例。

首先我们需要为 Module Controller V2 准备必要的 RBAC 配置。

1. 下载 [Service Account YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account.yaml)
2. 下载 [Cluster Role YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account_cluster_role.yaml)
3. 下载 [Cluster Role Binding YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account_cluster_role_binding.yaml)

接下来，依次 apply 上面的三个 yaml 文件，完成 service account 的权限设置与绑定。

接下来我们需要准备 Module Controller 部署的 [Pod Yaml](https://github.com/koupleless/module-controller/tree/main/example/quick-start/module-controller.yaml)：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: module-controller
  labels:
    app: module-controller
spec:
  serviceAccountName: virtual-kubelet # 上一步中配置好的 Service Account
  containers:
    - name: module-controller
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/release/module-controller-v2:v2.1.2 # 已经打包好的镜像
      imagePullPolicy: Always
      resources:
        limits:
          cpu: "1000m"
          memory: "400Mi"
      ports:
        - name: httpTunnel
          containerPort: 7777
      env:
        - name: ENABLE_HTTP_TUNNEL
          value: "true"
```

apply 上述 Module Controller 的 yaml 到 K8S 集群，等待 Module Controller Pod 变成 Running 状态。

接下来，模块运维能力已经搭建完成了，接下来将准备测试基座和测试模块。

## 测试基座部署

为了方便上手，我们这里也准备好了测试基座的 Docker 镜像，首先下载[基座 Yaml](https://github.com/koupleless/module-controller/tree/main/example/quick-start/base.yaml)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: base
  labels:
    app: base
spec:
  containers:
    - name: base
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/base-web:1.4.0 # 已经打包好的镜像, 镜像来源 https://github.com/koupleless/samples/blob/main/springboot-samples/web/tomcat/Dockerfile
      imagePullPolicy: Always
      ports:
        - name: base
          containerPort: 8080
        - name: arklet
          containerPort: 1238
      env:
        - name: MODULE_CONTROLLER_ADDRESS
          value: {YOUR_MODULE_CONTROLLER_IP_AND_PORT}   # 127.0.0.1:7777
```

同上一步，将yaml中的 `{YOUR_MODULE_CONTROLLER_IP_AND_PORT}` 替换为实际 Module Controller 的Pod IP 和 端口。

apply 更改后的 yaml 到 K8S 集群，等待 Base Pod 变成 Running 状态。

基座启动完成之后，我们可以通过以下方式验证基座已经成功映射成为 VNode：

```bash
kubectl get nodes
```

看到存在名为 vnode.test-base.dev 的 node，并且状态为 Ready，则说明基座已经成功启动并完成映射。

> 上述 uuid 是在基座启动时生成的，每一次重新启动都会不同

接下来为了方便验证访问，我们使用 `port-forward` 将基座容器的服务暴露出来，使用如下命令：

```bash
kubectl port-forward base 8080:8080
```

接下来访问[链接](http://localhost:8080/biz1) 如果能够正常访问，说明已完成映射。

## 测试模块发布与状态查看

### 模块发布

为了对比，我们首先看一下模块还没有安装的时候的情况，访问基座服务：[模块测试](http://localhost:8080/biz1)

此时应当返回错误页，表明模块还未安装。

接下来我们将使用 Deployment 对模块进行发布，将下面的模块 [yaml](https://github.com/koupleless/module-controller/tree/main/example/quick-start/module.yaml) apply 到 K8S ，即可进行模块发布。这里以单个模块发布为例：

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: biz1
  labels:
    virtual-kubelet.koupleless.io/component: module-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      module: biz1
  template:
    metadata:
      labels:
        module: biz1
        virtual-kubelet.koupleless.io/component: module
    spec:
      containers:
        - name: biz1
          image: https://serverless-opensource.oss-cn-shanghai.aliyuncs.com/module-packages/stable/biz1-web-single-host-0.0.1-SNAPSHOT-ark-biz.jar
          env:
            - name: BIZ_VERSION
              value: 0.0.1-SNAPSHOT
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: vnode.koupleless.io/version
                    operator: In
                    values:
                      - 1.0.0
                  - key: base.koupleless.io/name
                    operator: In
                    values:
                      - koupleless-sample
      tolerations:
        - key: "schedule.koupleless.io/virtual-node"
          operator: "Equal"
          value: "True"
          effect: "NoExecute"
        - key: "schedule.koupleless.io/node-env"
          operator: "Equal"
          value: "dev"
          effect: "NoExecute"
```

发布完成之后，可以通过 `kubectl get pods` 来查看所有模块 pod 的状态。

当 deployment 创建出的 pod 状态变为 Running 之后，表示当前模块已经安装完成了，接下来我们再次访问基座服务： [模块测试](http://localhost:8080/biz1) 来验证模块安装情况。

可以看到，页面内容已经发生了变化，展示：`hello to /biz1 deploy` ，表明模块已经安装完成。

### 模块删除

模块删除可以直接通过删除模块的 Deployment 来实现，使用命令：

```bash
kubectl delete deployment biz1
```

可以通过 `kubectl get pods` 来查看 pod 是否已经删除成功。

删除成功之后，再次访问基座服务 [模块测试](http://localhost:8080/biz1) 来验证模块卸载情况。

可以看到，页面内容又恢复回了模块未安装的状态，表明模块卸载完成。
