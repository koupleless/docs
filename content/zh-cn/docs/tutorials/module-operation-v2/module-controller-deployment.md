---
title: 5.4 Module Controller 部署
date: 2024-07-19T09:28:32+08:00
description: Koupleless Module Controller V2的部署方式
weight: 800
---

注意：当前 ModuleController v2 仅在 K8S 1.24 版本测试过，没有在其它版本测试，ModuleController V2依赖了部分K8S特性，K8S的版本不能低于V1.10。

### 资源文件位置

1. [Role 定义](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account_cluster_role.yaml)
2. [RBAC 定义](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account_cluster_role_binding.yaml)
3. [ServiceAccount 定义](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account.yaml)
4. [ModuleControllerV2 部署定义](https://github.com/koupleless/module-controller/blob/main/samples/module_controller_pod.yaml)

### 部署方式

使用 kubectl apply 命令，依次 apply 上述 4 个资源文件，即可完成单实例 ModuleController 部署。

如使用 Module Controller 分片集群能力，指需要将上述部署定义修改为 Deployment 版本，将 Pod Spec 中内容放到 Deployment template 中。

如需在分片集群中使用负载均衡能力，需要在 Module Controller ENV 配置中将 IS_CLUSTER 参数置为 true。

### 可配置参数解析

## 环境变量配置

以下是一些可配置的环境变量及其解释：

- **ENABLE_MQTT_TUNNEL**
- 含义: MQTT 运维管道启用标志。设置为 `true` 表示启用 MQTT 运维管道，如启用，请配置以下相关环境变量。

- **MQTT_BROKER**
- 含义: MQTT 代理的 URL。

- **MQTT_PORT**
- 含义: MQTT 端口号。

- **MQTT_USERNAME**
- 含义: MQTT 用户名。

- **MQTT_PASSWORD**
- 含义: MQTT 密码。

- **MQTT_CLIENT_PREFIX**
- 含义: MQTT 客户端前缀。

- **ENABLE_HTTP_TUNNEL**
- 含义: HTTP 运维管道启用标志。设置为 `true` 表示启用 HTTP 运维管道，可选择配置以下环境变量。

- **HTTP_TUNNEL_LISTEN_PORT**
- 含义: 模块控制器 HTTP 运维管道监听端口，默认使用 7777。

- **REPORT_HOOKS**
- 含义: 错误上报链接，支持多个链接，用`;`进行分割，目前仅支持钉钉机器人 webhook。

- **ENV**
- 含义: Module Controller环境，将设置为VNode标签，用于运维环境隔离。

- **IS_CLUSTER**
- 含义: 集群标志，若为 `true`，将使用集群配置启动 Virtual kubelet。

- **WORKLOAD_MAX_LEVEL**
- 含义: 集群配置，表示 Virtual kubelet 中工作负载计算的最大工作负载级别，默认值为 3，详细计算规则请参考 Module Controller 架构设计。

- **ENABLE_MODULE_DEPLOYMENT_CONTROLLER**
- 含义: Module Deployment Controller 启用标志，若为 `true`，将启动部署控制器以修改模块部署的副本和基线。

- **VNODE_WORKER_NUM**
- 含义: VNode 并发模块处理线程数，设为 1 表示单线程。

### 文档参考

具体的结构和实现介绍请参考[文档](/docs/contribution-guidelines/module-controller-v2/architecture/)

<br/>
<br/>
