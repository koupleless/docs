---
title: 4.3.9 模块多配置
date: 2024-03-01T10:28:32+08:00
weight: 620
---

## 为什么要多配置
在不同场合下，一份模块代码会部署到不同的应用中，但需要使用不同的配置。

## 怎么使用

步骤一：在不同场合下，给一份模块代码打包时，配置不同的 bizName，如：biz1, biz2

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
        <!-- 不同场合配置不同的bizName，如：biz1, biz2 -->
        <bizName>biz1</bizName>
        <!-- ... 其它属性 -->
    </configuration>
</plugin>
```

步骤二：在模块的 resources 目录下，新增文件。其中 config, biz1 和 biz2 为文件夹：

- config/biz1/application.properties

- config/biz2/application.properties

步骤三：用不同的 bizName（biz1,biz2），打包出两个不同的 ark-biz 文件：

- biz1-0.0.1-SNAPSHOT-ark-biz.jar

- biz2-0.0.1-SNAPSHOT-ark-biz.jar

步骤四：在不同场合下，安装不同的 ark-biz 模块。模块启动时，将根据不同的 bizName 读取不同的配置文件：
- config/biz1/application.properties

- config/biz2/application.properties

## 原理

模块启动时，根据模块名称与 spring.profiles.active 字段，读取以下文件为属性源：

- config/${bizName}/application-${profile}.properties
- config/${bizName}/application.properties

如果未设置 spring.profiles.active，则读取以下文件为属性源：

- config/${bizName}/application.properties

