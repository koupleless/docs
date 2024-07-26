---
title: 模块上线与下线
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

## 模块下线
在 K8S 集群中删除模块的Pod或其他控制资源即可完成模块下线，例如，在Deployment部署的场景下，可以直接删除对应的Deployment实现模块的下线：
```bash
kubectl delete yourmoduledeployment --namespace yournamespace
```
其中 _yourmoduledeployment_ 替换成您的 ModuleDeployment 名字，_yournamespace_ 替换成您的 namespace。

如果要自定义模块发布运维策略（比如分组、Beta、暂停等），可参考[模块发布运维策略](/docs/tutorials/module-operation-v2/operation-and-scheduling-strategy/)。

样例演示的是使用 kubectl 方式，直接调用 K8S APIServer 删除Deployment一样能实现模块分组下线。

<br/>
<br/>
