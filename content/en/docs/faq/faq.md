---
title: FAQ List
date: 2024-01-25T10:28:32+08:00
weight: 10
---

## Usage Issue
### arklet Installation Issue
#### Symptom
Unable to install arkctl using go install command. The command executed is as follows:
```shell
go install koupleless.alipay.com/koupleless/v1/arkctl@latest
```
The error message received is as follows:
```text
go: koupleless.alipay.com/koupleless/v1/arkctl@latest: module koupleless.alipay.com/koupleless/v1/arkctl: Get "https://proxy.golang.org/koupleless.alipay.com/koupleless/v1/arkctl/@v/list": dial tcp 142.251.42.241:443: i/o timeout
```
#### Solution
As arkctl is present as a subdirectory of koupleless, it cannot be directly installed using go get. You can download the executable file from [here](https://github.com/koupleless/koupleless/releases/tag/arkctl-release-0.2.0) and refer to the instructions to install arkctl.

## Module Building Issues
### Maven version too low
#### Symptom 
During the build,
- Error: Unable to parse configuration of mojo com.alipay.sofa:sofa-ark-maven-plugin:.*:repackage for parameter excludeArtifactIds
- Error: com.google.inject.ProvisionException: Unable to provision, see the following errors:
- Error: Error injecting: private org.eclipse.aether.spi.log.Logger org.apache.maven.repository.internal.DefaultVersionRangeResolver.logger
- Error: Caused by: java.lang.IllegalArgumentException: Can not set org.eclipse.aether.spi.log.Logger field org.apache.maven.repository.internal.DefaultVersionRangeResolver.logger to org.eclipse.aether.internal.impl.slf4j.Slf4jLoggerFactory

#### Cause 
Maven version is too low

#### Solution

Upgrade to version 3.6.1 or above

## Configuration Issues
### application.properties configuration
#### Symptom
spring.application.name must be configured

#### Cause
spring.application.name is not configured in application.properties

#### Solution
Configure spring.application.name in application.properties

### Failure of SOFABoot base or module startup due to AutoConfiguration
#### Symptom
An error is reported: "The following classes could not be excluded because they are not auto-configuration classes: org.springframework.boot.actuate.autoconfigure.startup.StartupEndpointAutoConfiguration".
#### Cause
SOFABoot needs to import spring-boot-actuator-autoconfiguration correctly because it defines "spring.exclude.autoconfiguration" as `org.springframework.boot.actuate.autoconfigure.startup.StartupEndpointAutoConfiguration` in the code [here](https://github.com/sofastack/sofa-boot/blob/82d0ca388b433ac18fb44704e2f2b280fda1b760/sofa-boot-project/sofa-boot/src/main/java/com/alipay/sofa/boot/env/SofaBootEnvironmentPostProcessor.java#L88). An error will be reported if the class cannot be found during startup.
#### Solution
Import sprign-boot-actuator-autoconfiguration in the base or module.

## Runtime Issues

### koupleless dependency missing
#### Phenomenon
- When installing the module, it throws an error com.alipay.sofa.ark.exception.ArkLoaderException: \[ArkBiz Loader\] module1:1.0-SNAPSHOT: can not load class: com.alipay.sofa.koupleless.common.spring.KouplelessApplicationListener
#### Cause
koupleless dependency missing
#### Solution
Please add the following dependency in the module:
```xml
<dependency>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-app-starter</artifactId>
    <version>${koupleless.runtime.version}</version>
</dependency>
```
Alternatively, upgrade koupleless to the latest version.

### koupleless version is too low
#### Symptom
- Module installation error: Master biz environment is null
- Module static merge deployment cannot find module package from the specified directory
#### Solution
Upgrade koupleless version to the latest version
```xml
<dependency>
    <groupId>com.alipay.sofa.koupleless</groupId>
    <artifactId>koupleless-app-starter</artifactId>
    <version>${latest_version}</version>
</dependency>
```

### Class missing
#### Symptom
- Error: java.lang.ClassNotFoundException
- Error: java.lang.NoClassDefFoundError

#### Cause
Module/Foundation cannot find the class

#### Solution
 Investigate the module class missing and foundation class missing.
### Module class missing
#### Symptom
Error: ArkBiz Loader.*can not load class

#### Cause
The module is missing the dependency for the corresponding class!

#### Solution
 Check if the module contains the dependency for the class. If not, add the corresponding dependency.
### Foundation class missing
#### Symptom
Error: ArkLoaderException: Post find class .* occurs an error via biz ClassLoaderHook

#### Cause
The class delegate to the foundation loading is not found in the foundation, or the dependency version is incorrect.

#### Solution
 Add the corresponding dependency to the foundation or modify the dependency version.
### Module depends on the class with multiple different sources
Symptom:
- Error: java.lang.LinkageError
- Error: java.lang.ClassCastException
- Error: previously initiated loading for a different type with name

#### Cause
The class introduced multiple identical dependencies between the foundation and the module, and the loaded class may come from different ClassLoader.

#### Solution
 In the main pom of the module, set the package where the class is located to provided. (Ensure module slimming and dependency management between the foundation and the module.)
### Method missing
#### Symptom
Error: java.lang.NoSuchMethodError

#### Cause
java.lang.NoSuchMethodError is thrown, indicating a possible jar conflict or unloaded dependency.

#### Solution
 Check for jar conflicts or unloaded dependencies.
### Module directly uses foundation's datasource
#### Symptom
Error: No operation is allowed after dataSource is closed

#### Cause
The module directly uses the dataSource in the foundation, and the unloading of the module causes the foundation's dataSource to close.

#### Solution
 The dataSource has been closed. Check if the module directly uses the dataSource in the foundation through bean acquisition.
### Module's rest service webContextPath conflict
#### Symptom
Error: org.springframework.context.ApplicationContextException: Unable to start web server; nested exception is java.lang.IllegalArgumentException: Child name xxx is not unique

#### Cause
webContextPath conflict

#### Solution
 Check if other modules have set the same webContextPath
### Incorrect JVM parameter configuration
#### Symptom
Error: Error occurred during initialization of VM

#### Cause
Error occurred during initialization of VM, generally indicating a problem with JVM parameter configuration.

#### Solution
 Check JVM parameter configuration on the user side
### Bean configuration issues
Symptom:
- Error: org.springframework.beans.factory.parsing.BeanDefinitionParsingException: Configuration problem: Invalid bean definition with name
- Error: java.lang.IllegalArgumentException: JVM Reference
- Error creating bean with name
- Error: BeanDefinitionStoreException: Invalid bean definition with name
- Error: org.springframework.beans.FatalBeanException: Bean xx has more than one interface
- Error: No qualifying bean of type
- Error: BeanDefinitionStoreException: Invalid bean definition with name

#### Cause
Bean configuration issues in the project

#### Solution

1. Check if the bean is incorrectly configured in the XML or if there are dependency issues.
2. Bean initialization/definition exception, please check the business logic.
### Duplicate Spring Bean definition
#### Symptom
Error: There is already xxx bean

#### Cause
Business coding issue: duplicate bean definition

#### Solution
 Check the business-side code
### XML configuration issues
#### Symptom
Error: Error parsing XPath XXX #### Cause
java.io.IOException: Could not find resource

#### Cause
XML file parsing failed, unable to find the corresponding dependency configuration

#### Solution
 Investigate the parsing failure issue
### JMX configuration issues
#### Symptom
Error: org.springframework.jmx.export.UnableToRegisterMBeanException: Unable to register MBean

#### Cause
JMX needs to manually configure the application name

#### Solution
 Add -Dspring.jmx.default-domain=${spring.application.name} as a startup parameter to the foundation
### Dependency configuration
#### Symptom
Error: Dependency satisfaction failed XXX java.lang.NoClassDefFoundError

#### Cause
Jar dependency issue, class not found

#### Solution
 Check jar dependencies, if the project depends on incorrect jar packages, make corrections
### SOFA JVM Service lookup failure
Symptom:
- Error: can not find corresponding jvm service
- Error: JVM Reference XXX can not find the corresponding JVM service

#### Cause
The JVM service referenced by JVM Reference is not found


#### Solution
 Check if the business code is correct and if the corresponding service exists.
### Insufficient memory
Symptom:
- Error: Insufficient space for shared memory
- Error: java.lang.OutOfMemoryError: Metaspace

#### Cause
Insufficient memory or memory overflow

#### Solution
 Replace or restart the machine
### Hessian version conflict
#### Symptom
Error: Illegal object reference

#### Cause
Hessian version conflict

#### Solution
 Use mvn dependency:tree to view the dependency tree and resolve the conflict dependencies

### guice version is too low

Symptom: Caused by: java.Lang.ClassNotFoundException: com.google.inject.multibindings.Multibinder

![guice_version_incompatibility.png](/docs/faq/imgs/guice_version_incompatibility.png)

#### Cause
The version of Guice in the user's project is not compatible with the version used in Koupleless, and it is an older version.

#### Solution
Upgrade the Guice version to a newer version, such as:

```xml
<dependency>
    <groupId>com.google.inject</groupId>
    <artifactId>guice</artifactId>
    <version>6.0.0</version>
</dependency>
```

### Need to slim down the module
#### Symptom
- Error java.lang.IllegalArgumentException: Cannot instantiate interface org.springframework.context.ApplicationListener: com.alipay.sofa.koupleless.common.spring.KouplelessApplicationListener
#### Reason
The module should import the springboot dependency in a provided manner.
#### Solution
Slim down the module, refer to here: [Module Slimming](/docs/tutorials/module-development/module-slimming)

### SOFABoot health check failure
#### Symptom
Error: HealthCheck Failed

#### Cause
SOFABoot project HealthCheck failure

#### Solution
 Investigate the specific cause of the failure on the user side.

### When the module shares the library with the base, the module starts the logic of the base.
#### Symptom
For example, if the base introduces druid but the module does not, according to the design, the module should not need to initialize dataSource. However, if the module also initializes dataSource, this behavior is not as expected and may cause errors.
#### Solution
1. Ensure that the module can be built independently, i.e., can execute `mvn clean package` in the module's directory without errors.
2. Upgrade the koupleless version to the latest version 0.5.7.

### Unable to Initialize EnvironmentPostProcessor on Module Startup
#### Phenomenon
During the module startup, an error message like the following is reported:

```
Unable to instantiate com.baomidou.mybatisplus.autoconfigure.SafetyEncryptProcessor [org.springframework.boot.environment.EnvironmentPostProcessor]
```

#### Solution
Specify the ClassLoader of the ResourceLoader when launching Spring Boot in the module's main method.

```java
SpringApplicationBuilder builder = new SpringApplicationBuilder(Biz1Application.class);
// set the biz to use the resource loader.
ResourceLoader resourceLoader = new DefaultResourceLoader(
    Biz1Application.class.getClassLoader());
builder.resourceLoader(resourceLoader);
builder.build().run(args);
```

### Error occurred when closing the base and shutting down the Tomcat server
#### Symptoms
When the base is closed, an error message "Unable to stop embedded Tomcat" is displayed.
#### Causes
When the base is closed, Tomcat has its own shutdown logic. However, koupleless adds additional shutdown logic, causing the base to attempt a second shutdown. This message is just a warning and does not affect the normal shutdown of the base.
#### Solution
No action is required.

```markdown
### Module compile includes Tomcat causing startup error `Caused by: java.lang.Error: factory already defined`
#### Phenomenon
You can see the detailed error stack trace [here](https://github.com/sofastack/sofa-ark/issues/185).
#### Reason
The module compile introduces Tomcat, and upon module startup, Tomcat is reinitialized. At this time, `TomcatURLStreamHandlerFactory` tries to register itself via `URL::setURLStreamHandlerFactory` to URL, but since the base has already registered once, the duplicated registration throws an error. For more details, see [here](https://github.com/spring-projects/spring-boot/issues/10529).
#### Solution
Resolve the issue by setting `TomcatURLStreamHandlerFactory.disable()` in the code.
```
