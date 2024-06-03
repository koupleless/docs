---
title: Module Using Dubbo
date: 2024-05-24T10:28:32+08:00
weight: 635
---
# Module Interceptor (Filter)
A module can use interceptors defined within itself or those defined on the base. 

⚠️Note: Avoid naming module interceptors the same as those on the base. If the names are identical, the interceptors from the base will be used.
