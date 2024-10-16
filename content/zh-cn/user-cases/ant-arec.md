---
title: Koupleless 助力蚂蚁搜推平台 Serverless 化演进
date: 2023-09-15T10:28:32+08:00
description: Koupleless 助力蚂蚁搜推平台 Serverless 化演进
weight: 1000
type: docs
---
> 作者：陈铿彬
 

# <font style="color:rgba(25, 26, 31, 0.9);">背景介绍</font>
蚂蚁推荐平台 [Arec, Ant Recommender Platform, 后续简称 Arec] 是针对蚂蚁搜索、推荐、营销以及投放等业务特点建设的在线算法 FaaS 平台。Arec 是由支付宝通用推荐平台 [recneptune, 中文称: 海王星] 演进发展而来，目前在蚂蚁内部服务了支付宝、数金、网商、国际等多个部门的搜索、营销、投放等基于大数据和算法的业务[后面统一叫个性化业务]。  
在个性化业务的特点下，算法同学的核心在于通过在线多版本能力，面向体验和效果实现和优化相关策略和算法，而不关心整体系统、环境、稳定性保障等细节，专注于数据、策略和算法以及效果提升是个性化业务取得成功的关键。而蚂蚁传统的业务开发是一套复杂、周期性的迭代式发布流，针对高频变化、实验的个性化业务来说，建设相关平台能力，提升整体效率是 Arec 2.0 在 Serverless 化的重要目标。

# <font style="color:rgba(25, 26, 31, 0.9);">问题与挑战</font>
早期的 Arec 是基于 SOFA4 [Cloud-Engine] 技术栈开发的应用系统，是基于 SOFA4 提供的动态模块化方案来实现的，采用集中部署策略，将所有业务方案代码通过 SOFA CE 动态 Bundle 方式热部署到同一个在线应用中。这种方式虽然在部署效率、切流稳定性和资源利用率上都有一定优势，但当业务场景增长到几百上千个，并且在线请求量增长到上百万 QPS 之后，业务隔离性挑战越来越大、平台维护成本越来越高、方案代码编译发布保障弱效率低、头部场景多人协同研发效率等问题不断。

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724124052542-e59629e6-be95-48fa-b0e1-21094a680cdc.png)



1. <font style="color:rgba(25, 26, 31, 0.9);">随着蚂蚁在搜推广业务的发展，在单台机器里部署的方案和代码越来越多，</font>**<font style="color:rgba(25, 26, 31, 0.9);">业务隔离性诉求</font>**<font style="color:rgba(25, 26, 31, 0.9);">、</font>**<font style="color:rgba(25, 26, 31, 0.9);">服务稳定性差</font>**<font style="color:rgba(25, 26, 31, 0.9);">、</font>**<font style="color:rgba(25, 26, 31, 0.9);">平台维护成本高</font>**<font style="color:rgba(25, 26, 31, 0.9);">，以至于混合部署的方案难以继续推进。</font>
2. <font style="color:rgba(25, 26, 31, 0.9);">从 Arec 整体的产品层视角出发，为了解决隔离性问题，势必需要引入独立部署机制。Arec 2.0的模型、产品设计上，目标在于</font>**<font style="color:rgba(25, 26, 31, 0.9);">平滑衔接独立部署机制</font>**<font style="color:rgba(25, 26, 31, 0.9);">以确保算法部署效率不受影响，甚至达到更优的效果；并且针对算法在线部分，Arec 1.0原本地编译流程</font>**<font style="color:rgba(25, 26, 31, 0.9);">不可控、产物不可信、导致部署和运维困难的问题</font>**<font style="color:rgba(25, 26, 31, 0.9);">，以及如何良好的解决</font>**<font style="color:rgba(25, 26, 31, 0.9);">头部场景多人协同研发以及在线多版本实验的效率问题</font>**<font style="color:rgba(25, 26, 31, 0.9);">，都极大影响了个性化业务日常研发的效率以及产品的使用体验，亟待解决。</font>
3. 经过近两年的迭代后，Arec 更是产生了 CPU 等物理资源利用率不高的问题，存在较大空间优化。

# 解决方式
为此，Arec 1.0 算法研发能力通过接入 [Koupleless](https://koupleless.io/home/) 做了化全面升级。

![](https://intranetproxy.alipay.com/skylark/lark/0/2023/png/149473/1695131554610-ef5c4a2f-0080-45eb-8fed-55fdf5d827f9.png#clientId=ua84a92a5-30aa-4&from=paste&height=459&id=u7227f759&originHeight=918&originWidth=3714&originalType=binary&ratio=2&rotation=0&showTitle=false&size=309179&status=done&style=none&taskId=u12307968-2a79-4f77-9c78-e976399c60e&title=&width=1857)

## <font style="color:rgb(64, 64, 64);">多集群化与模块化</font>
<font style="color:rgb(64, 64, 64);">通过对集中部署机制升级为多个按业务或按场景隔离部署，彻底解决了业务隔离问题和平台维护问题。</font>

<font style="color:rgb(64, 64, 64);">首先，我们将原来大的集群，根据业务域拆分出不同的集群，如下图的腰封集群、基金集群、底纹词集群，每个集群上按业务安装不同的模块代码包。这样解决了不同业务域的隔离和稳定性问题。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724124355550-33570285-99bf-4857-8151-e5d0b7e74732.png)

完整的研发模式升级为如下图，具备如下的优势：

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724124912012-5e0c85dc-7e68-4cb1-91eb-aec5ac63a69c.png)

+ **研发过程解耦**：模块和基座、模块和模块间的研发活动、运维活动完全独立，互不干扰。
+ **模块极速研发：**模块非常轻量，构建 20 秒，发布仅 10 秒，极大提高了开发效率。此外，模块与应用一样，通过标准迭代发布到线上基座，迭代可以做到非常快，甚至是朝写夕发。
+ **低成本业务隔离：**几分钟即可创建逻辑集群（机器分组），只部署特定模块，服务特定业务流量，和其他业务实现资源隔离、变更隔离，模块还支持秒级弹性伸缩。
+ **<font style="color:rgb(64, 64, 64);">变更部署能力全面升级</font>**<font style="color:rgb(64, 64, 64);">：通过打通 Git 仓库，对接 ACI，我们实现 Git 仓库自动创建，算法编译部署流程自动化，代码产物从未知不可信提升 到 模块产物可信可交付，发布链路难定位 到 链路可溯源、状态有感追踪，通过编译缓存优化将日常构建时间从7分钟缩短到1分钟；并升级支持多灰度方案，和代码实验极大提升复杂场景多人协同研发效率。</font>

<font style="color:rgb(64, 64, 64);"></font>

## <font style="color:rgb(64, 64, 64);">模块组与流量单元</font>
Arec 除了将代码拆分出各个不同的模块外，它还有两个问题需要解决：

1. <font style="color:rgb(64, 64, 64);">模块里放基座SPI实现，负责一个个业务逻辑片段，但还需要多个模块搭配在一起才能组装出一个完整的业务，即需要有多个模块</font>**组合运维**<font style="color:rgb(64, 64, 64);">的能力；</font>
2. <font style="color:rgb(64, 64, 64);">中台业务基座一般会暴露一套统一服务来承接业务流量，但又经常有业务隔离部署的诉求，希望将机器资源划成几份，安装不同模块服务不同业务。如果对服务不做区分，就会出现业务A的请求打到业务B的机器（只部署了业务B相关模块）上，请求失败的情况：</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724125169354-902d53b1-b4ed-4b85-bf74-f29683a44773.png)

<font style="color:rgb(64, 64, 64);">我们将参数发布和代码发布解耦，并定义场景的模型（场景=模块组 + 流量单元），一个场景可以圈多个模块，一起打包部署，一个场景发布出的服务可以通过场景 id 作为服务 id，这样每个场景都有自己特有的一套服务，和其他场景完全独立。通过这种『拆』服务的方式，实现业务流量隔离。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724125204700-8afdafe2-5642-41c2-8f08-e86a1ae95a91.png)

<font style="color:rgb(64, 64, 64);">即使代码相同也可以发布不同的服务，通过这种方式我们实现了 AB 测试能力。</font>

## <font style="color:rgba(25, 26, 31, 0.9);">在线多版本与代码实验</font>
<font style="color:rgba(25, 26, 31, 0.9);">Arec 作为面向算法 FaaS：</font>**<font style="color:rgba(25, 26, 31, 0.9);">实现线上并行化的 A/B 实验能力，需要丰富整个 A/B 实验的生态，</font>**<font style="color:rgba(25, 26, 31, 0.9);">是产品的核心诉求。  
</font><font style="color:rgba(25, 26, 31, 0.9);">1、当时的 Arec </font>**<font style="color:rgba(25, 26, 31, 0.9);">仅能支持三个在线版本</font>**<font style="color:rgba(25, 26, 31, 0.9);">同时运行：</font>`<font style="color:rgba(25, 26, 31, 0.9);">基线 Base</font>`<font style="color:rgba(25, 26, 31, 0.9);">、</font>`<font style="color:rgba(25, 26, 31, 0.9);">切流 UP</font>`<font style="color:rgba(25, 26, 31, 0.9);">、</font>`<font style="color:rgba(25, 26, 31, 0.9);">压测 LT</font>`<font style="color:rgba(25, 26, 31, 0.9);">。单一的开发、测试版本能力</font>**<font style="color:rgba(25, 26, 31, 0.9);">不满足多人协同研发的诉求</font>**<font style="color:rgba(25, 26, 31, 0.9);">。</font>

+ <font style="color:rgba(25, 26, 31, 0.9);">原来针对同一个场景，多位算法、工程同学需要创建多个</font>**<font style="color:rgba(25, 26, 31, 0.9);">同名前缀的场景单独验证。</font>**<font style="color:rgba(25, 26, 31, 0.9);">例如，主场景</font>`<font style="color:rgba(25, 26, 31, 0.9);">feeds_v1</font>`<font style="color:rgba(25, 26, 31, 0.9);">，就可能同时创建了</font>`<font style="color:rgba(25, 26, 31, 0.9);">feeds_v1_01</font>`<font style="color:rgba(25, 26, 31, 0.9);">,</font><font style="color:rgba(25, 26, 31, 0.9);"> </font>`<font style="color:rgba(25, 26, 31, 0.9);">feeds_v1_02</font>`<font style="color:rgba(25, 26, 31, 0.9);">,</font><font style="color:rgba(25, 26, 31, 0.9);"> </font>`<font style="color:rgba(25, 26, 31, 0.9);">feeds_v1_03</font>`<font style="color:rgba(25, 26, 31, 0.9);">，分别用于不同研发同学研发、验证与实验。</font>

<font style="color:rgba(25, 26, 31, 0.9);">2、并且在实际多人协同研发的场景下，同一算法、业务实验，工程代码的验证往往我们需要推进到切流、甚至基线阶段，才能看到工程代码对于算法的效果，原本基于原有的</font>**<font style="color:rgba(25, 26, 31, 0.9);">纯参数 A/B 实验能力，难以支持代码实验的诉求</font>**<font style="color:rgba(25, 26, 31, 0.9);">；</font>

<font style="color:rgba(25, 26, 31, 0.9);">  
</font>![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724127170131-abf629a0-a6a2-433f-aee0-c7886b1b7dc1.png)<font style="color:rgba(25, 26, 31, 0.9);">  
</font>

### <font style="color:rgba(25, 26, 31, 0.9);">方案</font>
**<font style="color:rgba(25, 26, 31, 0.9);">在线多版本</font>**<font style="color:rgba(25, 26, 31, 0.9);">  
</font><font style="color:rgba(25, 26, 31, 0.9);">在产品优化中，我们明确支持多个版本在线同时运行，并且可以支持指定版本和白名单测试的能力，让一个场景能同时支持多位算法、工程同学在线研发、验证和实验。  
</font><font style="color:rgba(25, 26, 31, 0.9);">【2.0 产品设计】针对多版本问题，我们基于原来</font>**<font style="color:rgba(25, 26, 31, 0.9);">三个版本的类型，加入了开发版本类型，和验证阶段的概念</font>**

+ **<font style="color:rgba(25, 26, 31, 0.9);">验证阶段：支持多个开发版本的代码同时运行在线，并且支持指定版本和白名单指定验证的能力；</font>**
+ <font style="color:rgba(25, 26, 31, 0.9);">切流阶段：保持原1.0的产品设计，用以可发布版本的线上端到端流量的验证；</font>
+ <font style="color:rgba(25, 26, 31, 0.9);">基线阶段：保持原1.0的产品设计，用以线上完成功能、实验验证的推全版本；</font>

**<font style="color:rgba(25, 26, 31, 0.9);">代码实验</font>**<font style="color:rgba(25, 26, 31, 0.9);">  
</font><font style="color:rgba(25, 26, 31, 0.9);">基于多版本在线运行，以及指定版本验证的能力下，将在线运行的代码A [基线CTR=1.0] 进行A/B实验，以此获取到具体的算法产出结果，用于判断代码B [实验组] 是否会大面积影响了算法的指标[CTR=0.5/1.5]，用于决策代码B [重构、大规模改动] 是否可以进行推全发布。</font>

+ <font style="color:rgba(25, 26, 31, 0.9);">为了不影响业务实验的逻辑，我们将业务实验的流量单元和代码实验的流量单元独立出来，代码实验的决策优先级高于业务实验，待代码版本确认后，再继续执行业务实验的参数合并逻辑；</font>
+ <font style="color:rgba(25, 26, 31, 0.9);">【代码实验】代码实验的流量单元决策当前 PV 所执行的版本，通过达尔文的参数实验能力，在 A/B 实验参数中决策出当前流量所命中的代码版本，例如 Version=重构。而基于我们可指定版本验证的能力下，Version=重构的流量将直接命中重构代码的逻辑，并且返回相关的实验指标，反馈到实验桶中，用于基线版本和重构版本之间各类指标的体现。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724127201417-5961fd08-05a2-4a22-96b3-3ee8ca5b1001.png)<font style="color:rgba(25, 26, 31, 0.9);">  
</font>

## Serverless 调度与弹性伸缩
<font style="color:rgba(25, 26, 31, 0.9);">随着支付宝业务的快速发展，包括但不限于首页、Tab3、生活管家、医疗助理等，Arec 平台截止 2024-07 目前使用和管理几十万核的 CPU 资源，承载超过 几百万 QPS 的峰值流量。在降本增效的背景下，结合多方面的目标和长期问题的暴露，如何建设并优化一套有效的、高效的、低成本的资源管理和优化能力，成为 Arec 当前阶段亟需解决的问题。</font>

<font style="color:rgba(25, 26, 31, 0.9);"></font>

<font style="color:rgba(25, 26, 31, 0.9);">从解决利用率问题的角度切入，应用级别的粒度确实非常大，并且需要求整体最优解的难度就更难。因此，我们通过拆解问题单位，用子问题更优解反推问题更优解的方式，一步步拆分和验证各个问题的解决方案，并且取得对应的结果。  
</font><font style="color:rgba(25, 26, 31, 0.9);">我们将应用级的利用率提升拆分到业务集群粒度的利用率提升；再将业务集群天级利用率提升拆分到业务集群小时级利用率提升，从而反向一环环的影响整体结论。  
</font>![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724127823564-83a5ed6d-0683-44f8-9400-5922b8178832.png)

<font style="color:rgba(25, 26, 31, 0.9);">我们通过将资源分配的调度粒度更细化到模块粒度，也是我们当前正在做的优化方式。通过提供预热集群，业务集群和模块的扩容，将跳过基座冷启动阶段，转而直接进行模块等代码片段的安装，可以让弹性的速度更快，资源部署的密度更高。  
</font>

### <font style="color:rgb(34, 35, 40);">基于非对称部署的场景混部提升平台资源利用率保障场景资源诉求</font>
<font style="color:rgb(64, 64, 64);">Arec 承接了上千个活跃场景，支撑的服务器集群达到了几十万核级别，随着业务接入越来越多，对机器的需求量越来越大。当集群达到一定的规模之后那机器成本是必须要考虑的，不可能无限制的扩充机器。如何在资源有限的情况下支撑更多的业务？必然要做的就是提升资源利用率。</font>

<font style="color:rgb(64, 64, 64);"> 针对资源利用率的提升云原生领域已经有成熟的思路，即做资源调度。常见的产品如开源的 K8S 。</font>

<font style="color:rgb(64, 64, 64);"> 为什么资源调度能够提升资源利用率？简单来讲，</font><font style="color:rgba(25, 26, 31, 0.9);">调度就是通过各种技术手段提升机器部署密度把机器资源充分使用上。</font>**<font style="color:rgb(64, 64, 64);">为什么已经有基于 K8S 的成熟产品了还需要做 Serverless 资源调度？</font>**

<font style="color:rgb(64, 64, 64);">两者面临的调度场景是不同的。</font>

+ <font style="color:rgb(64, 64, 64);">K8S 调度的粒度是 Pod，Pod 与应用的比例是 1:1 ,他解决的问题是如何把各种规格诉求的应用部署到按照各种规格虚拟化后的 Pod 里。比如一台物理机有 32C，可以把他虚拟化为一个 16C 和2个 8C 的 Pod，然后就可以把一个规则为 16C32G 的应用和两个 8C16G规格的应用部署到该物理机上。</font>
+ <font style="color:rgb(64, 64, 64);">而 Serverless 调度的粒度是模块，虽然 Arec 是一个应用，可以在上面安装多个模块。模块的启动速度更快，与传统 K8S Pod 的启动速度有很大优势；模块占用资源小，可以在模块这层将资源部署密度做的更高。</font>

<font style="color:rgb(64, 64, 64);"></font>

<font style="color:rgb(64, 64, 64);">那么</font>**<font style="color:rgb(64, 64, 64);"> </font>**<font style="color:rgb(64, 64, 64);">Serverless 做模块资源调度要做什么？与 K8S 类似，要做两大能力：1、场景混部 2、非对称部署</font>

#### <font style="color:rgb(34, 35, 40);">场景混部</font>
<font style="color:rgb(64, 64, 64);">Arec 上运行着上千个场景，而且场景各异，有的只有几 qps，有的却有几万 qps。考虑到蚂蚁的应用部署架构有8个 zone，而每个 zone 为了避免单点至少需要2台机器，那每个场景至少需要 8*2=16 台机器。头部场景流量大，独立部署可以将资源充分利用起来，但是长尾场景如果都按照独占计算的话，假如长尾场景有 1000 个，那至少需要 16*1000 = 16000 台机器，这个规模是惊人的，无法让人接受的，通过混部可以将资源利用起来，实际运行中 1000 台机器就将长尾业务支撑起来，直接可节省 1w+ 台机器。</font>

#### <font style="color:rgb(64, 64, 64);">非对称部署</font>
![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724135937520-a413f551-8aa7-49a4-b76e-83ca041e66b3.png)

<font style="color:rgb(64, 64, 64);">如上图(基于 Koupleless 模块化架构)，是对称部署还是非对称部署是针对一组机器来讲的。如果一组机器上部署的模块(如果是 K8S 对应着一组物理机上都部署着相同的 Pod )，那我们称之为对称部署。相反的，如果一组机器中，有的机器部署着3个模块(对应与 K8S 就是3个 Pod)，而另一个部署着5个模块，或者说有的机器部署着 A、B ，有的机器部署的 C、D，那我们就称之为非对称部署。</font>

<font style="color:rgb(64, 64, 64);"></font>

<font style="color:rgb(64, 64, 64);">资源隔离其实是对虚拟化后的容器做了个规格约束，可以类比于普通应用的规格。当做完资源隔离之后其实我们就能够对 Arec 的场景设置规格，比如一个小的场景我给他约束规格为 2C4G，稍大一点的约束为 4C8G，再大一点的约束为 8C16G，这样就能够比较准确的评估出场景所需要的资源，可以称之为场景副本数，也就是虚拟化后的容器部署个数。不同的场景流量不同，逻辑不同所需要的副本数也就不同。Arec 整体集群的机器数是一定的，而不同的场景需要的副本数不同，那就无法做到所有的场景都平铺到集群的所有机器上，因此 Arec 需要做非对称部署。</font>

<font style="color:rgb(64, 64, 64);"></font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724308553913-3e32ab49-0762-41eb-83d7-31cbd08228b8.png)

<font style="color:rgb(64, 64, 64);">该非对称部署方案满足了 Arec 的两个诉求</font>

<font style="color:rgb(64, 64, 64);">1、亲和与非亲和部署</font>

+ <font style="color:rgb(64, 64, 64);">类比 K8S ，消耗资源高的场景容器不能部署到同一台 Pod 上，避免由于容器隔离不彻底导致的两个场景都受影响。</font>
+ <font style="color:rgb(64, 64, 64);">存在场景互调的场景尽可能部署到同一台 Pod 上，由于推荐场景 tr 请求的 request 和 response 都很大，这样可以减少序列化和非序列化消耗。</font>

<font style="color:rgb(64, 64, 64);">2、提高部署密度提升资源利用率</font>

+ <font style="color:rgb(64, 64, 64);">把资源进一步细化分隔，从而把碎片化的资源利用起来。举个例子：一个场景有隔离诉求，按照蚂蚁 K8S 现在的调度，蚂蚁现在有 8 个 zone，那流量再小也要最少 16 台机器，但是对于流量小的业务 16 台根本无法将资源充分利用起来。</font>

<font style="color:rgb(64, 64, 64);"></font>

### <font style="color:rgb(34, 35, 40);">多目标弹性决策降低弹性对业务的影响</font>
<font style="color:rgba(25, 26, 31, 0.9);">在执行弹性的过程中只有准确的评估出服务的运行情况才能够更好的做到弹的稳。</font>

<font style="color:rgba(25, 26, 31, 0.9);">Arec 上运行着上千个异构的场景，各个场景的逻辑不同，有 io 密集型的，有 cpu 密集型的。有的场景 cpu 达到了 80% 服务成功率还能保持在 99%，而有的场景可能 cpu 只有 40% 但是已经出现大量超时和抖动了。怎么样才能够比较准确的评估出场景的运行情况是决定弹的是否稳定的关键。</font>

<font style="color:rgba(25, 26, 31, 0.9);">我们认为在对场景能否能够正常运行的评估中除了 cpu、load 等基础指标，再观察场景的超时情况、异常情况以及降级熔断发生的情况能够比较真实的反应运行情况。基于此，Arec 建设了多目标评估的弹性。目前 Arec 的评估指标包括：</font>

+ <font style="color:rgba(25, 26, 31, 0.9);">超时</font>
+ <font style="color:rgba(25, 26, 31, 0.9);">异常</font>
+ <font style="color:rgba(25, 26, 31, 0.9);">降级</font>
+ <font style="color:rgba(25, 26, 31, 0.9);">限流</font>
+ <font style="color:rgba(25, 26, 31, 0.9);">熔断</font>
+ <font style="color:rgba(25, 26, 31, 0.9);">cpu 利用率</font>

<font style="color:rgba(25, 26, 31, 0.9);">在弹性缩容的过程中通过多批次，多目标的评估执行，保证弹性的安全平稳。</font>

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/webp/149473/1724135447519-7ba6d188-2538-443f-8fce-bec139944d9d.webp)



#### 弹性算法
Arec 基于 Metrics 提供了基于过往峰值的计算决策 Base Max、基于过往均值权重的计算决策 Base Weight，联合 OPTK 的时序预测算法，提供了不同的弹性决策算法能力。

而 OPTK 是一个主要针对互联网、金融等产业应用中的多种垂直领域超大规模优化问题，蚂蚁自研的一套高效分布式数学规划求解器套件。OPTK 从【领域问题建模与抽象】【求解算子和算法】及【分布式引擎】三个方面提供了全方位的统一求解套件。

#### 弹性配置化
在收获到上述的成本优化结论和实践后，Arec将业务集群日常的运维委托交付到 SRE 手中，减轻平台日常的运维成本，并且提升 SRE 可自主化运维的可控性。针对不同集群可以开启不同的弹性算法，例如：时序预测、历史峰值决策、算比决策等。  
因此 Arec 定义了一套声明式设计，以及可调整的配置内容。API 与 Config First，减少 UI 开发成本和链路健壮性。未来还将持续扩展更丰富的配置策略，支持不同的诉求：按时、按天、不同 Metrics 决策、独立 Zone、全量 Zone 等；

![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724127652422-54bca274-b270-4b4c-82d8-9cb09a524086.png)![](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/149473/1724127670041-1b9cd794-90d5-47da-b752-2d7b85fdc2a4.png)



# 阶段结果
当前所有 Arec 的算法与流量都运行在基于 Koupleless 建设的 Serverless 能力之上，除了隔离和业务稳定性得到保障外，支持了日均 1000+ 的工程师协同研发，个性化场景分钟级上线，日均  CPU 利用率从原来 17% 提升到  27%。

# 未来规划
1. 极致的搜推 Serverless 的生态建设，包括但不仅限于：研发、运维、高可用、弹性、实验、特征数据等；
2. 绿色计算的优化与生态能力共建，包括但不仅限于：决策算法、弹性能力；
