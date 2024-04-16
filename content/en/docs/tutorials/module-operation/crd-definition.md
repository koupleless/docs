---
title: All K8S Resource Definitions and Deployment Methods
date: 2024-01-25T10:28:32+08:00
description: Koupleless All K8S Resource Definitions and Deployment Methods
weight: 900
---

### Resource File Locations

1. [ModuleDeployment CRD Definition](https://github.com/koupleless/module-controller/blob/main/config/crd/bases/koupleless.io_moduledeployments.yaml)
2. [ModuleReplicaset CRD Definition](https://github.com/koupleless/module-controller/blob/main/config/crd/bases/koupleless.io_modulereplicasets.yaml)
3. [ModuleTemplate CRD Definition](https://github.com/koupleless/module-controller/blob/main/config/crd/bases/koupleless.io_moduletemplates.yaml)
4. [Module CRD Definition](https://github.com/koupleless/module-controller/blob/main/config/crd/bases/koupleless.io_modules.yaml)
5. [Role Definition](https://github.com/koupleless/module-controller/blob/main/config/rbac/role.yaml)
6. [RBAC Definition](https://github.com/koupleless/module-controller/blob/main/config/rbac/role_binding.yaml)
7. [ServiceAccount Definition](https://github.com/koupleless/module-controller/blob/main/config/rbac/service_account.yaml)
8. [ModuleController Deployment Definition](https://github.com/koupleless/module-controller/blob/main/config/samples/module-deployment-controller.yaml)

### Deployment Method

Use the `kubectl apply` command to apply the 8 resource files listed above sequentially to deploy the ModuleController.

<br/>
<br/>