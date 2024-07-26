---
title: Module Controller V2 部署
date: 2024-07-19T10:28:32+08:00
description: Koupleless Module Controller V2的部署方式
weight: 700
---

注意：当前 ModuleController v2 仅在 K8S 1.24 版本测试过，没有在其它版本测试，ModuleController V2依赖了部分K8S特性，K8S的版本不能低于V1.10。

### 资源文件位置

// TODO 更新链接
1. [Role 定义](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account_cluster_role.yaml)
2. [RBAC 定义](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account_cluster_role_binding.yaml)
3. [ServiceAccount 定义](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account.yaml)
4. [ModuleControllerV2 部署定义](https://github.com/koupleless/virtual-kubelet/blob/main/samples/virtual_kubelet_pod.yaml)

### 部署方式

使用 kubectl apply 命令，依次 apply 上述 4 个资源文件，即可完成 ModuleController 部署。

<br/>
<br/>
