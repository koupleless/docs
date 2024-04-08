---
title: Health Check
date: 2024-03-21T10:28:32+08:00
weight: 900
---

## Background
The purpose of health checks is to obtain the status of an application throughout its lifecycle, including operational and runtime status, so that users can make decisions based on that status. For example, if an application is found to be DOWN, it indicates a failure, and the user may restart or replace the machine.

In the case of a single application, health checks are relatively simple:
- Operational status:
    - If starting up, then UNKNOWN;
    - If start-up fails, then DOWN;
    - If start-up succeeds, then UP.
- Runtime status:
    - If all health check points of the application are healthy, then UP;
    - If any health check points of the application are not healthy, then DOWN.

In a multi-application scenario, the situation is much more complicated. We need to consider the impact of multiple applications' operational and runtime status on the overall health status of applications. When designing health checks, we need to consider the following two questions:

- Should module operational status affect the overall application health status?

  In different scenarios, users have different expectations. In koupleless, there are three scenarios for module operations:

  | Scenario       | Impact of the module on the overall application health status                                                                                                                                                                                        |
  |--------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
  | Hot Deployment  | Provide configuration to let users decide if the results of module hot deployment should affect the overall health status of the application (default configuration: **does not affect** with the original health status of the overall application) |
  | Static Merge Deployment | Module deployment occurs at base startup, and the module operational status **should directly affect** the overall health status of the application                                                                                                  |
  | Module Replay   | Module replay happens at base startup, and the module operational status **should directly affect** the overall health status of the application                                                                                                     |

- Should module runtime status affect the overall application health status?

  The runtime status of a module should **directly affect** the overall health status of the application.
  
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
- Usage: Same as the health check configuration for regular springboot, configure in the base's application.properties:
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


#### Module launch result affect the overall application health status
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
