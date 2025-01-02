---
title: 6.5.3.7 模块使用宝蓝德 web 服务器
date: 2024-01-25T10:28:32+08:00
weight: 7
draft: false
---

# koupleless-adapter-bes
koupleless-adapter-bes 是为了适配宝蓝德（BES)容器，以支持基座模块复用相同的端口。仓库地址为 [koupleless-adapter-bes](https://github.com/koupleless/adapter/tree/main/koupleless-adapter-web-bes)（感谢社区同学[陈坚](https://github.com/chenjian6824)贡献）。

项目目前仅在BES 9.5.5.004 版本中验证过，其他版本需要自行验证，必要的话需要根据相同的思路进行调整。

如果多个BIZ模块不需要使用同一端口来发布服务,只需要关注下文安装依赖章节提到的注意事项即可，不需要引入本项目相关的依赖。

## 快速开始

### 0. 前置条件
#### jdk8

koupleless >= 1.3.1
sofa-ark >= 2.2.14

#### jdk17

koupleless >= 2.1.6
sofa-ark >= 3.1.7

如果不满足改条件，需要按照该文档的老版本进行操作，可通过 github 文档源码查看该文档的老版本。

### 1. 安装依赖

首先需要确保已经在maven仓库中导入了BES相关的依赖，参考导入脚本如下：
```shell
mvn install:install-file -Dfile=D:/software/xc/BES-EMBED/bes-lite-spring-boot-starter-9.5.5.004.jar -DgroupId=com.bes.besstarter -DartifactId=bes-lite-spring-boot-starter -Dversion=9.5.5.004 -Dpackaging=jar

mvn install:install-file -Dfile=D:/software/xc/BES-EMBED/bes-gmssl-9.5.5.004.jar -DgroupId=com.bes.besstarter -DartifactId=bes-gmssl -Dversion=9.5.5.004 -Dpackaging=jar

mvn install:install-file -Dfile=D:/software/xc/BES-EMBED/bes-jdbcra-9.5.5.004.jar -DgroupId=com.bes.besstarter -DartifactId=bes-jdbcra -Dversion=9.5.5.004 -Dpackaging=jar

mvn install:install-file -Dfile=D:/software/xc/BES-EMBED/bes-websocket-9.5.5.004.jar -DgroupId=com.bes.besstarter -DartifactId=bes-websocket -Dversion=9.5.5.004 -Dpackaging=jar
```

### 2. 编译安装本项目插件

进入本项目的 bes9-web-adapter 目录执行 `mvn install` 命令即可。
项目将会安装 bes-web-ark-plugin 和 bes-sofa-ark-springboot-starter 两个模块。

### 3. 使用本项目组件
首先需要根据koupleless的文档，[将项目升级为Koupleless基座](https://koupleless.io/docs/tutorials/base-create/springboot-and-sofaboot/)

然后将依赖中提到的
```xml
<dependency>
    <groupId>com.alipay.sofa</groupId>
    <artifactId>web-ark-plugin</artifactId>
    <version>${sofa.ark.version}</version>
</dependency>
```
替换为本项目的坐标
```xml
<dependency>
    <groupId>com.alipay.sofa</groupId>
    <artifactId>bes-web-ark-plugin</artifactId>
    <version>${sofa.ark.version}</version>
</dependency>
<dependency>
   <groupId>com.alipay.sofa</groupId>
   <artifactId>bes-sofa-ark-springboot-starter</artifactId>
   <version>${sofa.ark.version}</version>
</dependency>
```

引入BES相关依赖（同时需要exclude tomcat的依赖）。参考依赖如下：
```xml
       <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-starter-tomcat</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

        <dependency>
            <groupId>com.bes.besstarter</groupId>
            <artifactId>sofa-ark-bes-lite-spring-boot-starter</artifactId>
            <version>9.5.5.004</version>
        </dependency>

        <dependency>
            <groupId>com.bes.besstarter</groupId>
            <artifactId>bes-gmssl</artifactId>
            <version>9.5.5.004</version>
        </dependency>

        <dependency>
            <groupId>com.bes.besstarter</groupId>
            <artifactId>bes-jdbcra</artifactId>
            <version>9.5.5.004</version>
        </dependency>

        <dependency>
            <groupId>com.bes.besstarter</groupId>
            <artifactId>bes-websocket</artifactId>
            <version>9.5.5.004</version>
        </dependency>
```

### 4. 基座中增加宝蓝德特殊配置
为什么需要这个配置， 是因为 koupleless其中 SOFAArk组件对于依赖包的识别机制与BES的包结构冲突，[参考这里](https://github.com/sofastack/sofa-ark/pull/997)

需要在模块根目录 ark 配置文件中（`conf/ark/bootstrap.properties` 或 `conf/ark/bootstrap.yml`）增加白名单

```properties
declared.libraries.whitelist=com.bes.besstarter:bes-sofa-ark-springboot-starter
```

### 5. 完成
完成上述步骤后，即可在 Koupleless 基座和模块中使用 BES 启动项目。
