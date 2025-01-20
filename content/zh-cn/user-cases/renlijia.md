---
title: Koupleless 助力「人力家」实现分布式研发集中式部署，又快又省！
date: 2024-29-10T17:15:32+08:00
description: Koupleless 助力「人力家」实现分布式研发集中式部署，又快又省！
weight: 1400
type: docs
---
> 作者：赵云兴，葛志刚, 仁励家网络科技（杭州）有限公司架构师，专注 to B 领域架构

### <font style="color:rgb(62, 62, 62);">背景</font>
<font style="color:rgba(0, 0, 0, 0.9);">人力家由阿里钉钉与人力窝共同孵化，致力于为企业提供以薪酬为核心的一体化 HR SaaS 解决方案，加速对中国人力资源服务行业数字化赋能。</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

<font style="color:rgba(0, 0, 0, 0.9);">人力资源软件通常由</font>**<font style="color:rgba(0, 0, 0, 0.9);">多模块</font>**<font style="color:rgba(0, 0, 0, 0.9);">组成，如人力资源规划、招聘、培训、绩效管理、薪酬福利、劳动关系，以及员工和组织管理等。随着业务发展，部分模块进入稳定期，仅需少量维护投入。例如，一个早期有 20 人研发的项目，现在拆分为 5 个应用。尽管产品成熟，但由于客户需求随竞争、业务和政策变化，仍需每年投入部分精力进行迭代。</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

<font style="color:rgba(0, 0, 0, 0.9);">长时间以来，我们一直面临着以下问题，而苦于没有解决方案：</font>

+ **<font style="color:rgba(0, 0, 0, 0.9);">系统资源浪费</font>**<font style="color:rgba(0, 0, 0, 0.9);">：5 个应用支撑的业务，我们在生产环境为每个应用部署了 3 台 2C4G 的 Pod，一共是 15 个 Pod 的资源。</font>
+ **<font style="color:rgba(0, 0, 0, 0.9);">迭代运维成本高</font>**<font style="color:rgba(0, 0, 0, 0.9);">：因为业务的复杂性，经常需要多个应用同时改动，部署等待周期长，单应用部署时间在 6 分钟左右。</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

<font style="color:rgba(0, 0, 0, 0.9);">在过去，我们已经探索过以下方案：</font>

+ **<font style="color:rgba(0, 0, 0, 0.9);">压缩工程</font>**<font style="color:rgba(0, 0, 0, 0.9);">：通过排除冗余的 jar 依赖，降低镜像大小。但空间有限，整个应用 jar 包只能从 100+M 减少到 80+M，整个镜像依然有 500M，能节省的部署等待时间有限。</font>
+ **<font style="color:rgba(0, 0, 0, 0.9);">单 ECS 上部署多应用</font>**<font style="color:rgba(0, 0, 0, 0.9);">：我们需要为这个应用做特别的定制，譬如监听端口要支持多个；部署脚本也要特别定制，要支持滚动发布，健康检测不同的端口，一段时间以后运维容易搞不清整个部署方案，容易出现运维事故。</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

### <font style="color:rgb(62, 62, 62);">初见成效   </font>
<font style="color:rgba(0, 0, 0, 0.9);">直到在某个月不黑风不高的夜晚，我们在最大的程序员交友网站上遇到了 Koupleless 团队。看完框架的介绍，我们立刻明白，Koupleless 就是我们要寻找的解决方案。</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

<font style="color:rgba(0, 0, 0, 0.9);">经过近两个月的敲敲打打，</font>**<font style="color:rgba(0, 0, 0, 0.9);">模块成功瘦身了，其中最大的模块的 jar 也只有不到 4M</font>**<font style="color:rgba(0, 0, 0, 0.9);">。</font>**<font style="color:rgba(0, 0, 0, 0.9);">应用部署的体积从 500M 一下子降到了 5M 以下</font>**<font style="color:rgba(0, 0, 0, 0.9);">，具体可见下图～</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2025/webp/106556484/1737361250206-55daa0de-96c3-4d2b-8b41-4b221e009c53.webp)

<font style="color:rgb(172, 172, 172);">瘦身以后模块的 jar</font>

<font style="color:rgba(0, 0, 0, 0.9);">  
</font>

<font style="color:rgb(62, 62, 62);">但高兴不过一天，我们在「</font>**<font style="color:rgb(62, 62, 62);">如何把 Koupleless 部署到生产环境</font>**<font style="color:rgb(62, 62, 62);">」上遇到了难题。因为我们没有专门的运维团队，部署都是开发人员通过阿里云的云效流水线，直接把镜像推送到 K8s 的 Pod。但这样改了以后，我们迎来了一连串待解决的问题……</font>

+ <font style="color:rgb(62, 62, 62);">模块要不要流量，还是直接通过基座处理流量？</font>
+ <font style="color:rgb(62, 62, 62);">如何在单独部署模块的时候先把基座的流量摘掉？</font>
+ <font style="color:rgb(62, 62, 62);">发布成功以后如何做健康检查？</font>
+ <font style="color:rgb(62, 62, 62);">如何重新开放基座流量？</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

### <font style="color:rgb(62, 62, 62);">Koupleless 的生产环境部署 </font>
<font style="color:rgb(62, 62, 62);">在这里要特别感谢 Koupleless 团队的伙伴，给了我们很多专业的建议和方案。最终，我们选择了以下部署方案：</font><font style="color:rgba(0, 0, 0, 0.9);"></font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2025/webp/106556484/1737361250264-761d2fe2-8847-476e-a777-d12d1b87ad92.webp)

<font style="color:rgba(0, 0, 0, 0.9);">  
</font>

<font style="color:rgb(62, 62, 62);">整体方案是，在基座上增加监听 oss 文件变化自动更新部署模块，卸载老版本模块安装新版模块，所有流量由 nginx 进入，转发到进程 tomcat </font>_<font style="color:rgb(178, 178, 178);">(基座和多个模块复用同个 tomcat host)</font>_<font style="color:rgb(62, 62, 62);">，并在基座上控制健康检查和流量的开关，主要工作是在基座上扩充一些能力：</font>

<font style="color:rgb(62, 62, 62);">1、基座支持配置自身运行的必要条件，譬如需要模块 A、B、C 都安装成功才能放流量进来；</font>

<font style="color:rgb(62, 62, 62);">2、检查 oss 目录，自动安装最新的模块版本，并做健康检查；</font>

<font style="color:rgb(62, 62, 62);">3、实现 K8s 的 liveness：用来在基座部署的时候判断基座是否成功启动。只要基座启动成功，即返回成功，这样基座可以走后续的安装模块逻辑；</font>

<font style="color:rgb(62, 62, 62);">4、实现 K8s 的 readiness：主要控制外部流量是否可以进来。因此这里需要判断所有必须安装的模块是否健康，并且对应的流量文件 A_status 等是否存在</font>_<font style="color:rgb(172, 172, 172);">（该文件是一个空文件，在滚动发布的时候开关流量的时候用）</font>_<font style="color:rgb(62, 62, 62);">。</font>

<font style="color:rgb(62, 62, 62);"></font>

**<font style="color:rgb(31, 126, 241);">小 Tips：</font>**

<font style="color:rgb(62, 62, 62);">目前 Koupleless 优化了静态部署和健康检查能力，能够直接满足我们的需求：</font>

+ **<font style="color:rgb(62, 62, 62);">静态部署</font>**<font style="color:rgb(62, 62, 62);">：在基座启动成功后，允许用户通过自定义的方式安装模块；</font>
+ **<font style="color:rgb(62, 62, 62);">健康检查</font>**<font style="color:rgb(62, 62, 62);">：在基座启动成功且用户自定义安装的模块启动后，Koupleless 框架将原生 SpringBoot 的 readiness 配置为 'ACCEPTING_TRAFFIC'，用户可以通过探测 readiness 决定是否让流量进入。</font>

<font style="color:rgb(62, 62, 62);"></font>

<font style="color:rgb(0, 0, 0);">以下是 K8s 上的配置图：</font>

+ <font style="color:rgb(62, 62, 62);">就绪检查和启动探测：</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2025/webp/106556484/1737361250176-d27ed3fe-b4e1-4efa-9cde-0874c45897a1.webp)

<font style="color:rgba(0, 0, 0, 0.9);"></font>

+ <font style="color:rgb(62, 62, 62);">在 Pod 上增加云存储的挂载：</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2025/webp/106556484/1737361250219-172e9640-348a-42ef-98b2-bc53658a3490.webp)

<font style="color:rgba(0, 0, 0, 0.9);"></font>

<font style="color:rgb(62, 62, 62);">模块动态部署时需要考虑两个问题：怎么感知新的模块并部署？在模块部署的前后怎么通过健康检查，控制基座流量？</font>

<font style="color:rgb(62, 62, 62);"></font>

<font style="color:rgb(62, 62, 62);">我们的方案大概如下：</font>

1. <font style="color:rgb(62, 62, 62);">模块通过流水线，直接 jar 上传到一个 oss 目录；</font>
2. <font style="color:rgb(62, 62, 62);">基座上增加配置，配置基座承接流量的必须安装的模块，以及对应模块的健康检查地址；</font>
3. <font style="color:rgb(62, 62, 62);">基座监听 oss 文件夹的变化，来决定是否重新部署模块</font>_<font style="color:rgb(172, 172, 172);">（譬如有更晚的/更大的版本的模块上传到了 oss）</font>_<font style="color:rgb(62, 62, 62);">；</font>
4. <font style="color:rgb(62, 62, 62);">基座部署模块前，先摘流量</font>_<font style="color:rgb(172, 172, 172);">（可以通过删除一个空文件来实现，结合上一步 K8s 的 readiness 逻辑，空文件删除以后，readiness 检测不通过，流量就不会进来。但模块是存活的，防止有耗时的线程还在运行）</font>_<font style="color:rgb(62, 62, 62);">；</font>
5. <font style="color:rgb(62, 62, 62);">安装好模块以后，把删除的文件写上，就可以开流量了；</font>
6. <font style="color:rgb(62, 62, 62);">集群下，基座通过 redis 来控制 Pod 不会出现并行安装，保证流量不会断；</font>
7. <font style="color:rgb(62, 62, 62);">基座提供就绪检查：就绪检查只需要判断基座起来了就可以。</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

<font style="color:rgb(62, 62, 62);">存活检查是比较关键的一步：</font>

<font style="color:rgb(62, 62, 62);">a.判断第 4 步的空文件是否存在</font>

<font style="color:rgb(62, 62, 62);">b.需要判断所有必须安装的模块都可以访问</font>

<font style="color:rgb(62, 62, 62);"></font>

**<font style="color:rgb(31, 126, 241);">小 Tips：</font>**

<font style="color:rgb(62, 62, 62);">目前 Koupleless 优化了</font>**<font style="color:rgb(62, 62, 62);">健康检查能力</font>**<font style="color:rgb(62, 62, 62);">，能够在模块动态安装/卸载之前关闭流量，将 readiness 配置为 REFUSING_TRAFFIC，并允许用户配置模块卸载前的静默时长，让流量在静默时期处于关闭状态。在卸载的静默时长结束、旧模块卸载完成、全部模块安装成功后，readiness 才会配置为 ACCEPTING_TRAFFIC 状态。</font>

<font style="color:rgba(0, 0, 0, 0.9);"></font>

### <font style="color:rgb(62, 62, 62);">总结  </font>
<font style="color:rgb(62, 62, 62);">在以前，单个模块升级发布一次要 6 分多钟。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2025/webp/106556484/1737361250912-feb677f6-ee34-43e9-ac5c-12accf97c9eb.webp)

<font style="color:rgba(0, 0, 0, 0.9);"></font>

<font style="color:rgb(62, 62, 62);">而改造后，升级单个模块只需要把编译后的 jar 上传到 oss 即可。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2025/webp/106556484/1737361250944-4f45ae61-052f-4451-82d1-f196f9f82ef6.webp)

<font style="color:rgba(0, 0, 0, 0.9);">  
</font>

<font style="color:rgb(62, 62, 62);">最终的效果，通过一组简单的数字对比就可以看出差异：</font>

+ <font style="color:rgb(62, 62, 62);">在服务器资源上，以前需要 15X2C4G，现在只需要 3X4c8G，</font>**<font style="color:rgb(31, 126, 241);">节省了 18C36G 的服务器资源</font>**<font style="color:rgb(62, 62, 62);">；</font>
+ <font style="color:rgb(62, 62, 62);">在单个模块的发布时间上，我们从之前的 6 分钟</font>**<font style="color:rgb(31, 126, 241);">降低到了</font>**<font style="color:rgb(62, 62, 62);"> </font>**<font style="color:rgb(31, 126, 241);">3 分钟</font>**<font style="color:rgb(62, 62, 62);">；</font>
+ <font style="color:rgb(62, 62, 62);">在单个模块的部署资源上，我们从 500M</font><font style="color:rgb(62, 62, 62);"> </font>**<font style="color:rgb(31, 126, 241);">降低到了 5</font>****<font style="color:rgb(31, 126, 241);">M</font>**<font style="color:rgb(62, 62, 62);">。</font>

<font style="color:rgb(62, 62, 62);"></font>

<font style="color:rgb(62, 62, 62);">再次感谢 Koupleless 团队伙伴的专业支持，特别是有济、立蓬。当我们在改造过程中遇到一些个性场景的兼容性问题，他们都能快速响应，让我们整个升级改造时间大大缩短。</font>

<font style="color:rgb(62, 62, 62);"></font>

<font style="color:rgb(62, 62, 62);">通过升级 Koupleless 架构，人力家实现了</font>**<font style="color:rgb(62, 62, 62);">多应用的合并部署、并行研发、轻量集中部署，大大降低了运维成本。</font>**

**<font style="color:rgb(62, 62, 62);"></font>**

<font style="color:rgb(62, 62, 62);">天下架构，分久必合，合久必分。而 Koupleless，让架构演进（分合）更丝滑</font><font style="color:rgb(62, 62, 62);">🥰</font>
