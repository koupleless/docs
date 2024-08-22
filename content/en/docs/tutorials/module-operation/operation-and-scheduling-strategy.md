title: Module Deployment Operation Strategy
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Deployment Operation Strategy
weight: 600
draft: true
---

## Operation Strategy
To achieve lossless changes in the production environment, module deployment operations provide secure and reliable change capabilities. Users can configure the change strategy of deployment operations in the operationStrategy field of the ModuleDeployment CR spec. The specific fields in operationStrategy are explained as follows:

| Field Name | Field Explanation                                                                                                                                                                                          | Value Range | Description |
| --- |------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| --- | --- |
| batchCount | Number of batches for deployment operations                                                                                                                                                                | 1 - N | Deploy modules in 1 to N batches |
| useBeta | Whether to enable beta group deployment. Enabling beta group deployment will allow only one IP for the first batch, and the remaining IPs will be divided into (batchCount - 1) batches                    | true or false | true means enabling beta group, false means not enabling beta group |
| needConfirm | Whether to enable group confirmation. When enabled, after each batch of module deployment operations, it will pause. After modifying ModuleDeployment.spec.pause to **false**, the operation will continue | true or false | true means enabling group confirmation, false means not enabling group confirmation |
| grayTime | After each batch of deployment operations is completed, how long to sleep before executing the next batch                                                                                                  | 0 - N | The gray time between batches, in seconds. 0 means executing the next batch immediately after the batch is completed, N means sleeping N seconds before executing the next batch |

## Scheduling Strategy
You can configure the Label "koupleless.alipay.com/max-module-count" for the base K8S Pod Deployment to specify how many modules can be installed on each Pod at most. Supports configuration of integers from 0 to N. Modules support scatter scheduling and stacking scheduling. <br />
**Scatter Scheduling**: Set ModuleDeployment.spec.schedulingStrategy.schedulingPolicy to **scatter**. Scatter scheduling means that when modules are deployed, scaled, or replaced, they are preferentially scheduled to machines with the fewest number of modules installed. <br />
**Stacking Scheduling**: Set ModuleDeployment.spec.schedulingStrategy.schedulingPolicy to **stacking**. Stacking scheduling means that when modules are deployed, scaled, or replaced, they are preferentially scheduled to machines with the most modules installed and not yet reaching the base max-module-count limit.

## Protection Mechanism
_(Under development, scheduled for release on October 15th)_ You can configure ModuleDeployment.spec.maxUnavailable to specify how many module replicas can be unavailable simultaneously during deployment operations. Module deployment operations require updating K8S Service and uninstalling modules, which may result in some module replicas being unavailable. **Configuring it to 50%** means that for a batch of module deployment operations, at least **50% of module replicas must be available**, otherwise ModuleDeployment.status will display an error message.

## Peer and Non-Peer
You can configure ModuleDeployment.spec.replicas to specify whether the module adopts peer-to-peer or non-peer deployment architecture. <br />
**Non-Peer Architecture**: Set ModuleDeployment.spec.replicas to **0 - N** to indicate a non-peer architecture. In a non-peer architecture, you must set the number of replicas for ModuleDeployment and ModuleReplicaSet, so scaling operations for modules are supported. <br />
**Peer Architecture**: Set ModuleDeployment.spec.replicas to **-1** to indicate a peer architecture. In a peer architecture, as many modules are installed on Pods as the number of replicas for the K8S Pod Deployment, and the number of module replicas is always consistent with the number of replicas for the K8S Pod Deployment. Therefore, scaling operations for modules are not supported in a peer architecture. _Peer architecture is under construction and is scheduled for release on October 30th._


<br/>
<br/>
