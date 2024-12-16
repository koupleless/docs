---
title: 4.3.13 Koupleless Configuration
date: 2024-07-25T10:28:32+08:00
description: Koupleless configuration
weight: 810
---
# Packaging Phase
## Base Packaging Plugin Configuration
### Plugin Parameter Configuration
The complete `koupleless-base-build-plugin` plugin configuration template is as follows:
```xml
<plugin>
  <groupId>com.alipay.sofa.koupleless</groupId>
  <artifactId>koupleless-base-build-plugin</artifactId>
  <version>${koupleless.runtime.version}</version>
  <executions>
    <execution>
      <goals>
        <goal>add-patch</goal>
        <!-- Used for static merger deployment-->
        <goal>integrate-biz</goal>
      </goals>
    </execution>
  </executions>
  <configuration>
      <!--Base packaging directory, default is the project build directory-->
      <outputDirectory>./target</outputDirectory>
      
      <!--The groupId of the starter to be packaged, which defaults to the groupId of the project-->
      <dependencyGroupId>${groupId}</dependencyGroupId>
      
      <!--ArtifactId of the starter to be packaged-->
      <dependencyArtifactId>${baseAppName}-dependencies-starter</dependencyArtifactId>
      
      <!--Version number of the starter to be packaged-->
      <dependencyVersion>0.0.1-SNAPSHOT</dependencyVersion>
      
      <!--For debugging, change to true to see the intermediate products of the packaged starter-->
      <cleanAfterPackageDependencies>false</cleanAfterPackageDependencies>
  </configuration>
</plugin>
```
### Static Integration Deployment Configuration
Developers need to specify the Ark Biz package that needs to be integrated and deployed in the ark configuration file of the base (`conf/ark/bootstrap.properties` or `conf/ark/bootstrap.yml`), with support for:
+ Local directory
+ Local file URL (File path for Windows is `file:\\`, and for Linux it is `file://`)
+ Remote URL (supports `http://`,`https://`)
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
## Module Packaging Plugin Configuration
### Plugin Parameter Configuration
The complete `sofa-ark-maven-plguin` plugin configuration template is as follows:
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
                    <!--Ark package and ark biz packaging directory, default is the project build directory-->
                    <outputDirectory>./target</outputDirectory>
                    <!--Set the root directory of the application for reading the ${base.dir}/conf/ark/bootstrap.application configuration file, default to ${project.basedir}-->
                    <baseDir>./</baseDir>
                    <!--Generated ark package file name, default is ${artifactId}-->
                    <finalName>demo-ark</finalName>
                    <!--Whether to skip the goal:repackage execution, default to false-->
                    <skip>false</skip>
                    <!--Whether to package, install and publish ark biz, details please refer to the Ark Biz document, default to false-->
                    <attach>true</attach>
                    <!--Set the classifier of the ark package, default to empty-->
                    <arkClassifier>ark</arkClassifier>
                    <!--Set the classifier of the ark biz, default to ark-biz-->
                    <bizClassifier>ark-biz</bizClassifier>
                    <!--Set the biz name of the ark biz, default to ${artifactId}-->
                    <bizName>demo-ark</bizName>
                    <!--Set the biz version of the ark biz, default to ${artifactId}-->
                    <bizVersion>0.0.1</bizVersion>
                    <!--Set the startup priority of the ark biz, smaller priority has higher priority, ${artifactId}-->
                    <priority>100</priority>
                    <!--Set the startup entry of the ark biz, it will automatically search for the entry class that contains the main method and has the org.springframework.boot.autoconfigure.SpringBootApplication annotation-->
                    <mainClass>com.alipay.sofa.xx.xx.MainEntry</mainClass>
                    <!--Set whether to package dependencies with scope=provided, default to false-->
                    <packageProvided>false</packageProvided>
                    <!--Set whether to generate the Biz package, default to true-->
                    <keepArkBizJar>true</keepArkBizJar>
                    <!--For web applications, set the context path, default to /, each module should configure its own webContextPath, e.g.: biz1-->
                    <webContextPath>/</webContextPath>
                    <!--When packaging ark biz, exclude specified package dependencies; format: ${groupId:artifactId} or ${groupId:artifactId:classifier}-->
                    <excludes>
                        <exclude>org.apache.commons:commons-lang3</exclude>
                    </excludes>
                    <!--When packaging ark biz, exclude dependencies with the specified groupId-->
                    <excludeGroupIds>
                        <excludeGroupId>org.springframework</excludeGroupId>
                    </excludeGroupIds>
                    <!--When packaging ark biz, exclude dependencies with the specified artifactId-->
                    <excludeArtifactIds>
                        <excludeArtifactId>sofa-ark-spi</excludeArtifactId>
                    </excludeArtifactIds>
                    <!--When packaging ark biz, configure classes not covered by the ark plugin index; by default, ark biz will prioritize indexing all exported classes of ark plugin, which means it will only load the class locally, rather than delegating ark plugin to load-->
                    <denyImportClasses>
                        <class>com.alipay.sofa.SampleClass1</class>
                        <class>com.alipay.sofa.SampleClass2</class>
                    </denyImportClasses>
                    <!--Corresponding to the denyImportClasses configuration, package level can be configured-->
                    <denyImportPackages>
                        <package>com.alipay.sofa</package>
                        <package>org.springframework.*</package>
                    </denyImportPackages>
                    <!--When packaging ark biz, configure resources not covered by the ark plugin index; by default, ark biz will prioritize indexing all exported resources of the ark plugin, adding that configuration means that ark biz will only search for the resources internally without searching from the ark plugin-->
                    <denyImportResources>
                        <resource>META-INF/spring/test1.xml</resource>
                        <resource>META-INF/spring/test2.xml</resource>
                    </denyImportResources>
                  
                     <!--Isolates the dependencies that the ark biz has declared in its pom, default to false-->
                    <declaredMode>true</declaredMode>
                    <!--When packaging ark biz, only package dependencies that the base does not have, or dependencies of modules that are different from the base. This parameter specifies the "dependency management" identifier of the base, and is required to be a parent of module pom with the format ${groupId}:${artifactId}:${version}-->
                    <baseDependencyParentIdentity>${groupId}:${artifactId}:${version}</baseDependencyParentIdentity>
                </configuration>
            </execution>
        </executions>
    </plugin>
</plugins>
```
### Module Slimming Configuration
SOFAArk module slimming reads configuration from two places:
+ `module project root directory/conf/ark/bootstrap.properties`, e.g.: my-module/conf/ark/bootstrap.properties
+ `module project root directory/conf/ark/bootstrap.yml`, e.g.: my-module/conf/ark/bootstrap.yml
  **bootstrap.properties**
  In the `module project root directory/conf/ark/bootstrap.properties`, configure the commonly used packages of the framework and middleware that need to be down to the base as follows:
```properties
# excludes config ${groupId}:{artifactId}:{version}, split by ','
excludes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# excludeGroupIds config ${groupId}, split by ','
excludeGroupIds=org.springframework
# excludeArtifactIds config ${artifactId}, split by ','
excludeArtifactIds=sofa-ark-spi
```
**bootstrap.yml**
In the `module project root directory/conf/ark/bootstrap.yml`, configure the commonly used packages of the framework and middleware that need to be down to the base as follows:

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

For partial dependencies, even if the dependency versions used by the module and the base are consistent, the dependency must still be retained when the module is packaged. This means you need to configure a whitelist for module dependency trimming.

Configuration method: Add the dependencies that need to be retained in the `module project root directory/conf/ark/bootstrap.properties` or `module project root directory/conf/ark/bootstrap.yml`. If these files do not exist, you can create the directories and files yourself.

**bootstrap.properties**

```properties
# includes config ${groupId}:${artifactId}, split by ','
includes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# includeGroupIds config ${groupId}, split by ','
includeGroupIds=org.springframework
# includeArtifactIds config ${artifactId}, split by ','
includeArtifactIds=sofa-ark-spi
```

**bootstrap.yml**

```yaml
# includes config ${groupId}:${artifactId}
includes:
  - org.apache.commons:commons-lang3
  - commons-beanutils:commons-beanutils
# includeGroupIds config ${groupId}
includeGroupIds:
  - org.springframework
# includeArtifactIds config ${artifactId}
includeArtifactIds:
  - sofa-ark-spi
```

# Development Phase
## Arklet Configuration
### Port Configuration
When the base is started, configure the port in the JVM parameters, default is 1238
```shell
-Dkoupleless.arklet.http.port=XXXX
```
## Module Runtime Configuration
### Configuration of Health Check
Configuration in the application.properties of the base:
```properties
# Or do not configure management.endpoints.web.exposure.include
management.endpoints.web.exposure.include=health
# If all information needs to be displayed, configure the following content
management.endpoint.health.show-components=always
management.endpoint.health.show-details=always
# Do not ignore module startup status
koupleless.healthcheck.base.readiness.withAllBizReadiness=true
```
### Web Gateway Configuration
When traditional applications are split into modules, each module has its own webContextPath, and the upstream caller needs to modify the request path. To avoid the modification, you can configure Web Gateway forwarding rules in the application.properties or application.yaml, allowing the upstream caller not to modify.
In the configuration, three strategies can be configured:
+ Domain matching: specifies that `requests that meet HostA` are forwarded to `ModuleA`
+ Path matching: specifies that `requests that meet PathA` are forwarded to `specific PathB` of `ModuleA`
+ Domain and path matching: specifies that `requests that meet HostA and PathA` will be forwarded to `specific PathB of ModuleA`
  **application.yaml** Configuration example:
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
**application.properties** Configuration example:
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
