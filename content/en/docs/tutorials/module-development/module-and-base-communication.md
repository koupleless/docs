---
title: Module Communication Module to Module and Module to Base Communication
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Communication Module to Module and Module to Base Communication
weight: 300
---

Between the base and modules, and among modules, there is spring context isolation, meaning their beans do not conflict and are not visible to each other. However, in many scenarios such as the middleware mode and independent module mode, there are situations where the base calls the module, the module calls the base, and modules call each other.
Currently, three methods are supported for invocation: @AutowiredFromBiz, @AutowiredFromBase, and SpringServiceFinder method calls. Note that the usage of these three methods varies.

# Spring Environment

## Importing Dependencies in Modules

```xml
<dependency>
    <groupId>com.alipay.koupleless</groupId>
    <artifactId>koupleless-app-starter</artifactId>
    <version>0.5.6</version>
    <scope>provided</scope>
</dependency>
```

## Base Calling Module

Only SpringServiceFinder can be used.

```java
@RestController
public class SampleController {

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String hello() {

        Provider studentProvider = SpringServiceFinder.getModuleService("biz", "0.0.1-SNAPSHOT",
                "studentProvider", Provider.class);
        Result result = studentProvider.provide(new Param());

        Provider teacherProvider = SpringServiceFinder.getModuleService("biz", "0.0.1-SNAPSHOT",
                "teacherProvider", Provider.class);
        Result result1 = teacherProvider.provide(new Param());
        
        Map<String, Provider> providerMap = SpringServiceFinder.listModuleServices("biz", "0.0.1-SNAPSHOT",
                Provider.class);
        for (String beanName : providerMap.keySet()) {
            Result result2 = providerMap.get(beanName).provide(new Param());
        }

        return "hello to ark master biz";
    }
}
```

## Module Calling Base

### Method 1: Annotation @AutowiredFromBase

```java
@RestController
public class SampleController {

    @AutowiredFromBase(name = "sampleServiceImplNew")
    private SampleService sampleServiceImplNew;

    @AutowiredFromBase(name = "sampleServiceImpl")
    private SampleService sampleServiceImpl;

    @AutowiredFromBase
    private List<SampleService> sampleServiceList;

    @AutowiredFromBase
    private Map<String, SampleService> sampleServiceMap;

    @AutowiredFromBase
    private AppService appService;

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String hello() {

        sampleServiceImplNew.service();

        sampleServiceImpl.service();

        for (SampleService sampleService : sampleServiceList) {
            sampleService.service();
        }

        for (String beanName : sampleServiceMap.keySet()) {
            sampleServiceMap.get(beanName).service();
        }

        appService.getAppName();

        return "hello to ark2 dynamic deploy";
    }
}
```

### Method 2: Programming API SpringServiceFinder

```java
@RestController
public class SampleController {

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String hello() {

        SampleService sampleServiceImplFromFinder = SpringServiceFinder.getBaseService("sampleServiceImpl", SampleService.class);
        String result = sampleServiceImplFromFinder.service();
        System.out.println(result);

        Map<String, SampleService> sampleServiceMapFromFinder = SpringServiceFinder.listBaseServices(SampleService.class);
        for (String beanName : sampleServiceMapFromFinder.keySet()) {
            String result1 = sampleServiceMapFromFinder.get(beanName).service();
            System.out.println(result1);
        }

        return "hello to ark2 dynamic deploy";
    }
}
```

## Module Calling Module

Referencing the module calling the base, the annotation is used with @AutowiredFromBiz and the programming API is supported by SpringServiceFinder.

### Method 1: Annotation @AutowiredFromBiz

```java
@RestController
public class SampleController {

    @AutowiredFromBiz(bizName = "biz", bizVersion = "0.0.1-SNAPSHOT", name = "studentProvider")
    private Provider studentProvider;

    @AutowiredFromBiz(bizName = "biz", name = "teacherProvider")
    private Provider teacherProvider;

    @AutowiredFromBiz(bizName = "biz", bizVersion = "0.0.1-SNAPSHOT")
    private List<Provider> providers;

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String hello() {

        Result provide = studentProvider.provide(new Param());

        Result provide1 = teacherProvider.provide(new Param());

        for (Provider provider : providers) {
            Result provide2 = provider.provide(new Param());
        }

        return "hello to ark2 dynamic deploy";
    }
}
```

### Method 2: Programming API SpringServiceFinder

```java
@RestController
public class SampleController {

    @RequestMapping(value = "/", method = RequestMethod.GET)
    public String hello() {

        Provider teacherProvider1 = SpringServiceFinder.getModuleService("biz", "0.0.1-SNAPSHOT", "teacherProvider", Provider.class);
        Result result1 = teacherProvider1.provide(new Param());

        Map<String, Provider> providerMap = SpringServiceFinder.listModuleServices("biz", "0.0.1-SNAPSHOT", Provider.class);
        for (String beanName : providerMap.keySet()) {
            Result result2 = providerMap.get(beanName).provide(new Param());
        }

        return "hello to ark2 dynamic deploy";
    }
}
```

[Complete Example](https://github.com/koupleless/samples/tree/main/)

# SOFABoot Environment

[Please refer to this documentation](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-jvm/)

<br/>
<br/>
