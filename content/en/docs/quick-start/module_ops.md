---
title: 2.2 Module Operations
date: 2024-01-25T10:28:32+08:00
description: Quick Start with Koupleless
weight: 210
---

This quick start guide primarily introduces module operations based on Module Controller V2. It encompasses:

1. Environment Setup
2. Deployment of Module Controller V2
3. Preparation of Test Base
4. Module Publishing and Status Checking

# Environment Preparation

## Deployment of K8S Environment

Module Controller V2 builds its module operation capabilities upon K8S, thus requiring a foundational K8S environment.

> **Note:** Currently, Module Controller only supports execution environments for **arm64 / amd64**.

**Skip this section if you already have an available K8S cluster.**

For local testing, it's recommended to use Minikube to quickly set up K8S locally. Minikube is an open-source tool for local Kubernetes setup, facilitating the swift deployment of all K8S dependent components.

To install Minikube, first, you need to set up the Docker runtime environment: [Docker Official Website](https://www.docker.com/get-started/)

After installing Docker and starting the Docker daemon, preparations for Minikube installation are complete.

Minikube installation can be referred to in the [official documentation](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download)

## Preparation of MQTT Environment

Module Controller V2 incorporates an operational pipeline based on MQTT, relying on MQTT for command issuance and data synchronization. Therefore, an MQTT service must be prepared.

**Skip this section if you already have an available MQTT service.**

For testing purposes, it's advised to directly utilize the MQTT service image from NanoMQ. Deploy the MQTT service using the [yaml](https://github.com/koupleless/docs/tree/main/static/example/module-controller/mqtt.yaml) in K8S:

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

Post-deployment, use `kubectl get pods -o wide` to check the status. Once the container state turns to Running, note down the Pod IP for subsequent steps.

# Deployment of Module Controller V2

Module Controller V2 offers two deployment methods:
1. Local Execution (requires Go environment setup, not recommended)
2. Image Deployment (recommended)

We proceed with image deployment as an example.

First, we need to prepare the necessary RBAC configurations for Module Controller V2.

1. Download the [Service Account YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account.yaml)
2. Download the [Cluster Role YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account_cluster_role.yaml)
3. Download the [Cluster Role Binding YAML](https://github.com/koupleless/module-controller/blob/main/samples/rbac/base_service_account_cluster_role_binding.yaml)

Sequentially apply these three YAML files to complete the service account permissions setting and binding.

Next, we need to prepare the [Pod YAML](https://github.com/koupleless/docs/tree/main/static/example/module-controller/module-controller.yaml) for Module Controller deployment:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: module-controller
  labels:
    app: module-controller
spec:
  serviceAccountName: virtual-kubelet # Service Account configured earlier
  containers:
    - name: module-controller
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/release/module_controller:2.0.0 # Pre-built image
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

Ensure to replace `YOUR_MQTT_BROKER` in the above YAML with the actual MQTT service endpoint. If you followed the tutorial to deploy NanoMQ, substitute it with the mqtt Pod IP obtained during MQTT environment preparation.

Apply the above Module Controller YAML to the K8S cluster and wait for the Module Controller Pod to transition to Running status.

With that, the module operation capability is established. Next, we'll prepare a test base and a test module.

## Deployment of Test Base

For ease of getting started, we also provide a Docker image for the test base. Download the [Base YAML](https://github.com/koupleless/docs/tree/main/static/example/module-controller/base.yaml)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: base
  labels:
    app: base
spec:
  serviceAccountName: virtual-kubelet # Service Account configured earlier
  containers:
    - name: base
      image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/base # Pre-built image
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

Similarly, replace `YOUR_MQTT_BROKER` in the YAML with the actual MQTT service endpoint. If you deployed NanoMQ, replace it with the mqtt Pod IP from the MQTT environment preparation.

Apply the modified YAML to the K8S cluster and wait for the Base Pod to turn into Running status.

Upon base startup completion, we can verify the base has successfully mapped to a VNode through:

```bash
kubectl get nodes
```

If a node named vnode.{uuid} appears, with a status of Ready, it indicates the base has successfully started and mapped.

For convenient verification, expose the base container's service using `port-forward`:

```bash
kubectl port-forward base 8080:8080
```

Visit [this link](http://localhost:8080/biz1). A successful visit confirms the mapping is complete.

## Testing Module Publishing and Status Checking

### Module Publishing

To compare, let's first look at the scenario before the module is installed. Visit the base service: [Module Test](http://localhost:8080/biz1)

An error page should appear, indicating the module is not yet installed.

Next, we'll publish the module using a Deployment. Apply the following module [yaml](https://github.com/koupleless/docs/tree/main/static/example/module-controller/module.yaml) to K8S for module publication, using a single module as an example:

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

Once the deployment is complete, you can view the status of all module pods using `kubectl get pods`.

When the Deployment-created pod status changes to Running, it indicates the current module has been successfully installed. Now, revisit the base service: [Module Test](http://localhost:8080/biz1) to verify the module installation.

You will observe that the page content has changed, displaying: `hello to /biz1 deploy`, confirming the module installation is complete.

### Module Deletion

Module deletion can be directly achieved by deleting the module's Deployment, using the command:

```bash
kubectl delete deployment biz1
```

Use `kubectl get pods` to verify whether the pod has been successfully deleted.

After successful deletion, revisit the base service [Module Test](http://localhost:8080/biz1) to validate the module uninstallation.

The page content reverts back to the state before the module was installed, indicating the module has been successfully uninstalled. 