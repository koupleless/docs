---
title: 4.3.11 Static Merge Deployment
date: 2024-01-25T10:28:32+08:00
description: Static Merge Deployment of Koupleless Module
weight: 700
---

## Introduction
SOFAArk provides the capability of static merge deployment, where the **Base package (foundation application)** can start already constructed **Biz package (module application)** during startup. The default way of obtaining the module is through local directory, local file URL, and remote URL. 

In addition, SOFAArk also provides an extension interface for static merge deployment, where developers can customize the way of obtaining the **Biz package (module application)**.

## Usage
### Step 1: Package Module Application into Ark Biz
If developers wish for their application's Ark Biz package to be used as a Jar package dependency by other applications, running on the same SOFAArk container, they need to package and publish the Ark Biz package. For details, see [Ark Biz Introduction](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-biz/). The Ark Biz package is generated using the Maven plugin sofa-ark-maven-plugin.

```xml
<build>
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
            <!-- Default is 100, larger values indicate later installation, with Koupleless runtime version greater than or equal to 1.2.2 -->
            <priority>200</priority>
        </configuration>
    </plugin>
</build>
```

### Step 2: Base Fetching Ark Biz for Merge Deployment
Requirements:
- JDK8
    - sofa.ark.version >= 2.2.12
    - koupleless.runtime.version >= 1.2.3
- JDK17/JDK21
    - sofa.ark.version >= 3.1.5
    - koupleless.runtime.version >= 2.1.4

#### Method 1: Using Official Default Retrieval Method, Supporting Local Directory, Local File URL, Remote URL
##### 1. Base Configuration of Local Directory, Local File URL, Remote URL
Developers need to specify the Ark Biz package that needs to be merged and deployed in the base's ark configuration file (`conf/ark/ark.properties` or `conf/ark/ark.yml`), supporting:
- Local directory
- Local file URL (windows system as `file:\\`, linux system as `file://`)
- Remote URL (supporting `http://`,`https://`)
  In `integrateBizURLs` field for local file URL and remote URL, and `integrateLocalDirs` field for local directory.
  The configuration is as follows:

```properties
integrateBizURLs=file://${xxx}/koupleless_samples/springboot-samples/service/biz1/biz1-bootstrap/target/biz1-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar,\
  file://${xxx}/koupleless_samples/springboot-samples/service/biz2/biz2-bootstrap/target/biz2-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar,\
  https://oss.xxxxx/biz2-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar
integrateLocalDirs=/home/${xxx}/sofa-ark/biz,\
  /home/${xxx}/sofa-ark/biz2
```

or

```yaml
integrateBizURLs:
  - file://${xxx}/springboot-samples/service/biz2/biz2-bootstrap/target/biz2-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar
  - file://${xxx}/koupleless_samples/springboot-samples/service/biz2/biz2-bootstrap/target/biz2-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar
integrateLocalDirs:
  - /home/${xxx}/sofa-ark/biz
  - /home/${xxx}/sofa-ark/biz2
```

##### 2. Base Configuration of Packaged Plugin Target integrate-biz
Add the <goal>integrate-biz</goal> to koupleless-base-build-plugin in the base's bootstrap pom, as shown below:

```xml
<plugin>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-base-build-plugin</artifactId>
    <version>${koupleless.runtime.version}</version>
    <executions>
        <execution>
            <goals>
                <goal>add-patch</goal>
                <!-- Used for static merge deployment -->
                <goal>integrate-biz</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

After the build, if the packaged jar file is manually unpacked, the specified module ark-biz package can be seen in classPath/SOFA-ARK/biz.

#### Method 2: Using Custom Retrieval Method
##### 1. Ark Extension Mechanism Principle
Refer to [Ark Extension Mechanism Introduction](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-extension/)

##### 2. Implement AddBizToStaticDeployHook Interface
In the base/third-party package, implement the AddBizToStaticDeployHook interface, using AddBizInResourcesHook as an example, as shown below:

```java
@Extension("add-biz-in-resources-to-deploy")
public class AddBizInResourcesHook implements AddBizToStaticDeployHook {
    @Override
    public List<BizArchive> getStaticBizToAdd() throws Exception {
        List<BizArchive> archives = new ArrayList<>();
        // ...
        archives.addAll(getBizArchiveFromResources());
        return archives;
    }
    protected List<BizArchive> getBizArchiveFromResources() throws Exception {
        // ... Read Ark Biz package in resources
        return archives;
    }
}
```

##### 3. Configure SPI
Add the /META-INF/services/sofa-ark/ directory in the resources directory, then add a file named com.alipay.sofa.ark.spi.service.biz.AddBizToStaticDeployHook in /META-INF/services/sofa-ark/ directory, where the file contains the fully qualified name of the hook class:

```text
com.alipay.sofa.ark.support.common.AddBizInResourcesHook
```

Rebuild the base.

### Step 3: Start the Base
Add the JVM parameter configuration: `-Dsofa.ark.embed.static.biz.enable=true`