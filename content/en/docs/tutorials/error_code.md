---
title: Error Codes
date: 2024-03-08T10:28:32+08:00
weight: 1000
---
This article mainly introduces the error codes of Arklet, ModuleController, and KouplelessBoard.
## ErrorCode Rules
Two-level error codes, support dynamic combination, using PascalCase, different levels of error codes can only be separated by "."<br />such as Arklet.InstallModuleFailed<br />Level 1: Error Source<br />Level 2: Error Type
## Suggestion
Briefly explain the solution for upstream operations to refer to.
## Arklet Error Codes
### Level 1: Error Source
| Code | Meaning |
| --- | --- |
| User | Errors caused by the user |
| Arklet | Exceptions from Arklet itself |
| ModuleController | Exceptions caused by specific upstream components |
| OtherUpstream | Exceptions caused by unknown upstream |
### Level 2: Error Type
| Business Type | Error Source | Error Type | Meaning | Solution |
| --- | --- | --- | --- | --- |
| General | Arklet | UnknownError | Unknown error (default) | Please check |
| <br /> | ModuleController | InvalidParameter | Parameter validation failed | Please check the parameters |
|  | ModuleController | InvalidRequest | Invalid operation type | Please check the request |
|  | OtherUpstream | DecodeURLFailed | URL parsing failed | Please check if the URL is valid |
| Query Related | Arklet | NoMatchedBiz | Module query failed, no target biz exists | - |
|  | Arklet | InvalidBizName | Module query failed, query parameter bizName cannot be empty | Please add the query parameter bizName |
| Installation Related | Arklet | InstallationRequirementNotMet | Module installation conditions are not met | Please check the necessary parameters for module installation |
|  | Arklet | PullBizError | Package pulling failed | Please retry |
|  | Arklet | PullBizTimeOut | Package pulling timed out | Please retry |
|  | User | DiskFull | Disk full when pulling the package | Please replace the base |
|  | User | MachineMalfunction | Machine malfunction | Please restart the base |
|  | User | MetaspaceFull | Metaspace exceeds the threshold | Please restart the base |
|  | Arklet | InstallBizExecuting | Module is being installed | Please retry |
| <br /> | Arklet | InstallBizTimedOut | Uninstalling old module failed during module installation | Please check |
|  | Arklet | InstallBizFailed | New module installation failed during module installation | Please check |
|  | User | InstallBizUserError | Module installation failed, business exception | Please check the business code |
| Uninstallation Related | Arklet | UninstallBizFailed | Uninstallation failed, current biz still exists in the container | Please check |
|  | Arklet | UnInstallationRequirementNotMet | Module uninstallation conditions are not met | The current module has multiple versions, and the version to be uninstalled is in the active state, which is not allowed to be uninstalled |
## ModuleController Error Codes
### Level 1: Error Source
| Code | Meaning |
| --- | --- |
| User | Errors caused by the user |
| ModuleController | Exceptions from ModuleController itself |
| KouplelessBoard | Exceptions caused by specific upstream components |
| Arklet | Exceptions caused by specific downstream components |
| OtherUpstream | Exceptions caused by unknown upstream |
| OtherDownstream | Exceptions caused by unknown downstream |
### Level 2: Error Type
| Business Type | Error Source | Error Type | Meaning | Solution |
| --- | --- | --- | --- | --- |
| General | ModuleController | UnknownError | Unknown error (default) | Please check |
| <br /> | OtherUpstream | InvalidParameter | Parameter validation failed | Please check the parameters |
|  | Arklet | ArkletServiceNotFound | Base service not found | Please ensure that the base has Koupleless dependency |
|  | Arklet | NetworkError | Network call exception | Please retry |
|  | OtherUpstream | SecretAKError | Signature exception | Please confirm that there are operation permissions |
|  | ModuleController | DBAccessError | Database read/write failed | Please retry |
|  | OtherUpstream | DecodeURLFailed | URL parsing failed | Please check if the URL is valid |
|  | ModuleController | RetryTimesExceeded | Multiple retries failed | Please check |
|  | ModuleController | ProcessNodeMissed | Lack of available working nodes | Please retry later |
|  | ModuleController | ServiceMissed | Service missing | Please check if ModuleController version contains the template type |
|  | ModuleController | ResourceConstraned | Resource limited (thread pool, queue, etc. full) | Please retry later |
| Installation Related | Arklet | InstallModuleTimedOut | Module installation timed out | Please retry |
|  | Arklet / User | InstallModuleFailed | Module installation failed | Please check the failure reason |
|  | Arklet | InstallModuleExecuting | Module is being installed | The same module is being installed, please retry later |
|  | User | DiskFull | Disk full | Please replace |
| Uninstallation Related | OtherUpstream | EmptyIPList | IP list is empty | Please enter the IP to be uninstalled |
| <br /> | Arklet | UninstallBizTimedOut | Module uninstallation timed out | Please retry |
| <br /> | Arklet | UninstallBizFailed | Module uninstallation failed | Please check |
| Base Related | ModuleController | BaseInstanceNotFound | Base instance not found | Please ensure that the base instance exists |
| <br /> | KubeAPIServer | GetBaseInstanceFailed | Failed to query base information | Please ensure that the base instance exists |
|  | ModuleController | BaseInstanceInOperation | Base instance is under operation | Please retry later |
|  | ModuleController | BaseInstanceNotReady | Base data not read or base is not available | Please ensure that the base is available |
|  | ModuleController | BaseInstanceHasBeenReplaced | Base instance has been replaced | Additional base instances will be added later, please wait |
|  | ModuleController | InsufficientHealthyBaseInstance | Insufficient healthy base instances | Please scale out |
| Scaling Related | ModuleController | RescaleRequirementNotMet | Scaling conditions are not met | Please check if there are enough machines for scaling/Check the scaling ratio |

⚠️ Note: The base runs on different base instances, such as pods. Therefore, BaseInstanceInOperation, BaseInstanceNotReady, BaseInstanceHasBeenReplaced, InsufficientHealthyBaseInstance error codes may refer to both the application status of the base and the status of the base instance.
## DashBoard Error Codes
### Level 1: Error Source
| Code | Meaning |
| --- | --- |
| KouplelessBoard | Exceptions from KouplelessBoard itself |
| ModuleController | Exceptions caused by specific downstream components |
| OtherUpstream | Exceptions caused by unknown upstream |
| OtherDownstream | Exceptions caused by unknown downstream |
### Level 2: Error Type
| Business Type | Error Source | Error Type | Meaning | Solution |
| --- | --- | --- | --- | --- |
| General | KouplelessBoard | UnknownError | Unknown error (default) |  |
| <br /> | OtherUpstream | InvalidParameter | Parameter validation failed | Please check the parameters |
| Work Order | KouplelessBoard | OperationPlanNotFound | Work order not found | Please check |
|  | KouplelessBoard | OperationPlanMutualExclusion | Work order mutual exclusion | Please retry |
| Internal Error | KouplelessBoard | InternalError | Internal system error | Please check |
|  | KouplelessBoard | ThreadPoolError | Thread pool call exception | Please check |
| Operation and Maintenance | ModuleController | BaseInstanceOperationFailed | Operation failed | Please check |
|  | ModuleController | BaseInstanceUnderOperation | Under operation | Please retry |
|  | ModuleController | BaseInstanceOperationTimeOut | Operation timed out | Please retry |
|  | ModuleController | OverFiftyPercentBaseInstancesUnavaliable | More than 50% of machine traffic is unreachable | Please check the base instance |
|  | KouplelessBoard | BaselineInconsistency | Consistency check failed (inconsistent baseline) | Please check |
| External Service Call Error | OtherDownstream | ExternalError | External service call error | Please check |
|  | KouplelessBoard | NetworkError | External service call timed out | Please retry |