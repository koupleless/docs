---
title: Module Information Inquiry
date: 2024-07-19T10:28:32+08:00
description: Inspection of Installed Modules on Koupleless Base
weight: 800
---
## Viewing All Installed Module Names and Statuses on a Base

This requirement can be fulfilled by examining the Pods associated with the node that corresponds to the base. Initially, it's essential to comprehend the mapping between the base service and the node.

In the design of Module Controller V2, each base generates a globally unique UUID at startup, which serves as an identifier for the base service. The Name of the corresponding node incorporates this ID. Furthermore, the IP of the base service is in one-to-one correspondence with the node's IP, allowing the base Node to be identified via its IP as well.

Consequently, to view all Pods (modules) installed on a specific base, along with their respective statuses, you may employ the following commands:

```bash
kubectl get pod -n <namespace> --field-selector status.podIP=<baseIP>
```

or

```bash
kubectl get pod -n <namespace> --field-selector spec.nodeName=virtual-node-<baseUUID>
```