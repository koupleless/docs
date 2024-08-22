---
title: 6.5.3.2 Introduction to Multi-Module Integration Testing Framework
date: 2024-03-28T10:28:32+08:00
weight: 2
---
This article focuses on the design concepts, implementation details, and usage of the multi-module integration testing framework.

## Why Do We Need a Multi-Module Integration Testing Framework?
Assuming there is no integration testing framework, when developers want to verify whether the deployment process of multiple modules behaves correctly, they need to follow these steps:
1. Build the base and JAR packages for all modules.
2. Start the base process.
3. Install the module JAR packages into the base.
4. Invoke HTTP/RPC interfaces.
5. Verify whether the returned results are correct.

Although the above workflow appears simple, developers face several challenges:
1. Constantly switching back and forth between the command line and the code.
2. If the validation results are incorrect, they need to repeatedly modify the code and rebuild + remote debug.
3. If the app only provides internal methods, they must modify the code to expose interfaces via HTTP/RPC to validate the behavior of the multi-module deployment.

These challenges lead to low efficiency and an unfriendly experience for developers. Therefore, we need an integration testing framework to provide a one-stop validation experience.

## What Problems Should the Integration Testing Framework Solve?
The integration testing framework needs to simulate the behavior of multi-module deployment in the same process with a single start. It should also allow developers to directly call code from the modules/base to verify module behavior.

The framework needs to solve the following technical problems:
1. Simulate the startup of the base Spring Boot application.
2. Simulate the startup of module Spring Boot applications, supporting loading modules directly from dependencies instead of JAR packages.
3. Simulate the loading of Ark plugins.
4. Ensure compatibility with Maven's testing commands.

By default, Sofa-ark loads modules through executable JAR packages and Ark plugins. Therefore, developers would need to rebuild JAR packages or publish to repositories during each validation, reducing validation efficiency. The framework needs to intercept the corresponding loading behavior and load modules directly from Maven dependencies to simulate multi-module deployment.

The code that accomplishes these tasks includes:
1. **TestBizClassLoader**: Simulates loading the biz module and is a derived class of the original BizClassLoader, solving the problem of loading classes on demand to different ClassLoaders within the same JAR package.
2. **TestBiz**: Simulates starting the biz module and is a derived class of the original Biz, encapsulating the logic for initializing TestBizClassLoader.
3. **TestBootstrap**: Initializes ArkContainer and loads Ark plugins.
4. **TestClassLoaderHook**: Controls the loading order of resources via a hook mechanism. For instance, application.properties in the biz JAR package will be loaded first.
5. **BaseClassLoader**: Simulates normal base ClassLoader behavior and is compatible with testing frameworks like Surefire.
6. **TestMultiSpringApplication**: Simulates the startup behavior of multi-module Spring Boot applications.

## How to Use the Integration Testing Framework?
### Start Both Base and Module Spring Boot Applications in the Same Process
Sample code is as follows:
```java
public void demo() {
    new TestMultiSpringApplication(MultiSpringTestConfig
            .builder()
            .baseConfig(BaseSpringTestConfig
                    .builder()
                    .mainClass(BaseApplication.class) // Base startup class
                    .build())
            .bizConfigs(Lists.newArrayList(
                    BizSpringTestConfig
                            .builder()
                            .bizName("biz1") // Name of module 1
                            .mainClass(Biz1Application.class) // Startup class of module 1
                            .build(),
                    BizSpringTestConfig
                            .builder()
                            .bizName("biz2") // Name of module 2
                            .mainClass(Biz2Application.class) // Startup class of module 2
                            .build()
            ))
            .build()
    ).run();
}
```
### Write Assert Logic
You can retrieve module services using the following method:
```java
public void getService() {
    StrategyService strategyService = SpringServiceFinder.
            getModuleService(
                    "biz1-web-single-host",
                    "0.0.1-SNAPSHOT",
                    "strategyServiceImpl",
                    StrategyService.class
            );
}
```
After obtaining the service, you can write assert logic.

### Reference Use Cases
For more comprehensive use cases, you can refer to [Tomcat Multi-Module Integration Testing Cases](https://github.com/koupleless/samples/blob/main/springboot-samples/web/tomcat/tomcat-web-integration-test/README-zh_CN.md).
