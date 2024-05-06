---
title: Creating Modules Using Maven Archetype
date: 2024-01-25T10:28:32+08:00
weight: 300
---

We can create Biz Module in three ways, and this article introduces the second one:

1. [Splitting a large application into multiple modules](/docs/contribution-guidelines/split-module-tool/split-module-tool-intro/)
2. [Transforming an existing application into a single module](/docs/tutorials/module-create/springboot-and-sofaboot/)
3. **[Directly creating a module using a scaffold](/docs/tutorials/module-create/init-by-archetype/)**

It's easy to creating a module from maven archetype, all you need to do is input the Maven groupId and artifactId for the archetype in IDEA.

<div style="text-align: center;">
    <img align="center" width="300px" src="/docs/tutorials/imgs/created-by-archetype.png" />
</div>

The module created from this archetype has already integrated the module packaging plugin and automatic slimming configuration. It can be directly packaged as a module and installed on the base, or started independently locally.
