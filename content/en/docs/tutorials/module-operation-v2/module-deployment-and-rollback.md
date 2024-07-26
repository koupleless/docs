---
title: Module Release
date: 2024-07-19T10:28:32+08:00
description: Koupleless Module Release
weight: 200
---
**Note:** The current ModuleController v2 has only been tested on Kubernetes version 1.24, and has not been verified on other versions. ModuleController V2 relies on certain Kubernetes features, thus the Kubernetes version must not be lower than v1.10.

## Module Release
Refer to the Deployment release method outlined in module deployment procedures for releasing modules.

## Module Rollback
Given its compatibility with native Deployments, module rollback can be achieved by leveraging the rollback mechanism of Deployments.

### Check Deployment History
To view the history of a Deployment, use:
```bash
kubectl rollout history deployment yourdeploymentname
```

### Rollback to a Specific Version
To revert to a particular revision:
```bash
kubectl rollout undo deployment yourdeploymentname --to-revision=<TARGET_REVISION>
```
<br/>
<br/>