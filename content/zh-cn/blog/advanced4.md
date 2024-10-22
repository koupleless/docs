---
title: Koupleless 可演进架构的设计与实践｜当我们谈降本时，我们谈些什么
date: 2024-01-25T10:28:32+08:00
description: Koupleless 可演进架构的设计与实践｜当我们谈降本时，我们谈些什么
weight: 403
author: 赵真灵
---
本篇文章属于 Koupleless 进阶系列文章第三篇，默认读者对 Koupleless 的基础概念、能力都已经了解，如果还未了解过的可以查看[官网](https://koupleless.io/docs/introduction/intro-and-scenario/)。

进阶系列一：[Koupleless 模块化的优势与挑战，我们是如何应对挑战的](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97%E6%A8%A1%E5%9D%97%E5%8C%96%E9%9A%94%E7%A6%BB%E4%B8%8E%E5%85%B1%E4%BA%AB%E5%B8%A6%E6%9D%A5%E7%9A%84%E6%94%B6%E7%9B%8A%E4%B8%8E%E6%8C%91%E6%88%98/)

进阶系列二： [Koupleless 内核系列 | 单进程多应用如何解决兼容问题](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97-%E5%8D%95%E8%BF%9B%E7%A8%8B%E5%A4%9A%E5%BA%94%E7%94%A8%E5%A6%82%E4%BD%95%E8%A7%A3%E5%86%B3%E5%85%BC%E5%AE%B9%E9%97%AE%E9%A2%98/)

进阶系列三：[Koupleless 内核系列 | 一台机器内 Koupleless 模块数量的极限在哪里？](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97-%E4%B8%80%E5%8F%B0%E6%9C%BA%E5%99%A8%E5%86%85-koupleless-%E6%A8%A1%E5%9D%97%E6%95%B0%E9%87%8F%E7%9A%84%E6%9E%81%E9%99%90%E5%9C%A8%E5%93%AA%E9%87%8C/)

进阶系列四：[Koupleless 可演进架构的设计与实践｜当我们谈降本时，我们谈些什么](http://koupleless.io/blog/2024/01/25/koupleless-%E5%8F%AF%E6%BC%94%E8%BF%9B%E6%9E%B6%E6%9E%84%E7%9A%84%E8%AE%BE%E8%AE%A1%E4%B8%8E%E5%AE%9E%E8%B7%B5%E5%BD%93%E6%88%91%E4%BB%AC%E8%B0%88%E9%99%8D%E6%9C%AC%E6%97%B6%E6%88%91%E4%BB%AC%E8%B0%88%E4%BA%9B%E4%BB%80%E4%B9%88/)

## 引入｜为什么写这篇文章
此前，我们已经介绍了 Koupleless 的**收益**、**挑战**以及**应对方式**，帮助大家了解到 Koupleless 是“如何”为业务研发带来效率提升和资源下降的，以及收益的比例会有多少。不过对于企业和开发者来说，这些收益终究还不是自己的，想要让这些收益成为自己的，还需要踏出第一步：**动手试用和接入**。这里涉及到的关键问题是：

1. 代码接入成本是多少？存量应用是否可以使用？
2. 发布到线上所需的平台能力是否需要重新建设？相关的基础设施是否需要适配？

这些问题是企业和开发者关心的问题，也是 Koupleless 能否顺利帮助更广泛的企业降本增效需要解决的关键问题。

本篇文章将详细介绍 Koupleless 为了**降低接入成本**做了哪些设计和考量，并引申出 Koupleless 另一个能力，也就是通过**可演进式架构帮助存量应用低成本演进和享受到 Serverless 收益**的解决方案。这里需要解决的这几个问题：

1. 存量应用的低成本接入
2. 企业模块化平台的低成本建设
3. 应用架构的灵活切换
4. 面向未来的 Serverless 平台

## 存量应用的低成本接入
存量应用要做到低成本接入，需要从研发框架着手，也就是模块化的定义与使用上出发。模块化在 Java 领域里由来已久，相比其他的模块化技术，Koupleless 模块化有哪些不同？为什么 Koupleless 的模块化技术可以规模化落地呢？ 关键问题在于如何处理**模块间的隔离和共享**。

在 Java 领域的各类模块化技术里，有 OSGI/JPMS/Spring Modulith 等，

对于 JPMS 与 Spring Modulith，主要考虑业务逻辑和代码的隔离与管理，通过内置模块或者 inner package 来做逻辑隔离，该方式与传统应用开发习惯有较大不同，对开发者有较高学习成本，存量应用较难改造使用。

在 Koupleless 里，我们使用 Java 领域里用户最熟悉的 ClassLoader 隔离类和资源 和  Spring ApplicationContext 来做隔离对象，这和 OSGI 比较一致。

下面我们主要对比 Koupleless 模块（SOFAArk）与 OSGI 模块的不同，来说明 Koupleless 模块是如何做到低成本使用和规模化落地的。

| | 隔离 | | 共享 |
| --- | --- | --- | --- |
| | 类与资源 | bean与服务 | 类与资源 | bean与服务 |
| JPMS | JVM 内置模块级别访问控制 | JVM 内置模块级别访问控制 | 定义模块间依赖关系，源模块与目标模块定义导入导出列表 | 定义模块间依赖关系，源模块与目标模块定义导入导出列表 |
| Spring Modulith | inner 的子 package，inner 内不允许外部模块访问，并通过 ArchUnit 的 verify 来做校验，未通过则构建失败。 | inner 包，通过单元测 verify 来校验 | 模块 API<br/> | 模块 API 与事件 |
| OSGI | ClassLoader | Spring ApplicationContext | 定义模块间依赖关系，源模块与目标模块定义导入导出列表 | 定义模块间依赖关系，源模块与目标模块定义导入导出列表 |
| SOFAArk | ClassLoader | Spring ApplicationContext | 源模块默认委托给基座（pom 依赖 scope 设置成 provided） | 默认打通跨模块 bean 与服务发现 |


### Koupleless 模块 vs OSGI 模块
Koupleless 模块与 OSGI 模块的不同，主要体现在**模块间如何完成通信和共享**。OSGI 的模块要进行共享和通信，package 需要在每个模块指定 import 和 export，服务需要编写代码定义 Activator 使用 <font style="color:rgb(221, 74, 104);background-color:rgb(245, 242, 240);">BundleContext.registerService</font>   进行注册，示例如下：

```java
// 类导出，定义在 MANI
Export-Package: com.example.mypackage, com.example.anotherpackage

// 服务导出
MyService myService = new MyServiceImpl();
context.registerService(MyService.class.getName(), myService, null);
```

```java
// 类导入
Import-Package: com.example.mypackage, com.example.anotherpackage

// 服务导入
MyService myService = new MyServiceImpl();
context.registerService(MyService.class.getName(), myService, null);
```

这就带来了较大的配置和使用成本。



<font style="color:#117CEE;">而 Koupleless 模块化设计虽然借鉴了 OSGI 的设计，却也简化了这一模块共享和通信的使用方式。</font>

<font style="color:#117CEE;"></font>

#### 1⃣️免配置的类与资源共享方式
1. OSGI 模块角色都是对等的，在这一点上 Koupleless 与之不同。Koupleless 对模块做了区分，定义了两种不同角色：模块与基座（基座背后也是一个模块）。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1722234767836-5acf6726-3b15-4fb4-b275-08de3e09f7ac.png)



在类和资源共享的时候，默认从各自模块自身查找。如果查找到则直接返回；如果查找不到，只要模块 pom 里引入过的类就会<font style="color:#DF2A3F;">默认从基座</font>查找。所以模块里并不需要定义类和资源的导入导出配置，只要定义哪些由自己加载，哪些委托给基座加载即可。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1722234908590-2f01ac6a-8471-4008-8505-f807797f9170.png)![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1722235190576-3ebd3074-68ac-48b0-8c41-caa7abb363fd.png)



而定义由自己加载的方式只要模块的 pom 里 compile 引入对应依赖即可；要委托给基座的，也只需要在配置文件里配置即可，如下配置，详见[模块瘦身](https://koupleless.io/docs/tutorials/module-development/module-slimming/)。



```properties
excludes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
excludeGroupIds=org.springframework
excludeArtifactIds=sofa-ark-spi
```

#### 2⃣️免配置的通信方式
与 OSGI 需要主动注册的方式不同，Koupleless 在 Dubbo 或者 SOFABoot 等框架里提供了跨模块间查找的能力，模块开发方式完全没有改动，需要使用其他可以直接使用等 `@SOFAReference` 注解获取其他模块里的对象。而在 SpringBoot 里，Koupleless 也提供了 @AutowiredFromBase @AutowiredFromBiz 来主动获取其他模块的对象。

#### 3⃣️给业务自由
Koupleless 让业务模块来决定哪些类和资源或者对象需要从基座里获取，与 OSGI 相比，这里不需要双向的配置，只要业务模块主动“去拿”就可以。



凭借以上三点，可以让模块开发者像开发普通 SpringBoot 一样开发模块，让业务低成本的使用 Koupleless 模块化框架。当然这里并不是说 Koupleless 模块比 OSGI 模块更优秀，而是 Koupleless 模块根据特定的场景做了特定的简化，也随之带来了这样的效果。

当然除了上述的简化外，Koupleless 在研发侧还做了大量的工作，包括普通应用只需要引入 SDK 和构建插件[低成本改造](https://koupleless.io/docs/tutorials/base-create/springboot-and-sofaboot/)成基座或模块、[低成本的模块瘦身方案](https://koupleless.io/docs/tutorials/module-development/module-slimming/)、[arkctl 的研发工具](https://github.com/koupleless/arkctl/releases)、[生态组件的多应用低成本适配和使用](https://github.com/koupleless/adapter)等。



## 企业模块运维调度平台的低成本建设
### 🤔️直接的方案：在基座平台之上建设模块平台
在介绍运维调度的低成本方案前，我们需要先了解模块化的运维调度到底是在做什么。简单理解，就是在已有基座的情况下，**在基座上分批安装模块**。安装需要如下几个步骤：

1. 假如基座有 100 台机器，需要获取基座的一个批次的机器（例如 10 台机器的 IP）；
2. 给这个批次的每台机器，逐个发送运维指令，包括模块名、模块 jar 包地址、运维类型等信息；
3. 每台机器接收到指令后，解析指令，下载模块 jar 包并解压，然后通过模块里定义的 main 方法启动模块；
4. 返回模块安装状态信息，批次安装结束；
5. 开始新的批次，直到所有机器完成安装。

该过程需要选择基座机器并发送运维指令，然后根据状态判断安装成功与否，从而继续下批次运维。

实现这类运维过程比较直接的解决方式是，**<font style="color:#117CEE;">在基座平台之上建设模块平台</font>**。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1722262755360-53f23e76-0009-4daf-8da6-05530198b2a4.png)

再由模块平台负责：

1. 管理模块版本、模块流量
2. 选择待安装的机器
3. 发送安装指令
4. 维护模块状态
5. ……

然而选择这种方式，企业除了需要建设完整的模块化运维调度平台及对应产品外，还需要适配多种基础设施平台，例如：

1. 应用元数据管理平台：新增模块应用元数据
2. 研发与迭代管理平台：增加模块创建、模块迭代、模块构建、发起模块发布
3. 联调平台：增加模块与基座、模块与普通应用联调
4. 可观测平台：监控与告警、trace 追踪、日志采集与查询
5. 灰度平台
6. 模块流量

这样的话，企业接入的成本是相当大的。为了降低生态企业建设成本，我们设计了与生态更融合的模块化平台建设方案。

### ✅降本的方案：复用原生 K8s 的模块化平台
为了尽可能降低模块化平台建设成本，我们进一步分析模块运维调度的过程：这个过程主要是“选择有资源空闲或者带升级机器然后执行指令”，也就是**将模块 Jar 调度安装到 Pod 上**的过程，这个过程实际与普通应用将 Pod 调度到 Node 上的运维调度过程非常类似。所以我们设计了基于 Virtual-Kubelet 的方案，将模块平台融入到 K8s 平台里。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1722303860276-cf6eb830-b12b-462f-9088-0954372c271d.png)

将业务模块映射成 pod，将基座 pod 映射成 Node，这样就可以复用 K8s 的能力来运维调度模块。具体过程如下：

1. 安装 Virtual-Kubelet，映射出 Virtual Node，Virtual Kubelet 将保持基座与 VNode 的状态同步：![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1719314578342-c64f1d51-0238-4db0-a532-42cbb73e8d72.png)
2. 安装模块，创建模块的 Deployment（即原生 K8s Deployment），此时 K8s ControllerManager 会创建出模块的 VPod（刚创建时还未调度到节点上，状态为 Pending）：

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1719314609419-5d388c62-738d-4b5f-97ee-c3f0b18a0875.png)

3. K8s Scheduler 发现 VPod 可以调度到 VNode 上，将 VPod 分配到 VNode 上：

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1719314631905-0b34c960-55af-4287-bc13-3e4b42c0f552.png)

4. Virtual Kubelet 发现 VNode 上有 VPod 调度上来，发起模块安装指令到基座上：

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1719314680898-2f1bae1d-2c34-4be2-a593-68fb9c1cc49e.png)

5. 安装成功后，保持模块与 VPod、基座 Pod 与 Node 间的状态同步：

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1719316854992-6a29bbb1-792b-4357-abab-b2bfb02f5f91.png)

6. 同时可以使用 K8s Service 创建模块的独立流量单元：

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1719316877032-a7ca3a14-98be-4f16-9804-f8c545be2cd2.png)

这样模块的版本管理、安装发布、模块的流量都可以通过创建模块的 deployment 和 service 来完成。更进一步的，模块的发布平台也可以直接复用普通应用的 PaaS 平台来完成，只要创建或更新对应的模块 Deployment 即可。

## 可演进的应用架构
Koupleless 模块化实际上是在单体架构和微服务架构之间增加了**模块化架构**这个桥梁，并降低经由这个桥梁的改造成本，这是 Koupleless 可演进架构的关键设计。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1722307031166-d42b1954-e1df-42bf-9cf3-23c790366abd.png)

模块架构在之前文章已有详细介绍，这里介绍下 Koupleless 如何降低其中演进过程的改造工作。

Koupleless 为了帮助应用从单体架构 <--> 模块架构 <--> 微服务架构平滑演进，提供了半自动化工具和最佳实践。例如

1. 单体架构 <--> 模块架构：[模块半自动拆分工具](https://koupleless.io/docs/contribution-guidelines/split-module-tool/split-module-tool-intro/)；基座与模块共库
2. 模块架构 <--> 微服务架构：不改代码即可切换模块还是微服务部署模式，主要是在代码里同时引入 springboot fatjar 和 sofaArk biz jar 打包插件，然后根据发布方式不同选择镜像化部署还是模块化部署。

```xml
<build>
    <plugins>
        <plugin>
            <groupId>com.alipay.sofa</groupId>
            <artifactId>sofa-ark-maven-plugin</artifactId>
            <version>${sofa.ark.version}</version>
        </plugin>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <version>${spring.boot.version}</version>
        </plugin>
    </plugins>
</build>
```



## 基于 Koupleless 的 Serverless 的能力
当前对于业务模块开发者来说，由于已经不需要感知机器，已经享受到了一些 Serverless 的收益。这种收益对于类似代码片段的中台模块来说更加明显，除了不感知机器外，还不需要引入、配置和初始化中间件等基础服务的使用方式，这些都由基座封装成 API 给模块使用。

在调度上，由于不同的机器上可以安装不同的模块，这样我们可以划分出不同机器组，例如日常机器组、高保机器组、buffer 机器组。模块 3 可以安装到高保机器组上，如果模块 3 流量增加，可以从 buffer 机器组里调度出机器直接安装模块，这样模块 3 的扩容即可秒级完成。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1722310694697-7e14ef45-33b7-44cd-9902-02e90662da98.png)

另外，模块也可以有自己的副本数，模块可以配置弹性伸缩规则、流量驱动等更多的 Serverless 能力。

## 总结
通过上文相信大家已经了解，存量应用从单体应用或者微服务应用可以低成本演进到模块应用，并利用模块化能力，演进出 Serverless 的能力。



不过当前 Koupleless 还没有开放出 Serverless 平台的能力，还需要和社区共同建设。希望未来有更多的伙伴加入，一起打造帮助存量应用低成本演进和享受到 Serverless 收益的可演进架构和解决方案。
