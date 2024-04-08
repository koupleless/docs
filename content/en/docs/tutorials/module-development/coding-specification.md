---
title: Coding Standards
date: 2024-01-25T10:28:32+08:00
description: Koupleless Coding Standards
weight: 100
---

## Basic Specifications
1. The list of middleware clients officially verified and compatible in Koupleless modules can be found [here](/docs/tutorials/module-development/runtime-compatibility-list). Any middleware client can be used in the base.
   <br/><br/>
2. If you need to use `System.setProperties()` and `System.getProperties()` in module without sharing with the base, please add `MultiBizProperties.initSystem()` in the main method of the base platform. For details, refer to [samples](https://github.com/koupleless/samples/blob/main/springboot-samples/config/apollo/base/src/main/java/com/alipay/sofa/config/apollo/ApolloApplication.java).
3. If the module hot unload capability is used, you can use the following API to decorate ExecutorService (typical for various thread pools), Timer, and Thread objects declared in the module code. When the module is unloaded, 
   the Koupleless Arklet client will attempt to automatically clean up the decorated ExecutorService, Timer, and Thread:
   <br/>
    - In the module code, decorate the ExecutorService that needs to be automatically cleaned up. The underlying code will call the shutdownNow and awaitTermination interfaces of the ExecutorService object, attempting to gracefully release threads (not guaranteed to release 100%, such as when threads are waiting). The specific usage is:
      ```
      ShutdownExecutorServicesOnUninstallEventHandler.manageExecutorService(myExecutorService);
      ```
      Where myExecutorService needs to be a subtype of ExecutorService.
      You can also configure com.alipay.koupleless.executor.cleanup.timeout.seconds in the module's SpringBoot or SOFABoot properties file to specify the graceful waiting time for thread pool awaitTermination.
      <br/><br/>
    - In the module code, decorate the Timer that needs to be automatically cleaned up. The underlying code will call the cancel method of the Timer object. The specific usage is:
      ```
      CancelTimersOnUninstallEventHandler.manageTimer(myTimer);
      ```
      <br/><br/>
    - In the module code, decorate the Thread that needs to be automatically cleaned up. The underlying code will forcibly call the stop method of the Thread object. The specific usage is:
      ```
      ForceStopThreadsOnUninstallEventHandler.manageThread(myThread);
      ```
      Note: JDK does not recommend forcibly stopping threads, as it may cause unexpected problems such as forcibly releasing locks on threads. Unless you are sure that forcibly closing threads will not cause any related issues, use it with caution.
      <br/><br/>
4. If the module hot unload capability is used and there are other resources or objects that need to be cleaned up, you can listen for the Spring **ContextClosedEvent** event and clean up the necessary resources and objects in the event handler function.
   You can also specify their **destroy-method** at the place where Beans are defined in Spring XML. When the module is unloaded, Spring will automatically execute the **destroy-method**.
   <br/><br/>
5. When the base is started, all modules will be deployed. Therefore, when coding the base, make sure to be compatible with all modules, otherwise the base deployment will fail. If there are incompatible changes that cannot be bypassed (usually there will be many incompatible changes between the base and modules during the module splitting process), 
   please refer to [Incompatible Base and Module Upgrade](/docs/tutorials/module-operation/incompatible-base-and-module-upgrade)。
   <br/>

## Knowledge Points
[Module Slimming](../module-slimming) (Important)<br />
[Module-to-Module and Module-to-Base Communication](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-jvm/)  (Important)<br />
[Module Testing](../module-debug)  (Important)<br />
[Reuse Base Interceptors in Modules](../reuse-base-interceptor)<br />
[Reuse Base Data Sources in Modules](../reuse-base-datasource)<br />
[Introduction to the Principle of Class Delegation Between Base and Modules](/docs/introduction/architecture/class-delegation-principle)
[Multiple Configurations for Modules](../module-multi-application-properties)

<br/>
<br/>
