---
title: 4.3.12 Static Merge Deployment Extension SPI
date: 2024-01-25T10:28:32+08:00
description: Koupleless module static merge deployment SPI
weight: 701
---

## Introduction
SOFAArk provides the ability for static merge deployment, where the **Base package (base application)** can start the already built **Biz package (module application)** when it is launched. This supports local directory, local file URL, and remote URL, see [Static Merge Deployment](./static-merge-deployment.md).

In addition to this, SOFAArk also provides an extension interface for static merge deployment, allowing developers to customize the way of obtaining **Biz package (module application)**.

## Usage
### Prerequisites
Requirements:
- jdk8
  - sofa.ark.version >= 2.2.12
  - koupleless.runtime.version >= 1.2.3
- jdk17/jdk21
  - sofa.ark.version >= 3.1.5
  - koupleless.runtime.version >= 2.1.4

### Ark Extension Mechanism Principle
See [Introduction to Ark Extension Mechanism](https://www.sofastack.tech/projects/sofa-boot/sofa-ark-ark-extension/)

### How to Use AddBizToStaticDeployHook
1. In the base/base second-party package, implement the AddBizToStaticDeployHook interface, using AddBizInResourcesHook as an example, as shown below:

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
        // ... read Ark Biz package from resources
        return archives;
    }
}
```

2. Configure the SPI configuration

Add the /META-INF/services/sofa-ark/ directory under the resources directory, and then add a file named com.alipay.sofa.ark.spi.service.biz.AddBizToStaticDeployHook under /META-INF/services/sofa-ark/ with the fully qualified name of the hook class as its content:

```text
com.alipay.sofa.ark.support.common.AddBizInResourcesHook
```

Repackage the base application.

3. Start the base application and configure the static merge deployment parameters

Add the parameter to the JVM configuration: `-Dsofa.ark.embed.static.biz.enable=true`
