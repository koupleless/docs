---
title: 4.3.11 静态合并部署
date: 2024-01-25T10:28:32+08:00
description: Koupleless 模块静态合并部署
weight: 700
---

## 介绍

SOFAArk 提供了静态合并部署能力，**Base 包（基座应用）** 在启动时，可以启动已经构建完成的 **Biz 包（模块应用)**，默认获取模块的方式为：本地目录、本地文件URL、远程URL。

此外，SOFAArk 还提供了静态合并部署的扩展接口，开发者可以自定义获取 **Biz 包（模块应用)** 的方式。

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
        <configuration>
            <!--                默认100，数值越大越后面安装，koupleless runtime 版本大于等于 1.2.2             -->
            <priority>200</priority>
        </configuration>
    </plugin>
</build>
```

### 步骤二：基座获取需要合并部署的 Ark Biz

要求:
- jdk8
    - sofa.ark.version >= 2.2.12
    - koupleless.runtime.version >= 1.2.3
- jdk17/jdk21
    - sofa.ark.version >= 3.1.5
    - koupleless.runtime.version >= 2.1.4


#### 方式一：使用官方默认获取方式，支持本地目录、本地文件URL、远程URL

##### 1. 基座配置本地目录、本地文件URL、远程URL

开发者需要在基座的 ark 配置文件中（`conf/ark/bootstrap.properties` 或 `conf/ark/bootstrap.yml`）指定需要合并部署的 Ark Biz 包，支持：

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

##### 2. 基座配置打包插件目标 integrate-biz

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

执行打包后，如果自行解压打包的 jar 文件，可以在 classPath/SOFA-ARK/biz 中看到指定的模块 ark-biz 包。

#### 方式二：使用自定义获取方式

##### 1. Ark 扩展机制原理

见 [Ark 扩展机制原理介绍](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-extension/)

##### 2. 实现 AddBizToStaticDeployHook 接口

基座/基座二方包中，实现 AddBizToStaticDeployHook 接口，以 AddBizInResourcesHook 为例，如下：
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
        // ... 读取资源中的Ark Biz包
        return archives;
    }
}
```

##### 3. 配置 spi 

在 resources 目录下添加 /META-INF/services/sofa-ark/ 目录，再在 /META-INF/services/sofa-ark/ 添加一个 名为 com.alipay.sofa.ark.spi.service.biz.AddBizToStaticDeployHook 的文件，文件里面内容为 hook 类的全限定名：
```text
com.alipay.sofa.ark.support.common.AddBizInResourcesHook
```

重新打包基座。

### 步骤三：启动基座

JVM 添加参数，配置： `-Dsofa.ark.embed.static.biz.enable=true`, 或者在基座 main 方法里增加这行代码 `ArkConfigs.setEmbedStaticBizEnable(true);`
