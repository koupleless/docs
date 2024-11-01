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

## MQTT 环境准备

Module Controller V2 包含一个基于 MQTT 的运维管道，依赖 MQTT 进行运维指令的下发与数据同步，因此需要准备一个 MQTT 服务。

**如果已经有可用的 MQTT 服务，请跳过本节。**

这里推荐直接使用 NanoMQ 的 MQTT 服务镜像进行测试， 使用 [yaml](https://github.com/koupleless/module-controller/tree/main/example/quick-start/mqtt.yaml) 在 K8S 中部署 MQTT 服务：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mqtt
  labels:
    app: mqtt
spec:
  containers:
    - name: mqtt
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/base/emqx/nanomq:latest
      resources:
        limits:
          cpu: "200m"
          memory: "100Mi"
      ports:
        - name: mqtt
          containerPort: 1883
```

发布之后通过 `kubectl get pods -o wide` 来查看部署情况，容器状态转为 Running 之后保存下来查看到的 Pod IP 信息，用于后续操作。

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
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/release/module_controller:2.0.0 # 已经打包好的镜像
      imagePullPolicy: Always
      resources:
        limits:
          cpu: "1000m"
          memory: "400Mi"
      env:
        - name: MQTT_BROKER # mqtt broker url
          value: YOUR_MQTT_BROKER
        - name: MQTT_PORT # mqtt port
          value: "1883"
        - name: MQTT_USERNAME # mqtt username
          value: koupleless
        - name: MQTT_PASSWORD # mqtt password
          value: public
        - name: MQTT_CLIENT_PREFIX # mqtt client prefix
          value: koupleless
```

注意，请将上面 Yaml 中 env 下的 YOUR_MQTT_BROKER 替换成为实际 MQTT 服务的端点，如果按照教程部署了 NanoMQ 服务，将此处替换为 MQTT 环境准备中获得的 mqtt Pod 的 IP。

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
  serviceAccountName: virtual-kubelet # 上一步中配置好的 Service Account
  containers:
    - name: base
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/base # 已经打包好的镜像
      imagePullPolicy: Always
      resources:
        limits:
          cpu: "1000m"
          memory: "400Mi"
      env:
        - name: KUPLELESS_ARKLET_MQTT_BROKER
          value: YOUR_MQTT_BROKER
        - name: KUPLELESS_ARKLET_MQTT_PORT
          value: "1883"
        - name: KUPLELESS_ARKLET_MQTT_USERNAME
          value: koupleless_base
        - name: KUPLELESS_ARKLET_MQTT_PASSWORD
          value: public
        - name: KUPLELESS_ARKLET_MQTT_CLIENT_PREFIX
          value: koupleless
        - name: KUPLELESS_ARKLET_CUSTOM_TUNNEL_CLASSNAME
          value: com.alipay.sofa.koupleless.arklet.tunnel.mqtt.MqttTunnel
        - name: KUPLELESS_ARKLET_CUSTOM_BASE_METADATA_CLASSNAME
          value: com.alipay.sofa.web.base.metadata.MetadataHook
```

同上一步，将yaml中的 `YOUR_MQTT_BROKER` 替换为实际 MQTT 服务的端点，如果按照教程部署了 NanoMQ 服务，将此处替换为 MQTT 环境准备中获得的 mqtt Pod 的 IP。

apply 更改后的 yaml 到 K8S 集群，等待 Base Pod 变成 Running 状态。

基座启动完成之后，我们可以通过以下方式验证基座已经成功映射成为 VNode：

```bash
kubectl get nodes
```

看到存在名为 vnode.{uuid} 的 node，并且状态为 Ready，则说明基座已经成功启动并完成映射。

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
                  - key: base.koupleless.io/stack
                    operator: In
                    values:
                      - java
                  - key: vnode.koupleless.io/version
                    operator: In
                    values:
                      - 1.0.0
                  - key: vnode.koupleless.io/name
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
