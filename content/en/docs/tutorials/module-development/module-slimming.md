---
title: Module Slimming
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Slimming
weight: 200
---
## Why Slim Modules
To make module installation faster and reduce memory usage:
- Improve the speed of module installation, reduce module package size, and reduce startup dependencies. Control module installation time to be < 30 seconds, or even < 5 seconds.
- After a module starts, many objects are created in the Spring context. If module hot unloading is enabled, it may be impossible to completely reclaim resources, causing high overhead in the Old and Metaspace areas and frequent FullGC triggers. Therefore, it's necessary to control the size of a single module package to be < 5MB. **This allows hundreds of hot deploys and hot unloads without replacing or restarting the base.**

## One-Click Automatic Slimming (Recommended)
### Slimming Principles

The principle of building an ark-biz jar package is to place common packages like frameworks and middleware into the base as much as possible while ensuring the module's functionality. Reuse the base's packages in the module to make the ark-biz jar lighter. For complex applications, to better use automatic module slimming, configure more common dependencies to exclude in the module slimming configuration (module root directory /conf/ark/filename.txt) based on the sample given.

### Step 1: Package "Base-dependencies-starter"
**Goal**

This step will package the "Base dependencies-starter" to uniformly manage module dependency versions.

**Add configuration to base bootstrap pom**

Note: The dependencyArtifactId in the following configuration needs to be modified, usually to ${baseAppName}-dependencies-starter.

```xml
<build>
<plugins>
    <plugin>
        <groupId>com.alipay.sofa.koupleless</groupId>
        <artifactId>koupleless-base-build-plugin</artifactId>
        <version>1.2.4-SNAPSHOT</version>
        <configuration>
            <!-- ArtifactId for generated starter (groupId same as base), needs modification -->
            <dependencyArtifactId>${baseAppName}-dependencies-starter</dependencyArtifactId>
            <!-- Version number for generated jar -->
            <dependencyVersion>0.0.1-SNAPSHOT</dependencyVersion>
            <!-- For debugging, set to true to see intermediate build artifacts -->
            <cleanAfterPackageDependencies>false</cleanAfterPackageDependencies>
        </configuration>
    </plugin>
  </plugins>
</build>
```
**Local Testing**

1. Package the base dependency-starter jar: Execute the command in the base root directory:

``` shell
mvn com.alipay.sofa.koupleless:koupleless-base-build-plugin::packageDependency -f ${Relative path to base bootstrap pom from base root directory} 
```

The constructed pom will be in the outputs directory and will be automatically installed into the local maven repository.

### Step 2: Modify Module Packaging Plugin and Parent

**Goal**

1. When developing modules, use the "Base-dependencies-starter" from Step 1 as the module project's parent to manage dependency versions uniformly.
2. Modify the module packaging plugin so that only dependencies "absent in the base" or "with different versions from the base" are packaged into the module, achieving seamless module slimming without manually configuring "provided".

Note: Sometimes the dependency still needs to be retained while packaging the module, although the base and module use the same dependency version. This feature will be launched by the end of July.

**Configure parent in module root pom:**

```xml
<parent>
   <groupId>com.alipay</groupId>
   <artifactId>${baseAppName}-dependencies-starter</artifactId>
   <version>0.0.1-SNAPSHOT</version>
</parent>
```

**Configure plugin in module packaging pom:**

```xml
<build>
   <plugins>
       <plugin>
           <groupId>com.alipay.sofa</groupId>
           <artifactId>sofa-ark-maven-plugin</artifactId>
           <version>2.2.13-SNAPSHOT</version>
           <executions>
               <execution>
                   <id>default-cli</id>
                   <goals>
                       <goal>repackage</goal>
                   </goals>
               </execution>
           </executions>
           <configuration>
               <!-- Configuration of base-dependencies-starter's identifier, format: '${groupId}:${artifactId}':'version' -->
               <baseDependencyParentIdentity>com.alipay:${baseAppName}-dependencies-starter:0.0.1-SNAPSHOT</baseDependencyParentIdentity>
           </configuration>
       </plugin>
   </plugins>
</build>
```
### Step 3
Package the module to generate the ark-biz jar package. You will notice a significant size difference in the slimmed ark-biz jar package.

You can [click here](https://github.com/koupleless/samples/tree/master/springboot-samples/slimming) to view the complete module slimming sample project. You can also continue reading below to understand the principles behind module slimming.

## Basic Principles
Koupleless leverages the SOFAArk framework to achieve mutual isolation between modules, and between modules and the base. The following core logic is crucial and must be deeply understood:

1. The base has its own class loader and Spring context, and each module also has its own **class loader** and **Spring context**. The Spring contexts are **isolated** from each other.
2. During module startup, various objects are initialized. The module's class loader is **prioritized** to load classes, resources, and jars from the FatJar package. **If the class is not found, it delegates the base class loader** to find it.

<div style="text-align: center;">
    <img width="700" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/8276/1678275655551-75bf283f-3817-447a-84b2-7f6f7f773300.jpeg"/>
</div>

This class delegation mechanism allows the base and module to share classes, resources, and jar files, **reducing** the module's size significantly. More importantly, it allows modules to extensively reuse the base's classes, beans, services, IO connection pools, thread pools, and other resources during runtime, leading to **minimal** memory consumption and **fast** startup times for modules.

Module slimming essentially means ensuring that jar dependencies already present in the base are thoroughly excluded from the module. Declare the shared jar dependencies as **provided** in both the main pom.xml and bootstrap/pom.xml, so they don't participate in the build process.

## Other Slimming Methods (Not Recommended)
### Method 1: SOFAArk Configuration File Exclusion
### Step 1
SOFAArk module slimming reads three types of configuration files:

- "Module root directory/conf/ark/bootstrap.properties", e.g., my-module/conf/ark/bootstrap.properties
- "Module root directory/conf/ark/bootstrap.yml", e.g., my-module/conf/ark/bootstrap.yml
- "Module root directory/conf/ark/filename.txt", e.g., my-module/conf/ark/rules.txt

#### Configuration
##### bootstrap.properties (Recommended)

In the "Module root directory/conf/ark/bootstrap.properties", configure the common framework and middleware packages to be delegated to the base in the following format:

```properties
# excludes config ${groupId}:{artifactId}:{version}, split by ','
excludes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# excludeGroupIds config ${groupId}, split by ','
excludeGroupIds=org.springframework
# excludeArtifactIds config ${artifactId}, split by ','
excludeArtifactIds=sofa-ark-spi
```

##### bootstrap.yml (Recommended)

In the "Module root directory/conf/ark/bootstrap.yml", configure the common framework and middleware packages to be delegated to the base in the following format:

```yaml
# Configure with excludes ${groupId}:{artifactId}:{version}, separated by -
# excludeGroupIds with ${groupId}, separated by -
# excludeArtifactIds with ${artifactId}, separated by -
excludes:
  - org.apache.commons:commons-lang3
  - commons-beanutils:commons-beanutils
excludeGroupIds:
  - org.springframework
excludeArtifactIds:
  - sofa-ark-spi
```

##### rules.txt (Not Recommended)

In the "Module root directory/conf/ark/filename.txt", configure the common framework and middleware packages to be delegated to the base in the following format. You can also directly copy the [default rules.txt](https://github.com/koupleless/samples/blob/main/springboot-samples/slimming/log4j2/biz1/conf/ark/rules.txt) file content to your project.

```xml
excludeGroupIds=org.apache*
excludeArtifactIds=commons-lang
```

### Step 2

In the module packaging plugin, reference the configuration file:

```xml
    <!-- Plugin 1: Packaging plugin for sofa-ark biz, packages into ark biz jar -->
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
            <!-- packExcludesConfig	Module slimming config file -->
            <!-- Config file location: biz1/conf/ark/rules.txt -->
            <packExcludesConfig>rules.txt</packExcludesConfig>
            <webContextPath>biz1</webContextPath>
            <declaredMode>true</declaredMode>
            <!-- Package, install, and publish ark biz -->
            <!-- Static merge deployment requires configuration -->
            <!-- <attach>true</attach> -->
        </configuration>
    </plugin>
```
### Step 3

Package the module to generate the ark-biz jar package. You will notice a significant size difference in the slimmed ark-biz jar package.

You can [click here](https://github.com/koupleless/samples/tree/master/springboot-samples/slimming) to view the complete module slimming sample project. You can also continue reading below to understand the principles behind module slimming.

### Method 2: Exclude Dependencies in pom

#### Exclusion Technique 1: Use Maven Helper Plugin

During module runtime, classes are loaded by checking the module's dependencies first. If not found, the class loader delegates the search to the base's ClassLoader.

Therefore, for dependencies already present in the base, set their scope to provided in the module pom to avoid them participating in the module packaging.

<div style="text-align: center;">
    <img width="700" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/8276/1678276103445-036d226e-4f88-40bc-937d-90fd4c60b83d.png#clientId=udf1ce5b3-f5a9-4&from=paste&height=521&id=jFiln&originHeight=1042&originWidth=1848&originalType=binary&ratio=2&rotation=0&showTitle=false&size=957278&status=done&style=none&taskId=u254c8709-de81-4175-bcf8-f1c4a26bc49&title=&width=924"/>
</div>
If the dependency to exclude isn't found, use the **maven helper plugin** to find its direct dependencies. For example, the dependency to exclude is spring-boot-autoconfigure, and the direct dependencies on the right are sofa-boot-alipay-runtime, ddcs-alipay-sofa-boot-starter, etc. (Consider only dependencies with the scope as compile):

<div style="text-align: center;">
    <img width="800" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/191604/1691733668683-34a9d11f-3ca6-4b66-a4e3-22ade9413094.png#clientId=u05d65c58-49f7-4&from=paste&height=869&id=u467da8b5&originHeight=1738&originWidth=2644&originalType=binary&ratio=2&rotation=0&showTitle=false&size=1043897&status=done&style=none&taskId=u70530c01-d7a5-4ca9-875d-3785f59242b&title=&width=1322"/>
</div>
Confirm the presence of ddcs-alipay-sofa-boot-starter in your code pom.xml and add exclusions to eliminate dependencies:

<div style="text-align: center;">
    <img width="600" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/191604/1691735644585-9201c203-b749-46e9-ab96-49ecc8090098.png#clientId=uda997d0f-c9aa-4&from=paste&height=244&id=ub08bbabe&originHeight=488&originWidth=1476&originalType=binary&ratio=2&rotation=0&showTitle=false&size=85290&status=done&style=none&taskId=u7f72a9d1-a1cd-422e-a50a-beafc4a9c4a&title=&width=738"/>
</div>

#### Exclusion Technique 2: Unified Exclusion in pom (More Thorough)

Some dependencies bring in too many indirect dependencies, making manual exclusion difficult. Use wildcard matching to exclude all middleware and base dependencies, e.g., org.apache.commons, org.springframework, etc. This method excludes indirect dependencies as well, making it more efficient compared to using sofa-ark-maven-plugin for exclusions:

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

#### Exclusion Technique 3: Specify Exclusions in sofa-ark-maven-plugin

Use **excludeGroupIds, excludeArtifactIds** to exclude many common dependencies already present in the base:

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
