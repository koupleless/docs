---
title: 4.3.13 Koupleless 配置
date: 2024-07-25T10:28:32+08:00
description: Koupleless 各项配置
weight: 810
---
# 打包构建阶段
## 基座打包插件配置
### 插件参数配置

完整的 `koupleless-base-build-plugin` 插件配置模板如下：

```xml
<plugin>
  <groupId>com.alipay.sofa.koupleless</groupId>
  <artifactId>koupleless-base-build-plugin</artifactId>
  <version>${koupleless.runtime.version}</version>
  <executions>
    <execution>
      <goals>
        <goal>add-patch</goal>
        <!-- 用于静态合并部署-->
        <goal>integrate-biz</goal>
      </goals>
    </execution>
  </executions>
  <configuration>
      <!--基座打包存放目录，默认为工程 build 目录-->
      <outputDirectory>./target</outputDirectory>
      
      <!--打包 starter 的 groupId，默认为工程的 groupId-->
      <dependencyGroupId>${groupId}</dependencyGroupId>
      
      <!--打包 starter 的 artifactId-->
      <dependencyArtifactId>${baseAppName}-dependencies-starter</dependencyArtifactId>
      
      <!--打包 starter 的版本号-->
      <dependencyVersion>0.0.1-SNAPSHOT</dependencyVersion>
      
      <!-- 调试用，改成 true 即可看到打包 starter 的中间产物 -->
      <cleanAfterPackageDependencies>false</cleanAfterPackageDependencies>
  </configuration>
</plugin>
```

### 静态合并部署的配置
开发者需要在基座的 ark 配置文件中（`conf/ark/bootstrap.properties` 或 `conf/ark/bootstrap.yml`）指定需要合并部署的 Ark Biz 包，支持：

+ 本地目录
+ 本地文件URL(windows 系统为 `file:\\`, linux 系统为 `file://`)
+ 远程URL（支持 `http://`,`https://`）

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

## 模块打包插件配置
### 插件参数配置
完整的 `sofa-ark-maven-plguin` 插件配置模板如下：

```xml
<plugins>
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
                <configuration>
                    <!--ark 包和 ark biz 的打包存放目录，默认为工程 build 目录-->
                    <outputDirectory>./target</outputDirectory>

                    <!--设置应用的根目录，用于读取 ${base.dir}/conf/ark/bootstrap.application 配置文件，默认为 ${project.basedir}-->
                    <baseDir>./</baseDir>

                    <!--生成 ark 包文件名称，默认为 ${artifactId}-->
                    <finalName>demo-ark</finalName>

                    <!--是否跳过执行 goal:repackage，默认为false-->
                    <skip>false</skip>

                    <!--是否打包、安装和发布 ark biz，详细参考 Ark Biz 文档，默认为false-->
                    <attach>true</attach>

                    <!--设置 ark 包的 classifier，默认为空-->
                    <arkClassifier>ark</arkClassifier>

                    <!--设置 ark biz 的 classifier，默认为 ark-biz-->
                    <bizClassifier>ark-biz</bizClassifier>

                    <!--设置 ark biz 的 biz name，默认为 ${artifactId}-->
                    <bizName>demo-ark</bizName>

                    <!--设置 ark biz 的 biz version，默认为 ${artifactId}-->
                    <bizVersion>0.0.1</bizVersion>

                    <!--设置 ark biz 的 启动优先级，值越小优先级越高，${artifactId}-->
                    <priority>100</priority>

                    <!--设置 ark biz 的启动入口，默认会搜索被打 org.springframework.boot.autoconfigure.SpringBootApplication 注解且含有 main 方法的入口类-->
                    <mainClass>com.alipay.sofa.xx.xx.MainEntry</mainClass>

                    <!--设置是否将 scope=provided 的依赖打包，默认为 false-->
                    <packageProvided>false</packageProvided>

                    <!--设置是否生成 Biz 包，默认为true-->
                    <keepArkBizJar>true</keepArkBizJar>

                    <!--针对 Web 应用，设置 context path，默认为 /，模块应该配置自己的 webContextPath，如：biz1 -->
                    <webContextPath>/</webContextPath>

                    <!--打包 ark biz 时，排除指定的包依赖；格式为: ${groupId:artifactId} 或者 ${groupId:artifactId:classifier}-->
                    <excludes>
                        <exclude>org.apache.commons:commons-lang3</exclude>
                    </excludes>

                    <!--打包 ark biz 时，排除和指定 groupId 相同的包依赖-->
                    <excludeGroupIds>
                        <excludeGroupId>org.springframework</excludeGroupId>
                    </excludeGroupIds>

                    <!--打包 ark biz 时，排除和指定 artifactId 相同的包依赖-->
                    <excludeArtifactIds>
                        <excludeArtifactId>sofa-ark-spi</excludeArtifactId>
                    </excludeArtifactIds>

                    <!--打包 ark biz 时，配置不从 ark plugin 索引的类；默认情况下，ark biz 会优先索引所有 ark plugin 的导出类，
                    添加该配置后，ark biz 将只在ark biz内部加载该类，不再优先委托 ark plugin 加载-->
                    <denyImportClasses>
                        <class>com.alipay.sofa.SampleClass1</class>
                        <class>com.alipay.sofa.SampleClass2</class>
                    </denyImportClasses>

                    <!--对应 denyImportClasses 配置，可以配置包级别-->
                    <denyImportPackages>
                        <package>com.alipay.sofa</package>
                        <package>org.springframework.*</package>
                    </denyImportPackages>

                    <!--打包 ark biz 时，配置不从 ark plugin 索引的资源；默认情况下，ark biz 会优先索引所有 ark plugin 的导出资源,
                    添加该配置后，ark biz 将只在ark biz内部寻找该资源，不在从 ark plugin 查找-->
                    <denyImportResources>
                        <resource>META-INF/spring/test1.xml</resource>
                        <resource>META-INF/spring/test2.xml</resource>
                    </denyImportResources>
                  
                     <!--ark biz 仅能找到自己在pom 中声明过的依赖，默认为 false-->
                    <declaredMode>true</declaredMode>

                    <!--打包 ark biz 时，仅打包基座没有的依赖、模块与基座不同版本的依赖。该参数用于指定“基座的依赖管理”标识，“基座的依赖管理”需要作为模块 pom 的 parent ，以 ${groupId}:${artifactId}:${version} 标识 -->
                    <baseDependencyParentIdentity>${groupId}:${artifactId}:${version}</baseDependencyParentIdentity>
                </configuration>
            </execution>
        </executions>
    </plugin>
</plugins>
```

### 模块瘦身配置
SOFAArk 模块瘦身会读取两处配置文件：

+ "模块项目根目录/conf/ark/bootstrap.properties"，比如：my-module/conf/ark/bootstrap.properties
+ "模块项目根目录/conf/ark/bootstrap.yml"，比如：my-module/conf/ark/bootstrap.yml

**bootstrap.properties**

在「模块项目根目录/conf/ark/bootstrap.properties」中按照如下格式配置需要下沉到基座的框架和中间件常用包，比如：

```properties
# excludes config ${groupId}:{artifactId}:{version}, split by ','
excludes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# excludeGroupIds config ${groupId}, split by ','
excludeGroupIds=org.springframework
# excludeArtifactIds config ${artifactId}, split by ','
excludeArtifactIds=sofa-ark-spi
```

**bootstrap.yml**

在「模块项目根目录/conf/ark/bootstrap.yml」中按照如下格式配置需要下沉到基座的框架和中间件常用包，比如：

```yaml
# excludes 中配置 ${groupId}:{artifactId}:{version}, 不同依赖以 - 隔开
# excludeGroupIds 中配置 ${groupId}, 不同依赖以 - 隔开
# excludeArtifactIds 中配置 ${artifactId}, 不同依赖以 - 隔开
excludes:
  - org.apache.commons:commons-lang3
  - commons-beanutils:commons-beanutils
excludeGroupIds:
  - org.springframework
excludeArtifactIds:
  - sofa-ark-spi
```
# 开发阶段
## Arklet 配置
### 端口配置
基座启动时，在JVM参数中配置端口，默认为 1238

```shell
-Dkoupleless.arklet.http.port=XXXX
```

## 模块运行时配置
### 健康检查的配置
基座的 application.properties 配置：

```properties
# 或者不配置 management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
# 如果需要展示所有信息，则配置以下内容
management.endpoint.health.show-components=always
management.endpoint.health.show-details=always
# 不忽略模块启动状态
koupleless.healthcheck.base.readiness.withAllBizReadiness=true
```

### Web Gateway 配置
在传统应用拆出模块时，由于每个模块都有自己的 webContextPath，上游调用方需要修改请求路径。为了避免修改，可以在 application.properties 或 application.yaml 中配置 Web Gateway 转发规则，让上游调用方无需修改。

在配置上，可以配置三种策略：

+ 域名匹配：指定 `符合HostA的请求` 转发到 `模块A`
+ 路径匹配：指定 `符合PathA的请求` 转发到 `模块A的特定PathB`
+ 域名和路径同时匹配：指定 `符合HostA且PathA的请求` 转发到 `模块A的特定PathB`

**application.yaml** 配置样例如下：

```yaml
koupleless:
  web:
    gateway:
      forwards:
# host in [a.xxx,b.xxx,c.xxx] path /${anyPath} --forward to--> biz1/${anyPath}
        - contextPath: biz1
        - hosts:
            - a
            - b
            - c
# /idx2/** -> /biz2/**, /t2/** -> /biz2/timestamp/**
        - contextPath: biz2
        - paths:
            - from: /idx2
            - to: /
            - from: /t2
            - to: /timestamp
# /idx1/** -> /biz1/**, /t1/** -> /biz1/timestamp/**
        - contextPath: biz1
        - paths:
            - from: /idx1
            - to: /
            - from: /t1
            - to: /timestamp
```

**application.properties** 配置样例如下：

```properties
# host in [a.xxx,b.xxx,c.xxx] path /${anyPath} --forward to--> biz1/${anyPath}
koupleless.web.gateway.forwards[0].contextPath=biz1
koupleless.web.gateway.forwards[0].hosts[0]=a
koupleless.web.gateway.forwards[0].hosts[1]=b
koupleless.web.gateway.forwards[0].hosts[2]=c
# /idx2/** -> /biz2/**, /t2/** -> /biz2/timestamp/**
koupleless.web.gateway.forwards[1].contextPath=biz2
koupleless.web.gateway.forwards[1].paths[0].from=/idx2
koupleless.web.gateway.forwards[1].paths[0].to=/
koupleless.web.gateway.forwards[1].paths[1].from=/t2
koupleless.web.gateway.forwards[1].paths[1].to=/timestamp
# /idx1/** -> /biz1/**, /t1/** -> /biz1/timestamp/**
koupleless.web.gateway.forwards[2].contextPath=biz1
koupleless.web.gateway.forwards[2].paths[0].from=/idx1
koupleless.web.gateway.forwards[2].paths[0].to=/
koupleless.web.gateway.forwards[2].paths[1].from=/t1
koupleless.web.gateway.forwards[2].paths[1].to=/timestamp

```
