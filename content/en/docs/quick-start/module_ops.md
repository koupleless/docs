---
title: 2.2 Module Operations
date: 2024-01-25T10:28:32+08:00
description: Quick Start with Koupleless
weight: 210
---

This quick start guide mainly introduces Module operations based on Module Controller V2. It includes:

1. Environment Preparation
2. Module Controller V2 Deployment
3. Test Base Preparation
4. Module Deployment and Status Checking

# Environment Preparation

## K8S Environment Deployment

Module Controller V2 builds Module operation capabilities based on K8S, so a basic K8S environment is needed first.

> **Note**: Module Controller currently only supports **arm64 / amd64** environments.

**If you already have a K8S cluster, skip this section.**

For local testing, it is recommended to use Minikube to quickly set up K8S locally. Minikube is an open-source tool for local Kubernetes deployment, helping quickly deploy K8S components.

To install Minikube, first, install the Docker environment: [Docker Official Website](https://www.docker.com/get-started/)

After installing Docker and starting the Docker daemon, Minikube installation preparation is complete.

Refer to the [official documentation](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download) for Minikube installation.

# Module Controller V2 Deployment

Module Controller V2 can be deployed in two ways:
1. Local execution (requires go environment, not recommended)
2. Image deployment (recommended)

Next, we will use image deployment as an example.

First, prepare necessary RBAC configuration for Module Controller V2.

1. Download [Service Account YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account.yaml)
2. Download [Cluster Role YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account_cluster_role.yaml)
3. Download [Cluster Role Binding YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account_cluster_role_binding.yaml)

Then apply the above three YAML files to set permissions and bindings for the service account.

Next, prepare the [Pod Yaml](https://github.com/koupleless/module-controller/tree/main/example/quick-start/module-controller.yaml) for Module Controller deployment:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: module-controller
  labels:
    app: module-controller
spec:
  serviceAccountName: virtual-kubelet # Service Account configured in the previous step
  containers:
    - name: module-controller
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/release/module_controller:2.1.0 # Pre-packaged image
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

Apply the above YAML to the K8S cluster, and wait for the Module Controller Pod to reach the Running state.

The Module operations capability is now set up. Next, prepare the test base and test Module.

## Test Base Deployment

To facilitate onboarding, a Docker image of a test base is provided. First, download the [Base Yaml](https://github.com/koupleless/module-controller/tree/main/example/quick-start/base.yaml):

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
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/base-web:1.1.1 # Pre-packaged image
      imagePullPolicy: Always
      ports:
        - name: base
          containerPort: 8080
        - name: arklet
          containerPort: 1238
      env:
        - name: MODULE_CONTROLLER_ADDRESS
          value: {YOUR_MODULE_CONTROLLER_IP}
```

Replace `{YOUR_MODULE_CONTROLLER_IP}` with the actual Module Controller Pod IP in the YAML.

Apply the modified YAML to the K8S cluster and wait for the Base Pod to reach the Running state.

Once the base has started, verify its successful mapping to a VNode with:

```bash
kubectl get nodes
```

If a node named vnode.test-base.dev appears and is Ready, the base is successfully started and mapped.

> The UUID above is generated at base startup and changes each restart.

Next, use `port-forward` to expose the base container's service for verification, using the command:

```bash
kubectl port-forward base 8080:8080
```

Visit [link](http://localhost:8080/biz1) to verify if it maps successfully.

## Module Deployment and Status Checking

### Module Deployment

First, verify the state before Module installation by visiting the base service: [Module Test](http://localhost:8080/biz1).

It should return an error page indicating the Module is not installed.

Next, deploy the Module using a Deployment. Apply the [Module YAML](https://github.com/koupleless/module-controller/tree/main/example/quick-start/module.yaml) to K8S for Module deployment. Here is an example for a single Module:

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
                  - key: base.koupleless.io/version
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

Once deployment is complete, use `kubectl get pods` to check the status of all Module pods.

When the pods created by the deployment reach the Running state, the Module installation is complete. Verify by visiting the base service again: [Module Test](http://localhost:8080/biz1).

You should see the content: `hello to /biz1 deploy`, indicating the Module installation is complete.

### Module Deletion

Modules can be removed by deleting their Deployment with:

```bash
kubectl delete deployment biz1
```

Check the pod deletion success with `kubectl get pods`.

After deletion, visit the base service [Module Test](http://localhost:8080/biz1) to verify Module uninstallation.

The page should revert to the state indicating the Module is uninstalled.  
