---
title: Health Check
date: 2024-03-21T10:28:32+08:00
weight: 900
---

## Background
The purpose of health checks is to obtain the status of an application throughout its lifecycle, including the operational and runtime phases, so that users can make decisions based on this status. For instance, if the application status is DOWN, it indicates a malfunction in the application, and the user may choose to restart or replace the machine.

In the case of a single application, health checks are relatively simple:
- Operational phase status:
  - If it's starting up, the status is UNKNOWN;
  - If startup fails, the status is DOWN;
  - If startup is successful, the status is UP.
- Runtime phase status:
  - If all health checkpoints of the application are healthy, the status is UP;
  - If any health checkpoint of the application is not healthy, the status is DOWN.

In multi-application scenarios, the situation can be much more complex. We need to consider the impact of the multi-application's status during both the **operational phase** and the **runtime phase** on the overall application health. When designing health checks, we need to consider the following two issues:

- During the **module operational phase**, should the module start-up status affect the overall application health status?

  In different operational scenarios, users have different expectations. koupleless module operations have three scenarios:
  
  | Scenario          | Impact of the Module on the Overall Application Health Status                                                 |
  |-------------------|---------------------------------------------------------------------------------------------------------------|
  | Module Hot-Deployment | Provide configuration to let users decide whether the hot-deployment result should affect the overall application health status (default configuration is: **does not affect** the original health status of the application) |
  | Static Merge Deployment | Module deployment occurs during the base startup, so the module startup status **should directly affect** the overall health status of the application |
  | Module Replay         | Module replay occurs during the base startup, thus the module startup status **should directly affect** the overall health status of the application |

- During the **module runtime phase**, should the module running status affect the overall application health status?
  
  The module runtime phase status should have a **direct impact** on the overall application health status.

Under this context, we have designed a health check approach for multi-application scenarios.

## Usage

### Requirements
- Koupleless version >= 1.1.0
- sofa-ark version >= 2.2.9

### Obtain the overall health status of the application
There are 3 types of health status for the base:

| **Status** | **Meaning** |
| --- | --- |
| UP | Healthy, indicating readiness |
| UNKNOWN | Currently starting up |
| DOWN | Unhealthy (may be due to startup failure or unhealthy running state) |

Since Koupleless supports hot deployment of modules, while obtaining the overall health status of the application, users may wish for the module deployment result to impact the overall application health status or not.

#### Module launch result does not affect the overall application health status (default)
- Features: For a healthy base, if the module installation fails, it will not affect the overall application health status.
- Usage: Same as the health check configuration for regular Spring Boot, configure in the base's application.properties:
``` properties
# or do not configure management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
# If you need to display all information, configure the following content
management.endpoint.health.show-components=always
management.endpoint.health.show-details=always
```
- Access: {baseIp:port}/actuator/health
- Result:
``` json
{
    // Overall health status of the application
    "status": "UP",
    "components": {
        // Aggregated health status of the modules
        "arkBizAggregate": {
            "status": "UP",
            "details": {
                "biz1:0.0.1-SNAPSHOT": {
                    "status": "UP",
                    // Can see the health status of all active HealthIndicators in the modules
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
        // Startup health status of base and modules
        "masterBizStartUp": {
            "status": "UP",
            // Including the startup status of each module.
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

#### Overall Health Status in Different Scenarios
Scenario 1: Start base 

| **Status** | **Meaning** |
| --- | --- |
| UP | Base is healthy |
| UNKNOWN | Base is starting up |
| DOWN | Base is unhealthy |

Scenario 2: Start base and install modules with static merge deployment

| Status | Meaning                                                                               |
| --- |---------------------------------------------------------------------------------------|
| UP | Base and module are healthy                                                           |
| UNKNOWN | Base or module is starting up                                                         |
| DOWN | Base startup failed / base is unhealthy / module startup failed / module is unhealthy |

Scenario 3: After base starts, install modules with hot deployment

Note: In the hot deployment scenario, whether the module is installed successfully does not affect the overall health status of the application

| Status | Meaning                                                       |
| --- |---------------------------------------------------------------|
| UP | Base and module are healthy                                   |
| UNKNOWN | Base or module is starting up                                 |
| DOWN | Base startup failed / base is unhealthy / module is unhealthy |

Scenario 4: Base running

| Status | Meaning                                  |
| --- |------------------------------------------|
| UP | Base and module are healthy              |
| UNKNOWN | -                                        |
| DOWN | Base is unhealthy or module is unhealthy |

Scenario 5: After base started, reinstall module

Reinstall module refers to automatically pulling the module baseline and installing the module after the base is started.

Reinstall module is not supported at the moment

| Status | Meaning |
| --- | --- |
| UP | Base and module are healthy |
| UNKNOWN | Base or module is starting up |
| DOWN | Base is unhealthy or module startup failed or module is unhealthy |


#### Module launch result affects the overall application health status
- Features: For a healthy base, if a module installation fails, the overall application health status will also fail.
- Usage: In addition to the above configuration, you need to configure koupleless.healthcheck.base.readiness.withAllBizReadiness=true, that is, configure in the base's application.properties:
```properties
# Alternatively, do not configure management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
# If you need to display all information, configure the following content
management.endpoint.health.show-components=always
management.endpoint.health.show-details=always
# Do not ignore module startup status
koupleless.healthcheck.base.readiness.withAllBizReadiness=true
```
- Access: {baseIp:port}/actuator/health
- Result:
``` json
{
    // Overall health status of the application
    "status": "UP",
    "components": {
        // Aggregated health status of the modules
        "arkBizAggregate": {
            "status": "UP",
            "details": {
                "biz1:0.0.1-SNAPSHOT": {
                    "status": "UP",
                    // Can see the health status of all active HealthIndicators in the modules
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
        // Startup health status of base and modules
        "masterBizStartUp": {
            "status": "UP",
            // Including the startup status of each module.
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

#### Overall Health Status in Different Scenarios
Scenario 1: Start base

| **Status** | **Meaning** |
| --- | --- |
| UP | Base is healthy |
| UNKNOWN | Base is starting up |
| DOWN | Base is unhealthy |

Scenario 2: Start base and install modules with static merge deployment

| Status | Meaning |
| --- | --- |
| UP | Base and module are healthy |
| UNKNOWN | Base or module is starting up |
| DOWN | Base startup failed / base is unhealthy / module startup failed / module is unhealthy |

Scenario 3: After base starts, install modules with hot deployment

Note: In the hot deployment scenario, whether the module is installed successfully should not affect the overall health status of the application. Therefore, it is not recommended to set koupleless.healthcheck.base.readiness.withAllBizReadiness=true.

Scenario 4: Base running

| Status | Meaning                                  |
| --- |------------------------------------------|
| UP | Base and module are healthy              |
| UNKNOWN | -                                        |
| DOWN | Base is unhealthy or module is unhealthy |

Scenario 5: After base started, reinstall module

Reinstall module refers to automatically pulling the module baseline and installing the module after the base is started.

Reinstall module is not supported at the moment.

### Obtaining the Health Status of a Single Module
- Usage: Consistent with the normal springboot health check configuration, enable the health node, i.e. configure in the module's application.properties:
``` properties
# or do not configure management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
```
- Access: {baseIp:port}/{bizWebContextPath}/actuator/info
- Result:
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

### Get information about pedestal, modules, and plugins
- Usage: Same as the regular springboot health check configuration, enable the info endpoint, i.e., configure in the pedestal's application.properties:
``` properties
# Note: If the user configures management.endpoints.web.exposure.include on their own, they need to include the health endpoint, otherwise the health endpoint cannot be accessed
management.endpoints.web.exposure.include=health,info
```
- Access: {baseIp:port}/actuator/info
- Result:
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
