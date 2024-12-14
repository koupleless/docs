---
title: Koupleless 内核系列 | 单进程多应用如何解决兼容问题
date: 2024-01-25T10:28:32+08:00
description: Koupleless 内核系列 | 单进程多应用如何解决兼容问题
weight: 401
author: 苟振东
---

本篇文章属于 Koupleless 进阶系列文章第二篇，默认读者对 Koupleless 的基础概念、能力都已经了解，如果还未了解过的可以查看[官网](https://koupleless.io/docs/introduction/intro-and-scenario/)。

进阶系列一：[Koupleless 模块化的优势与挑战，我们是如何应对挑战的](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97%E6%A8%A1%E5%9D%97%E5%8C%96%E9%9A%94%E7%A6%BB%E4%B8%8E%E5%85%B1%E4%BA%AB%E5%B8%A6%E6%9D%A5%E7%9A%84%E6%94%B6%E7%9B%8A%E4%B8%8E%E6%8C%91%E6%88%98/)

进阶系列二： [Koupleless 内核系列 | 单进程多应用如何解决兼容问题](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97-%E5%8D%95%E8%BF%9B%E7%A8%8B%E5%A4%9A%E5%BA%94%E7%94%A8%E5%A6%82%E4%BD%95%E8%A7%A3%E5%86%B3%E5%85%BC%E5%AE%B9%E9%97%AE%E9%A2%98/)

进阶系列三：[Koupleless 内核系列 | 一台机器内 Koupleless 模块数量的极限在哪里？](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97-%E4%B8%80%E5%8F%B0%E6%9C%BA%E5%99%A8%E5%86%85-koupleless-%E6%A8%A1%E5%9D%97%E6%95%B0%E9%87%8F%E7%9A%84%E6%9E%81%E9%99%90%E5%9C%A8%E5%93%AA%E9%87%8C/)

进阶系列四：[Koupleless 可演进架构的设计与实践｜当我们谈降本时，我们谈些什么](http://koupleless.io/blog/2024/01/25/koupleless-%E5%8F%AF%E6%BC%94%E8%BF%9B%E6%9E%B6%E6%9E%84%E7%9A%84%E8%AE%BE%E8%AE%A1%E4%B8%8E%E5%AE%9E%E8%B7%B5%E5%BD%93%E6%88%91%E4%BB%AC%E8%B0%88%E9%99%8D%E6%9C%AC%E6%97%B6%E6%88%91%E4%BB%AC%E8%B0%88%E4%BA%9B%E4%BB%80%E4%B9%88/)

# 多应用兼容性 —— Koupleless 极速研发体系下存在的问题
Koupleless 是模块化研发的体系，应用被抽象成了基座和模块两个部分，模块可以动态地安装到基座上，如下图所示：

![画板](https://intranetproxy.alipay.com/skylark/lark/0/2024/jpeg/43656686/1714034988220-3defaffb-de07-4cf2-acec-8128106e7b2c.jpeg)

通过该抽象，一个进程里可以运行多个应用，用户可以享受到：节省资源、快速部署、迭代提效等收益。具体解析可以参考文章：[https://koupleless.io/docs/introduction/architecture/arch-principle/](https://koupleless.io/docs/introduction/architecture/arch-principle/)

这种单进程多应用的模式背后其实是共享与隔离的极致平衡，像文中所说的，隔离可以带来独立的迭代升级能力，共享可以带来极致的启动速度与研发效率。但是共享会带来互相干扰的问题，如[进阶系列第一篇](https://lark.alipay.com/middleware/sofa-serverless/yabayt72doudtpgo)文章所说，需要引入额外的兼容性治理，首先兼容性问题大致可以分为 3 大类：



1. 全局变量互相污染（多数为 static 变量、System Properties 导致）
2. ClassLoader 不匹配
3. 部分资源不卸载（只有热部署时才会有）



综上，为了让用户能低成本地享受到 Koupleless 的收益，同时保证业务执行的正确性，我们设计了从问题的发现 -> 治理 -> 防御 角度全面治理此类问题的方案，在每个阶段分别提供了相应的工具和组件：

#### 问题发现
问题发现部分主要分为静态问题暴露和动态问题暴露两块：

1. 静态问题暴露：通过静态代码扫描工具，识别潜在的不兼容点，并由人工确认和修复。
2. 动态问题暴露：提供简单易用的 koupleless 运行时集成测试框架，允许用户低成本地编写集成测试逻辑，回归验证模块行为符合预期。

#### 问题治理
当我们发现问题后，需要提供对应的兼容性修复方案。为此，我们提供了基座构建插件，自动进行兼容性修复，帮助用户低成本地解决兼容性问题。

#### 问题防御
集成测试框架，同样可以帮助完成治理后回归验证问题，避免版本升级带来的回归问题。



# 问题发现：<font style="color:rgb(31, 35, 40);">代码扫描工具 </font>
在 Java 单进程多应用模式下，根据团队的经验积累，我们发现了一些常见的不兼容静态代码模式。基于这个现状，我们可以通过静态代码扫描工具来识别这些模式，在运行前暴露风险，让开发者尽早修复问题。

## 常用的不兼容模式
常用的不兼容模式主要有 3 类：

+ 全局变量相互污染：比如基座通过 static 维护了一些全局变量，多个模块在写入 / 读取 static 变量的时候可能是用了同一个 key，进而导致潜在的互相污染的风险。
+ classLoader 不匹配问题：在 sofa-ark 类隔离机制中，属于模块自身的类只能由自己的 classLoader 加载。因此，在一些 classLoader 使用不正确的时候，例如用基座的 classLoader 加载模块类的全称，可能会出现预期外的问题。
+ 模块泄漏问题：在多模块架构中，模块是一个单独的运维单位，如果卸载模块时没有正确地关闭一些服务，例如 shutdown 线程池，可能会导致内存泄漏的问题。

## 代码扫描工具
上述 3 类问题是 koupleless 不兼容的主要问题，我们可以通过一些常见的代码片段模式进行问题识别和暴露这 3 类问题，然后由人工进行确认和修复。

为此，我们基于开源社区的 sonarqube 静态代码扫描服务，开发了针对性的静态代码扫描插件，以帮助开发者快速地发现问题，从而进行有效的治理。目前项目已经开源，地址在 [https://github.com/koupleless/scanner](https://github.com/koupleless/scanner) .

目前已有的扫描规则有：

+ static 变量扫描：扫描和暴露可修改的 static 变量（不可修改的变量无污染问题）。当然，由于工程中使用 static 变量是一种常见的模式，全部告警可能会造成大量噪音，因此我们也基于一定的特征（命名、类型等）进行了没有潜在风险的降噪处理。
+ class.forName 方法调用扫描：class.forName 会使用堆栈中 caller 的 classLoader 进行类加载，这往往是基座的 classLoader, 因此有较高的风险导致 ClassNotFound。
+ SomeClass.getClassLoader 方法：如果要加载的目标类和 SomeClass 不在一个模块中，则会导致 ClassNotFound 异常，有比较高的风险。

当前已经有一些企业在使用该工具。未来，扫描规则还会持续完善，也欢迎开源社区的各位在发现了新的不兼容模式后，将其完善成为规则，并且 PR 贡献，让静态代码扫描规则越来越完善！

# 问题治理：基座构建插件 —— 让基座低成本地快速增强多应用模式
前一小节我们提到，koupleless 运行时可能由于引入多应用污染的问题而导致需要兼容性修复，而兼容性修复又主要解决 3 大问题：

1. 修复原有代码：一些组件的某个版本已经固化，已不再允许提高代码修改，如何才能低成本的方式修改原有逻辑增强多应用的能力？
2. 多版本适配：同一组件不同版本之间的实现可能不同，导致修复方式也不同。如何修改这么多的版本，并做到长期的可维护呢？
3. 用户如何低成本的使用：每个组件对应不同版本可能有不同的增强逻辑，用户怎么知道具体要引入哪段增强逻辑呢？怎样才能让用户低成本甚至不感知的情况下，自动帮助找到对应的增强逻辑呢？

接下来，我们继续介绍一下是如何解决这些问题的。

## 如何低成本增强组件原有代码
这里的低成本要考虑两点：

1. 组件本身代码增强的低成本，让 Koupleless 贡献者能低成本扩展一些组件支持多应用能力。
2. 每个组件存在许多历史版本，一个组件的不同版本其实现可能不同，进而需要增强的逻辑也不同，如何能低成本的增强这些历史版本，而非逐个版本的增强。

常见的手段有三种：同名类覆盖、反射、提交到修复的主分支。

| 修复方法 | 优点 | 缺点 |
| --- | --- | --- |
| 同名类覆盖 | 修复逻辑比较直观，还可以用 diff 软件和源文件进行实现的对比。 | 需要用户引入额外的依赖，以及必须优先于原有实现被 JVM 加载。 |
| 反射 | 不需要用户引入额外的依赖，可以由框架自动代理类和生成增强。 | 无法直观地看到增强逻辑，可维护性比较差，可能有性能影响。 |
| 提交到修复的主分支 | 用户只需要升级 SDK 即可修复。 | 迭代周期比较长，无法及时解决用户问题，以及许多用户用的是历史老版本，官方可能不再维护接受 PR。 |


为了有更好的可维护性 koupleless 最终采用了同名类覆盖的办法，并将有关增强类统一放置在了独立仓库: [https://github.com/koupleless/adapter](https://github.com/koupleless/adapter) 。

每个组件的多版本问题，所以这里也维护了组件不同版本的不同 adapter 实现列表，如 log4j2，这里 koupleless-adapter-log4j2-spring-starter-2.1 实际上是增强了springboot 2.1 版本到 3.2 的所有版本。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1714453696761-52c8673a-6540-464e-b637-33aa986838a9.png)

## 如何解决用户低成本使用问题
某个组件不同版本对应的增强逻辑不同，这也给用户带来了使用负担，为了进一步降低用户的接入成本，免去用户对照依赖版本查询增强的繁琐，我们也提供了 koupleless-base-build-plugin 插件，用户可以将如下构建插件添加到自己的 maven 工程中:

```xml
 <plugin>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-base-build-plugin</artifactId>
    <version>${koupleless.runtime.version}</version>
    <executions>
        <execution>
            <goals>
               <goal>add-patch</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```



该插件会动态地解析用户使用的依赖，识别到需要增强的依赖，并动态地添加增强类，工作流程如下图所示：

![画板](https://intranetproxy.alipay.com/skylark/lark/0/2024/jpeg/43656686/1713883322523-ee56d9f0-1431-4798-b36e-7b228e64d1fc.jpeg)

值得注意的是，在使用增强的过程中，我们必须保证对于一个同名类，koupleless 维护的增强优先于原本的类被 classLoader 加载。

我们在 koupleless-base-build-plugin 中保证了这个优先级，保证的方法是在 maven 的 generated-sources 阶段将增强类拷贝到当前工程中，正如上述流程图的 5～6 步所示，而当前工程中的类加载优先级是最高的。用户可以参考 samples 工程 [https://github.com/koupleless/samples/tree/main/springboot-samples/logging/log4j2](https://github.com/koupleless/samples/tree/main/springboot-samples/logging/log4j2) 进行验证和实践，在当前项目下执行 maven clean package 命令后，可以看到构建结果如下图：



![org.apache.logging 和 org.springframework.boot 是 koupleless 增强过的同名类，被自动拷贝到了当前项目中。](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/43656686/1713931129276-ab18fd29-c258-4878-80ea-e18688e0605f.png)

总结一下，用户可以通过在 maven 工程中引入 koupleless-base-build-plugin 插件保证其业务逻辑在多应用模式下的兼容性，其优势有：

1. 通过同名类覆盖的方式自动修复潜在的兼容性问题。
2. 通过动态依赖映射减少用户自己查询依赖到补丁的映射。
3. 通过将补丁拷贝到当前的工程目录自动解决补丁优先级应该是最高的问题。

如此，用户只需要引入一个构建插件，即可快速地接入 koupleless。

# 问题防御：集成测试框架 —— 简单又快速验证正确性的效率神器
当然，由于这套模式在一个 JVM 里运行多个应用不可避免存在的一些兼容性问题，我们当然不能指望用户每次都到生产才发现这个问题。我们需要将风险左移，在本地测试验证的时候尽可能地暴露问题。不过，由于 koupleless 是以动态加载 jar 包的模式实现单进程多应用的，我们也推出了集成测试框架 koupleless-test-suite 来尽可能地简化中间件、sdk 开发者的验证流程，也便于未来治理后的回归性验证。

## 原生的集成测试编写方式有什么问题
那么 koupleless-test-suite 解决了什么问题呢？假设没有这个框架，当用户需要在本地验证代码的正确性时，其需要经历如下的操作步骤：

1. 构建基座代码。
2. 启动基座代码。
3. 构建模块代码。
4. 安装模块代码。
5. 进行 http / rpc 掉用验证接口结果。

如果 5 失败，则用户需要反复地在 3～5 之间来回操作，并且会涉及在多个 ide / 终端之间的来回切换。

上述步骤是原生的 koupleless 模式无法避免的，因为 koupleless 是多 classLoader 加载多个 jar 包的模式，在该模式下模块单独打包构建是必要的，但这又会引入比较繁琐的验证成本。

## 集成测试框架如何解决了该问题
为了优化该问题，给用户提供简单直接的编程体验，即在 IDEA 里点一下 Debug 按钮即可调试了。我们需要一定的 mock 能力去在 1 个 jar 包中模拟出多个 jar 包的加载行为，免于用户在多个项目之间来回切换。

最终呈现给用户的接口是非常简洁的，用户需要引入如下依赖：

```xml
<dependency>
  <groupId>com.alipay.sofa.koupleless</groupId>
  <artifactId>koupleless-test-suite</artifactId>
  <version>${koupleless.runtime.version}</version>
  <scope>test</scope>
</dependency>
```

启动基座 + 模块的样例代码如下：

```java
  public static void setUpMultiApplication() {
        multiApp = new TestMultiSpringApplication(MultiSpringTestConfig
            .builder()
            .baseConfig(BaseSpringTestConfig.builder()
                        .mainClass(BaseApplication.class)
                        .build()
                       )
            .bizConfigs(
                Lists.newArrayList(
                    BizSpringTestConfig.builder()
                        .bizName("biz1")
                        .mainClass(Biz1Application.class)
                        .build(),
                    BizSpringTestConfig.builder()
                        .bizName("biz2")
                         .mainClass(Biz2Application.class)
                        .build())
            ).build()
        );
        multiApp.run();
    }
```

上述代码会在一个进程中同时启动基座 + 模块 APP，并且底层类加载的行为和生产基本保持一致。

接着，我们就可以便捷地写验证逻辑了, 比如直接拿到模块内部的 Bean 并且进行行为的验证，如下：

```java
Assert.assertEquals(
    "biz1",
    SpringServiceFinder.getModuleService(
        "biz1",
        null,
        StrategyService.class
    ).getAppName()
);
```

目前，Koupleless 自身的 samples 用例，也都通过这套测试框架来做功能性的测试验证，完整的测试用例可以参照工程样例：

[https://github.com/koupleless/samples/tree/main/springboot-samples/web/tomcat/tomcat-web-integration-test](https://github.com/koupleless/samples/tree/main/springboot-samples/web/tomcat/tomcat-web-integration-test)

如果你对测试框架的实现方式感兴趣，欢迎参照官方文档 [https://koupleless.io/docs/tutorials/multi_app_integration_test](https://koupleless.io/docs/tutorials/multi_app_integration_test/) 对测试框架各个重要方法的简单介绍。

# 展望与规划
当然，为了能更好地让用户平滑地接入 koupleless 模式，我们希望与社区共同完善配套工具链，不断完善静态代码扫描与动态集成测试规则，沉淀治理的 adapter，让更多的用户能更低成本的接入使用。

最后欢迎大家来使用 koupleless，并献上您宝贵的意见！

## 
