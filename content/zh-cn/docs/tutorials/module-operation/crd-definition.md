---
title: 所有 K8S 资源定义及部署方式
date: 2024-01-25T10:28:32+08:00
description: Koupleless 所有 K8S 资源定义及部署方式
weight: 900
---

注意：当前 ModuleController 在 K8S 1.24 版本测试过，没有在其它版本测试，但 ModuleController 没有依赖 K8S 过多特性，理论上可以支持 K8S 其它版本。

### 资源文件位置

1. [ModuleDeployment CRD 定义](https://github.com/koupleless/module-controller/blob/main/config/crd/bases/koupleless.io_moduledeployments.yaml)
2. [ModuleReplicaset CRD 定义](https://github.com/koupleless/module-controller/blob/main/config/crd/bases/koupleless.io_modulereplicasets.yaml) 
3. [ModuleTemplate CRD 定义](https://github.com/koupleless/module-controller/blob/main/config/crd/bases/koupleless.io_moduletemplates.yaml)
4. [Module CRD 定义](https://github.com/koupleless/module-controller/blob/main/config/crd/bases/koupleless.io_modules.yaml)
5. [Role 定义](https://github.com/koupleless/module-controller/blob/master/config/rbac/role.yaml)
6. [RBAC 定义](https://github.com/koupleless/module-controller/blob/master/config/rbac/role_binding.yaml)
7. [ServiceAccount 定义](https://github.com/koupleless/module-controller/blob/master/config/rbac/service_account.yaml)
8. [ModuleController 部署定义](https://github.com/koupleless/module-controller/blob/master/config/samples/module-deployment-controller.yaml)

### 部署方式

使用 kubectl apply 命令，依次 apply 上述 8 个资源文件，即可完成 ModuleController 部署。

<br/>
<br/>
