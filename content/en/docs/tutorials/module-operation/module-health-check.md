---
title: Health Check
date: 2024-03-21T10:28:32+08:00
weight: 900
---

## Background
Users need to be aware of the health status of the base and modules in order to quickly locate issues when a module fails. At the same time, users need to obtain information about all modules and plugins in the base.

## Usage

### Requirements
koupleless version >= 1.0.2
sofa-ark version >= 2.2.9

### Obtain the overall health status of the application
There are 3 types of health status for the base:
| **Status** | **Meaning** |
| --- | --- |
| UP | Healthy, indicating readiness |
| UNKNOWN | Currently starting up |
| DOWN | Unhealthy (may be due to startup failure or unhealthy running state) |
Because Koupleless supports hot-swappable modules, users may want to ignore module startup status or not when obtaining the overall health status of the application.

#### Do not ignore module startup status (default)
- Features: For a healthy base, if a module installation fails, the overall application health status will also fail.
- Usage: Same as the health check configuration for regular springboot, configure in the base's application.properties:
```properties
# Alternatively, do not configure management.endpoints.web.exposure.include
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
                }
            }
        }
    }
}
```

#### Overall Health Status in Different Scenarios
Scenario 1: Start without module base
| **Status** | **Meaning** |
| --- | --- |
| UP | Base is healthy |
| UNKOWN | Base is starting up |
| DOWN | Base is unhealthy |
Scenario 2: Start with base, static merged deployment
| Status | Meaning |
| --- | --- |
| UP | Base and module are healthy |
| UNKOWN | Base or module is starting up |
| DOWN | Base is unhealthy or module startup failed or module is unhealthy |
Scenario 3: Start with base, hot deployment
Note: In the hot deployment scenario, whether the module is installed successfully does not affect the overall health status of the application
| Status | Meaning |
| --- | --- |
| UP | Base and module are healthy |
| UNKOWN | Base or module is starting up |
| DOWN | Base is unhealthy or module is unhealthy |
Scenario 4: Base running
| Status | Meaning |
| --- | --- |
| UP | Base and module are healthy |
| UNKOWN | Module is starting up |
| DOWN | Base is unhealthy or module is unhealthy |
Scenario 5: Base start, module playback
Module playback is not supported at the moment
| Status | Meaning |
| --- | --- |
| UP | Base and module are healthy |
| UNKOWN | Base or module is starting up |
| DOWN | Base is unhealthy or module startup failed or module is unhealthy |
#### Ignore module startup status
- Features: For a healthy base, if the module installation fails, it will not affect the overall application health status.
- Usage: In addition to the above configuration, you need to configure koupleless.arklet.health.associateWithArkBizStartUpStatus=false, that is, configure in the base's application.properties:
``` properties
# or do not configure management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
# If you need to display all information, configure the following content
management.endpoint.health.show-components=always
management.endpoint.health.show-details=always
# Ignore module startup status
koupleless.arklet.health.associateWithArkBizStartUpStatus=false
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
The overall health status in all scenarios only represents the health status of the base and modules, and is not related to the module startup status.
| Status | Meaning          |
| --- |-------------|
| UP | Both the base and modules are healthy    |
| UNKNOWN | The base is in the process of starting     |
| DOWN | The base or module is not healthy |
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
