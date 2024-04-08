---
title: 健康检查
date: 2024-03-21T10:28:32+08:00
weight: 900
---

## 背景
用户需要感知基座和模块的健康状态，以便于在模块出现故障时快速定位问题。同时，用户需要获取基座中所有的模块和插件信息

## 使用

### 前置条件
koupleless 版本 >= 1.1.0
sofa-ark 版本 >= 2.2.9

### 获取应用整体健康状态

基座的健康状态有 3 类：

| **状态** | **含义** |
| --- | --- |
| UP | 健康，表示已就绪（readiness） |
| UNKNOWN | 正在启动中 |
| DOWN | 不健康（可能是启动失败，也可能是运行状态不健康） |

由于 Koupleless 支持热部署模块，因此用户在获取应用整体健康状态时，可能希望忽略模块启动状态或者不忽略。

#### 忽略模块启动状态（默认）
- 特点：对于健康的基座，如果模块安装失败，不会影响整体应用健康状态。
- 使用：和普通 springboot 应用的配置一致，在基座的 application.properties 中配置：
``` properties
# 或者不配置 management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
# 如果需要展示所有信息，则配置以下内容
management.endpoint.health.show-components=always
management.endpoint.health.show-details=always
```

- 访问：{baseIp:port}/actuator/health
- 结果：
``` json
{
    // 应用整体健康状态
    "status": "UP",
    "components": {
        // 模块聚合健康状态
        "arkBizAggregate": {
            "status": "UP",
            "details": {
                "biz1:0.0.1-SNAPSHOT": {
                    "status": "UP",
                    // 可以看到模块中所有生效的 HealthIndicator 的健康状态
                    "details": {
                        "diskSpace": {
                          "status": "UP",
                          "details": {
                            "total": 494384795648,
                            "free": 272435396608,
                            "threshold": 10485760,
                            "exists": true
                            }
                        },
                        "pingHe": {
                          "status": "UP",
                          "details": {}
                        }
                    }
                }
            }
        },
        // 启动健康状态
        "masterBizStartUp": {
            "status": "UP",
            // 包括每一个模块的启动状态
            "details": {
                "base:1.0.0": {
                    "status": "UP"
                },
                "biz1:0.0.1-SNAPSHOT": {
                    "status": "UP"
                },
                "biz2:0.0.1-SNAPSHOT": {
                    "status": "DOWN"
                }
            }
        }
    }
}
```

#### 不同场景下的整体健康状态

场景1：无模块基座启动

| **状态** | **含义** |
| --- | --- |
| UP | 基座健康 |
| UNKNOWN | 基座正在启动中 |
| DOWN | 基座不健康 |

场景2：基座启动时，静态合并部署

| 状态 | 含义                        |
| --- |---------------------------|
| UP | 基座和模块都健康                  |
| UNKNOWN | 基座正在启动中/模块正在启动中           |
| DOWN | 基座启动失败/基座不健康/模块启动失败/模块不健康 |

场景3：基座启动后，热部署

注意：热部署场景下，模块是否安装成功不影响应用整体健康状态。

| 状态 | 含义                        |
| --- |---------------------------|
| UP | 基座和模块都健康                  |
| UNKNOWN | 基座正在启动中           |
| DOWN | 基座启动失败/基座不健康/模块不健康 |

场景4：基座运行中

| 状态 | 含义          |
| --- |-------------|
| UP | 基座和模块都健康    |
| UNKNOWN | -           |
| DOWN | 基座不健康或模块不健康 |

场景5：基座启动后，模块回放

模块回放是指在基座启动后，自动拉取模块基线，并安装模块。

目前未支持模块回放。


#### 不忽略模块启动状态
- 特点：对于健康的基座，如果模块安装失败，整体应用健康状态也会为失败。
- 使用：在上述配置之外，需要配置 koupleless.healthcheck.base.readiness.withAllBizReadiness=true，即在基座的 application.properties 中配置：
``` properties
# 或者不配置 management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
# 如果需要展示所有信息，则配置以下内容
management.endpoint.health.show-components=always
management.endpoint.health.show-details=always
# 不忽略模块启动状态
koupleless.healthcheck.base.readiness.withAllBizReadiness=true
```

- 访问：{baseIp:port}/actuator/health
- 结果：
``` json
{
    // 应用整体健康状态
    "status": "UP",
    "components": {
        // 模块聚合健康状态
        "arkBizAggregate": {
            "status": "UP",
            "details": {
                "biz1:0.0.1-SNAPSHOT": {
                    "status": "UP",
                    // 可以看到模块中所有生效的 HealthIndicator 的健康状态
                    "details": {
                        "diskSpace": {
                          "status": "UP",
                          "details": {
                            "total": 494384795648,
                            "free": 272435396608,
                            "threshold": 10485760,
                            "exists": true
                            }
                        },
                        "pingHe": {
                          "status": "UP",
                          "details": {}
                        }
                    }
                }
            }
        },
        // 启动健康状态
        "masterBizStartUp": {
            "status": "UP",
            // 包括每一个模块的启动状态
            "details": {
                "base:1.0.0": {
                    "status": "UP"
                },
                "biz1:0.0.1-SNAPSHOT": {
                    "status": "UP"
                }
            }
        }
    }
}
```

#### 不同场景下的整体健康状态
场景1：无模块基座启动

| **状态** | **含义** |
| --- | --- |
| UP | 基座健康 |
| UNKNOWN | 基座正在启动中 |
| DOWN | 基座不健康 |

场景2：基座启动时，静态合并部署

| 状态 | 含义                        |
| --- |---------------------------|
| UP | 基座和模块都健康                  |
| UNKNOWN | 基座正在启动中/模块正在启动中           |
| DOWN | 基座启动失败/基座不健康/模块启动失败/模块不健康 |

场景3：基座启动后，热部署

注意：热部署场景下，模块是否安装成功不应该影响应用整体健康状态。因此不建议设置为 koupleless.healthcheck.base.readiness.withAllBizReadiness=true

场景4：基座运行中

| 状态 | 含义          |
| --- |-------------|
| UP | 基座和模块都健康    |
| UNKNOWN | -           |
| DOWN | 基座不健康或模块不健康 |

场景5：基座启动后，模块回放

模块回放是指在基座启动后，自动拉取模块基线，并安装模块。

目前未支持模块回放。

### 获取单个模块的健康状态
- 使用：和普通 springboot 的健康检查配置一致，开启 health 节点，即：在模块的 application.properties 中配置：
``` properties
# 或者不配置 management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
```

- 访问：{baseIp:port}/{bizWebContextPath}/actuator/info
- 结果：
```json
{
    "status": "UP",
    "components": {
        "diskSpace": {
            "status": "UP",
            "details": {
                "total": 494384795648,
                "free": 270828220416,
                "threshold": 10485760,
                "exists": true
            }
        },
        "ping": {
            "status": "UP"
        }
    }
}
```

### 获取基座、模块和插件信息
- 使用：和普通 springboot 的健康检查配置一致，开启 info 节点，即：在基座的 application.properties 中配置：
``` properties
# 注意：如果用户自行配置了 management.endpoints.web.exposure.include，则需要将 health 节点配置上，否则无法访问 health 节点
management.endpoints.web.exposure.include=health,info
```
- 访问：{baseIp:port}/actuator/info
- 结果：
```json
{
    "arkBizInfo": [
      {
        "bizName": "biz1",
        "bizVersion": "0.0.1-SNAPSHOT",
        "bizState": "ACTIVATED",
        "webContextPath": "biz1"
      },
      {
        "bizName": "base",
        "bizVersion": "1.0.0",
        "bizState": "ACTIVATED",
        "webContextPath": "/"
      }
    ],
    "arkPluginInfo": [
        {
            "pluginName": "koupleless-adapter-log4j2",
            "groupId": "com.alipay.sofa.koupleless",
            "artifactId": "koupleless-adapter-log4j2",
            "pluginVersion": "1.0.1-SNAPSHOT",
            "pluginUrl": "file:/Users/lipeng/.m2/repository/com/alipay/sofa/koupleless/koupleless-adapter-log4j2/1.0.1-SNAPSHOT/koupleless-adapter-log4j2-1.0.1-SNAPSHOT.jar!/",
            "pluginActivator": "com.alipay.sofa.koupleless.adapter.Log4j2AdapterActivator"
        },
        {
            "pluginName": "web-ark-plugin",
            "groupId": "com.alipay.sofa",
            "artifactId": "web-ark-plugin",
            "pluginVersion": "2.2.9-SNAPSHOT",
            "pluginUrl": "file:/Users/lipeng/.m2/repository/com/alipay/sofa/web-ark-plugin/2.2.9-SNAPSHOT/web-ark-plugin-2.2.9-SNAPSHOT.jar!/",
            "pluginActivator": "com.alipay.sofa.ark.web.embed.WebPluginActivator"
        },
        {
            "pluginName": "koupleless-base-plugin",
            "groupId": "com.alipay.sofa.koupleless",
            "artifactId": "koupleless-base-plugin",
            "pluginVersion": "1.0.1-SNAPSHOT",
            "pluginUrl": "file:/Users/lipeng/.m2/repository/com/alipay/sofa/koupleless/koupleless-base-plugin/1.0.1-SNAPSHOT/koupleless-base-plugin-1.0.1-SNAPSHOT.jar!/",
            "pluginActivator": "com.alipay.sofa.koupleless.plugin.ServerlessRuntimeActivator"
        }
    ]
}
```
