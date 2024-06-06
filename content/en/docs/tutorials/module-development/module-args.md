---
title: Module Startup Parameters
date: 2024-05-24T10:28:32+08:00
weight: 630
---
There are two deployment methods for modules: static merging deployment and hot deployment.

Static merging deployment modules do not support the configuration of startup parameters. Most of the module's startup parameters can be placed in the module configuration (application.properties). For example, when configuring a profile, the startup parameter --spring.profiles.active=dev can be set in application.properties as spring.profiles.active=true.

Hot deployment modules support the configuration of startup parameters. For instance, when installing a module via web request using arklet, startup parameters and environment variables can be configured as follows:

```shell
curl --location --request POST 'localhost:1238/installBiz' \
--header 'Content-Type: application/json' \
--data '{
    "bizName": "${Module Name}",
    "bizVersion": "${Module Version}",
    "bizUrl": "file:///path/to/ark/biz/jar/target/xx-xxxx-ark-biz.jar",
    "args": ["--spring.profiles.active=dev"],
    "env": {
        "XXX": "YYY"
    }
}'
```
