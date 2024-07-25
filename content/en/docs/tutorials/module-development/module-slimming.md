---
title: Module Slimming
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Slimming
weight: 200
---

## Why Slimming?
In order to make the module installation faster and reduce memory consumption:

- Speed up the module installation, reduce the size of the module package, reduce startup dependencies, and control the module installation time to less than 30 seconds, or even less than 5 seconds.
- After the module is started, many objects will be created in the Spring context. If module hot unloading is enabled, it may not be completely recycled. Too many installations will result in large overhead in the Old area and Metaspace area, triggering frequent FullGC. Therefore, the package size of a single module should be controlled to be less than 5MB. **This way, you can hot deploy and unload the module hundreds of times without replacing or restarting the pedestal.**

## Basic Principles of Slimming
Koupleless relies on the underlying SOFAArk framework to achieve mutual isolation between modules, between modules and the pedestal, and the following two core logics are very important for coding and need to be deeply understood:

1. The pedestal has an independent class loader and Spring context, and the module also has **independent class loader** and **Spring context**, and the Spring contexts are **isolated from each other**.
2. When a module starts, it will initialize various objects, and will **use the module's class loader first** to load the classes, resources, and JAR files in the built artifact FatJar. If the class is not found, it will delegate to the pedestal's class loader to search.

```html
<div style="text-align: center;">
    <img width="700" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/8276/1678275655551-75bf283f-3817-447a-84b2-7f6f7f773300.jpeg"/>
</div>
```

Based on this delegation-based loading mechanism, the classes, resources, and JAR files shared by the base and module **sink** into the base, which can make the module's built artifact **very small**. More importantly, it can also allow modules to largely reuse the base's existing resources such as classes, beans, services, IO connection pools, and thread pools during runtime, making the module consume very little memory and start up very quickly. <br /> The so-called slimming of the module is to exclude the Jar dependencies already in the base from participating in the module packaging.

## Slimming Principles
The principle of building the ark-biz jar package is to place common packages such as frameworks and middleware in the base as much as possible while ensuring the functionality of the module, and reuse the base packages in the module, making the resulting ark-biz jar more lightweight. 

In different scenarios, complex applications can choose different slimming methods.

## Scenarios and Corresponding Slimming Methods

## Scenario 1: The pedestal and the module have close cooperation, such as the middle platform mode/shared library mode

In the case of close cooperation between the pedestal and modules, the modules should perceive some facade classes of the pedestal and the dependency versions currently used by the pedestal during development, and import the required dependencies as needed. During module packaging, only two types of dependencies should be included: dependencies that the pedestal does not have, and dependencies whose versions are inconsistent with those of the pedestal.

Therefore, the pedestal needs to:
1. Unified control over module dependency versions to let module developers know which dependencies the pedestal has during development, to mitigate risks, and allow module developers to import part of the dependencies as needed without specifying versions.

The module needs to:
1. Only include dependencies that are not in the pedestal and dependencies whose versions are inconsistent with those of the pedestal during packaging to reduce the cost of slimming the module

#### Step 1: Packaging "pedestal-dependencies-starter"
**Objective**

This step will produce "pedestal dependency-starter" for unified control of module dependency versions.

**Pom configuration for base bootstrap:**

Note: The dependencyArtifactId in the following configuration needs to be modified, generally to ${baseAppName}-dependencies-starter

```xml
<build>
<plugins>
    <plugin>
        <groupId>com.alipay.sofa.koupleless</groupId>
        <artifactId>koupleless-base-build-plugin</artifactId>
        <version>1.2.4-SNAPSHOT</version>
        <configuration>
            <!-- Generate the artifactId of the starter (groupId consistent with the pedestal), which needs to be modified here!! -->
            <dependencyArtifactId>${baseAppName}-dependencies-starter</dependencyArtifactId>
            <!-- Generate the version number of the jar -->
            <dependencyVersion>0.0.1-SNAPSHOT</dependencyVersion>
            <!-- For debugging, change to true to see the intermediate products of the packaging -->
            <cleanAfterPackageDependencies>false</cleanAfterPackageDependencies>
        </configuration>
    </plugin>
  </plugins>
</build>
```

**Local test**

1. Pack the pedestal dependency-starter jar: execute the command in the root directory of the pedestal:

```shell
mvn com.alipay.sofa.koupleless:koupleless-base-build-plugin::packageDependency -f ${Relative path of the pedestal bootstrap pom to the root directory of the pedestal} 
```

The constructed pom will be in the outputs directory and will be automatically installed in the local Maven repository.

#### Step 2: Module modification packaging plug-in and parent

**Objective**

1. When developing the module, use the "pedestal-dependencies-starter" from Step 1 as the parent of the module project for unified management of dependency versions;
2. Modify the module packaging plug-in to only include "dependencies not in the pedestal" and "dependencies whose versions are inconsistent with those of the pedestal" when packaging the module, eliminating the need to manually configure "provided" and achieving automatic slimming of the module.

In addition: For some dependencies, even if the module and pedestal use the same dependency version, the dependency needs to be retained when the module is packaged, i.e., the module slimming dependency whitelist needs to be configured. This feature will be launched at the end of July.

**Configure the parent in the module's root directory pom:**

```xml
<parent>
   <groupId>com.alipay</groupId>
   <artifactId>${baseAppName}-dependencies-starter</artifactId>
   <version>0.0.1-SNAPSHOT</version>
</parent>
```

**Configure plug-in in the module's packaging pom:**

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
               <!-- Configure the identifier of "pedestal-dependencies-starter", standardized as '${groupId}:${artifactId}':'version' -->
               <baseDependencyParentIdentity>com.alipay:${baseAppName}-dependencies-starter:0.0.1-SNAPSHOT</baseDependencyParentIdentity>
           </configuration>
       </plugin>
   </plugins>
</build>
```

#### Step 3

Simply build the module ark-biz jar package, and you will see a significant difference in the size of the slimmed ark-biz jar package.

### Scenario 2: The pedestal and the module have loose cooperation, such as resource saving in multi-application merge deployment

In the case of loose cooperation between the pedestal and the module, the module should not perceive the dependency versions currently used by the pedestal during development, so the module needs to focus more on the low-cost access to module slimming. Dependencies that need to be excluded from module packaging can be configured.

### Method 1: SOFAArk Configuration File Combining
#### Step 1
SOFAArk Module Slimming reads configuration from two places:
- "Module Project Root Directory/conf/ark/bootstrap.properties", such as: my-module/conf/ark/bootstrap.properties
- "Module Project Root Directory/conf/ark/bootstrap.yml", such as: my-module/conf/ark/bootstrap.yml
#### Configuration
##### bootstrap.properties (recommended)

Configure the common package of frameworks and middleware that need to be sunk to the pedestal in "Module Project Root Directory/conf/ark/bootstrap.properties" in the following format, such as:

```properties
# excludes config ${groupId}:{artifactId}:{version}, split by ','
excludes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# excludeGroupIds config ${groupId}, split by ','
excludeGroupIds=org.springframework
# excludeArtifactIds config ${artifactId}, split by ','
excludeArtifactIds=sofa-ark-spi
```

##### bootstrap.yml (recommended)

Configure the common package of frameworks and middleware that need to be sunk to the base in "Module Project Root Directory/conf/ark/bootstrap.yml" in the following format, such as:

```yaml
# excludes config ${groupId}:{artifactId}:{version}, split by '-'
# excludeGroupIds config ${groupId}, split by '-'
# excludeArtifactIds config ${artifactId}, split by '-'
excludes:
  - org.apache.commons:commons-lang3
  - commons-beanutils:commons-beanutils
excludeGroupIds:
  - org.springframework
excludeArtifactIds:
  - sofa-ark-spi
```

#### Step 2
Upgrade the module packaging plug-in `sofa-ark-maven-plugin` version >= 2.2.12

```xml
    <!-- Plugin 1: Packaging plug-in for sofa-ark biz to package as ark biz jar -->
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
            <webContextPath>biz1</webContextPath>
            <declaredMode>true</declaredMode>
        </configuration>
    </plugin>
```

#### Step 3

Simply build the module ark-biz jar package, and you will see a significant difference in the size of the slimmed ark-biz jar package.

You can [click here](https://github.com/koupleless/samples/tree/master/springboot-samples/slimming) to view the complete example project for module slimming.