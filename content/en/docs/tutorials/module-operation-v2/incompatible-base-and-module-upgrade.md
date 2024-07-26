---
title: Incompatible Release of Base and Modules
date: 2024-07-19T10:28:32+08:00
description: Incompatible Release of Koupleless Base and Modules
weight: 300
---

## Step 1
Begin by deploying a `module` Deployment, where the `Container` is specified as the address of the latest version of the module code package, and `nodeAffinity` defines the name and version details of the new base version.
At this stage, this Deployment will create a corresponding Pod; however, since no instances of the new base version have been created yet, it will not be scheduled for deployment.

## Step 2
Update the `Base` Deployment to release the new version image. This triggers a replacement and restart of the base, which, upon startup, informs the `ModuleController V2` about the need to create nodes matching the base's updated version.

## Step 3
Following the creation of nodes matching the new base version, the Kubernetes (K8S) scheduler automatically initiates scheduling. It then assigns the Pod created in Step 1 to the appropriate base node, facilitating the installation of the new module version. This process achieves a simultaneous release of both base and modules.
<br/>
<br/>