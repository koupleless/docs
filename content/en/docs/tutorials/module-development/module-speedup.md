---
title: Module Startup Speedup
date: January 25, 2024 10:28:32 AM GMT+08:00
description: Module Startup Speedup
weight: 301
---

## Design Philosophy of Module Startup Acceleration
The overall idea of module startup acceleration is:
1. The base platform starts the services early, which only requires the base to introduce dependencies in advance.
2. Modules reuse the services of the base platform in various ways. The following methods can be used to reuse the services. The specific method to use should be analyzed based on the actual situation. If there are any questions, feel free to discuss them in the community group:
   1. Reuse through the sharing of static variables of classes
   2. Reuse the services of the base platform by calling the API interfaces packaged by the base platform.
   3. Obtain the proxies of base objects through annotations, tools provided by Koupleless such as @AutowiredFromBase, @AutowiredFromBiz, SpringServiceFinder, and some annotations supported by dubbo or SOFARpc for jvm service calls.
   4. Find objects across modules directly to obtain base objects, such as the SpringBeanFinder tool provided by Koupleless.
This implies a problem: in order to successfully call the base services, the modules need to use some model classes. Therefore, modules generally need to introduce dependencies corresponding to these services. This causes modules to scan these services' configurations when starting, resulting in reinitialization of these services. This will lead to the module starting some unnecessary services, as well as slower startup times and increased memory consumption. So actually, to accelerate module startup, three things need to be done:
1. The base platform starts the services early.
2. Modules prohibit starting these services, which is detailed in this article.
3. Modules reuse the services of the base platform.

## How Modules Can Prohibit Starting Certain Services
Starting with the Koupleless 1.1.0 version, the following configuration capabilities are provided:
```properties
koupleless.module.autoconfigure.exclude # AutoConfiguration of services that do not need to be started during module startup
koupleless.module.autoconfigure.include # AutoConfiguration of services that need to be started during module startup; if a service is configured with both include and exclude, the service will be started.
```
This configuration can be set in the base platform or in the modules. If it is configured in the base, it will be effective for all modules. If it is configured in the modules, it will only be effective for that module, and the module's configuration will override the base's configuration.

## Benchmark
Detailed benchmark data is forthcoming.
```
