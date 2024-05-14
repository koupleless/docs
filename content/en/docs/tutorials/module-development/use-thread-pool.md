---
title: Thread Pool Usage
date: 2024-01-25T10:28:32+08:00
description: Koupleless Thread Pool Usage
weight: 110
---
# Background
Due to the execution thread's Classloader in a thread pool being different from the Classloader used when creating the task, it's easy to encounter a ClassNotFoundException when the thread pool executes the task.

To maintain consistency between the Classloader used during the task execution in the thread pool and the Classloader used at the creation of the task, we need to make some modifications to the thread pool.

There are 4 common ways to use thread pools in Java:
1. Directly create thread tasks and submit them to the thread pool, such as: Runnable, Callable, ForkJoinTask
2. Customize ThreadPoolExecutor and submit tasks to ThreadPoolExecutor
3. Use ThreadPoolExecutor or ScheduledThreadPoolExecutor from the third-party libraries. 
4. Create thread pools through Executors and submit tasks to ExecutorService, ScheduledExecutorService, ForkJoinPool 
5. For SpringBoot users, submit tasks to ThreadPoolTaskExecutor, SchedulerThreadPoolTaskExecutor
This article will introduce how each method is used on Koupleless.

# How to Use

## 1. Directly create thread tasks and submit them to the thread pool

The original method:
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

If the threadPool remains unchanged, then it is necessary to wrap Runnable as KouplelessRunnable and Callable as KouplelessCallable, as follows:

```java
// Runnable
// wrap function:
threadPool.execute(KouplelessRunnable.wrap(new Runnable(){
    public void run() {
        //do something
    }
});

// or new KouplelessRunnable:
threadPool.execute(new KouplelessRunnable(){
    public void run() {
        //do something
    }
});

// Runnable
// wrap function:
threadPool.execute(KouplelessCallable.wrap(new Callable<String>(){
    public String call() {
        //do something
        return "mock";
    }
});

// or new KouplelessRunnable
threadPool.execute(new KouplelessCallable<String>(){
    public String call() {
        //do something
        return "mock";
    }
});
```

## 2. Customize ThreadPoolExecutor

The original method:
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

To keep Runnable and Callable unchanged, there are two ways to modify:
1. Change threadPool to KouplelessThreadPoolExecutor
2. Or use threadPoolAdapter to wrap threadPool.

First, let's take an example of the first modification method: change threadPool to KouplelessThreadPoolExecutor. As follows:

```java
// modify ThreadPoolExecutor as KouplelessThreadPoolExecutor
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

Then, illustrate the second method of modification: using threadPoolAdapter. As follows:
```java
ThreadPoolExecutor threadPool = new KouplelessThreadPoolExecutor(5, 5, 0L, TimeUnit.MILLISECONDS, new LinkedBlockingQueue<Runnable>());

// adapter threadPool as KouplelessExecutorServiceAdaptor
ExecutorService executor        = new KouplelessExecutorServiceAdaptor(threadPool);

// use executor to execute task
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

## 3. Use ThreadPoolExecutor or ScheduledThreadPoolExecutor from the third-party libraries.

The original method:
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

To keep Runnable and Callable unchanged, it is necessary to use an adapter to wrap ExecutorService and ScheduledExecutorService, as follows:

```java
ThreadPoolExecutorA executorService = new ThreadPoolExecutorA();

// wrap executorService as KouplelessExecutorServiceAdaptor
ExecutorService executor        = new KouplelessExecutorServiceAdaptor(executorService);

// use executor to execute tasks
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

ScheduledThreadPoolExecutorA scheduledExecutorService = new ScheduledThreadPoolExecutorA();

// wrap scheduledExecutorService as KouplelessScheduledExecutorServiceAdaptor
ScheduledExecutorService scheduledExecutor = new KouplelessScheduledExecutorServiceAdaptor(scheduledExecutorService);

// use scheduledExecutor to execute tasks
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



## 4. Create thread pools through Executors


The original method:
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

ScheduledExecutorService scheduledExecutorService = new SingleThreadScheduledExecutor();

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

To keep Runnable and Callable unchanged, it is necessary to use an adapter to wrap ExecutorService and ScheduledExecutorService, as follows:

```java
ExecutorService executorService = Executors.newFixedThreadPool(6);

// wrap executorService as KouplelessExecutorServiceAdaptor
ExecutorService executor        = new KouplelessExecutorServiceAdaptor(executorService);

// use executor to execute tasks
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

ScheduledExecutorService scheduledExecutorService = new SingleThreadScheduledExecutor();

// wrap scheduledExecutorService as KouplelessScheduledExecutorServiceAdaptor
ScheduledExecutorService scheduledExecutor = new KouplelessScheduledExecutorServiceAdaptor(scheduledExecutorService);

// use scheduledExecutor to execute tasks
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

## 5. For SpringBoot users, submit tasks to ThreadPoolTaskExecutor, SchedulerThreadPoolTaskExecutor
Due to koupeless having already adapted ThreadPoolTaskExecutor and SchedulerThreadPoolTaskExecutor for springboot (2.3.0-2.7.x), they can be used directly.
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