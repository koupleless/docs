---
title: 4.2.1 存量 SpringBoot 或 SOFABoot 升级为模块
date: 2024-01-25T10:28:32+08:00
description: 存量 SpringBoot 或 SOFABoot 升级为 Koupleless 模块
weight: 200
---

模块的创建有四种方式，本文介绍第二种方式：
1. [大应用拆出多个模块](/docs/contribution-guidelines/split-module-tool/split-module-tool-intro/)
2. **[存量应用改造成一个模块](/docs/tutorials/module-create/springboot-and-sofaboot/)**
3. [直接脚手架创建模块](/docs/tutorials/module-create/init-by-archetype/)
4. [普通代码片段改造成一个模块](/docs/tutorials/module-create/main-biz/)

本文介绍存量 SpringBoot 或 SOFABoot 如何低成本升级为模块的操作和验证步骤，仅需加一个 ark 打包插件 + 配置模块瘦身 即可实现普通应用一键升级为模块应用，并且能做到同一套代码分支，既能像原来 SpringBoot 一样独立启动，也能作为模块与其它应用合并部署在一起启动。

## 前提条件

1. SpringBoot 版本 >= 2.1.9.RELEASE（针对 SpringBoot 用户）
2. SOFABoot >= 3.9.0 或 SOFABoot >= 4.0.0（针对 SOFABoot 用户）

## 自动化改造工具

除了手动步骤，我们还提供了自动化工具 arkctl 来快速将存量应用改造成模块。以下是使用 arkctl 进行自动改造的详细说明。

### 1. 简介

对于存量应用自动改造成模块的实现方法依赖于arkctl create， 其中arkctl create 是 Koupleless 工具集中的一个命令，用于自动将现有的 SpringBoot 或 SOFABoot 应用转换为 Koupleless 模块。这个命令封装了 koupleless-ext-module-auto-convertor JAR 文件的功能，提供了更便捷的命令行界面。

### 2. 功能特点

- 自动修改 POM 文件，添加必要的依赖和插件
- 自动更新 application.properties 文件
- 自动创建 bootstrap.properties 文件（如果需要）
- 自动处理模块瘦身配置

### 3. 使用前提

- 已安装 arkctl 工具
- Java 8 或更高版本

### 4. 使用步骤

#### 4.1 运行命令
首先go build编译项目 
这一步会生成 `arkctl.exe`（Windows）或 `arkctl`（Linux/Mac）可执行文件。

在命令行中执行以下命令：

```
./arkctl create -p <项目路径> -a <应用名称>
```

参数说明：
- -p 或 --projectPath: 待改造项目的根目录路径（必填）
- -a 或 --applicationName: 应用名称（必填）

示例（Windows）：
```
./arkctl create -p "/path/to/your/project" -a "myapp"
```
Linux/Mac：
```
./arkctl create -p "/path/to/project" -a "myapp"
```

#### 4.2 确认改造结果

命令执行完成后，检查项目中的以下变更：

1. POM 文件：查看是否已添加必要的依赖和插件
2. application.properties：确认是否已更新应用名称
3. bootstrap.properties：如果创建了此文件，检查其内容是否正确
4. 模块瘦身配置：查看是否已添加相关配置

#### 4.3 手动调整（如需）

虽然 arkctl create 命令会自动处理大部分改造工作，但可能仍需要进行一些手动调整。请仔细检查改造后的项目，确保所有配置都符合您的需求。

### 5. 工作原理

#### arkctl create 命令的工作流程如下：

1. 接收用户输入的项目路径和应用名称
2. 将嵌入的 JAR 文件解压到临时目录
3. 使用 Java 执行该 JAR 文件，传入项目路径和应用名称作为参数
4. 捕获并显示 JAR 文件的输出信息
5. 完成后清理临时文件
#### JAR包（koupleless-ext-module-auto-convertor）内部的工作流程：
1. 接收并验证输入的项目路径和应用名称
2. 分析项目结构，确定项目类型（SpringBoot 或 SOFABoot）
3. 修改 POM 文件：
   - 添加 SOFAArk 相关依赖
   - 配置 SOFAArk 打包插件
   - 添加 Koupleless 运行时依赖
4. 更新 application.properties 文件：
   - 设置应用名称
   - 添加必要的 Koupleless 配置项
5. 创建 bootstrap.properties 文件（如果需要）：
   - 添加模块瘦身所需的配置
6. 处理模块瘦身配置：
   - 分析项目依赖
   - 在 POM 文件中添加适当的排除配置


### 6. 注意事项

- 在使用 arkctl create 命令之前，请确保已备份您的项目。
- 某些特殊项目可能需要额外的手动配置，请根据实际情况进行调整。
- 如果项目使用了特定的框架或库，可能需要额外的适配工作。

## 手动接入步骤

如果您选择手动进行改造，或需要对自动改造结果进行微调，请参考以下步骤：

### 步骤 1：修改 application.properties

```properties
# 需要定义应用名
spring.application.name = ${替换为实际模块应用名}
```

### 步骤 2：添加模块需要的依赖和打包插件

**特别注意**： sofa ark 插件定义顺序必须在 springboot 打包插件前;

```xml
<properties>
    <sofa.ark.version>2.2.14</sofa.ark.version>
    <!-- 不同jdk版本，使用不同koupleless版本，参考：https://koupleless.io/docs/tutorials/module-development/runtime-compatibility-list/#%E6%A1%86%E6%9E%B6%E8%87%AA%E8%BA%AB%E5%90%84%E7%89%88%E6%9C%AC%E5%85%BC%E5%AE%B9%E6%80%A7%E5%85%B3%E7%B3%BB -->
    <koupleless.runtime.version>1.2.3</koupleless.runtime.version>
</properties>
<!-- 模块需要引入的依赖，主要用户跨模块间通信 --> 
<dependencies>
    <dependency>
        <groupId>com.alipay.sofa.koupleless</groupId>
        <artifactId>koupleless-app-starter</artifactId>
        <version>${koupleless.runtime.version}</version>
        <scope>provided</scope>
    </dependency>
</dependencies>

<plugins>
    <!--这里添加ark 打包插件-->
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
            <bizName>${替换为模块名}</bizName>
            <webContextPath>${模块自定义的 web context path}</webContextPath>
            <declaredMode>true</declaredMode>
        </configuration>
    </plugin>
    <!--  构建出普通 SpringBoot fatjar，支持独立部署时使用，如果不需要可以删除  -->
    <plugin>
        <!--原来 spring-boot 打包插件 -->
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
    </plugin>
</plugins>
```

### 步骤 3：自动化瘦身模块

您可以使用 ark 打包插件的[自动化瘦身能力](/docs/tutorials/module-development/module-slimming.md)，自动瘦身模块里的 maven 依赖。这一步是必选的，否则构建出的模块 jar 包会非常大，而且启动会报错。
_扩展阅读_：如果模块不做依赖瘦身[独立引入 SpringBoot 框架会怎样？](/docs/faq/import-full-springboot-in-module)

### 步骤 4：构建成模块 jar 包

执行 `mvn clean package -DskipTest`, 可以在 target 目录下找到打包生成的 ark biz jar 包，也可以在 target/boot 目录下找到打包生成的普通的 springboot jar 包。

**小贴士**：[模块中支持的完整中间件清单](/docs/tutorials/module-development/runtime-compatibility-list/)。

## 实验：验证模块既能独立启动，也能被合并部署

增加模块打包插件（sofa-ark-maven-plugin）进行打包后，只会新增 ark-biz.jar 构建产物，与原生 spring-boot-maven-plugin 打包的可执行Jar 互相不冲突、不影响。
当服务器部署时，期望独立启动，就使用原生 spring-boot-maven-plugin 构建出的可执行 Jar 作为构建产物；期望作为 ark 模块部署到基座中时，就使用 sofa-ark-maven-plugin 构建出的 xxx-ark-biz.jar 作为构建产物

### 验证能合并部署到基座上

1. 启动上一步（验证能独立启动步骤）的基座
2. 发起模块部署

```shell
curl --location --request POST 'localhost:1238/installBiz' \
--header 'Content-Type: application/json' \
--data '{
    "bizName": "${模块名}",
    "bizVersion": "${模块版本}",
    "bizUrl": "file:///path/to/ark/biz/jar/target/xx-xxxx-ark-biz.jar"
}'
```

返回如下信息表示模块安装成功<br />

<div style="text-align: center;">
    <img align="center" width="900px" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695021262517-34e6728e-b39e-4996-855b-d866e839fd0a.png#clientId=ueb52f3f0-186e-4&from=paste&height=226&id=u8ab265a1&originHeight=452&originWidth=1818&originalType=binary&ratio=2&rotation=0&showTitle=false&size=60390&status=done&style=none&taskId=uf3b43b8e-80dd-43db-b486-3ca38663e5e&title=&width=909" />
</div>

3. 查看当前模块信息，除了基座 base 以外，还存在一个模块 dynamic-provider

<div style="text-align: center;">
    <img align="center" width="600px" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695021372335-9fbce7ae-ab41-44e8-ab51-6a771bddfef3.png#clientId=ueb52f3f0-186e-4&from=paste&height=367&id=u301dd5fb&originHeight=734&originWidth=1186&originalType=binary&ratio=2&rotation=0&showTitle=false&size=97949&status=done&style=none&taskId=u8570e201-b10d-460a-946a-d9c94529834&title=&width=593" />
</div>

4. 卸载模块

```json
curl --location --request POST 'localhost:1238/uninstallBiz' \
--header 'Content-Type: application/json' \
--data '{
    "bizName": "dynamic-provider",
    "bizVersion": "0.0.1-SNAPSHOT"
}'
```

返回如下，表示卸载成功

```json
{
    "code": "SUCCESS",
    "data": {
        "code": "SUCCESS",
        "message": "Uninstall biz: dynamic-provider:0.0.1-SNAPSHOT success."
    }
}
```

### 验证能独立启动

普通应用改造成模块之后，还是可以独立启动，可以验证一些基本的启动逻辑，只需要在启动配置里勾选自动添加 `provided`scope 到 classPath 即可，后启动方式与普通应用方式一致。通过自动瘦身改造的模块，也可以在 `target/boot` 目录下直接通过 springboot jar 包启动，[点击此处](https://github.com/koupleless/samples/tree/main/springboot-samples/slimming)查看详情。<br />

<div style="text-align: center;">
    <img align="center" width="600px" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695032642009-a5248a99-d91b-4420-b830-600b35eaa402.png#clientId=u4eb3445f-d3dc-4&from=paste&height=606&id=ued085b28&originHeight=1212&originWidth=1676&originalType=binary&ratio=2&rotation=0&showTitle=false&size=169283&status=done&style=none&taskId=u78d21e68-c71c-42d1-ac4c-8b41381bfa4&title=&width=838" />
</div>
