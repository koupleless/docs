---
title: 4.1.1 SpringBoot 或 SOFABoot 升级为基座
date: 2024-01-25T10:28:32+08:00
description: SpringBoot 或 SOFABoot 升级为 Koupleless 基座
weight: 100
---

## 前提条件

1. SpringBoot 版本 >= 2.1.9.RELEASE（针对 SpringBoot 用户）
2. SOFABoot 版本 >= 3.9.0 或 SOFABoot >= 4.0.0（针对 SOFABoot 用户）
3. 本地安装 maven，且 maven 版本大于 3.9.0

注意：SpringBoot 版本 == 2.1.9.RELEASE，见 [SpringBoot 2.1.9 升级为基座](#springboot-219-升级为基座)

## 接入步骤

### 代码与配置修改

#### 修改 application.properties

```properties
# 需要定义应用名
spring.application.name = ${替换为实际基座应用名}
```

#### 修改主 pom.xml

```xml
<properties>
    <sofa.ark.version>2.2.14</sofa.ark.version>
    <!-- 不同jdk版本，使用不同koupleless版本，参考：https://koupleless.io/docs/tutorials/module-development/runtime-compatibility-list/#%E6%A1%86%E6%9E%B6%E8%87%AA%E8%BA%AB%E5%90%84%E7%89%88%E6%9C%AC%E5%85%BC%E5%AE%B9%E6%80%A7%E5%85%B3%E7%B3%BB -->
    <koupleless.runtime.version>1.3.1</koupleless.runtime.version>
</properties>
```

```xml
<dependency>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-base-starter</artifactId>
    <version>${koupleless.runtime.version}</version>
</dependency>

<!-- 如果使用了 springboot web，则加上这个依赖，详细查看https://www.sofastack.tech/projects/sofa-boot/sofa-ark-multi-web-component-deploy/ -->
<dependency>
    <groupId>com.alipay.sofa</groupId>
    <artifactId>web-ark-plugin</artifactId>
    <version>${sofa.ark.version}</version>
</dependency>

<!-- 为了让三方依赖和 koupleless 模式适配，需要引入以下构建插件 -->
<build>
    <plugins>
        <plugin>
            <groupId>com.alipay.sofa.koupleless</groupId>
            <artifactId>koupleless-base-build-plugin</artifactId>
            <version>${koupleless.runtime.version}</version>
            <executions>
                <execution>
                    <goals>
                        <goal>add-patch</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

### 其它版本接入

#### SpringBoot 2.1.9 升级为基座

在修改以上配置后，还需额外修改以下配置：

##### 主 pom 引入 sdk

```xml
<!-- 注意放在构建 pom 的第一个依赖位置 -->
<dependency>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-base-starter</artifactId>
    <version>${koupleless.runtime.version}</version>
</dependency>
<!-- 如果使用了 springboot web，则加上这个依赖，详细查看https://www.sofastack.tech/projects/sofa-boot/sofa-ark-multi-web-component-deploy/ -->
<dependency>
    <groupId>com.alipay.sofa</groupId>
    <artifactId>web-ark-plugin</artifactId>
    <version>${sofa.ark.version}</version>
</dependency>
<dependency>
    <groupId>com.github.oshi</groupId>
    <artifactId>oshi-core</artifactId>
    <version>3.9.1</version>
</dependency>

<!-- 为了让三方依赖和 koupleless 模式适配，需要引入以下构建插件 -->
<build>
    <plugins>
        <plugin>
            <groupId>com.alipay.sofa.koupleless</groupId>
            <artifactId>koupleless-base-build-plugin</artifactId>
            <version>${koupleless.runtime.version}</version>
            <executions>
                <execution>
                    <goals>
                        <goal>add-patch</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

##### 修改基座启动类

在 koupleless 版本 1.1.0 及以上，无需改动。

在 koupleless 版本 1.1.0 以下，在基座 Springboot 启动类的注解 `@SpringBootApplication` 中，排除 HealthAutoConfiguration 类，如下：

```java
import com.alipay.sofa.koupleless.arklet.springboot.starter.health.HealthAutoConfiguration;
@SpringBootApplication(exclude = { HealthAutoConfiguration.class })
public class BaseApplication {
    public static void main(String[] args) {
        SpringApplication.run(BaseApplication.class, args);
    }
}
```

### 启动验证

基座应用能正常启动即表示验证成功！

<br/>
<br/>
