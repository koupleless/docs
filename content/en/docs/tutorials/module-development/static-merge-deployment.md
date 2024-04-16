---
title: Static Merge Deployment
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Static Merge Deployment
weight: 700
---

## Introduction

SOFAArk provides the capability of static merge deployment. During development, applications can be built into **Biz packages (module applications)** by other applications and loaded by the final **Base package (base applications)**.
Users can place Biz packages uniformly in a directory and then inform the base to scan this directory through startup parameters, thus completing static merge deployment (details described below). In this way, developers do not need to consider dependency conflicts between applications. Communication between Biz packages is achieved through @SofaService and @SofaReference to publish/reference JVM services (_SOFABoot, SpringBoot still under construction_).


## Step 1: Package the Module Application into an Ark Biz

If developers want their Ark Biz package to be directly dependent on other applications and run on the same SOFAArk container, they need to package and publish the Ark Biz package, 
detailed in [Ark Biz Introduction](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-biz/). The Ark Biz package is built using the Maven plugin sofa-ark-maven-plugin.

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

## Step 2: Move the Jar Files to the Specified Directory

Move the required biz jars to the specified directory, such as: /home/sofa-ark/biz/

```shell
mv /path/to/your/biz/jar /home/sofa-ark/biz/
```

## Step 3: Start the Base and Specify the Biz Directory through -D Parameter

```shell
java -jar -Dcom.alipay.sofa.ark.static.biz.dir=/home/sofa-ark/biz/ sofa-ark-base.jar
```

## Step 4: Verify the Startup of Ark Biz (Module)

After the base starts successfully, you can interact with the SOFAArk client interface via telnet:

```shell
telnet localhost 1234
```

Then execute the following command to view the module list:

```shell
biz -a
```

At this point, you should be able to see the Master Biz (base) and all statically merged deployed Ark Biz (modules).<br/>
The above operations can be experienced through the [SOFAArk Static Merge Deployment Sample](https://github.com/koupleless/samples/blob/master/springboot-samples/web/tomcat/README.md#%E5%AE%9E%E9%AA%8C%E5%86%85%E5%AE%B9(%E9%9D%99%E6%80%81%E5%90%88%E5%B9%B6%E9%83%A8%E7%BD%B2))

<br/>
<br/>
