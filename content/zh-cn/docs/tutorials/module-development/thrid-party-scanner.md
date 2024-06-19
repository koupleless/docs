---
title: 第三方兼容性扫描
date: 2024-06-19T10:28:32+08:00
weight: 620
---

<div align="center">

[English](./README.md) | 简体中文

</div>

# 为什么我们需要静态代码扫描工具？
koupleless 打破了传统的单进程单应用模型，而采用了单进程多应用模型。
很多第三方库并不支持单进程多应用模型，这就需要我们对第三方库进行兼容性扫描，并进行问题的修复。

## 常见的中间件不兼容模式
### 公共变量互相污染
在单进程多应用模型下，不同应用的公共变量会互相污染，导致应用逻辑混乱，这种污染常常发生在 singleton 对象或 static 变量上。
举个例子，假设有如下代 static 变量：
```java
public class CommonVariable {
    public static String appName = null;
}
```
很有可能，模块 A 修改了 CommonVariable.appName 的值，模块 B 读取了这个值，导致模块 B 的逻辑出现问题。
这是一种常见的兼容性问题。

### ClassLoader 调用异常
在 koupleless 的模式下，不同的模块有不同的 ClassLoader。
显然不同模块 ClassLoader 无法直接调用别的模块的类。
因此，如果 ClassLoader 和对应的类不匹配，就会出现 ClassNotFound 异常。
一个常见的，存在 ClassLoader 不匹配风险的代码如下:
```java
// Class.forName 默认查询 stack 中调用方的 ClassLoader，这很有可能是错误的。
Class.forName("someName");
```

### 资源释放异常
在 koupleless 的模式下，模块会被动态的安装和卸载。
如果在卸载的时候，模块没有正确的释放资源，比如 long running thread 就会导致资源泄露，甚至影响业务。

## 如何解决？
为了解决这些问题，我们提供了一个静态代码扫描工具，用于扫描模块代码中的兼容性问题。
在实现上，我们的静态代码扫描工具基于社区的开源静态代码扫描软件 sonarqube 开发, 并提供了自定义的插件。
对于已有 sonarqube 服务的用户，可以直接安装我们的插件，对模块代码进行扫描。
对于没有 sonarqube 服务的用户，我们提供了一个部署教程。
详情请参考 [静态代码扫描工具](https://github.com/koupleless/scanner)