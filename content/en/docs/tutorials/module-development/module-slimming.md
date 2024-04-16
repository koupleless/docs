---
title: Module Slimming
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Slimming
weight: 200
---

- Speed up module installation, reduce module package size, reduce startup dependencies, and control module installation time to less than 30 seconds, or even less than 5 seconds.
- After the module starts, many objects will be created in the Spring context. If module hot unloading is enabled, it may not be completely recycled. Too many installations will cause large overhead in the Old area and Metaspace area, triggering frequent FullGC. Therefore, the size of a single module package should be controlled to less than 5MB. **This way, you can deploy and unload hundreds of times without replacing or restarting the base.**

## One-Click Automatic Slimming

### Slimming Principles

The principle of building an ark-biz jar package is to place as many common packages such as frameworks and middleware as possible into the base while ensuring the functionality of the module. Reuse the base packages in the module, so that the ark-biz jar package will be lighter. In complex applications, in order to better use the automatic slimming function of the module, you need to exclude more common dependency packages based on the list of configurations given in the module slimming configuration (module root directory/conf/ark/file name.txt) according to the established format.

### Step 1

In the "module project root directory/conf/ark/file name.txt" (for example: my-module/conf/ark/rules.txt), configure the common packages of frameworks and middleware that need to be sunk to the base in the following format. You can also directly copy the [content of the default rules.txt file](https://github.com/koupleless/samples/blob/main/springboot-samples/slimming/log4j2/biz1/conf/ark/rules.txt)to your project.

```xml
excludeGroupIds=org.apache*
excludeArtifactIds=commons-lang
```

### Step 2

In the module packaging plugin, introduce the above configuration file:

```xml
    <!-- Plugin 1: Packaging plugin for sofa-ark biz, packaging as ark biz jar -->
    <plugin>
        <groupId>com.alipay.sofa</groupId>
        <artifactId>sofa-ark-maven-plugin</artifactId>
        <version>${sofa.ark.version}</version>
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
            <bizName>biz1</bizName>
            <!-- packExcludesConfig: Module slimming configuration, file name custom, corresponding to the configuration -->
            <!--                     File location: biz1/conf/ark/rules.txt -->
            <packExcludesConfig>rules.txt</packExcludesConfig>
            <webContextPath>biz1</webContextPath>
            <declaredMode>true</declaredMode>
            <!--                     Packaging, installation, and publication ark biz -->
            <!--                     Static merge deployment requires configuration -->
            <!--                     <attach>true</attach> -->
        </configuration>
    </plugin>
```

### Step 3

Build and package the module ark-biz jar package, and you can clearly see the difference in size after slimming.

You can [click here](https://github.com/koupleless/samples/tree/main/springboot-samples/slimming)to view the complete example project of module slimming. You can also continue reading to understand the slimming principle of the module.


## Basic Principles
Koupleless is based on the SOFAArk framework to achieve mutual isolation between modules, between modules and bases. The following two core logics are very important for coding and need to be deeply understood:

1. The base has an independent class loader and Spring context, and the module also has **an independent class loader** and **Spring context**, and the Spring context between them is **isolated**.
2. When the module starts, it will initialize various objects, and will **preferentially use the module's class loader** to load the classes, resources, and Jar packages in the built artifact FatJar. If the class cannot be found, it will delegate to the base's class loader to search.

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/8276/1678275655551-75bf283f-3817-447a-84b2-7f6f7f773300.jpeg)

Based on this set of class delegation loading mechanism, all the classes, resources, and Jar packages shared by the base and modules are **all sunk** to the base, which can make the module built artifact **very small**, more importantly, it can also make the module reuse a large number of resources such as class, bean, service, IO connection pool, thread pool, etc., already existing in the base during runtime, so the module consumes **very little memory** and starts very quickly. <br /> The so-called module slimming means that the dependencies already existing in the base must be cleaned out in the module, and the scope of the common Jar packages in the main pom.xml and bootstrap/pom.xml is declared as **provided**, so that they do not participate in packaging and building.


## Manual Package Exclusion Slimming
When loading classes during module runtime, it will first look for them in its own dependencies. If it cannot be found, it will delegate to the base's ClassLoader to load.<br />Therefore, for dependencies already existing in the base, set their scope to provided in the module pom.xml to avoid them participating in module packaging.<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/8276/1678276103445-036d226e-4f88-40bc-937d-90fd4c60b83d.png#clientId=udf1ce5b3-f5a9-4&from=paste&height=521&id=jFiln&originHeight=1042&originWidth=1848&originalType=binary&ratio=2&rotation=0&showTitle=false&size=957278&status=done&style=none&taskId=u254c8709-de81-4175-bcf8-f1c4a26bc49&title=&width=924)

If the dependency to be excluded cannot be found, you can use the **maven helper plugin** to find its direct dependencies. For example, in the figure, the dependency to be excluded is spring-boot-autoconfigure, and the direct dependencies on the right include sofa-boot-alipay-runtime, ddcs-alipay-sofa-boot-starter, etc. (only dependencies with scope compile need to be considered):<br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/191604/1691733668683-34a9d11f-3ca6-4b66-a4e3-22ade9413094.png#clientId=u05d65c58-49f7-4&from=paste&height=869&id=u467da8b5&originHeight=1738&originWidth=2644&originalType=binary&ratio=2&rotation=0&showTitle=false&size=1043897&status=done&style=none&taskId=u70530c01-d7a5-4ca9-875d-3785f59242b&title=&width=1322)<br />Confirm that ddcs-alipay-sofa-boot-starter is in your code pom.xml, add exclusions to exclude dependencies: <br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/191604/1691735644585-9201c203-b749-46e9-ab96-49ecc8090098.png#clientId=uda997d0f-c9aa-4&from=paste&height=244&id=ub08bbabe&originHeight=488&originWidth=1476&originalType=binary&ratio=2&rotation=0&showTitle=false&size=85290&status=done&style=none&taskId=u7f72a9d1-a1cd-422e-a50a-beafc4a9c4a&title=&width=738)


## Unified Packaging Exclusion in pom.xml (More Thorough)
Some dependencies bring in too many transitive dependencies, making manual inspection difficult. At this time, you can use wildcard matching to exclude all those dependencies of middleware and base, such as org.apache.commons, org.springframework, etc. This approach will exclude all indirect dependencies, which is more efficient than using sofa-ark-maven-plugin for exclusion:
```xml
<dependency>
    <groupId>com.koupleless.mymodule</groupId>
    <artifactId>mymodule-core</artifactId>
    <exclusions>
          <exclusion>
              <groupId>org.springframework</groupId>
              <artifactId>*</artifactId>
          </exclusion>
          <exclusion>
              <groupId>org.apache.commons</groupId>
              <artifactId>*</artifactId>
          </exclusion>
          <exclusion>
              <groupId>......</groupId>
              <artifactId>*</artifactId>
          </exclusion>
    </exclusions>
</dependency>
```

## Specify Packaging Exclusion in sofa-ark-maven-plugin
By using **excludeGroupIds** and **excludeArtifactIds**, you can exclude a large number of common dependencies already present on the base:
```xml
 <plugin>
      <groupId>com.alipay.sofa</groupId>
      <artifactId>sofa-ark-maven-plugin</artifactId>
      <executions>
          <execution>
              <id>default-cli</id>
              <goals>
                  <goal>repackage</goal>
              </goals>
          </execution>
      </executions>
      <configuration>
          <excludeGroupIds>io.netty,org.apache.commons,......</excludeGroupIds>
          <excludeArtifactIds>validation-api,fastjson,hessian,slf4j-api,junit,velocity,......</excludeArtifactIds>
          <outputDirectory>../../target</outputDirectory>
          <bizName>mymodule</bizName>
          <finalName>mymodule-${project.version}-${timestamp}</finalName>
          <bizVersion>${project.version}-${timestamp}</bizVersion>
          <webContextPath>/mymodule</webContextPath>
      </configuration>
  </plugin>
```

<br/>
<br/>
