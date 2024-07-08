---
title: 静态合并部署
date: 2024-01-25T10:28:32+08:00
description: Koupleless 模块静态合并部署
weight: 700
---

## 介绍

SOFAArk 提供了静态合并部署能力，**Base 包（基座应用）** 在启动时，可以启动已经构建完成的 **Biz 包（模块应用)**，支持本地目录、本地文件URL、远程URL 和自定义获取方式。

## 使用方式

### 步骤一：模块应用打包成 Ark Biz

如果开发者希望自己应用的 Ark Biz 包能够被其他应用直接当成 Jar 包依赖，进而运行在同一个 SOFAArk 容器之上，那么就需要打包发布 Ark Biz
包，详见 [Ark Biz 介绍](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-biz/)。 Ark Biz 包使用
Maven 插件 sofa-ark-maven-plugin 打包生成。

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

### 步骤二：基座配置需要合并部署的 Ark Biz（本地目录、本地文件URL、远程URL）

开发者需要在基座的 ark 配置文件中（`conf/ark/ark.properties` 或 `conf/ark/ark.yml`）指定需要合并部署的 Ark Biz 包，支持：

- 本地目录
- 本地文件URL(windows 系统为 `file:\\`, linux 系统为 `file://`)
- 远程URL（支持 `http://`,`https://`）

其中，本地文件URL、远程URL 配置在 `integrateBizURLs` 字段中，本地目录配置在 `integrateLocalDirs` 字段中。

配置方式如下：

```properties
integrateBizURLs=file://${xxx}/koupleless_samples/springboot-samples/service/biz1/biz1-bootstrap/target/biz1-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar,\
  file://${xxx}/koupleless_samples/springboot-samples/service/biz2/biz2-bootstrap/target/biz2-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar,\
  https://oss.xxxxx/biz2-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar
integrateLocalDirs=/home/${xxx}/sofa-ark/biz,\
  /home/${xxx}/sofa-ark/biz2
```

或

```yaml
integrateBizURLs:
  - file://${xxx}/springboot-samples/service/biz2/biz2-bootstrap/target/biz2-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar
  - file://${xxx}/koupleless_samples/springboot-samples/service/biz2/biz2-bootstrap/target/biz2-bootstrap-0.0.1-SNAPSHOT-ark-biz.jar
integrateLocalDirs:
  - /home/${xxx}/sofa-ark/biz
  - /home/${xxx}/sofa-ark/biz2
```

### 步骤三：基座配置打包插件目标 integrate-biz
required: koupleless.runtime.version yun>=

基座 bootstrap 的 pom 中给 koupleless-base-build-plugin 添加 <goal>integrate-biz</goal>，如下：
```xml
<plugin>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-base-build-plugin</artifactId>
    <version>${koupleless.runtime.version}</version>
    <executions>
        <execution>
            <goals>
                <goal>add-patch</goal>
<!--                用于静态合并部署-->
                <goal>integrate-biz</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### 步骤四：启动基座
JVM 添加参数，配置： `-Dsofa.ark.embed.static.biz.in.resource.enable=true`

## 指定本地目录方式（不推荐）

用户可以把 Biz 包统一放置在某个目录中，然后通过启动参数告知基座扫描这个目录，以此完成静态合并部署（详情见下描述）。如此，开发不需要考虑相互之间依赖冲突问题，Biz 之间则通过 @SofaService 和 @SofaReference 发布/引用 JVM 服务（_SOFABoot，SpringBoot 还在建设中_
）进行交互。

### 步骤 1：模块应用打包成 Ark Biz

如果开发者希望自己应用的 Ark Biz 包能够被其他应用直接当成 Jar 包依赖，进而运行在同一个 SOFAArk 容器之上，那么就需要打包发布 Ark Biz
包，详见 [Ark Biz 介绍](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-biz/)。 Ark Biz 包使用
Maven 插件 sofa-ark-maven-plugin 打包生成。

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

### 步骤 2：将上述 jar 包移动到指定目录。

把需要部署的 biz jar 都移动到指定目录，如：/home/sofa-ark/biz/

```shell
mv /path/to/your/biz/jar /home/sofa-ark/biz/
```

### 步骤 3：启动基座，并通过 -D 参指定 biz 目录

```shell
java -jar -Dcom.alipay.sofa.ark.static.biz.dir=/home/sofa-ark/biz/ sofa-ark-base.jar
```

### 步骤 4：验证 Ark Biz（模块）启动

在基座启动成功后，可以通过 telnet 启动 SOFAArk 客户端交互界面：

```shell
telnet localhost 1234
```

然后执行如下命令查看模块列表：

```shell
biz -a
```

此时应当可以看到 Master Biz（基座）和所有静态合并部署的 Ark Biz（模块）。<br/>
上述操作可以通过 [SOFAArk 静态合并部署样例](https://github.com/koupleless/samples/blob/master/springboot-samples/web/tomcat/README.md#%E5%AE%9E%E9%AA%8C%E5%86%85%E5%AE%B9(%E9%9D%99%E6%80%81%E5%90%88%E5%B9%B6%E9%83%A8%E7%BD%B2))
体验。<br/>

<br/>
<br/>
