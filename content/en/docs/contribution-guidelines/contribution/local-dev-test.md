---
title: 6.3.1 Local Development Testing
date: 2024-01-25T10:28:32+08:00
description: Koupleless Local Development Testing
weight: 100
---

## SOFAArk and Arklet

SOFAArk is a regular Java SDK project that uses Maven as its dependency management and build tool. You only need to install Maven 3.6 or higher locally to develop code and run unit tests normally, without any other environment preparation. <br /> For details on code submission, please refer to: [Completing the First PR Submission](/docs/contribution-guidelines/contribution/first-pr/).

## ModuleController

ModuleController is a standard K8S Golang Operator component, which includes ModuleDeployment Operator, ModuleReplicaSet Operator, and Module Operator. You can use minikube for local development testing. For details, please refer to [Local Quick Start](/docs/quick-start/module_ops/). <br />
To compile and build, execute the following command in the module-controller directory:

```bash
go mod download   # if compile module-controller first time
go build -a -o manager cmd/main.go
```

To run unit tests, execute the following command in the module-controller directory:

```bash
make test
```

You can also use an IDE for compiling, building, debugging, and running unit tests.<br />
The development approach for module-controller is exactly the same as the standard K8S Operator development approach. You can refer to the [official K8S Operator development documentation](https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/operator/).

If you want to deploy ModuleController via minikube for remote debugging of the Pod code, you can follow these steps:

1. Build a minikube Debug image in the module-controller project.

```bash
minikube image build -f debug.Dockerfile -t serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/module-controller-v2:latest .
```

2. Apply the Debug deployment.

```bash
kubectl apply -f example/quick-start/module-controller-test.yaml
```

3. Expose the module-controller remote debugging port.

```bash
kubectl port-forward deployments/module-controller 2345:2345
```

4. Enable remote debugging in your local IDE. Here's a reference for VSCode debug configuration:

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

5. Set breakpoints in your IDE and run the debugger to check if the program successfully pauses at the breakpoints.

You can use the following command to quickly complete steps 1 and 2 above:

```
make minikube-debug
```

## Arkctl

Arkctl is a regular Golang project, which is a command-line toolset that includes common tools for users to develop and maintain modules locally.
[You can refer here](/docs/tutorials/build_and_deploy)

<br/>
