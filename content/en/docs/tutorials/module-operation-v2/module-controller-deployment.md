---
title: 5.4 Deployment of Module Controller V2
date: 2024-07-19T09:28:32+08:00
description: Deployment methodology for Koupleless Module Controller V2
weight: 800
---

Note: ModuleController V2 has only been tested on K8S version 1.24 and relies on certain K8S features. Therefore, the K8S version should not be lower than V1.10.

### Resource File Locations

1. [Role Definition](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account_cluster_role.yaml)
2. [RBAC Definition](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account_cluster_role_binding.yaml)
3. [ServiceAccount Definition](https://github.com/koupleless/virtual-kubelet/blob/main/samples/rabc/base_service_account.yaml)
4. [ModuleControllerV2 Deployment Definition](https://github.com/koupleless/module-controller/blob/main/samples/module_controller_pod.yaml)

### Deployment Method

Use the `kubectl apply` command to sequentially apply the above four resource files to complete the deployment of a single-instance ModuleController.

For using the Module Controller's sharded cluster capability, modify the above deployment definition to a Deployment version, placing the Pod Spec content into the Deployment template.

To use load balancing in a sharded cluster, set the `IS_CLUSTER` parameter to true in the Module Controller ENV configuration.

### Configurable Parameter Explanation

## Environment Variable Configuration

Below are some configurable environment variables and their explanations:

- **ENABLE_MQTT_TUNNEL**
    - Meaning: Flag to enable MQTT operations pipeline. Set to `true` to enable. If enabled, configure the related environment variables below.

- **MQTT_BROKER**
    - Meaning: URL of the MQTT broker.

- **MQTT_PORT**
    - Meaning: MQTT port number.

- **MQTT_USERNAME**
    - Meaning: MQTT username.

- **MQTT_PASSWORD**
    - Meaning: MQTT password.

- **MQTT_CLIENT_PREFIX**
    - Meaning: MQTT client prefix.

- **ENABLE_HTTP_TUNNEL**
    - Meaning: Flag to enable HTTP operations pipeline. Set to `true` to enable. Optionally configure the environment variables below.

- **HTTP_TUNNEL_LISTEN_PORT**
    - Meaning: Module Controller HTTP operations pipeline listening port, default is 7777.

- **REPORT_HOOKS**
    - Meaning: Error reporting links. Supports multiple links separated by `;`. Currently only supports DingTalk robot webhooks.

- **ENV**
    - Meaning: Module Controller environment, set as VNode label for operations environment isolation.

- **IS_CLUSTER**
    - Meaning: Cluster flag. If `true`, Virtual Kubelet will start with cluster configuration.

- **WORKLOAD_MAX_LEVEL**
    - Meaning: Cluster configuration indicating the maximum workload level for workload calculation in Virtual Kubelet. Default is 3. Refer to Module Controller architecture design for detailed calculation rules.

- **ENABLE_MODULE_DEPLOYMENT_CONTROLLER**
    - Meaning: Flag to enable the Module Deployment Controller. If `true`, the deployment controller will start to modify Module deployment replicas and baselines.

- **VNODE_WORKER_NUM**
    - Meaning: Number of concurrent processing threads for VNode Modules. Set to 1 for single-threaded.

### Documentation Reference

For detailed structure and implementation, refer to the [documentation](/docs/contribution-guidelines/module-controller-v2/architecture/).  