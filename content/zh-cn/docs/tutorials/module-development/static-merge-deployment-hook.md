---
title: 4.3.12 静态合并部署扩展接口
date: 2024-01-25T10:28:32+08:00
description: Koupleless 模块静态合并部署Hook
weight: 701
---

## 介绍

SOFAArk 提供了静态合并部署能力，**Base 包（基座应用）** 在启动时，可以启动已经构建完成的 **Biz 包（模块应用)**，支持本地目录、本地文件URL和远程URL，见[静态合并部署](./static-merge-deployment.md)。

在此之外，SOFAArk 还提供了静态合并部署的扩展接口，开发者可以自定义获取 **Biz 包（模块应用)** 的方式。

## 使用方式

### 前置条件

要求：
- jdk8
  - sofa.ark.version >= 2.2.12
  - koupleless.runtime.version >= 1.2.3
- jdk17/jdk21
  - sofa.ark.version >= 3.1.5
  - koupleless.runtime.version >= 2.1.4

### Ark 扩展机制原理

见 [Ark 扩展机制原理介绍](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-extension/)

### AddBizToStaticDeployHook 使用方式

1.  基座/基座二方包中，实现 AddBizToStaticDeployHook 接口，以 AddBizInResourcesHook 为例，如下：
```java
@Extension("add-biz-in-resources-to-deploy")
public class AddBizInResourcesHook implements AddBizToStaticDeployHook {
    @Override
    public List<BizArchive> getStaticBizToAdd() throws Exception {
        List<BizArchive> archives = new ArrayList<>();
        // ...
        archives.addAll(getBizArchiveFromResources());
        return archives;
    }

    protected List<BizArchive> getBizArchiveFromResources() throws Exception {
        // ... 读取资源中的Ark Biz包
        return archives;
    }
}
```

2. 配置 spi 配置

在 resources 目录下添加 /META-INF/services/sofa-ark/ 目录，再在 /META-INF/services/sofa-ark/ 添加一个 名为 com.alipay.sofa.ark.spi.service.biz.AddBizToStaticDeployHook 的文件，文件里面内容为 hook 类的全限定名：
```text
com.alipay.sofa.ark.support.common.AddBizInResourcesHook
```

重新打包基座。

3. 启动基座，并配置静态合并部署参数

JVM 添加参数，配置： `-Dsofa.ark.embed.static.biz.enable=true`
