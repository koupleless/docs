---
title: 5.7 启用 Kubelet 代理
date: 2025-08-22T13:00:03+08:00
description: Koupleless Module Controller V2 Kubelet 代理的启用方式
weight: 1100
---

## Kubelet 代理

Kubelet 代理是 Module Controller V2 在 K8s 侧的增强功能，它允许用户通过 ``kubectl`` 工具直接与 Module Controller V2 交互，
提供类似于 K8s 原生 Kubelet 的操作体验。

设计请参考[文档](/docs/contribution-guidelines/module-controller-v2/virtual-kubelet-proxy)

## 启用 Kubelet 代理

0. 部署 cert-manager 管理证书的生成与轮换
   cert-manager 是一个 Kubernetes 插件，用于自动化管理和轮换 TLS 证书。它可以帮助我们生成和管理用于 Kubelet 代理的 TLS 证书。
   请参考 [cert-manager 文档](https://cert-manager.io/docs/installation/) 进行安装。
   这里给出一个简单的安装示例(v1.18.2)：

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml
```

部署成功后，我们部署相应的 Issuer 以及 Certificate:

- 创建 Issuer

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: virtual-kubelet-issuer
spec:
  selfSigned: {}
```

- 创建 Cert

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: virtual-kubelet-cert
spec:
  secretName: virtual-kubelet-tls # 证书存储的 Secret 名称，后续我们将会在 ModuleController 中使用
  duration: 2160h # 90天
  renewBefore: 360h # 15天前续期
  issuerRef:
    name: virtual-kubelet-issuer # 上一步创建的 Issuer
    kind: ClusterIssuer
  commonName: koupleless-virtual-kubelet # 公共名称
  usages:
  - server auth 
  - digital signature
  - key encipherment
```

创建完毕后，可以通过以下命令查看证书密钥是否生成成功：

```bash
kubectl get secret virtual-kubelet-tls
```

如果输出类似以下内容，说明证书生成成功：

```
NAME                   TYPE                DATA   AGE
virtual-kubelet-tls    kubernetes.io/tls   3      1m
```

1. 为 Role 增加 `pods/log` 权限

```yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: virtual-kubelet-role
rules:
  - apiGroups: [""] # "" indicates the core API group
    resources: ["pods" , "pods/status", "pods/spec","nodes", "nodes/status", "events", "pods/log"]
    verbs: ["get", "watch", "list", "update", "patch", "create", "delete"]
  - apiGroups: [ "apps" ]
    resources: [ "deployments", "deployments/status", "deployments/spec", "daemonSets", "daemonSets/status", "daemonSets/spec" ]
    verbs: [ "get", "watch", "list" ]
  - apiGroups: [""] # "" indicates the core API group
    resources: ["configmaps", "secrets", "services"]
    verbs: ["get", "watch", "list"]
  - apiGroups: ["coordination.k8s.io"] # "" indicates the core API group
    resources: ["leases"]
    verbs: ["get", "watch", "list", "update", "patch", "create", "delete"]
```

2. 为 ModuleController 部署创建 Service

```yaml
apiVersion: v1
kind: Service
metadata:
    name: module-controller
    namespace: default
    labels:
        app: module-controller
        virtual-kubelet.koupleless.io/kubelet-proxy-service: "true" # 必须，用于标识这是 Kubelet 的代理 Service
spec:
    selector:
        app: module-controller
    ports:
        - name: httptunnel # 运维 HTTP 管道端口，如果启用了 MQTT 管道，请将此端口删除
          port: 7777
          targetPort: 7777
        - name: kubelet-proxy # Kubelet 代理端口，与 ModuleController ENV 中的 KUBELET_PROXY_PORT 保持一致
          port: 10250
    type: ClusterIP
```

3. 修改 ModuleController 的 ENV 配置

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: module-controller
spec:
  replicas: 1
  selector:
    matchLabels:
      app: module-controller
  template:
    metadata:
      labels:
        app: module-controller
    spec:
      serviceAccountName: virtual-kubelet
      volumes:
        - name: tls-certs
          secret:
            secretName: virtual-kubelet-tls # 必须，挂载前面创建的 TLS 证书
      containers:
        - name: module-controller
          image: serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/release/module-controller-v2:<版本号>
          imagePullPolicy: IfNotPresent
          resources:
            limits:
              cpu: "1000m"
              memory: "400Mi"
          ports:
            - name: httptunnel # 如果未启用 HTTP 管道，请将此端口删除
              containerPort: 7777
            - name: kubelet-proxy # Kubelet 代理端口
              containerPort: 10250
          env:
            - name: ENABLE_HTTP_TUNNEL
              value: "true"
            - name: NAMESPACE # 必须，用于标识 ModuleController Pod 所在的命名空间
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
            - name: KUBELET_PROXY_ENABLED # 必须，启用 Kubelet 代理
              value: "true"
          volumeMounts: # 必须，挂载 TLS 证书
            - name: tls-certs
              mountPath: /etc/virtual-kubelet/tls
              readOnly: true
```

## 验证 Kubelet 代理

假设目前已部署了名为 `biz1-web-single-host` 的模块，并且 Module Controller 启用了 Kubelet 代理。

```
NAME                                    READY   STATUS    RESTARTS   AGE
base-76d79d8599-f64jt                   1/1     Running   0          13d
biz1-web-single-host-786dfc476f-qsp7q   1/1     Running   0          7m40s
module-controller-59f7bb765-8w84l       1/1     Running   0          13d
```

此时，通过 kubectl 命令可以直接访问模块的日志：

```bash
kubectl logs --tail=50 biz1-web-single-host-786dfc476f-qsp7q
```

期望会有正常的日志输出，如果报错，则可能是 Kubelet 代理未正确配置或未启用。
