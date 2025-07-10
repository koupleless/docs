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
The development approach for module-controller is the same as the standard K8S Operator development approach. You can refer to the [official K8S Operator development documentation](https://kubernetes.io/zh-cn/docs/concepts/extend-kubernetes/operator/).

If you want to deploy ModuleController via minikube for remote debugging of the Pod code, you can follow these steps:

1. Build a minikube Debug image in the module-controller project.

```bash
minikube image build -f debug.Dockerfile -t serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/module-controller-v2:latest .
```

Or

```bash
make minikube-build
```

Alternatively, you can directly use a pre-built image, `serverless-registry.cn-shanghai.cr.aliyuncs.com/opensource/test/module-controller-v2:v2.1.4`, which has already been configured with a [go-delve](https://github.com/go-delve/delve) remote debug environment, with debug port 2345. If you use this pre-built image, you need to modify the image pull policy in module-controller-test.yaml from Never to Always.

```yaml
imagePullPolicy: Always
```

2. Apply the Debug deployment.

```bash
kubectl apply -f example/quick-start/module-controller-test.yaml
```

Or

```bash
make minikube-deploy
```

3. Log into the started container.

```bash
kubectl exec deployments/module-controller -it -- /bin/sh
```

4. Inside the container, start delve.

```bash
dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec ./module_controller
```

Steps 3 and 4 can also be quickly executed with the following command.

```bash
make minikube-debug
```

5. Expose the module-controller remote debugging port.

```bash
kubectl port-forward deployments/module-controller 2345:2345
```

Or

```bash
make minikube-port-forward
```

6. Enable remote debugging in your local IDE. Reference VS Code debug configuration:

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

7. Set breakpoints in your IDE and run the debugger to verify that the program successfully pauses at the breakpoints.

8. When you need your code changes to take effect for debugging, you need to first close the connection, then stop the port forwarding on port 2345, and then run the following commands.

```bash
make minikube-restart
make minikube-port-forward
```

## Arkctl

Arkctl is a regular Golang project, which is a command-line toolset that includes common tools for users to develop and maintain modules locally.
[You can refer here](/docs/tutorials/build_and_deploy)

<br/>
