```
title: Module Use Tongweb
date: 2024-01-25T10:28:32+08:00
weight: 400
draft: false
```

# koupleless-adapter-tongweb
koupleless-adapter-tongweb is used to adapt the Eastern Pass (TongWEB) container, the warehouse address is: [koupleless-adapter-tongweb](https://github.com/chenjian6824/koupleless-adapter-tongweb) (thanks to community student Chen Jian for the contribution).

The project is currently only verified in the tongweb-embed-7.0.E.6_P7 version, and other versions need to be verified by themselves. If necessary, adjustments need to be made according to the same idea.

If multiple BIZ modules do not need to use the same port to publish services, only the precautions mentioned in the following dependency installation chapter need to be considered, and it is not necessary to introduce dependencies related to this project.

## Quick Start
### 1. Install dependencies
First, make sure that TongWEB-related dependencies have been imported into the Maven repository.
(Here is a key point, because the koupleless 2.2.9 project's recognition mechanism for dependency packages conflicts with the package structure of TongWEB, you need to add the sofa-ark- prefix to the TongWEB dependency packages. The specific recognition mechanism can refer to the com.alipay.sofa.ark.container.model.BizModel class of koupleless)

The reference import script is as follows:

```shell
mv XXX/tongweb-spring-boot-starter-7.0.E.6_P7.jar XXX/sofa-ark-tongweb-spring-boot-starter-7.0.E.6_P7.jar
mv XXX/tongweb-tongweb-embed-core-7.0.E.6_P7.jar XXX/sofa-ark-tongweb-embed-core-7.0.E.6_P7.jar
mv XXX/tongweb-lic-sdk-4.5.0.0.jar XXX/sofa-ark-tongweb-lic-sdk-4.5.0.0.jar
mvn install:install-file -DgroupId=com.tongweb.springboot -DartifactId=sofa-ark-tongweb-spring-boot-starter -Dversion=7.0.E.6_P7 -Dfile="XXX/sofa-ark-tongweb-spring-boot-starter-7.0.E.6_P7.jar" -Dpackaging=jar
mvn install:install-file -DgroupId=com.tongweb -DartifactId=sofa-ark-tongweb-embed-core -Dversion=7.0.E.6_P7 -Dfile="XXX/sofa-ark-tongweb-embed-core-7.0.E.6_P7.jar" -Dpackaging=jar
mvn install:install-file -DgroupId=com.tongweb -DartifactId=sofa-ark-tongweb-lic-sdk -Dversion=4.5.0.0 -Dfile="XXX/sofa-ark-tongweb-lic-sdk-4.5.0.0.jar" -Dpackaging=jar
```

### 2. Compile and install the project plugin

Enter the directory tongweb7-web-adapter of this project and execute the mvn install command.

The project will install the "tongweb7-web-ark-plugin" and "tongweb7-sofa-ark-springboot-starter" modules.

### 3. Use the components of this project

First, according to the koupleless documentation, [upgrade the project to the Koupleless base](https://koupleless.io/docs/tutorials/base-create/springboot-and-sofaboot/)

Then, replace the following mentioned dependencies
```
    <dependency>
        <groupId>com.alipay.sofa</groupId>
        <artifactId>web-ark-plugin</artifactId>
        <version>${sofa.ark.version></version>
    </dependency>
```
with the coordinates of this project
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
Introduce TongWEB related dependencies (also need to exclude tomcat dependencies). The reference dependencies are as follows:
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
### 4. Finish
After completing the above steps, you can start the project using TongWEB in Koupleless.
