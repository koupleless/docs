---
title: 模块启动参数
date: 2024-05-24T10:28:32+08:00
weight: 630
---


模块有两种部署方式：静态合并部署和热部署。

静态合并部署模块不支持配置启动参数。模块大部分的启动参数可以放在模块配置（application.properties）中，如配置 profile 时：将启动参数中的 --spring.profiles.active=dev，配置为 application.properties 中的 spring.profiles.active=true。

热部署模块支持配置启动参数。如：使用 arklet 通过 web 请求安装模块时，可以配置启动参数和环境变量：
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


