---
title: Deployment of Module Controller V2
date: 2024-07-19T10:28:32+08:00
description: Deployment methodology for Koupleless Module Controller V2
weight: 700
---
**Note:** The current ModuleController v2 has only been tested on K8S version 1.24, with no testing conducted on other versions. ModuleController V2 relies on certain Kubernetes (K8S) features, thus the K8S version must not be lower than v1.10.

### Resource File Locations

1. **Role Definition:** [Link](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rbac/base_service_account_cluster_role.yaml)
2. **RBAC Definition:** [Link](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rbac/base_service_account_cluster_role_binding.yaml)
3. **ServiceAccount Definition:** [Link](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rbac/base_service_account.yaml)
4. **ModuleControllerV2 Deployment Definition:** [Link](https://github.com/koupleless/virtual-kubelet/blob/main/samples/virtual_kubelet_pod.yaml)

### Deployment Procedure
To deploy the ModuleController, sequentially apply the above four resource files using the `kubectl apply` command.
<br/>
<br/>