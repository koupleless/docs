---
title: 怎么在一个基座上安装更多的 Koupleless 模块？
date: 2024-12-05T10:28:32+08:00
description: 怎么在一个基座上安装更多的 Koupleless 模块？
weight: 403
author: 梁栎鹏
---
本篇文章属于 Koupleless 进阶系列文章第五篇，默认读者对 Koupleless 的基础概念、能力都已经了解，如果还未了解过的可以查看[官网](https://koupleless.io/docs/introduction/intro-and-scenario/)。

进阶系列一：[Koupleless 模块化的优势与挑战，我们是如何应对挑战的](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97%E6%A8%A1%E5%9D%97%E5%8C%96%E9%9A%94%E7%A6%BB%E4%B8%8E%E5%85%B1%E4%BA%AB%E5%B8%A6%E6%9D%A5%E7%9A%84%E6%94%B6%E7%9B%8A%E4%B8%8E%E6%8C%91%E6%88%98/)

进阶系列二： [Koupleless 内核系列 | 单进程多应用如何解决兼容问题](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97-%E5%8D%95%E8%BF%9B%E7%A8%8B%E5%A4%9A%E5%BA%94%E7%94%A8%E5%A6%82%E4%BD%95%E8%A7%A3%E5%86%B3%E5%85%BC%E5%AE%B9%E9%97%AE%E9%A2%98/)

进阶系列三：[Koupleless 内核系列 | 一台机器内 Koupleless 模块数量的极限在哪里？](http://koupleless.io/blog/2024/01/25/koupleless-%E5%86%85%E6%A0%B8%E7%B3%BB%E5%88%97-%E4%B8%80%E5%8F%B0%E6%9C%BA%E5%99%A8%E5%86%85-koupleless-%E6%A8%A1%E5%9D%97%E6%95%B0%E9%87%8F%E7%9A%84%E6%9E%81%E9%99%90%E5%9C%A8%E5%93%AA%E9%87%8C/)

进阶系列四：[Koupleless 可演进架构的设计与实践｜当我们谈降本时，我们谈些什么](http://koupleless.io/blog/2024/01/25/koupleless-%E5%8F%AF%E6%BC%94%E8%BF%9B%E6%9E%B6%E6%9E%84%E7%9A%84%E8%AE%BE%E8%AE%A1%E4%B8%8E%E5%AE%9E%E8%B7%B5%E5%BD%93%E6%88%91%E4%BB%AC%E8%B0%88%E9%99%8D%E6%9C%AC%E6%97%B6%E6%88%91%E4%BB%AC%E8%B0%88%E4%BA%9B%E4%BB%80%E4%B9%88/)


在往期文章中，我们已经介绍了 Koupleless 的收益、挑战、应对方式及存量应用的改造成本，帮助大家了解到 Koupleless 是如何低成本地给业务研发带来效率提升和资源下降的。在实践中，开发者将多个 Koupleless 模块部署在同一个基座上，从而降低资源成本。那么，如何在一个基座上安装更多的模块呢？

通常来说，有三种方式：模块复用基座的类、模块复用基座的对象、以及模块卸载时清理资源。其中，最简单、最直接、最有效的方式是让模块复用基座的类，即：模块瘦身。接下来，我们将介绍模块瘦身。

模块瘦身是什么？<font style="color:rgba(0, 0, 0, 0.95);">所谓模块瘦身，就是让模块复用基座所有依赖的类，模块打包构建时移除基座已经有的 Jar 依赖，从而让基座中可以安装更多的模块。</font>

<font style="color:rgba(0, 0, 0, 0.95);">在最初的模块瘦身实践中，模块开发者需要感知基座有哪些依赖，在开发时尽量使用这些依赖，从而复用基座依赖里的类。其次，开发者需要根据基座所有依赖，判断可以移除哪些依赖，手工移除依赖。在移除依赖后，还可能会出现以下场景：</font>

1. <font style="color:rgba(0, 0, 0, 0.95);">由于开发者误判，移除了基座没有的依赖，导致模块编译正常通过，而运行期出现 ClassNotFound、LinkageError 等错误；</font>
2. <font style="color:rgba(0, 0, 0, 0.95);">由于模块依赖的版本和基座不同，导致模块编译正常通过，而运行期出现依赖版本不兼容的错误。</font>

由此，引申出 3 个关键问题：

+ <font style="color:rgba(0, 0, 0, 0.95);">模块怎么感知基座运行时的所有依赖，从而确定需要移除的依赖？</font>
+ <font style="color:rgba(0, 0, 0, 0.95);">怎么简单地移除依赖，降低普通应用和模块相互转换的改造成本？</font>
+ <font style="color:rgba(0, 0, 0, 0.95);">怎么保证在移除模块依赖后，模块编译时和模块运行在基座中的依赖是一样的？</font>

本篇文章将介绍模块瘦身原理、原则及关键问题的解决方式。<font style="color:rgba(0, 0, 0, 0.95);"></font>

### 模块瘦身原理
<font style="color:rgba(0, 0, 0, 0.95);">Koupleless 底层借助 SOFAArk 框架，实现了模块之间、模块和基座之间的类隔离。模块启动时会初始化各种对象，会</font>**<font style="color:rgba(0, 0, 0, 0.95);">优先使用模块的类加载器</font>**<font style="color:rgba(0, 0, 0, 0.95);">去加载构建产物 FatJar 中的 class、resource 和 Jar 包，</font>**<font style="color:rgba(0, 0, 0, 0.95);">找不到的类会委托基座的类加载器</font>**<font style="color:rgba(0, 0, 0, 0.95);">去查找。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/8276/1678275655551-75bf283f-3817-447a-84b2-7f6f7f773300.jpeg)

<font style="color:rgba(0, 0, 0, 0.95);">基于这套类委托的加载机制，让基座和模块共用的 class、resource 和 Jar 包</font>**<font style="color:rgba(0, 0, 0, 0.95);">通通下沉</font>**<font style="color:rgba(0, 0, 0, 0.95);">到基座中，可以让模块构建产物</font>**<font style="color:rgba(0, 0, 0, 0.95);">非常小</font>**<font style="color:rgba(0, 0, 0, 0.95);">，从而模块消耗的 Metaspace </font>**<font style="color:rgba(0, 0, 0, 0.95);">非常少</font>**<font style="color:rgba(0, 0, 0, 0.95);">，基座上能安装的模块数量也</font>**<font style="color:rgba(0, 0, 0, 0.95);">更多</font>**<font style="color:rgba(0, 0, 0, 0.95);">，启动也能</font>**<font style="color:rgba(0, 0, 0, 0.95);">非常快</font>**<font style="color:rgba(0, 0, 0, 0.95);">。</font>

<font style="color:rgba(0, 0, 0, 0.95);">其次，模块启动后 Spring 上下文中会创建很多对象，如果启用了模块热卸载，可能无法完全回收，安装次数过多会造成 Old 区、Metaspace 区开销大，触发频繁 FullGC，所以需要控制单模块包大小 < 5MB。</font>**<font style="color:rgba(0, 0, 0, 0.95);">这样不替换或重启基座也能热部署热卸载数百次。</font>**

<font style="color:rgba(0, 0, 0, 0.95);">在模块瘦身后，能实现以下两个好处：</font>

+ <font style="color:rgba(0, 0, 0, 0.95);">允许基座安装更多的模块数量，从而在合并部署场景下，降低更多的资源成本；在热部署热卸载场景下，不替换或重启基座也能热部署、热卸载模块更多次</font>
+ <font style="color:rgba(0, 0, 0, 0.95);">提高模块安装的速度，减少模块包大小，减少启动依赖，控制模块安装耗时 < 30秒，甚至 < 5秒</font>

### <font style="color:rgba(0, 0, 0, 0.95);">模块瘦身原则</font>
由上文模块瘦身原理可知，模块移除的依赖必须在基座中存在，否则模块会在运行期间出现 <font style="color:rgba(0, 0, 0, 0.95);">ClassNotFound、LinkageError 等错误。</font>

<font style="color:rgba(0, 0, 0, 0.95);">因此，模块瘦身的原则是，在保证模块功能的前提下，将框架、中间件等通用的依赖包尽量放置到基座中，模块中复用基座的依赖，这样打出的模块包会更加轻量。</font>如图：

![画板](https://intranetproxy.alipay.com/skylark/lark/0/2024/jpeg/67256811/1729421665929-dc2749f4-a6a3-4e39-950b-4aa01d2501ea.jpeg)

### 可感知的基座运行时
<font style="color:rgba(0, 0, 0, 0.95);">在基座和模块协作紧密的情况下，模块应该在开发时就感知基座正使用的所有依赖，并按需引入需要的依赖，而无需指定版本。为此，我们提供了“基座-dependencies-starter”的打包功能，该包在 <dependencyManagement> 中记录了基座当前所有运行时依赖的 GAV 坐标（GAV: GroupId、ArtifactId、Version）。打包方式非常简单，在基座的打包插件中配置必要的参数即可：</font>

```xml
<build>
  <plugins>
    <plugin>
      <groupId>com.alipay.sofa.koupleless</groupId>
      <artifactId>koupleless-base-build-plugin</artifactId>
      <configuration>
        <!-- ... -->
        <!--生成 starter 的 artifactId（groupId和基座一致），这里需要修改！！-->
        <dependencyArtifactId>${baseAppName}-dependencies-starter</dependencyArtifactId>
        <!--生成jar的版本号-->
        <dependencyVersion>0.0.1-SNAPSHOT</dependencyVersion>
      </configuration>
    </plugin>
  </plugins>
</build>

```

<font style="color:rgba(0, 0, 0, 0.95);">执行 mvn 命令，即可：</font>

```xml
mvn com.alipay.sofa.koupleless:koupleless-base-build-plugin::packageDependency -f ${基座 bootstrap pom 对于基座根目录的相对路径} 
```

<font style="color:rgba(0, 0, 0, 0.95);">然后，模块配置项目的 parent 为 “基座-dependencies-starter”。</font>

```xml
<parent>
    <groupId>com.alipay</groupId>
    <artifactId>${baseAppName}-dependencies-starter</artifactId>
    <version>0.0.1</version>
</parent>
```

以此，<font style="color:rgba(0, 0, 0, 0.95);">在模块的开发过程中，开发者能感知到基座运行时的所有依赖。</font>

### 低成本的模块瘦身
<font style="color:rgba(0, 0, 0, 0.95);">在应用中，最简单的移除依赖的方式是把依赖的 scope 设置为 provided，但这种方式会增加普通应用转换为模块的成本。这种方式也意味着，如果模块要转为普通应用，需要将这些依赖配置回 compile，改造成本较高。</font>

<font style="color:rgba(0, 0, 0, 0.95);">为了降低模块瘦身的成本，我们提供了两种配置模块瘦身的方式：基于“基座-dependencies-starter”自动瘦身和基于配置文件瘦身。</font>

+ <font style="color:rgba(0, 0, 0, 0.95);">基于“基座-dependencies-starter”自动瘦身</font>

我们提供了基于<font style="color:rgba(0, 0, 0, 0.95);">“基座-dependencies-starter” 的自动瘦身，自动排除和基座相同的依赖（GAV 都相同），保留和基座不同的依赖。配置十分简单，在模块的打包插件中配置 baseDependencyParentIdentity 标识即可：</font>

```xml
<build>
  <plugins>
    <plugin>
      <groupId>com.alipay.sofa</groupId>
      <artifactId>sofa-ark-maven-plugin</artifactId>
      <configuration>
        <!-- ... -->
        <!-- 配置 “基座-dependencies-starter” 的标识，规范为：'${groupId}:${artifactId}' -->
        <baseDependencyParentIdentity>${groupId}:${baseAppName}-dependencies-starter</baseDependencyParentIdentity>
      </configuration>
    </plugin>
  </plugins>
</build>
```

+ <font style="color:rgba(0, 0, 0, 0.95);">基于配置文件瘦身</font>

<font style="color:rgba(0, 0, 0, 0.95);">在配置文件中，模块开发者可以主动配置需要排除哪些依赖，保留哪些依赖。</font>

<font style="color:rgba(0, 0, 0, 0.95);">为了进一步降低配置成本，用户仅需配置需要排除的顶层依赖，打包插件会将该顶层依赖的所有间接依赖都排除，而无需手动配置所有的间接依赖。如：</font>

```properties
# excludes config ${groupId}:{artifactId}:{version}, split by ','
excludes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# excludeGroupIds config ${groupId}, split by ','
excludeGroupIds=org.springframework
# excludeArtifactIds config ${artifactId}, split by ','
excludeArtifactIds=sofa-ark-spi
```

### 保证瘦身的正确性
如果基座运行时没有模块被排除的依赖，或者基座运行时中提供的依赖版本和模块预期不一致，那么模块运行过程中可能会报错。为了保证瘦身的正确性，我们需要在模块编译和发布的环节做检查。

在模块编译时，模块打包插件会检查被瘦身的依赖是否在“基座-dependencies-starter”中，并在控制台输出检查结果，但检查结果不影响模块的构建结果。同时，插件允许更严格的检查：配置一定参数，如果基座中不存在模块被排除的依赖，那么模块构建失败，直接报错。

在模块发布时，在发布流程中拉取基座的运行时依赖，检查是否和 “基座-dependencies-starter” 一致。如果不一致，那么卡住发布流程，开发者可根据情况去升级模块的 “基座-dependencies-starter” 或跳过该卡点。

### 模块瘦身效果
以某个模块为例（该模块依赖了 16 个中间件），<font style="color:rgba(0, 0, 0, 0.95);">将模块的 parent 配置为 “基座-dependencies-starter”自动瘦身</font>，下表是瘦身前后的 ark-biz.jar 大小和 Metaspace 占用的对比：

| | 瘦身前 | 瘦身后 | 瘦身后/瘦身前 |
| --- | --- | --- | --- |
| ark-biz.jar 大小 | 133 MB | 24 KB | 0.02% |
| Metaspace 占用 | 84352 KB | 6400 KB | 7.5% |


### 总结
<font style="color:rgb(62, 62, 62);">通过上文相信大家已经了解，我们可以通过简单的配置，让模块打包更小，从而在一个基座上安装更多的 Koupleless 模块，降低更多的资源成本。</font>

<font style="color:rgb(62, 62, 62);">最后，再次欢迎大家使用和参与 Koupleless，我们期待您宝贵的意见！</font>
