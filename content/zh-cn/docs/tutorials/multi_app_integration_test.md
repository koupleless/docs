---
title: 多模块集成测试框架介绍
date: 2024-03-28T10:28:32+08:00
weight: 1000
---

本文着重介绍多模块继承测试框架的设计思路、实现细节、使用方式。

## 为什么需要多模块集成测试框架？

假设没有集成测试框架，当开发者想要验证多模块部署的进程是否行为正确时，开发者需要进行如下步骤:

1. 构建基座和所有模块的 jar 包。
2. 启动基座进程。
3. 安装模块 jar 包到基座中。
4. 进行 HTTP / RPC 接口的掉用。
5. 验证返回结果是否正确。

上述工作流看起来简单，但是开发者面临如下困扰:

1. 反复在命令行和代码中来回切换。
2. 如果验证结果不正确，还需要反复修改代码和重新构建 + 远程 debug。
3. 如果 APP 本来只提供内部方法，为了验证多模块部署的行为，还需要修改代码通过 HTTP / RPC 暴露接口。

上述困扰导致开发者的效率低下，体验不友好。</br>
因此，我们需要一个集成测试框架来提供一站式的验证体验。

## 集成测试框架需要解决哪些问题？

集成测试框架需要能在同一个进程中，通过一次启动，模拟多模块部署的行为。
同时也允许开发者直接对模块 / 基座进行直接的代码调用，验证模块的行为是否正确。
这需要解决如下几个技术问题:

1. 模拟基座 springboot 的启动。
2. 模拟模块 springboot 的启动，同时支持直接从 dependency 中而非 jar 包中加载模块。
3. 模拟 ark-plugin 的加载。
4. 和 maven 的测试命令集成兼容。

由于默认的 sofa-ark 是通过 jar 包的方式加载模块的 executable-jar 包和 ark-plugin。
而显然，这会需要开发者在每次验证时都需要重新构建 jar 包 / 发布到仓库，降低验证效率。
所以，框架需要能够拦截掉对应的加载行为，直接从 maven 依赖中加载模块，模拟多模块部署的行为。</br>
完成相关工作的代码有：

1. TestBizClassLoader: 完成模拟 biz 模块的加载工作，是原来 BizClassLoader 的派生类, 解决了在同一个 jar 包下按需加载类到不同的 ClassLoader 的问题。
2. TestBiz: 完成模拟 biz 模块的启动工作，是原来 Biz 的派生类，封装了初始化 TestBizClassLoader 的逻辑。
3. TestBootstrap: 完成 ArkContainer 的初始化，并完成 ark-plugin 的加载等。
4. TestClassLoaderHook: 通过 Hook 机制控制 resource 的加载顺序，例如 biz jar 包中的 application.properties 会被优先加载。
5. BaseClassLoader: 模拟正常的基座 ClassLoader 行为，会和 surefire 等测试框架进行适配。
6. TestMultiSpringApplication: 模拟多模块的 springboot 启动行为。

## 如何使用集成测试框架？

### 在同一个进程中同时启动基座和模块 springboot

样例代码如下：

```java
public void demo() {
    new TestMultiSpringApplication(MultiSpringTestConfig
            .builder()
            .baseConfig(BaseSpringTestConfig
                    .builder()
                    .mainClass(BaseApplication.class) // 基座的启动类
                    .build())
            .bizConfigs(Lists.newArrayList(
                    BizSpringTestConfig
                            .builder()
                            .bizName("biz1") // 模块1的名称
                            .mainClass(Biz1Application.class) // 模块1的启动类
                            .build(),
                    BizSpringTestConfig
                            .builder()
                            .bizName("biz2") // 模块2的名称
                            .mainClass(Biz2Application.class) // 模块2的启动类
                            .build()
            ))
            .build()
    ).run();
}
```

### 进行 Assert 逻辑的编写

可以通过如下方式获取模块的服务:

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

获取到服务后，可以进行断言逻辑的编写。

### 用例参考

更完整的用例可以参考 [tomcat 多模块集成测试用例](todo)