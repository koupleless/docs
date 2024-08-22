---
title: 4.3.9 Multiple Configurations for Modules
date: 2024-03-01T10:28:32+08:00
weight: 620
---
## Why Use Multiple Configurations
In different scenarios, a module's code may be deployed to different applications but require different configurations.
## How to Use
Step 1: When packaging a module's code for different scenarios, configure different `bizName`, such as `biz1`, `biz2`.
```xml
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
        <!-- Configure different bizName for different scenarios, such as biz1, biz2 -->
        <bizName>biz1</bizName>
        <!-- ... Other properties -->
    </configuration>
</plugin>
```
Step 2: In the `resources` directory of the module, add the following files, where `config` , `biz1` and `biz2` are folders:
- `config/biz1/application.properties`
- `config/biz2/application.properties`
  Step 3: Package two different `ark-biz` files with different `bizName` values (`biz1`, `biz2`):
- `biz1-0.0.1-SNAPSHOT-ark-biz.jar`
- `biz2-0.0.1-SNAPSHOT-ark-biz.jar`
  Step 4: Install the corresponding `ark-biz` module for different scenarios. When the module starts, it will read the configuration files based on the `bizName` value:
- `config/biz1/application.properties`
- `config/biz2/application.properties`
## Principle
When the module starts, it reads the following files as property sources based on the module name and `spring.profiles.active` field:
- `config/${bizName}/application-${profile}.properties`
- `config/${bizName}/application.properties`
  If `spring.profiles.active` is not set, it reads the following file as the property source:
- `config/${bizName}/application.properties`
