---
title: 多模块集成测试
date: 2024-03-01T10:28:32+08:00
weight: 620
---


<div align="center">

[English](./README.md) | 简体中文

</div>

# 为什么我们需要集成测试框架？

如果没有集成测试框架，在验证 koupleless 模块逻辑时，开发者的验证步骤是繁琐的，需要做如下步骤：

1. 启动一个基座进程。
2. 构建模块 jar 包。
3. 安装模块。
4. 调用模块的 http 接口（或其他方法）验证逻辑。

如果逻辑不符合预期，开发者需要重复上述步骤, 这样的验证流程是非常低效的。
为了提高开发者的验证效率，我们决定提供 koupleless 集成测试框架，让开发者能够在一个进程内同时启动基座和模块。

# 集成测试框架

## 原理

集成测试框架通过增强基座的类加载器和模块的类加载行为，来模拟多模块部署的场景。
具体的源代码可以参照 [koupleless-test-suite](https://github.com/koupleless/runtime/tree/main/koupleless-ext/koupleless-test-suite)

## 如何使用

以 webflux-samples 为例子。webflux-samples 的项目结构如下:

- demowebflux: [基座代码](https://github.com/koupleless/samples/tree/main/springboot-samples/web/webflux/demowebflux)。
- bizwebflux: [模块代码](https://github.com/koupleless/samples/tree/main/springboot-samples/web/webflux/bizwebflux)。

我们新建一个 maven module:

- webflux-integration-test:  [集成测试模块](https://github.com/koupleless/samples/tree/main/springboot-samples/web/webflux/demowebflux)

首先该 module 需要添加集成测试框架依赖:

```xml

<dependency>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-test-suite</artifactId>
    <version>${koupleless.runtime.version}</version>
</dependency>
```

然后我们需要添加基座和模块的依赖:

```xml
<!-- 基座依赖 -->
<dependency>
    <groupId>com.alipay.sofa.web.webflux</groupId>
    <artifactId>demowebflux</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <classifier>lib</classifier>
</dependency>
        <!-- 模块依赖 -->
<dependency>
<groupId>com.alipay.sofa.web.webflux</groupId>
<artifactId>bizwebflux</artifactId>
<version>0.0.1-SNAPSHOT</version>
</dependency>
```

接着，我们需要编写集成测试用例:

```java
    public static void setUp() {
    TestMultiSpringApplication multiApp = new TestMultiSpringApplication(
            MultiSpringTestConfig
                    .builder()
                    .baseConfig(
                            BaseSpringTestConfig
                                    .builder()
                                    // 传入基座的启动类。
                                    .mainClass(DemoWebfluxApplication.class)
                                    .build()
                    )
                    .bizConfigs(
                            Lists.newArrayList(
                                    BizSpringTestConfig
                                            .builder()
                                            .bizName("biz")
                                            // 传入模块的启动类。
                                            .mainClass(BizWebfluxApplication.class)
                                            .build()))
                    .build());
    multiApp.run();
}
```

最后，在 IDEA 里启动测试，我们会发现基座和模块的 Spring
容器都启动了。这样我们就可以在一个进程内验证多模块的逻辑。<br/>
如此，我们就完成了一个集成测试用例。

## 总结

通过上面的实验，我们验证了可以通过 koupleless 集成测试框架，来快速验证多模块的逻辑，提高开发者的验证效率。