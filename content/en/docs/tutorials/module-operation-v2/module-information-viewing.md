---
title: 5.5 Module Information Retrieval
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Information Retrieval
weight: 900
---

#### View the names and statuses of all installed modules on a base instance
```bash
kubectl get module -n <namespace> -l koupleless.alipay.com/base-instance-ip=<pod-ip> -o custom-columns=NAME:.metadata.name,STATUS:.status.status
```
or
```bash
kubectl get module -n <namespace> -l koupleless.alipay.com/base-instance-name=<pod-name> -o custom-columns=NAME:.metadata.name,STATUS:.status.status
```
#### View detailed information of all installed modules on a base instance
```bash
kubectl describe module -n <namespace> -l koupleless.alipay.com/base-instance-ip=<pod-ip>
```
or
```bash
kubectl describe module -n <namespace> -l koupleless.alipay.com/base-instance-name=<pod-name>
```

Replace ```<pod-ip>``` with the IP of the base instance you want to view, ```<pod-name>``` with the name of the base instance you want to view, and ```<namespace>``` with the namespace of the resources you want to view.
