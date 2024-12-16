---
title: 4.3.2 模块瘦身
date: 2024-01-25T10:28:32+08:00
description: Koupleless 模块瘦身
weight: 200
---

## 为什么要瘦身
Koupleless 底层借助 SOFAArk 框架，实现了模块之间、模块和基座之间的类隔离。模块启动时会初始化各种对象，会**优先使用模块的类加载器**去加载构建产物 FatJar 中的 class、resource 和 Jar 包，**找不到的类会委托基座的类加载器**去查找。

<div style="text-align: center;">
    <img width="700" src="https://intranetproxy.alipay.com/skylark/lark/0/2023/jpeg/8276/1678275655551-75bf283f-3817-447a-84b2-7f6f7f773300.jpeg"/>
</div>

基于这套类委托的加载机制，让基座和模块共用的 class、resource 和 Jar 包**通通下沉**到基座中，可以让模块构建产物**非常小**，从而模块消耗的内存**非常少**，启动也能**非常快**。<br />

其次，模块启动后 Spring 上下文中会创建很多对象，如果启用了模块热卸载，可能无法完全回收，安装次数过多会造成 Old 区、Metaspace 区开销大，触发频繁 FullGC，所以需要控制单模块包大小 < 5MB。**这样不替换或重启基座也能热部署热卸载数百次。**

所谓模块瘦身，就是让基座已经有的 Jar 依赖不参与模块打包构建，从而实现上述两个好处：

- 提高模块安装的速度，减少模块包大小，减少启动依赖，控制模块安装耗时 < 30秒，甚至 < 5秒
- 在热部署热卸载场景下，不替换或重启基座也能热部署热卸载数百次

## 瘦身原则

构建 ark-biz jar 包的原则是，在保证模块功能的前提下，将框架、中间件等通用的包尽量放置到基座中，模块中复用基座的包，这样打出的 ark-biz jar 会更加轻量。

在不同场景下，复杂应用可以选择不同的方式瘦身。

## 场景及相应的瘦身方式

### 场景一：基座和模块协作紧密，如中台模式 / 共库模式

在基座和模块协作紧密的情况下，模块应该在开发时就感知基座的部分facade类和基座正使用的依赖版本，并按需引入需要的依赖。 模块打包时，仅打包两种依赖：基座没有的依赖，模块和基座版本不一致的依赖。

因此，需要让基座：
1. 统一管控模块依赖版本，让模块开发时就知道基座有哪些依赖，风险前置，而且模块开发者按需引入部分依赖，无需指定版本。

需要让模块：
1. 打包时，仅打包基座没有的依赖、和基座版本不一致的依赖，降低模块瘦身成本

#### 步骤一 打包“基座-dependencies-starter”

**目标**

该步骤将打出 “基座依赖-starter”，用于统一管控模块依赖版本。

**基座bootstrap pom增加配置**

注意：以下配置中的 dependencyArtifactId 需要修改，一般为${baseAppName}-dependencies-starter

```xml
<build>
<plugins>
    <plugin>
        <groupId>com.alipay.sofa.koupleless</groupId>
        <artifactId>koupleless-base-build-plugin</artifactId>
        <version>1.2.4-SNAPSHOT</version>
        <configuration>
            <!--生成 starter 的 artifactId（groupId和基座一致），这里需要修改！！-->
            <dependencyArtifactId>${baseAppName}-dependencies-starter</dependencyArtifactId>
            <!--生成jar的版本号-->
            <dependencyVersion>0.0.1-SNAPSHOT</dependencyVersion>
            <!-- 调试用，改成 true 即可看到打包中间产物 -->
            <cleanAfterPackageDependencies>false</cleanAfterPackageDependencies>
        </configuration>
    </plugin>
  </plugins>
</build>
```

**本地测试**

1. 打包基座 dependency-starter jar：在基座根目录执行命令：

``` shell
mvn com.alipay.sofa.koupleless:koupleless-base-build-plugin::packageDependency -f ${基座 bootstrap pom 对于基座根目录的相对路径} 
```

构建出来的 pom 在 outputs 目录下，也会自动安装至本地的 maven 仓库。

**注意**，该步骤不会将 “基座依赖-starter” 上传至 maven 仓库。欢迎后续讨论补充 “上传至 maven 仓库” 的方案。

#### 步骤二 模块修改打包插件和 parent
**目标**
1. 模块开发时，将步骤一中的 “基座-dependencies-starter” 作为模块项目的 parent，统一管理依赖版本；
2. 修改模块打包插件，模块打包时只将“基座没有的依赖”、“与基座版本不一致的依赖”打包进模块，而**不用手动配置“provided”，自动实现模块瘦身**。

**模块根目录的 pom 中配置 parent：**

```xml
<parent>
   <groupId>com.alipay</groupId>
   <artifactId>${baseAppName}-dependencies-starter</artifactId>
   <version>0.0.1-SNAPSHOT</version>
</parent>
```
   
**模块打包的 pom 中配置 plugin：**
```xml
<build>
   <plugins>
       <plugin>
           <groupId>com.alipay.sofa</groupId>
           <artifactId>sofa-ark-maven-plugin</artifactId>
           <version>2.2.13-SNAPSHOT</version>
           <executions>
               <execution>
                   <id>default-cli</id>
                   <goals>
                       <goal>repackage</goal>
                   </goals>
               </execution>
           </executions>
           <configuration>
               <!-- 配置 “基座-dependencies-starter” 的标识，规范为：'${groupId}:${artifactId}':'version' -->
               <baseDependencyParentIdentity>com.alipay:${baseAppName}-dependencies-starter:0.0.1-SNAPSHOT</baseDependencyParentIdentity>
           </configuration>
       </plugin>
   </plugins>
</build>
```

#### 步骤三 配置模块依赖白名单

对于部分依赖，即使模块和基座使用的依赖版本一致，但模块打包时也需要保留该依赖，即需要配置模块瘦身依赖白名单。

配置方式：在「模块项目根目录/conf/ark/bootstrap.properties」 或 「模块项目根目录/conf/ark/bootstrap.yaml」中增加需要保留的依赖，如果该文件不存在，可自行新增目录和文件。以下提供了3个不同级别的配置，可根据实际情况进行添加。

```properties
# includes config ${groupId}:${artifactId}, split by ','
includes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# includeGroupIds config ${groupId}, split by ','
includeGroupIds=org.springframework
# includeArtifactIds config ${artifactId}, split by ','
includeArtifactIds=sofa-ark-spi
```

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

#### 步骤四 打包构建

打包构建出模块 ark-biz jar 包即可，您可以明显看出瘦身后的 ark-biz jar 包大小差异。



### 场景二：基座和模块协作松散，如多应用合并部署节省资源

在基座和模块协作松散的情况下，模块不应该在开发时感知基座正使用的依赖版本，因此模块更需要注重模块瘦身的低成本接入，可以配置模块打包需要排除的依赖。

### 方式一：SOFAArk 配置文件排包

### 步骤一

SOFAArk 模块瘦身会读取两处配置文件：

- "模块项目根目录/conf/ark/bootstrap.properties"，比如：my-module/conf/ark/bootstrap.properties
- "模块项目根目录/conf/ark/bootstrap.yml"，比如：my-module/conf/ark/bootstrap.yml

#### 配置方式

##### bootstrap.properties (推荐)

在「模块项目根目录/conf/ark/bootstrap.properties」中按照如下格式配置需要下沉到基座的框架和中间件常用包，比如：

```properties
# excludes config ${groupId}:{artifactId}:{version}, split by ','
excludes=org.apache.commons:commons-lang3,commons-beanutils:commons-beanutils
# excludeGroupIds config ${groupId}, split by ','
excludeGroupIds=org.springframework
# excludeArtifactIds config ${artifactId}, split by ','
excludeArtifactIds=sofa-ark-spi
```

##### bootstrap.yml (推荐)

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


### 步骤二

升级模块打包插件 `sofa-ark-maven-plugin` 版本 >= 2.2.12

```xml
    <!-- 插件1：打包插件为 sofa-ark biz 打包插件，打包成 ark biz jar -->
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
            <skipArkExecutable>true</skipArkExecutable>
            <outputDirectory>./target</outputDirectory>
            <bizName>biz1</bizName>
            <webContextPath>biz1</webContextPath>
            <declaredMode>true</declaredMode>
        </configuration>
    </plugin>
```

### 步骤三

打包构建出模块 ark-biz jar 包即可，您可以明显看出瘦身后的 ark-biz jar 包大小差异。

您可[点击此处](https://github.com/koupleless/samples/tree/master/springboot-samples/slimming)查看完整模块瘦身样例工程。
