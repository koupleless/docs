---
title: 错误码
date: 2024-03-08T10:28:32+08:00
weight: 1000
---

本文主要介绍 Arklet, ModuleController, KouplelessBoard 的错误码。

## ErrorCode 规则
两级错误码，支持动态组合，采用大驼峰方式，不同级别错误码之间只能用 "." 分隔。<br />如 Arklet.InstallModuleFailed<br />一级：错误来源<br />二级：错误类型
## Suggestion
简要说明解决方案，供上游操作参考。
## Arklet 错误码
### 一级 错误来源
| 编码 | 含义 |
| --- | --- |
| User | 客户导致的错误 |
| Arklet | Arklet 自身异常 |
| ModuleController | 具体上游组件导致的异常 |
| OtherUpstream | 未知上游导致的异常 |

### 二级 错误类型
| 业务类型 | 错误来源 | 错误类型 | 含义 | 解决方案 |
| --- | --- | --- | --- | --- |
| 通用 | Arklet | UnknownError | 未知错误（默认） | 请排查 |
| <br /> | ModuleController | InvalidParameter | 参数校验失败 | 请检查参数 |
|  | ModuleController | InvalidRequest | 操作类型非法 | 请检查请求 |
|  | OtherUpstream | DecodeURLFailed | url 解析失败 | 请检查 url 是否合法 |
| 查询相关 | Arklet | NoMatchedBiz | 模块查询失败，没有目标 biz 存在 | - |
|  | Arklet | InvalidBizName | 模块查询失败，查询参数 bizName 不能为空 | 请添加查询参数 bizName |
| 安装相关 | Arklet | InstallationRequirementNotMet | 模块安装条件不满足 | 请检查模块安装的必要参数 |
|  | Arklet | PullBizError | 拉包失败 | 请重试 |
|  | Arklet | PullBizTimeOut | 拉包超时 | 请重试 |
|  | User | DiskFull | 拉包时，磁盘已满 | 请替换基座 |
|  | User | MachineMalfunction | 机器故障 | 请重启基座 |
|  | User | MetaspaceFull | Metaspace超过阈值 | 请重启基座 |
|  | Arklet | InstallBizExecuting | 模块安装时，当前模块正在安装 | 请重试 |
| <br /> | Arklet | InstallBizTimedOut | 模块安装时，卸载老模块失败 | 请排查 |
|  | Arklet | InstallBizFailed | 模块安装时，新模块安装失败 | 请排查 |
|  | User | InstallBizUserError | 模块安装失败，业务异常 | 请检查业务代码 |
| 卸载相关 | Arklet | UninstallBizFailed | 卸载失败，当前 biz 还存在在 容器中 | 请排查 |
|  | Arklet | UnInstallationRequirementNotMet | 模块卸载条件不满足 | 当前模块存在多版本，且卸载的版本是激活状态的，不允许卸载 |

## ModuleController 错误码
### 一级 错误来源
| 编码 | 含义 |
| --- | --- |
| User | 客户导致的错误 |
| ModuleController | ModuleController 自身异常 |
| KouplelessBoard | 具体上游组件导致的异常 |
| Arklet | 具体下游组件导致的异常 |
| OtherUpstream | 未知上游导致的异常 |
| OtherDownstream | 未知下游导致的异常 |

### 二级 错误类型
| 业务类型 | 错误来源 | 错误类型 | 含义 | 解决方案 |
| --- | --- | --- | --- | --- |
| 通用 | ModuleController | UnknownError | 未知错误（默认） | 请排查 |
| <br /> | OtherUpstream | InvalidParameter | 参数校验失败 | 请检查参数 |
|  | Arklet | ArkletServiceNotFound | 找不到基座服务 | 请确保基座有Koupleless依赖 |
|  | Arklet | NetworkError | 网络调用异常 | 请重试 |
|  | OtherUpstream | SecretAKError | 签名异常 | 请确认有操作权限 |
|  | ModuleController | DBAccessError | 读写数据库失败 | 请重试 |
|  | OtherUpstream | DecodeURLFailed | url 解析失败 | 请检查 url 是否合法 |
|  | ModuleController | RetryTimesExceeded | 重试多次失败 | 请排查 |
|  | ModuleController | ProcessNodeMissed | 缺少可用的工作节点 | 请稍后重试 |
|  | ModuleController | ServiceMissed | 服务缺失 | 请检查ModuleController版本是否含有该模版类型 |
|  | ModuleController | ResourceConstraned | 资源受限（线程池、队列等满） | 请稍后重试 |
| 安装相关 | Arklet | InstallModuleTimedOut | 模块安装超时 | 请重试 |
|  | Arklet / User | InstallModuleFailed | 模块安装失败 | 请检查失败原因 |
|  | Arklet | InstallModuleExecuting | 模块安装中 | 相同模块在安装，请稍后重试 |
|  | User | DiskFull | 磁盘已满 | 请替换 |
| 卸载相关 | OtherUpstream | EmptyIPList | ip 列表为空 | 请输入要卸载的ip |
| <br /> | Arklet | UninstallBizTimedOut | 模块卸载超时 | 请重试 |
| <br /> | Arklet | UninstallBizFailed | 模块卸载失败 | 请排查 |
| 基座相关 | ModuleController | BaseInstanceNotFound | 基座实例不存在 | 请确保基座实例存在 |
| <br /> | KubeAPIServer | GetBaseInstanceFailed | 查询不到基座信息 | 请确保基座实例存在 |
|  | ModuleController | BaseInstanceInOperation | 基座正在运维中 | 请稍后重试 |
|  | ModuleController | BaseInstanceNotReady | 暂未读到基座数据或基座不可用 | 请确保基座可用 |
|  | ModuleController | BaseInstanceHasBeenReplaced | 基座已被替换 | 后续会新增基座实例，请等候 |
|  | ModuleController | InsufficientHealthyBaseInstance | 健康基座不足 | 请扩容 |
| 扩缩容 | ModuleController | RescaleRequirementNotMet | 扩缩容条件不满足 | 请检查扩容机器是否足够/请检查缩容比例 |

⚠️注意：基座运行在不同基座实例上，如：pod。因此 BaseInstanceInOperation, BaseInstanceNotReady, BaseInstanceHasBeenReplaced, InsufficientHealthyBaseInstance 错误码可能指包括基座应用状态或基座实例的状态。
## DashBoard 错误码
### 一级 错误来源
| 编码 | 含义 |
| --- | --- |
| KouplelessBoard | KouplelessBoard 自身异常 |
| ModuleController | 具体下游组件导致的异常 |
| OtherUpstream | 未知上游导致的异常 |
| OtherDownstream | 未知下游导致的异常 |

### 二级 错误类型
| 业务类型 | 错误来源 | 错误类型 | 含义 | 解决方案 |
| --- | --- | --- | --- | --- |
| 通用 | KouplelessBoard | UnknownError | 未知错误（默认） |  |
| <br /> | OtherUpstream | InvalidParameter | 参数校验失败 | 请检查参数 |
| 工单 | KouplelessBoard | OperationPlanNotFound | 工单不存在 | 请排查 |
|  | KouplelessBoard | OperationPlanMutualExclusion | 工单互斥 | 请重试 |
| 内部错误 | KouplelessBoard | InternalError | 系统内部错误 | 请排查 |
|  | KouplelessBoard | ThreadPoolError | 线程池调用异常 | 请排查 |
| 运维 | ModuleController | BaseInstanceOperationFailed | 运维失败 | 请排查 |
|  | ModuleController | BaseInstanceUnderOperation | 运维中 | 请重试 |
|  | ModuleController | BaseInstanceOperationTimeOut | 运维超时 | 请重试 |
|  | ModuleController | OverFiftyPercentBaseInstancesUnavaliable | 超过50% 机器流量不可达 | 请检查基座实例 |
|  | KouplelessBoard | BaselineInconsistency | 一致性校验失败（基线不一致） | 请排查 |
| 外部服务调用错误 | OtherDownstream | ExternalError | 外部服务调用错误 | 请排查 |
|  | KouplelessBoard | NetworkError | 外部服务调用超时 | 请重试 |
