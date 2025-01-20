```markdown
title: 4.2.3 Java Code Fragment as Module
date: 2024-01-25T10:28:32+08:00
description: Java Code Fragment as Module
weight: 310
```

Module creation has four methods, and this article introduces the fourth method:

1. [Split multiple modules from a large application](/docs/contribution-guidelines/split-module-tool/split-module-tool-intro/)
2. [Transform existing applications into a single module](/docs/tutorials/module-create/springboot-and-sofaboot/)
3. [Create a module directly using scaffolding](/docs/tutorials/module-create/init-by-archetype/)
4. **[Transform ordinary code fragments into a module](/docs/tutorials/module-create/main-biz/)**

This article introduces the operation and verification steps of upgrading Java code fragments to modules, and only requires adding an ark packaging plugin and configuring module slimming to achieve the one-click upgrade of Java code fragments into module applications. It enables the same set of code branches to be independently started like the original Java code fragments, and can also be deployed and started with other applications as a module.

## Prerequisites
- JDK 8
    - sofa.ark.version >= 2.2.14-SNAPSHOT
    - koupleless.runtime.version >= 1.3.1-SNAPSHOT
- JDK 17/JDK 21
    - sofa.ark.version >= 3.1.7-SNAPSHOT
    - koupleless.runtime.version >= 2.1.6-SNAPSHOT

## Integration Steps
### Step 1: Add dependencies and packaging plugins required for the module
```xml
<properties>
    <sofa.ark.version>${see-prerequisites-above}</sofa.ark.version>
    <!-- Use different koupleless versions for different JDK versions, see: https://koupleless.io/docs/tutorials/module-development/runtime-compatibility-list/#%E6%A1%86%E6%9E%B6%E8%87%AA%E8%BA%AB%E5%90%84%E7%89%88%E6%9C%AC%E5%85%BC%E5%AE%B9%E6%80%A7%E5%85%B3%E7%B3%BB -->
    <koupleless.runtime.version>${see-prerequisites-above}</koupleless.runtime.version>
</properties>

<dependencies>
    <dependency>
        <groupId>com.alipay.sofa.koupleless</groupId>
        <artifactId>koupleless-app-starter</artifactId>
        <version>${koupleless.runtime.version}</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
<plugins>
    <!-- Add the ark packaging plugin here -->
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
            <bizName>${replace-with-module-name}</bizName>
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

### Step 2: Add initialization logic

Add `MainApplication.init()` in the code snippet to initialize the container.

```java
public static void main(String[] args) {
        // Initialize the module's instance container
        MainApplication.init();
        // ...
    }
```
In terms of communication between modules and the base, the module registers instances in the container, and the base obtains module instances through `SpringServiceFinder`. Using [biz3](https://github.com/koupleless/samples/tree/main/springboot-samples/service/biz3) as an example:

1. biz3 implements two instances that are based on the `AppService` interface: `Biz3AppServiceImpl` and `Biz3OtherAppServiceImpl`:
```java
public class Biz3OtherAppServiceImpl implements AppService {
    // Get the base bean
    private AppService baseAppService = SpringServiceFinder.getBaseService(AppService.class);
    @Override
    public String getAppName() {
        return "biz3OtherAppServiceImpl in the base: " + baseAppService.getAppName();
    }
}
public class Biz3AppServiceImpl implements AppService {
  // Get the base bean
  private AppService baseAppService = SpringServiceFinder.getBaseService(AppService.class);
  public String getAppName() {
    return "biz3AppServiceImpl in the base: " + baseAppService.getAppName();
  }
}
```
In which, the module obtains the base bean using: `SpringServiceFinder.getBaseService(XXX.class)`, details can be found in: [Module and Base Communication](/docs/tutorials/module-development/module-and-base-communication/) under 'Module calls the base approach two: programming API SpringServiceFinder'.

2. biz3 registers instances of these two classes in the container:
```java
public static void main(String[] args) {
        // Initialize the module's instance container
        MainApplication.init();
        // Register instances in the module container
        MainApplication.register("biz3AppServiceImpl", new Biz3AppServiceImpl());
        MainApplication.register("biz3OtherAppServiceImpl", new Biz3OtherAppServiceImpl());
        }
```
3. The base obtains instances from biz3:
```java
@RestController
public class SampleController {
    // Get specific instances from biz3 through annotation
    @AutowiredFromBiz(bizName = "biz3", bizVersion = "0.0.1-SNAPSHOT", name = "biz3AppServiceImpl")
    private AppService biz3AppServiceImpl;
    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String hello() {
        System.out.println(biz3AppServiceImpl.getAppName());
        // Get specific instances from biz3 through an API
        AppService biz3OtherAppServiceImpl = SpringServiceFinder.getModuleService("biz3", "0.0.1-SNAPSHOT",
                "biz3OtherAppServiceImpl", AppService.class);
        System.out.println(biz3OtherAppServiceImpl.getAppName());
        // Get all instances of AppService class from biz3 through an API
        Map<String, AppService> appServiceMap = SpringServiceFinder.listModuleServices("biz3",
                "0.0.1-SNAPSHOT", AppService.class);
        for (AppService appService : appServiceMap.values()) {
            System.out.println(appService.getAppName());
        }
        return "hello to ark master biz";
    }
}
```
Where SpringBoot / SOFABoot base can obtain module instances through the `@AutowiredFromBiz` annotation or `SpringServiceFinder.getModuleService()` programming API, details can be found in: [Module and Base Communication](/docs/tutorials/module-development/module-and-base-communication/) under 'Base calls module'.

### Step 3: Automate module slimming
Typically, module dependencies for code fragments are relatively simple. You can set the scope of dependencies in the module that are consistent with the base to "provided", or use the [automated slimming capability](/docs/tutorials/module-development/module-slimming.md) of the ark packaging plugin to automatically slim down the maven dependencies in the module. This step is mandatory, otherwise the module jar package will be very large and will result in startup errors.

### Step 4: Build the module into a jar package
Execute `mvn clean package -DskipTest`, and you can find the packaged ark biz jar in the target directory.

## Experiment: Verify the module can be deployed and merged
1. Start the base from the previous step (verify independent start-up steps)
2. Initiate module deployment
   Refer to the sample module deployment of biz3: https://github.com/koupleless/samples/blob/main/springboot-samples/service/README-zh_CN.md
```
