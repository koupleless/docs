---
title: 线程池使用
date: 2024-01-25T10:28:32+08:00
description: Koupleless 线程池使用
weight: 110
---

# 背景
当**多个模块**或**模块和基座**共用一个线程池时，由于线程池执行任务使用的线程 Classloader 可能和创建该任务时使用的 Classloader 不一致，从而导致线程池执行任务时出现 ClassNotFound 异常。

因此，当多个模块或模块和基座共用一个线程池时，为了保持线程池执行任务时使用的 Classloader 和创建该任务时使用的 Classloader 一致，我们需要对线程池做一些修改。

⚠️注意：各模块使用各自的线程池，不会有此问题。

java常用的线程池使用方式有4种：
1. 直接创建线程任务，提交到线程池中，如：Runnable, Callable, ForkJoinTask
2. 自定义ThreadPoolExecutor，并提交到 ThreadPoolExecutor
3. 通过 Executors 创建线程池，并提交到 ExecutorService, ScheduledExecutorService, ForkJoinPool
4. SpringBoot 用户提交到 ThreadPoolTaskExecutor, SchedulerThreadPoolTaskExecutor

本文将介绍每一种方式在 Koupleless 上的使用方式。

# 使用方式

## 1. 直接创建线程任务，提交到线程池中
原来的方式：
```java

threadPool.execute(new Runnable(){
    public void run() {
        //do something
    }
});


threadPool.execute(new Callable<String>(){
public String call() {
        //do something
        return "mock";
 }
});
```

如果保持 threadPool 不变，则需要将 Runnable 包装成 KouplelessRunnable，将 Callable 包装成 KouplelessCallable，如下：

```java
// Runnable
// wrap方法
threadPool.execute(KouplelessRunnable.wrap(new Runnable(){
    public void run() {
        //do something
    }
});

// 或者直接new KouplelessRunnable
threadPool.execute(new KouplelessRunnable(){
    public void run() {
        //do something
    }
});

// Runnable
// wrap方法
threadPool.execute(KouplelessCallable.wrap(new Callable<String>(){
    public String call() {
        //do something
        return "mock";
    }
});

// 或者直接new KouplelessRunnable
threadPool.execute(new KouplelessCallable<String>(){
    public String call() {
        //do something
        return "mock";
    }
});
```

## 2. 自定义ThreadPoolExecutor

原来的方式：
```java
ThreadPoolExecutor threadPool = new ThreadPoolExecutor(5, 5, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());

threadPool.execute(new Runnable(){
    public void run() {
        //do something
    }
});


threadPool.execute(new Callable<String>(){
public String call() {
        //do something
        return "mock";
 }
});
```

如果要保持 Runnable 和 Callable 不变，则有两种改造方式：
1. 将 threadPool 修改为 KouplelessThreadPoolExecutor
2. 或者使用 kouplelessExecutorService。

首先，举例第一种改造方式：将 threadPool 修改为 KouplelessThreadPoolExecutor。如下：
```java
// 将 ThreadPoolExecutor 修改为 KouplelessThreadPoolExecutor
ThreadPoolExecutor threadPool = new KouplelessThreadPoolExecutor(5, 5, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());

threadPool.execute(new Runnable(){
    public void run() {
        //do something
    }
});


threadPool.execute(new Callable<String>(){
public String call() {
        //do something
        return "mock";
 }
});
```

然后，举例第二种改造方式：使用 kouplelessExecutorService。如下：
```java
// 使用 KouplelessExecutorService
ExecutorService executor        = new KouplelessExecutorService(new ThreadPoolExecutor(5, 5, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>()));

// 用 executor 执行任务
executor.execute(new Runnable(){
    public void run() {
        //do something
    }
});
executor.execute(new Callable<String>(){
public String call() {
        //do something
        return "mock";
 }
});
```

## 3. 使用二方包中的 ThreadPoolExecutor 或 ScheduledThreadPoolExecutor

原来的方式：
```java
ThreadPoolExecutorA executorService = new ThreadPoolExecutorA();

executorService.execute(new Runnable(){
    public void run() {
        //do something
    }
});


executorService.execute(new Callable<String>(){
public String call() {
        //do something
        return "mock";
 }
});

ScheduledThreadPoolExecutorA scheduledExecutorService = new ScheduledThreadPoolExecutorA();

scheduledExecutorService.execute(new Runnable(){
    public void run() {
        //do something
    }
});

scheduledExecutorService.execute(new Callable<String>(){
    public String call() {
        //do something
        return "mock";
    }
});
```

如果要保持 Runnable 和 Callable 不变，则需要使用 kouplelessExecutorService, kouplelessScheduledExecutorService，如下：

```java
// 使用 KouplelessExecutorService
ExecutorService executor        = new KouplelessExecutorService(new ThreadPoolExecutorA());

// 用 executor 执行任务
executor.execute(new Runnable(){
    public void run() {
        //do something
    }
});
executor.execute(new Callable<String>(){
    public String call() {
        //do something
    return "mock";
    }
});


// 使用 KouplelessScheduledExecutorService
ScheduledExecutorService scheduledExecutor = new KouplelessScheduledExecutorService(new ScheduledThreadPoolExecutorA());

// 用 scheduledExecutor 执行任务
scheduledExecutor.execute(new Runnable(){
    public void run() {
        //do something
    }
});
scheduledExecutor.execute(new Callable<String>(){
    public String call() {
        //do something
        return "mock";
    }
});
```



## 4. 通过 Executors 创建线程池


原来的方式：
```java
ExecutorService executorService = Executors.newFixedThreadPool(6);

executorService.execute(new Runnable(){
    public void run() {
        //do something
    }
});


executorService.execute(new Callable<String>(){
public String call() {
        //do something
        return "mock";
 }
});

ScheduledExecutorService scheduledExecutorService = Executors.newSingleThreadScheduledExecutor();

scheduledExecutorService.execute(new Runnable(){
    public void run() {
        //do something
    }
});

scheduledExecutorService.execute(new Callable<String>(){
    public String call() {
        //do something
        return "mock";
    }
});
```

如果要保持 Runnable 和 Callable 不变，则需要使用 kouplelessExecutorService, kouplelessScheduledExecutorService，如下：

```java
// 使用 KouplelessExecutorService
ExecutorService executor        = new KouplelessExecutorService(Executors.newFixedThreadPool(6));

// 用 executor 执行任务
executor.execute(new Runnable(){
    public void run() {
        //do something
    }
});
executor.execute(new Callable<String>(){
    public String call() {
        //do something
    return "mock";
    }
});

// 使用 KouplelessScheduledExecutorService
ScheduledExecutorService scheduledExecutor = new KouplelessScheduledExecutorService(Executors.newSingleThreadScheduledExecutor());

// 用 scheduledExecutor 执行任务
scheduledExecutor.execute(new Runnable(){
    public void run() {
        //do something
    }
});
scheduledExecutor.execute(new Callable<String>(){
    public String call() {
        //do something
        return "mock";
    }
});
```

## 5. SpringBoot 用户提交到 ThreadPoolTaskExecutor, SchedulerThreadPoolTaskExecutor
由于 koupeless 已经对 springboot(2.3.0-2.7.x) 的 ThreadPoolTaskExecutor 和 SchedulerThreadPoolTaskExecutor 做了适配，所以可以直接使用。
```java
@Autowired
private ThreadPoolTaskExecutor threadPoolTaskExecutor;

@Autowired
private SchedulerThreadPoolTaskExecutor schedulerThreadPoolTaskExecutor;

threadPoolTaskExecutor.execute(new Runnable(){
    public void run() {
        //do something
    }
});

schedulerThreadPoolTaskExecutor.execute(new Runnable(){
    public void run() {
        //do something
    }
});
```