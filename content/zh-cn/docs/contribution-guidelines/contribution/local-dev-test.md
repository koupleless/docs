---
title: 6.3.1 本地开发测试
date: 2024-01-25T10:28:32+08:00
description: Koupleless 本地开发测试
weight: 100
---

## SOFAArk 和 Arklet

SOFAArk 是一个普通 Java SDK 项目，使用 Maven 作为依赖管理和构建工具，只需要本地安装 Maven 3.6 及以上版本即可正常开发代码和单元测试，无需其它的环境准备工作。<br />关于代码提交细节请参考：[完成第一次 PR 提交](/docs/contribution-guidelines/contribution/first-pr)。

## ModuleController

ModuleController 是一个标准的 K8S Golang Operator 组件，里面包含了 ModuleDeployment Operator、ModuleReplicaSet Operator、Module Operator，在本地可以使用 minikube 做开发测试，具体请参考[本地快速开始](/docs/quick-start/module_ops)。<br />
编译构建请在 module-controller 项目里执行：

```bash
go mod download   # if compile module-controller first time
go build -a -o manager cmd/main.go
```

单元测试执行请在 module-controller 项目里执行：

```bash
make test
```

您也可以使用 IDE 进行编译构建、开发调试和单元测试执行。<br />
module-controller 开发方式和标准 K8S Operator 开发方式完全一样，您可以参考 K8S Operator 开发[官方文档](https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/operator/)。

如果想要通过 minikube 部署 ModuleController 来对 Pod 远程调试代码，可以参考以下步骤。

1. 在 module-controller 项目里构建 minikube Debug 镜像。

```bash
minikube image build -f debug.Dockerfile -t serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/module-controller-v2:latest .
```

或者

```bash
make minikube-build
```

也可以直接使用已经构建好的镜像，`serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/module-controller-v2:v2.1.4`，该镜像已经配置了 [go-delve](https://github.com/go-delve/delve) 远程 debug 环境，debug 端口为 2345。如果使用该构建好的镜像，需要修改 module-controller-test.yaml 中的拉取镜像策略从 Never 改为 Always。

```yaml
imagePullPolicy: Always
```

2. 应用 Debug deployment。

```bash
kubectl apply -f example/quick-start/module-controller-test.yaml
```

或者

```bash
make minikube-deploy
```

3. 登录到启动后的容器

```bash
kubectl exec deployments/module-controller -it -- /bin/sh
```

4. 进入容器内部，启动 delve

```bash
dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec ./module_controller
```

第三步和第四步也可以用下面命令快速启动 delve。

```bash
make minikube-debug
```

5. 暴露 module-controller 远程调试端口。

```bash
kubectl port-forward deployments/module-controller 2345:2345
```

或者

```bash
make minikube-port-forward
```

6. 在本地 IDE 上开启远程调试。参考 vscode 调试设置。

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Connect to module-controller Pod",
      "type": "go",
      "request": "attach",
      "mode": "remote",
      "port": 2345,
      "host": "127.0.0.1",
      "substitutePath": [
        {
          "from": "${cwd}",
          "to": "/workspace/module-controller"
        }
      ],
      "showLog": true,
      "logOutput": "dap"
    }
  ]
}
```

7. 在 IDE 打断点后运行调试，看看程序是否成功在断点处暂停。

8. 当修改代码后需要调试生效时，需要先关闭连接，然后关闭占用 2345 的端口转发，再 make 以下命令。

```bash
make minikube-restart
make minikube-port-forward
```

## Arkctl

Arkctl 是一个普通 Golang 项目，他是一个命令行工具集，包含了用户在本地开发和运维模块过程中的常用工具。
[可参考此处](/docs/tutorials/build_and_deploy)

<br/>
