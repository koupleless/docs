---
title: Reusing Base Interceptors
date: 2024-01-25T10:28:32+08:00
description: Koupleless Module Reusing Base Interceptors
weight: 500
---

# Objective
In the base, many Aspect interceptors (Spring interceptors) are defined, and you may want to reuse them in the module. However, the Spring contexts of the module and the base are isolated, which means that Aspect interceptors will not take effect in the module.<br/><br/>

# Solution
Create a proxy object for the original interceptor class, allowing the module to invoke this proxy object. Then, the module initializes this proxy object through the AutoConfiguration annotation. The complete steps and example code are as follows:

### Step 1:
The base code defines an interface that defines the execution method of the interceptor. This interface needs to be visible to the module (referenced in the module dependencies):
```java
public interface AnnotionService {
    Object doAround(ProceedingJoinPoint joinPoint) throws Throwable;
}
```

### Step 2:
Write the specific implementation of the interceptor in the base. This implementation class needs to be annotated with @SofaService (SOFABoot) or @SpringService (SpringBoot, _under construction_): 
```java
@Service
@SofaService(uniqueId = "facadeAroundHandler")
public class FacadeAroundHandler implements AnnotionService {

    private final static Logger LOG = LoggerConst.MY_LOGGER;

    public Object doAround(ProceedingJoinPoint joinPoint) throws Throwable {
        log.info("Start execution")
        joinPoint.proceed();
        log.info("Execution completed")
    }
}
```

### Step 3:
In the module, use the @Aspect annotation to implement an Aspect. SOFABoot injects the FacadeAroundHandler on the base via @SofaReference. <br />**Note**: Do not declare this as a bean, do not add @Component or @Service annotation, only @Aspect annotation is needed.
```java
// Note: Do not declare this as a bean, do not add @Component or @Service annotation
@Aspect
public class FacadeAroundAspect {

    @SofaReference(uniqueId = "facadeAroundHandler")
    private AnnotionService facadeAroundHandler;

    @Pointcut("@annotation(com.alipay.linglongmng.presentation.mvc.interceptor.FacadeAround)")
    public void facadeAroundPointcut() {
    }

    @Around("facadeAroundPointcut()")
    public Object doAround(ProceedingJoinPoint joinPoint) throws Throwable {
        return facadeAroundHandler.doAround(joinPoint);
    }
}
```

### Step 4:
Use the @Configuration annotation to create a Configuration class, and declare the aspectj objects needed by the module as Spring Beans. <br />**Note**: This Configuration class needs to be visible to the module, and related Spring Jar dependencies need to be imported with <scope>provided</scope>.
```java
@Configuration
public class MngAspectConfiguration {
    @Bean
    public FacadeAroundAspect facadeAroundAspect() {
        return new FacadeAroundAspect();
    }
    @Bean
    public EnvRouteAspect envRouteAspect() {
        return new EnvRouteAspect();
    }
    @Bean
    public FacadeAroundAspect facadeAroundAspect() {
        return new FacadeAroundAspect();
    }
    
}
```

### Step 5: 
Explicitly depend on the Configuration class MngAspectConfiguration created in step 4 in the module code.
```java
@SpringBootApplication
@ImportResource("classpath*:META-INF/spring/*.xml")
@ImportAutoConfiguration(value = {MngAspectConfiguration.class})
public class ModuleBootstrapApplication {
    public static void main(String[] args) {
        SpringApplicationBuilder builder = new SpringApplicationBuilder(ModuleBootstrapApplication.class)
        	.web(WebApplicationType.NONE);
        builder.build().run(args);
    }
}
```

<br/>
<br/>
