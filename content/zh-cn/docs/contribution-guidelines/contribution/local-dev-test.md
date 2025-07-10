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

1. 在 modue-controller 项目里构建 minikube Debug 镜像。

```bash
minikube image build -f debug.Dockerfile -t serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/module-controller-v2:latest .
```

2. 应用 Debug deployment。

```bash
kubectl apply -f example/quick-start/module-controller-test.yaml
```

3. 暴露 module-controller 远程调试端口。

```bash
kubectl port-forward deployments/module-controller 2345:2345
```

4. 在本地 IDE 上开启远程调试。参考 vscode 调试设置。

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

5. 在 ide 打断点后运行调试，看看程序是否成功在断点处暂停。

上面的第一步和第二步可以使用下面的命令来快速构建调试。

```
make minikube-debug
```

## Arkctl

Arkctl 是一个普通 Golang 项目，他是一个命令行工具集，包含了用户在本地开发和运维模块过程中的常用工具。
[可参考此处](/docs/tutorials/build_and_deploy)

<br/>
