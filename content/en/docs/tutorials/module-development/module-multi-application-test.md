---
title: 4.3.10 Multimodule Integration Testing
date: 2024-03-01T10:28:32+08:00
weight: 630
---

<div align="center">
[English](./README.md) | 简体中文
</div>

# Why Do We Need an Integration Testing Framework?
Without an integration testing framework, the validation steps for developers when verifying koupleless module logic can be cumbersome and involve the following steps:
1. Start a base process.
2. Build the module JAR package.
3. Install the module.
4. Call the module's HTTP interface (or other methods) to validate the logic.
   If the logic does not meet expectations, developers need to repeat the above steps, making such a validation process highly inefficient.
   To improve the validation efficiency for developers, we decided to provide the koupleless integration testing framework, allowing developers to start both the base and the module within a single process.

# Integration Testing Framework
## Principle
The integration testing framework simulates a multi-module deployment scenario by enhancing the class loading behavior of the base and the modules.
The specific source code can be referenced in [koupleless-test-suite](https://github.com/koupleless/runtime/tree/main/koupleless-ext/koupleless-test-suite).

## How to Use
Taking webflux-samples as an example, the project structure of webflux-samples is as follows:
- demowebflux: [Base Code](https://github.com/koupleless/samples/tree/main/springboot-samples/web/webflux/demowebflux).
- bizwebflux: [Module Code](https://github.com/koupleless/samples/tree/main/springboot-samples/web/webflux/bizwebflux).

We create a new Maven module:
- webflux-integration-test: [Integration Testing Module](https://github.com/koupleless/samples/tree/main/springboot-samples/web/webflux/demowebflux).

First, this module needs to add the integration testing framework dependency:
```xml
<dependency>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-test-suite</artifactId>
    <version>${koupleless.runtime.version}</version>
</dependency>
```

Next, we need to add the dependencies for the base and the module:
```xml
<!-- Base Dependency -->
<dependency>
    <groupId>com.alipay.sofa.web.webflux</groupId>
    <artifactId>demowebflux</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <classifier>lib</classifier>
</dependency>
<!-- Module Dependency -->
<dependency>
    <groupId>com.alipay.sofa.web.webflux</groupId>
    <artifactId>bizwebflux</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

Then, we need to write the integration test case:
```java
public static void setUp() {
    TestMultiSpringApplication multiApp = new TestMultiSpringApplication(
            MultiSpringTestConfig
                    .builder()
                    .baseConfig(
                            BaseSpringTestConfig
                                    .builder()
                                    // Pass in the base application's startup class.
                                    .mainClass(DemoWebfluxApplication.class)
                                    .build()
                    )
                    .bizConfigs(
                            Lists.newArrayList(
                                    BizSpringTestConfig
                                            .builder()
                                            .bizName("biz")
                                            // Pass in the module's startup class.
                                            .mainClass(BizWebfluxApplication.class)
                                            .build()))
                    .build());
    multiApp.run();
}
```

Finally, by starting the tests in IDEA, we will find that both the base and module's Spring containers are up and running. This allows us to validate the multi-module logic within a single process.

Thus, we have completed an integration test case.

## Summary
Through the above experiment, we have validated that the koupleless integration testing framework can quickly verify multi-module logic, improving developers' validation efficiency.
