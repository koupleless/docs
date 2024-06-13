---
title: SpringBoot or SOFABoot Upgrade to Base
date: 2024-01-25T10:28:32+08:00
description: Upgrade SpringBoot or SOFABoot to Koupleless Base
weight: 100
---

## Prerequisites

1. SpringBoot version >= 2.1.9.RELEASE (for SpringBoot users)
2. SOFABoot version >= 3.9.0 or SOFABoot >= 4.0.0 (for SOFABoot users)
3. Install maven version >= 3.9.0 locally

Note: SpringBoot version == 2.1.9.RELEASE, see [Upgrade SpringBoot 2.1.9 to Pedestal](#upgrade-springboot-219-to-base)

## Access Steps

### Code and Configuration Modifications

#### Modify application.properties

```properties
# Need to define the application name
spring.application.name = ${Replace with actual base app name}
```

#### Modify the main pom.xml

```xml
<properties>
    <sofa.ark.version>2.2.11</sofa.ark.version>
    <koupleless.runtime.version>1.2.2</koupleless.runtime.version>
</properties>
```

```xml
<!-- Place this as the first dependency in your build pom -->
<dependency>
    <groupId>com.alipay.koupleless</groupId>
    <artifactId>koupleless-base-starter</artifactId>
    <version>${koupleless.runtime.version}</version>
</dependency>

<!-- If using Spring Boot web, add this dependency. For more details, see https://www.sofastack.tech/projects/sofa-boot/sofa-ark-multi-web-component-deploy/ -->
<dependency>
    <groupId>com.alipay.sofa</groupId>
    <artifactId>web-ark-plugin</artifactId>
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

### Integration for Other Versions

#### Upgrade SpringBoot 2.1.9 to Base

After modifying the above configurations, additional modifications are required:

##### Modify main pom.xml

```xml
<!-- Place this as the first dependency in your pom -->
<dependency>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-base-starter</artifactId>
    <version>${koupleless.runtime.version}</version>
</dependency>

<!-- If using Spring Boot web, add this dependency. For more details, see https://www.sofastack.tech/projects/sofa-boot/sofa-ark-multi-web-component-deploy/ -->
<dependency>
    <groupId>com.alipay.sofa</groupId>
    <artifactId>web-ark-plugin</artifactId>
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

##### Modify base startup class

If version of koupleless is equals 1.1.0 or higher than 1.1.0, no need to change。

If version of koupleless is lower than 1.1.0, exclude the HealthAutoConfiguration class in the @SpringBootApplication annotation of the base Springboot startup class, as shown below:

```java
import com.alipay.sofa.koupleless.arklet.springboot.starter.health.HealthAutoConfiguration;
@SpringBootApplication(exclude = { HealthAutoConfiguration.class })
public class BaseApplication {
    public static void main(String[] args) {
        SpringApplication.run(BaseApplication.class, args);
    }
}
```

### Startup Verification

If the foundation application can start normally, the validation is successful!

<br/>
<br/>
