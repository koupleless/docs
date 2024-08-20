---
title: 6.5.3.8 模块使用东方通 web 服务器
date: 2024-01-25T10:28:32+08:00
weight: 8
draft: false
---

# koupleless-adapter-tongweb
koupleless-adapter-tongweb 是为了适配东方通（TongWEB)容器，仓库地址为：[koupleless-adapter-tongweb](https://github.com/chenjian6824/koupleless-adapter-tongweb)（感谢社区同学陈坚贡献）。

项目目前仅在tongweb-embed-7.0.E.6_P7 版本中验证过，其他版本需要自行验证，必要的话需要根据相同的思路进行调整。

如果多个BIZ模块不需要使用同一端口来发布服务,只需要关注下文安装依赖章节提到的注意事项即可，不需要引入本项目相关的依赖。

## 快速开始
### 1. 安装依赖
首先需要确保已经在maven仓库中导入了TongWEB相关的依赖。
(这里有个关键点，由于koupleless 2.2.9项目对于依赖包的识别机制与TongWEB的包结构冲突，需要将TongWEB的依赖包加上sofa-ark-的前缀,具体的识别机制可参考koupleless的com.alipay.sofa.ark.container.model.BizModel类)

参考导入脚本如下：
```shell
mv XXX/tongweb-spring-boot-starter-7.0.E.6_P7.jar XXX/sofa-ark-tongweb-spring-boot-starter-7.0.E.6_P7.jar
mv XXX/tongweb-tongweb-embed-core-7.0.E.6_P7.jar XXX/sofa-ark-tongweb-embed-core-7.0.E.6_P7.jar
mv XXX/tongweb-lic-sdk-4.5.0.0.jar XXX/sofa-ark-tongweb-lic-sdk-4.5.0.0.jar
mvn install:install-file -DgroupId=com.tongweb.springboot -DartifactId=sofa-ark-tongweb-spring-boot-starter -Dversion=7.0.E.6_P7 -Dfile="XXX/sofa-ark-tongweb-spring-boot-starter-7.0.E.6_P7.jar" -Dpackaging=jar
mvn install:install-file -DgroupId=com.tongweb -DartifactId=sofa-ark-tongweb-embed-core -Dversion=7.0.E.6_P7 -Dfile="XXX/sofa-ark-tongweb-embed-core-7.0.E.6_P7.jar" -Dpackaging=jar
mvn install:install-file -DgroupId=com.tongweb -DartifactId=sofa-ark-tongweb-lic-sdk -Dversion=4.5.0.0 -Dfile="XXX/sofa-ark-tongweb-lic-sdk-4.5.0.0.jar" -Dpackaging=jar
```
### 2. 编译安装本项目插件
进入本项目的tongweb7-web-adapter 目录执行mvn install命令即可。
项目将会安装“tongweb7-web-ark-plugin” 和 “tongweb7-sofa-ark-springboot-starter” 两个模块。

### 3. 使用本项目组件
首先需要根据koupleless的文档，[将项目升级为Koupleless基座](https://koupleless.io/docs/tutorials/base-create/springboot-and-sofaboot/)

然后将依赖中提到的
```
    <dependency>
        <groupId>com.alipay.sofa</groupId>
        <artifactId>web-ark-plugin</artifactId>
        <version>${sofa.ark.version></version>
    </dependency>
```
替换为本项目的坐标
```
    <dependency>
        <groupId>com.alipay.sofa</groupId>
        <artifactId>tongweb7-web-ark-plugin</artifactId>
        <version>2.2.9</version>
    </dependency>
    
    <dependency>
        <groupId>com.alipay.sofa</groupId>
        <artifactId>tongweb7-sofa-ark-springboot-starter</artifactId>
        <version>2.2.9</version>
    </dependency>
```

引入TongWEB相关依赖（同时需要exclude tomcat的依赖）。参考依赖如下：
```angular2html
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
            <groupId>com.tongweb.springboot</groupId>
            <artifactId>sofa-ark-tongweb-spring-boot-starter</artifactId>
            <version>7.0.E.6_P7</version>
        </dependency>
        <dependency>
            <groupId>com.tongweb</groupId>
            <artifactId>sofa-ark-tongweb-embed-core</artifactId>
            <version>7.0.E.6_P7</version>
        </dependency>
        <dependency>
            <groupId>com.tongweb</groupId>
            <artifactId>sofa-ark-tongweb-lic-sdk</artifactId>
            <version>4.5.0.0</version>
        </dependency>
```

### 4. 完成
完成上述步骤后，即可在Koupleless中使用TongWEB启动项目。
