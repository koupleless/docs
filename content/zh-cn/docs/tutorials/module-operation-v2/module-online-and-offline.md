---
title: 模块发布
date: 2024-07-19T10:28:32+08:00
description: Koupleless 模块上线与下线
weight: 100
---

注意：当前 ModuleController v2 仅在 K8S 1.24 版本测试过，没有在其它版本测试，ModuleController V2依赖了部分K8S特性，K8S的版本不能低于V1.10。

## 模块上线

ModuleController V2支持以任意Pod的发布方式进行模块发布上线，包含但不仅限于裸pod发布、Deployment、DaemonSet、StatefulSet。下面以Deployment为例演示模块的发布流程，其他方式可以参考Deployment中template的配置：

```bash
kubectl apply -f samples/module-deployment.yaml --namespace yournamespace
```
完整内容如下：
```yaml
apiVersion: apps/v1  # 指定api版本，此值必须在kubectl api-versions中
kind: Deployment  # 指定创建资源的角色/类型
metadata:  # 资源的元数据/属性
  name: test-module-deployment  # 资源的名字，在同一个namespace中必须唯一
  namespace: default # 部署在哪个namespace中
spec: # 资源规范字段
  replicas: 1
  revisionHistoryLimit: 3 # 保留历史版本
  selector: # 选择器
    matchLabels: # 匹配标签
      app: test-module-deployment
  strategy: # 策略
    rollingUpdate: # 滚动更新
      maxSurge: 30% # 最大额外可以存在的副本数，可以为百分比，也可以为整数
      maxUnavailable: 30% # 示在更新过程中能够进入不可用状态的 Pod 的最大值，可以为百分比，也可以为整数
    type: RollingUpdate # 滚动更新策略
  template: # 模版
    metadata: # 资源的元数据/属性
      labels: # 设定资源的标签
        module-controller.koupleless.io/component: module # 必要，声明pod的类型，用于module controller管理
        # deployment unique id
        app: test-module-deployment-non-peer
    spec: # 资源规范字段
      containers:
        - name: biz1 # 必要，声明module的bizName，需与pom中声明的artifactId保持一致
          image: https://serverless-opensource.oss-cn-shanghai.aliyuncs.com/module-packages/stable/biz1-web-single-host-0.0.1-SNAPSHOT-ark-biz.jar
          env:
            - name: BIZ_VERSION # 必要，声明module的biz_version，value需与pom中声明的version保持一致
              value: 0.0.1-SNAPSHOT
      affinity:
        nodeAffinity: # 必要，声明基座选择器，保证模块被调度到指定的基座上
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                  - key: base.koupleless.io/stack
                    operator: In
                    values:
                      - java # 多语言环境下可能有其他技术栈，必填
                  - key: base.koupleless.io/version
                    operator: In
                    values:
                      - 1.1.1 # 指定的基座版本，必填，至少需要一个
                  - key: base.koupleless.io/name
                    operator: In
                    values:
                      - base  # 指定的基座bizName，必填，至少需要一个
      tolerations: # 必要，允许pod被调度到基座node上
        - key: "schedule.koupleless.io/virtual-node"
          operator: "Equal"
          value: "True"
          effect: "NoExecute"
```

其中所有的配置与普通Deployment一致，除必填项外，可添加其他Deployment的配置实现自定义能力。


## 查看模块状态

这一需求可以通过查看nodeName为基座对应node的Pod来实现。首先需要了解基座服务与node的对应关系。

在Module Controller V2的设计中，每一个基座会在启动时随机生成一个全局唯一的UUID作为基座服务的标识，对应的node的Name则将包含这一ID。

除此之外，基座服务的IP与node的IP是一一对应的，也可以通过IP来筛选对应的基座Node。

因此，可以通过以下命令查看某个基座上安装的所有Pod（模块），和对应的状态。

```bash
kubectl get pod -n <namespace> --field-selector status.podIP=<baseIP>
```
或
```bash
kubectl get pod -n <namespace> --field-selector spec.nodeName=virtual-node-<baseUUID>
```

## 模块下线

在 K8S 集群中删除模块的Pod或其他控制资源即可完成模块下线，例如，在Deployment部署的场景下，可以直接删除对应的Deployment实现模块的下线：

```bash
kubectl delete yourmoduledeployment --namespace yournamespace
```

其中 _yourmoduledeployment_ 替换成您的 ModuleDeployment 名字，_yournamespace_ 替换成您的 namespace。

如果要自定义模块发布运维策略（比如分组、Beta、暂停等），可参考[模块发布运维策略](/docs/tutorials/module-operation-v2/operation-and-scheduling-strategy/)。

样例演示的是使用 kubectl 方式，直接调用 K8S APIServer 删除Deployment一样能实现模块分组下线。

## 模块扩缩容

由于ModuleController V2完全复用了K8S的Pod编排方案，扩缩容只发生在ReplicaSet、Deployment、StatefulSet等部署方式上，扩缩容可以按照各自对应的扩缩容方式实现，下面以Deployment为例：

```bash
kubectl scale deployments/yourdeploymentname --namespace=yournamespace --replicas=3
```

其中 _yourdeploymentname_ 替换成您的 Deployment name，_yournamespace_ 替换成您的 namespace，replicas参数设置为希望扩/缩容到的数量。

也可以通过API调用实现扩缩容策略。

## 模块替换

在ModuleController v2中，模块与Container是强绑定的关系，如果想实现模块的替换，需要执行更新逻辑，更新模块所在Pod上的模块对应Image地址。

具体的替换方式随模块部署的方式不同而略有区别，例如，直接更新Pod信息会在原地进行模块的替换，Deployment会执行配置的更新策略（例如滚动更新，先创建新版本的Pod，再删除旧版本的Pod），DaemonSet也会执行配置的更新策略，与Deployment不同，DaemonSet是先删除后创建的逻辑，可能会造成流量损失。

## 模块回滚

由于与原生的Deployment兼容，因此可以采用Deployment的回滚方式实现模块回滚。

查看deployment历史。

```bash
kubectl rollout history deployment yourdeploymentname
```

回滚到指定版本

```bash
kubectl rollout undo deployment yourdeploymentname --to-revision=<TARGET_REVISION>
```

## 其他运维问题

### 模块流量 Service 实现方案

可以通过创建原生Service的方式创建模块的Service，仅当基座与ModuleController部署在同一VPC中时才能够正常提供服务。

由于目前基座与ModuleController并不一定部署在同一个VPC下，两者之间通过MQTT消息队列实现交互。基座node会集成基座所在Pod的IP，模块所在Pod会集成基座node的IP，因此，当基座本身与ModuleController不属于同一个VPC的时候，这里模块的IP实际上是无效的，因此无法对外提供服务。

可能的解决方案是在Service上的LB层做转发，将对应Service的流量转发到基座所在K8S的对应IP的基座服务上。后续将根据实际使用情况对这一问题进行评估与优化。

### 基座和模块不兼容发布

1. 首先部署一个module的Deployment，其中Container指定为最新版本的模块代码包地址，nodeAffinity指定新版本基座的名称和版本信息。
    此时，这一Deployment会创建出对应的Pod，但是由于还没有新版本的基座创建，因此不会被调度。

2. 更新基座Deployment，发布新版本镜像，此时会触发基座的替换和重启，基座启动时会告知ModuleController V2控制器，会创建对应版本的node。

3. 对应版本的基座node创建之后，K8S调度器会自动触发调度，将步骤1中创建的模块Pod调度到基座node上，进行新版本的模块安装，从而实现同时发布。

<br/>
<br/>
