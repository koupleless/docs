---
title: Incompatible Deployment of Base and Module
date: 2024-01-25T10:28:32+08:00
description: Koupleless Incompatible Deployment of Base and Module
weight: 300
draft: true
---

## Step 1
Modify the code of both the base and the module, then build the base into a new version of the image and the module into a new version of the code package (in Java, it's a JAR file).

## Step 2
Modify the ModuleDeployment.spec.template.spec.module.url for the module to point to the new module code package.

## Step 3
Use K8S Deployment to deploy the base to the new version of the image (which triggers the replacement or restart of the base container). When the base container starts, it will pull the latest module code package address from ModuleDeployment, thereby achieving the incompatible change between the base and the module (i.e., simultaneous deployment).

<br/>
<br/>
