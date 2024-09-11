---
title: 4.2.3 Java 代码片段作为模块
date: 2024-01-25T10:28:32+08:00
description: Java 代码片段作为模块
weight: 210
---

模块的创建有四种方式，本文介绍第四种方式：
1. [大应用拆出多个模块](/docs/contribution-guidelines/split-module-tool/split-module-tool-intro/)
2. [存量应用改造成一个模块](/docs/tutorials/module-create/springboot-and-sofaboot/)
3. [直接脚手架创建模块](/docs/tutorials/module-create/init-by-archetype/)
4. **[普通代码片段改造成一个模块](/docs/tutorials/module-create/main-biz/)**

本文介绍 Java 代码片段升级为模块的操作和验证步骤，仅需加一个 ark 打包插件 + 配置模块瘦身 即可实现 Java 代码片段一键升级为模块应用，并且能做到同一套代码分支，既能像原来 Java 代码片段一样独立启动，也能作为模块与其它应用合并部署在一起启动。

## 前提条件

- jdk8
    - sofa.ark.version >= 2.2.14-SNAPSHOT
    - koupleless.runtime.version >= 1.3.1-SNAPSHOT
- jdk17/jdk21
    - sofa.ark.version >= 3.1.7-SNAPSHOT
    - koupleless.runtime.version >= 2.1.6-SNAPSHOT

## 接入步骤

### 步骤 1：添加模块需要的依赖和打包插件

```xml
<properties>
    <sofa.ark.version>${见上述前提条件}</sofa.ark.version>
    <!-- 不同jdk版本，使用不同koupleless版本，参考：https://koupleless.io/docs/tutorials/module-development/runtime-compatibility-list/#%E6%A1%86%E6%9E%B6%E8%87%AA%E8%BA%AB%E5%90%84%E7%89%88%E6%9C%AC%E5%85%BC%E5%AE%B9%E6%80%A7%E5%85%B3%E7%B3%BB -->
    <koupleless.runtime.version>${见上述前提条件}</koupleless.runtime.version>
</properties>
<!-- 模块需要引入的依赖，主要用户跨模块间通信 --> 
<dependencies>
    <dependency>
        <groupId>com.alipay.sofa.koupleless</groupId>
        <artifactId>koupleless-app-starter</artifactId>
        <version>${koupleless.runtime.version}</version>
        <scope>provided</scope>
    </dependency>
</dependencies>

<plugins>
    <!--这里添加ark 打包插件-->
    <plugin>
        <groupId>com.alipay.sofa</groupId>
        <artifactId>sofa-ark-maven-plugin</artifactId>
        <version>{sofa.ark.version}</version>
        <executions>
            <execution>
                <id>default-cli</id>
                <goals>
                    <goal>repackage</goal>
                </goals>
            </execution>
        </executions>
        <configuration>
            <skipArkExecutable>true</skipArkExecutable>
            <outputDirectory>./target</outputDirectory>
            <bizName>${替换为模块名}</bizName>
            <declaredMode>true</declaredMode>
        </configuration>
    </plugin>
    
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>3.2.0</version>
        <executions>
            <execution>
                <goals>
                    <goal>jar</goal>
                </goals>
                <phase>package</phase>
                <configuration>
                    <classifier>lib</classifier>
                    <!-- Ensure other necessary configuration here -->
                </configuration>
            </execution>
        </executions>
    </plugin>
</plugins>
```

### 步骤 2: 增加初始化逻辑
在代码片段添加：`MainApplication.init()` 来初始化容器。 
```java
public static void main(String[] args) {
        // 初始化模块的实例容器
        MainApplication.init();

        // ...
    }
```

在模块和基座的通信上，模块将实例注册在容器中，基座通过`SpringServiceFinder`获取模块实例，我们以[biz3](https://github.com/koupleless/samples/tree/main/springboot-samples/service/biz3) 为例：

1. biz3 实现了以 `AppService` 为接口的两个实例：`Biz3AppServiceImpl` 和 `Biz3OtherAppServiceImpl`：
```java
public class Biz3OtherAppServiceImpl implements AppService {
    // 获取基座的bean
    private AppService baseAppService = SpringServiceFinder.getBaseService(AppService.class);

    @Override
    public String getAppName() {
        return "biz3OtherAppServiceImpl in the base: " + baseAppService.getAppName();
    }
}

public class Biz3AppServiceImpl implements AppService {
  // 获取基座的bean
  private AppService baseAppService = SpringServiceFinder.getBaseService(AppService.class);

  public String getAppName() {
    return "biz3AppServiceImpl in the base: " + baseAppService.getAppName();
  }
}
```

其中，模块获取基座的 bean 方式为：`SpringServiceFinder.getBaseService(XXX.class)`，详细可见：[模块和基座通信](/docs/tutorials/module-development/module-and-base-communication/) 的 `模块调用基座的方式二：编程API SpringServiceFinder`。

2. biz3 将这两个类的实例注册到容器中：
```java
public static void main(String[] args) {
        // 初始化模块的实例容器
        MainApplication.init();

        // 注册实例到模块容器中
        MainApplication.register("biz3AppServiceImpl", new Biz3AppServiceImpl());
        MainApplication.register("biz3OtherAppServiceImpl", new Biz3OtherAppServiceImpl());

        }
```

3. 基座中获取 biz3 中的实例：
```java
@RestController
public class SampleController {

    // 通过注解获取 biz3 中的指定实例
    @AutowiredFromBiz(bizName = "biz3", bizVersion = "0.0.1-SNAPSHOT", name = "biz3AppServiceImpl")
    private AppService biz3AppServiceImpl;

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String hello() {
        System.out.println(biz3AppServiceImpl.getAppName());

        // 通过 api 获取 biz3 中的指定实例
        AppService biz3OtherAppServiceImpl = SpringServiceFinder.getModuleService("biz3", "0.0.1-SNAPSHOT",
                "biz3OtherAppServiceImpl", AppService.class);
        System.out.println(biz3OtherAppServiceImpl.getAppName());

        // 通过 api 获取 biz3 中 AppService.class 的所有实例
        Map<String, AppService> appServiceMap = SpringServiceFinder.listModuleServices("biz3",
                "0.0.1-SNAPSHOT", AppService.class);
        for (AppService appService : appServiceMap.values()) {
            System.out.println(appService.getAppName());
        }
        return "hello to ark master biz";
    }
}
```

其中，SpringBoot / SOFABoot 基座可以通过 `@AutowiredFromBiz` 注解或 `SpringServiceFinder.getModuleService()` 编程API 获取模块中的实例，详细可见：[模块和基座通信](/docs/tutorials/module-development/module-and-base-communication/) 的`基座调用模块`。

### 步骤 3：自动化瘦身模块

一般来说，代码片段式的模块依赖比较简单，您可以自行将模块中与基座一致的依赖的 scope 设置成 provided，或使用 ark 打包插件的[自动化瘦身能力](/docs/tutorials/module-development/module-slimming.md)，自动瘦身模块里的 maven 依赖。这一步是必选的，否则构建出的模块 jar 包会非常大，而且启动会报错。

### 步骤 4：构建成模块 jar 包

执行 `mvn clean package -DskipTest`, 可以在 target 目录下找到打包生成的 ark biz jar 包。

## 实验：验证模块能合并部署

1. 启动上一步（验证能独立启动步骤）的基座
2. 发起模块部署

可以参考样例中 biz3 的模块部署：https://github.com/koupleless/samples/blob/main/springboot-samples/service/README-zh_CN.md