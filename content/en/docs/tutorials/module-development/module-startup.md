---
title: 4.3.3 Module Startup  
date: 2024-01-25T10:28:32+08:00  
description: Module Startup  
weight: 300
---
## Module Startup Parameters
Modules can be deployed in two ways: static merged deployment and hot deployment.  
Static merged deployment does not support configuration startup parameters. Most of the startup parameters for the module can be placed in the module configuration (application.properties); for example, when configuring the profile: change the startup parameter `--spring.profiles.active=dev` to `spring.profiles.active=true` in the `application.properties` file.  
Hot deployment modules support configuration of startup parameters. For example, when using Arklet to install a module via a web request, you can configure startup parameters and environment variables:
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
## Module Startup Acceleration
### Design Concept for Module Startup Acceleration
The overall idea for module startup acceleration is:
1. The base platform should start the services in advance, which only requires the base platform to pre-import the dependencies.
2. The module can reuse the base platform's services in various ways. The methods for reusing the base services include, but are not limited to, analyzing the specific use case; if there are any questions, feel free to discuss in the community group:
   1. Reuse through sharing class static variables.
   2. Reuse by having the base platform encapsulate some service interface APIs, allowing the module to call these APIs directly.
   3. Obtain proxy objects of base platform objects through annotations, using tools provided by Koupleless like `@AutowiredFromBase`, `@AutowiredFromBiz`, `SpringServiceFinder`, and some annotations supporting JVM service calls provided by Dubbo or SOFARpc.
   4. Find objects across modules to directly obtain base platform objects, using tools like `SpringBeanFinder` provided by Koupleless.
      There is an implicit issue here: for modules to successfully invoke base platform services, they need to use certain model classes. Therefore, modules typically need to import the dependencies corresponding to those services, leading to these service configurations being scanned during module startup, which may result in reinitializing these services. This can cause unnecessary services to start and slow down the module startup, increasing memory consumption. Thus, to accelerate module startup, three tasks must be completed:
1. The base platform should start the services in advance.
2. The module should prohibit the startup of these services, which is the focus of this article.
3. The module should reuse base platform services.
### How Modules Can Prohibit Startup of Certain Services
Starting from version 1.1.0, Koupleless provides the following configuration capability:
```properties
koupleless.module.autoconfigure.exclude # Services that do not need to start during module startup
koupleless.module.autoconfigure.include # Services that need to start during module startup. If a service is configured with both include and exclude, the service will start.
```
This configuration can be set in the base platform or in the module. If configured in the base platform, it applies to all modules. If configured in the module, it only applies to that module and will override the configuration in the base platform.
## Benchmark
Detailed benchmark information is yet to be added.
