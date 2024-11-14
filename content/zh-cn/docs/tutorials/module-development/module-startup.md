---
title: 4.3.3 模块启动
date: 2024-01-25T10:28:32+08:00
description: 模块启动
weight: 300
---

## 模块启动参数
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

## 模块启动加速
### 模块启动加速的设计思路

模块启动加速的总体思路是：
1. 基座提前启动好服务，这个只需要基座提前引入依赖即可
2. 模块通过各种方式复用基座的服务，可以通过如下的方式复用基座服务包括，具体使用哪种方式需要根据实际情况分析，有疑问可以社区群里交流：
   1. 通过类 static 变量的共享达到复用
   2. 通过基座封装一些服务的接口 api，模块直接调用这些 api 来复用基座的服务。
   3. 通过注解的方式获取基座对象的代理，Koupleless 提供的 @AutowiredFromBase 、@AutowiredFromBiz、SpringServiceFinder 工具类 ，dubbo 或者 SOFARpc 的一些支持 jvm service 调用的注解。
   4. 通过跨模块查找对象的方式，直接获取基座对象，如 Koupleless 提供的 SpringBeanFinder 工具类

这里隐含了一个问题，那就是模块为了能顺利调用基座服务，需要使用一些模型类，所以模块一般都需要将该服务对应的依赖引入进来，这导致模块启动的时候会扫描到这些服务的配置，从而再次初始化这些服务，这会导致模块启动一些不需要的服务，并且启动变慢，内存消耗增加。所以要让模块启动加速实际上要完成三件事情：

1. 基座提前启动好服务
2. 模块禁止启动这些服务，这是本文要详细介绍的
3. 模块复用基座服务

### 模块如何禁止启动部分服务
Koupleless 1.1.0 版本开始，提供了如下的配置能力：
```properties
koupleless.module.autoconfigure.exclude # 模块启动时不需要启动的服务 AutoConfiguration
koupleless.module.autoconfigure.include # 模块启动时需要启动的服务 AutoConfiguration，如果某个服务同时配置了 include 和 exclude，则会启动该服务
koupleless.module.initializer.skip # 模块启动是需要跳过的 initializer
```

该配置可以在基座里配置，也可以在模块里配置。如果在基座里配置，则所有模块都会生效，如果在模块里配置，则只有该模块生效，并且模块里的配置会覆盖基座的配置。



## benchmark
详细 benchmark 还待补充 
