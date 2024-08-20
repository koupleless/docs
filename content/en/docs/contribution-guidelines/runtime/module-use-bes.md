---
title: Module Use Bes
date: 2024-01-25T10:28:32+08:00
weight: 400
draft: false
---

# koupleless-adapter-bes

koupleless-adapter-bes is used to adapt to the BaoLande (BES) container, the warehouse address is [koupleless-adapter-bes](https://github.com/chenjian6824/koupleless-adapter-bes) (thanks to the community student Chen Jian for his contribution).

The project is currently only verified in BES 9.5.5.004 version, and other versions need to be verified by themselves, and necessary adjustments need to be made according to the same logic.

If multiple BIZ modules do not need to use the same port to publish services, only need to pay attention to the precautions mentioned in the installation dependency section below, and do not need to introduce the dependencies related to this project.

## Quick Start

### 1. Install Dependencies

First, make sure that BES-related dependencies have been imported into the maven repository.
(There is a key point here. Due to the conflicting package structure of BES's dependency package with the recognition mechanism of the koupleless 2.2.9 project, users need to add the prefix sofa-ark- to the BES's dependency package by themselves, and the specific recognition mechanism can refer to koupleless' com.alipay.sofa.ark.container.model. BizModel class)

The reference import script is as follows:

```shell
mv XXX/BES-EMBED/bes-lite-spring-boot-2.x-starter-9.5.5.004.jar XXX/BES-EMBED/sofa-ark-bes-lite-spring-boot-2.x-starter-9.5.5.004.jar
mvn install:install-file -Dfile=XXX/BES-EMBED/sofa-ark-bes-lite-spring-boot-2.x-starter-9.5.5.004.jar -DgroupId=com.bes.besstarter -DartifactId=sofa-ark-bes-lite-spring-boot-2.x-starter -Dversion=9.5.5.004 -Dpackaging=jar
mvn install:install-file -Dfile=XXX/BES-EMBED/bes-gmssl-9.5.5.004.jar -DgroupId=com.bes.besstarter -DartifactId=bes-gmssl -Dversion=9.5.5.004 -Dpackaging=jar
mvn install:install-file -Dfile=XXX/BES-EMBED/bes-jdbcra-9.5.5.004.jar -DgroupId=com.bes.besstarter -DartifactId=bes-jdbcra -Dversion=9.5.5.004 -Dpackaging=jar
mvn install:install-file -Dfile=XXX/BES-EMBED/bes-websocket-9.5.5.004.jar -DgroupId=com.bes.besstarter -DartifactId=bes-websocket -Dversion=9.5.5.004 -Dpackaging=jar
```

### 2. Compile and Install the Project Plugin

Enter the bes9-web-adapter directory of the project and execute the mvn install command.

The project will install the "bes-web-ark-plugin" and "bes-sofa-ark-springboot-starter" two modules.

### 3. Use the Project Components

First, according to the koupleless documentation, [upgrade the project to Koupleless Base](https://koupleless.io/docs/tutorials/base-create/springboot-and-sofaboot/)

Then, replace the coordinates mentioned in the dependencies
```
<dependency>
    <groupId>com.alipay.sofa</groupId>
    <artifactId>web-ark-plugin</artifactId>
    <version>${sofa.ark.version}</version>
</dependency>
```
with the coordinates of this project
```
<dependency>
    <groupId>com.alipay.sofa</groupId>
    <artifactId>bes-web-ark-plugin</artifactId>
    <version>2.2.9</version>
</dependency>
<dependency>
   <groupId>com.alipay.sofa</groupId>
   <artifactId>bes-sofa-ark-springboot-starter</artifactId>
   <version>2.2.9</version>
</dependency>
```
Introduce BES-related dependencies (also need to exclude the dependency of tomcat). The reference dependence is as follows:
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

### 4. Finished

After completing the above steps, you can start the project in Koupleless using BES.
