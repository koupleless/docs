---
title: 4.3.2 Module Slimming
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Slimming
weight: 200
---

## Why Slimming?


Using the underlying SOFAArk framework, Koupleless achieves class isolation between modules and between modules and the base. When the module starts, it initializes various objects and **prioritizes using the module's class loader** to load classes, resources, and JAR files from the FatJar build artifact. **Classes that cannot be found will be delegated to the base's class loader** for retrieval.

<div style="text-align: center;">
    <img width="700" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/8276/1678275655551-75bf283f-3817-447a-84b2-7f6f7f773300.jpeg"/>
</div>

Based on this class delegation loading mechanism, the common classes, resources, and JAR files shared by the base and modules **all sink** into the base, allowing the module build artifact to be **very small**, resulting in **very low** memory consumption for the module and **very fast** startup. 

Furthermore, after the module starts, many objects will be created in the Spring context. If module hot-unloading is enabled, complete recycling may not be possible, and excessive installations can cause high overhead in the Old generation and Metaspace, triggering frequent FullGC. Therefore, it is necessary to control the size of individual module packages to be < 5MB. **In this way, the base can hot deploy and hot unload hundreds of times without replacement or restarting.**

The so-called "module slimming" means that the JAR dependencies already present in the base do not participate in the module packaging and construction, thus achieving the two benefits mentioned above:

- Increase the speed of module installation, reduce module package size, reduce startup dependencies, and control module installation time < 30 seconds, or even < 5 seconds.
- In the hot deploy and hot unload scenario, the base can hot deploy and hot unload hundreds of times without replacement or restart.


## Slimming Principles
The principle of building the ark-biz jar package is to place common packages such as frameworks and middleware in the base as much as possible while ensuring the functionality of the module, and reuse the base packages in the module, making the resulting ark-biz jar more lightweight. 

In different scenarios, complex applications can choose different slimming methods.

## Scenarios and Corresponding Slimming Methods

## Scenario 1: The base and the module have close cooperation, such as the middle platform mode/shared library mode

In the case of close cooperation between the base and modules, the modules should perceive some facade classes of the base and the dependency versions currently used by the base during development, and import the required dependencies as needed. During module packaging, only two types of dependencies should be included: dependencies that the base does not have, and dependencies whose versions are inconsistent with those of the base.

Therefore, the base needs to:
1. Unified control over module dependency versions to let module developers know which dependencies the base has during development, to mitigate risks, and allow module developers to import part of the dependencies as needed without specifying versions.

The module needs to:
1. Only include dependencies that are not in the base and dependencies whose versions are inconsistent with those of the base during packaging to reduce the cost of slimming the module

#### Step 1: Packaging "base-dependencies-starter"
**Objective**

This step will produce "base-dependencies-starter" for unified control of module dependency versions.

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
            <!-- Generate the artifactId of the starter (groupId consistent with the base), which needs to be modified here!! -->
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

1. Pack the base-dependencies-starter jar: execute the command in the root directory of the base:

```shell
mvn com.alipay.sofa.koupleless:koupleless-base-build-plugin::packageDependency -f ${Relative path of the base bootstrap pom to the root directory of the base} 
```

The constructed pom will be in the outputs directory and will be automatically installed in the local Maven repository.

**Note**, this step will not upload "base-dependencies-starter" to the maven repository. We welcome further discussion to supplement the solution of "uploading to the maven repository".

#### Step 2: Module modification packaging plugin and parent

**Objective**

1. When developing the module, use the "base-dependencies-starter" from Step 1 as the parent of the module project for unified management of dependency versions;
2. Modify the module packaging plug-in to only include "dependencies not in the base" and "dependencies whose versions are inconsistent with those of the base" when packaging the module, eliminating the need to manually configure "provided" and achieving automatic slimming of the module.

In addition: For some dependencies, even if the module and base use the same dependency version, the dependency needs to be retained when the module is packaged, i.e., the module slimming dependency whitelist needs to be configured. This feature will be launched at the end of July.

**Configure the parent in the module's root directory pom:**

```xml
<parent>
   <groupId>com.alipay</groupId>
   <artifactId>${baseAppName}-dependencies-starter</artifactId>
   <version>0.0.1-SNAPSHOT</version>
</parent>
```

**Configure plugin in the module's packaging pom:**

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
               <!-- Configure the identifier of "base-dependencies-starter", standardized as '${groupId}:${artifactId}':'version' -->
               <baseDependencyParentIdentity>com.alipay:${baseAppName}-dependencies-starter:0.0.1-SNAPSHOT</baseDependencyParentIdentity>
           </configuration>
       </plugin>
   </plugins>
</build>
```

#### Step 3: Configure Module Dependency Whitelist

For some dependencies, even if the module and base use the same version of the dependency, the dependency needs to be retained when the module is packaged. This requires configuring a module slimming dependency whitelist.

Configuration way: Add the dependencies that need to be retained in the module project root directory/conf/ark/bootstrap.properties or module project root directory/conf/ark/bootstrap.yaml. If these files do not exist, you can create the directories and files yourself. The following provides three different levels of configuration, which can be added according to the actual situation.

```properties
# includes config ${groupId}:${artifactId}, split by ','
includes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# includeGroupIds config ${groupId}, split by ','
includeGroupIds=org.springframework
# includeArtifactIds config ${artifactId}, split by ','
includeArtifactIds=sofa-ark-spi
```

```yaml
# includes config ${groupId}:${artifactId}
includes:
  - org.apache.commons:commons-lang3
  - commons-beanutils:commons-beanutils
# includeGroupIds config ${groupId}
includeGroupIds:
  - org.springframework
# includeArtifactIds config ${artifactId}
includeArtifactIds:
  - sofa-ark-spi
```

#### Step 4: Package Building

### Scenario 2: The base and the module have loose cooperation, such as resource saving in multi-application merge deployment

In the case of loose cooperation between the base and the module, the module should not perceive the dependency versions currently used by the base during development, so the module needs to focus more on the low-cost access to module slimming. Dependencies that need to be excluded from module packaging can be configured.

### Method 1: SOFAArk Configuration File Combining
#### Step 1
SOFAArk Module Slimming reads configuration from two places:
- "Module Project Root Directory/conf/ark/bootstrap.properties", such as: my-module/conf/ark/bootstrap.properties
- "Module Project Root Directory/conf/ark/bootstrap.yml", such as: my-module/conf/ark/bootstrap.yml
#### Configuration
##### bootstrap.properties (recommended)

Configure the common package of frameworks and middleware that need to be sunk to the base in "Module Project Root Directory/conf/ark/bootstrap.properties" in the following format, such as:

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
