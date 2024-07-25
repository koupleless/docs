---
title: Static Merged Deployment
date: 2024-01-25T10:28:32+08:00
description: Koupleless module static merged deployment
weight: 700
---

## Introduction

SOFAArk provides the capability of static merged deployment. The **Base package (base application)** can start the already built **Biz package (module application)** when it starts, supporting local directories, local file URLs, remote URLs, and custom acquisition methods.

## Usage
### Step 1: Package the Module Application into Ark Biz

If developers want their Ark Biz package of their applications to be directly used as a Jar package dependency by other applications and run on the same SOFAArk container, then they need to package and publish the Ark Biz package, see [Ark Biz Introduction](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-biz/) for details. The Ark Biz package is packaged using the Maven plugin sofa-ark-maven-plugin.

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
            <!--                Default 100, the larger the value, the later the installation, koupleless runtime version is greater than or equal to 1.2.2             -->
            <priority>200</priority>
        </configuration>
    </plugin>
</build>
```

### Step 2: Configure the Base to Deploy Merged Ark Biz (Local directory, local file URL, remote URL)

Developers need to specify the Ark Biz package that needs to be merged and deployed in the base's ark configuration file (`conf/ark/ark.properties` or `conf/ark/ark.yml`), supporting:

- Local directories
- Local file URLs (windows 'file:\\', linux 'file://')
- Remote URLs (supports 'http://','https://')

The local file URLs and remote URLs are configured in the `integrateBizURLs` field, and the local directories are configured in the `integrateLocalDirs` field.

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

### Step 3: Configure the Base to Package Plugin Target integrate-biz and Upgrade SOFAArk Version

Requirement:
- koupleless.runtime.version >= 1.2.3

Add the <goal>integrate-biz</goal> to the koupleless-base-build-plugin in the pom of the base bootstrap, as follows:

```xml
<plugin>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-base-build-plugin</artifactId>
    <version>${koupleless.runtime.version}</version>
    <executions>
        <execution>
            <goals>
                <goal>add-patch</goal>
<!--                Used for static merged deployment-->
                <goal>integrate-biz</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

After the package is executed, if the packaged jar file is unpacked, you can see the specified module ark-biz package in classPath/SOFA-ARK/biz.

### Step 4: Start the Base

Add the JVM parameter and configure:  `-Dsofa.ark.embed.static.biz.in.resource.enable=true`

### Specify Local Directory Mode (Not Recommended)

Users can place the Biz packages in a unified directory and then inform the base to scan this directory through startup parameters to complete the static merged deployment (see details below). In this way, developers do not need to consider dependency conflicts between them, and interactions between Biz use @SofaService and @SofaReference to publish/reference JVM services (_SOFABoot, SpringBoot is still under construction_).

### Step 1: Package the Module Application into Ark Biz

If developers want their Ark Biz package of their applications to be directly used as a Jar package dependency by other applications and run on the same SOFAArk container, then they need to package and publish the Ark Biz package, see [Ark Biz Introduction](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-biz/) for details. The Ark Biz package is packaged using the Maven plugin sofa-ark-maven-plugin.

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
    </plugin>
</build>
```

### Step 2: Move the above jar files to the specified directory.

Move the required deployment biz jars to the specified directory, e.g.: /home/sofa-ark/biz/

```shell
mv /path/to/your/biz/jar /home/sofa-ark/biz/
```

### Step 3: Start the Base and Specify the biz Directory through -D
```shell
java -jar -Dcom.alipay.sofa.ark.static.biz.dir=/home/sofa-ark/biz/ sofa-ark-base.jar
```

### Step 4: Verify the Ark Biz (Module) Startup
After the base starts successfully, you can start the SOFAArk client interaction interface through telnet:

```shell
telnet localhost 1234
```

Then execute the following command to view the module list:

```shell
biz -a
```

At this point, you should see the Master Biz (Base) and all statically merged and deployed Ark Biz (Modules).<br/>

The above operations can be experienced through [SOFAArk Static Merged Deployment Example](https://github.com/koupleless/samples/blob/master/springboot-samples/web/tomcat/README.md#%E5%AE%9E%E9%AA%8C%E5%86%85%E5%AE%B9(%E9%9D%99%E6%80%81%E5%90%88%E5%B9%B6%E9%83%A8%E7%BD%B2))<br/>

<br/>
<br/>
