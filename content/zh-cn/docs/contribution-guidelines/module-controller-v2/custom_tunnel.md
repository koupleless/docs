---
title: 多租户Virtual kubelet的结构与开发流程
date: 2024-01-25T10:28:32+08:00
description: Koupleless Multi-tenant Virtual-kubelet
weight: 600
---

## 结构简介

![image.png](/static/img/module-controller-v2/mt-vk-struct.jpg)

整体结构可以参考上图：
一句话总结：底层依赖K8S提供的调度，资源管理等能力，上层基于Virtual-kubelet构建了一整套调度方案，通过抽象过程+自定义Tunnel实现结合的方式实现对任意调度任务的适配。
核心的实现原理：
1. Base Register Controller通过监听包含特定Label的Pod资源+根据Node Name分发的能力实现了对K8S Informer资源对象的复用，从而降低在多Node的情况下listAndWatch的压力。
2. Node Provider和Pod Provider抽象了在多租户情况下Node状态维护和Pod状态维护的过程，通过调用自定义Tunnel实例实现多态能力
3. Custom Tunnel是对具体运维过程的实现，通过实现接口，传递通用格式的数据，实现低成本的调度能力接入
   部分关键逻辑时序如下：
1. VNode生命周期
   ![image.png](/static/img/module-controller-v2/vnode-lifecycle.jpg)

2. VPod生命周期
![image.png](/static/img/module-controller-v2/vpod-lifecycle.jpg)


上面的图中，CustomTunnel即为用户需要自定义开发的部分。
## 接入方式

接入多租户VK只需要对实现一个自定义的Tunnel即可。

### 接口定义

可以通过开发自定义Tunnel的方式快速的接入调度能力，Tunnel通过调用与回调的方式暴露能力。其中，回调函数是由多租户VK的Controller主动注入的，不需要额外开发，只需要实现Tunnel接口中的方法，并在合适的时机对回调方法进行调用即可。
Tunnel的接口定义如下：

```go
package tunnel

import (
"context"
"github.com/koupleless/virtual-kubelet/model"
v1 "k8s.io/api/core/v1"
)

// OnNodeDiscovered is the node discover callback, will start/stop a vnode depends on node state
type OnNodeDiscovered func(string, model.NodeInfo, Tunnel)

// OnNodeStatusDataArrived is the node health data callback, will update vnode status to k8s
type OnNodeStatusDataArrived func(string, model.NodeStatusData)

// OnQueryAllContainerStatusDataArrived is the container status data callback, will update vpod status to k8s
type OnQueryAllContainerStatusDataArrived func(string, []model.ContainerStatusData)

// OnStartContainerResponseArrived is the container start command callback, will update container-vpod status to k8s
type OnStartContainerResponseArrived func(string, model.ContainerOperationResponseData)

// OnShutdownContainerResponseArrived is the container stop callback, will update container-vpod status to k8s
type OnShutdownContainerResponseArrived func(string, model.ContainerOperationResponseData)

// QueryContainersBaseline func of query baseline, will return peer deployment baseline
type QueryContainersBaseline func(info model.QueryBaselineRequest) []*v1.Container

type Tunnel interface {
// Key is the identity of Tunnel, will set to node label for special usage
Key() string

	// Start is the func of tunnel start, please call the callback functions after start
	Start(ctx context.Context, clientID string, env string) error

	// Ready is the func for check tunnel ready, should return true after tunnel start success
	Ready() bool

	// RegisterCallback is the init func of Tunnel, please complete callback register in this func
	RegisterCallback(OnNodeDiscovered, OnNodeStatusDataArrived, OnQueryAllContainerStatusDataArrived, OnStartContainerResponseArrived, OnShutdownContainerResponseArrived)

	// RegisterQuery is the init func of Tunnel, please complete query func register in this func
	RegisterQuery(QueryContainersBaseline)

	// OnNodeStart is the func call when a vnode start successfully, you can implement it on demand
	OnNodeStart(ctx context.Context, nodeID string)

	// OnNodeStop is the func call when a vnode shutdown successfully, you can implement it on demand
	OnNodeStop(ctx context.Context, nodeID string)

	// FetchHealthData is the func call for vnode to fetch health data , you need to fetch health data and call OnNodeStatusDataArrived when data arrived
	FetchHealthData(ctx context.Context, nodeID string) error

	// QueryAllContainerStatusData is the func call for vnode to fetch all containers status data , you need to fetch all containers status data and call OnQueryAllContainerStatusDataArrived when data arrived
	QueryAllContainerStatusData(ctx context.Context, nodeID string) error

	// StartContainer is the func calls for vnode to start a container , you need to start container and call OnStartContainerResponseArrived when start complete with a response
	StartContainer(ctx context.Context, nodeID, podKey string, container *v1.Container) error

	// ShutdownContainer is the func calls for vnode to shut down a container , you need to start to shut down container and call OnShutdownContainerResponseArrived when shut down process complete with a response
	ShutdownContainer(ctx context.Context, nodeID, podKey string, container *v1.Container) error

	// GetContainerUniqueKey is the func returns a unique key of a container in a pod, vnode will use this unique key to find target Container status
	GetContainerUniqueKey(podKey string, container *v1.Container) string
}
```

### 数据结构

```go
// NetworkInfo is the network of vnode, will be set into node addresses
type NetworkInfo struct {
NodeIP   string `json:"nodeIP"`
HostName string `json:"hostName"`
}

// NodeStatus is the node curr status
type NodeStatus string

const (
// NodeStatusActivated node activated, will start vnode if not being started
NodeStatusActivated NodeStatus = "ACTIVATED"

	// NodeStatusDeactivated node deactivated, will shut down vnode if started
	NodeStatusDeactivated NodeStatus = "DEACTIVATED"
)

// NodeMetadata is the base data of a vnode, will be transfer to default labels of a vnode
type NodeMetadata struct {
// Name is the name of vnode
Name string `json:"name"`
// Version is the version of vnode
Version string `json:"version"`
// Status is the curr status of vnode
Status NodeStatus `json:"status"`
}

// QueryBaselineRequest is the request parameters of query baseline func
type QueryBaselineRequest struct {
Name         string            `json:"name"`
Version      string            `json:"version"`
CustomLabels map[string]string `json:"customLabels"`
CustomTaints []v1.Taint        `json:"customTaints"`
}

// NodeInfo is the data of node info.
type NodeInfo struct {
Metadata    NodeMetadata `json:"metadata"`
NetworkInfo NetworkInfo  `json:"networkInfo"`
}

// NodeResource is the data of node resource
type NodeResource struct {
Capacity    resource.Quantity `json:"capacity"`
Allocatable resource.Quantity `json:"allocatable"`
}

// NodeStatusData is the status of a node, you can set some custom attributes in this data structure
type NodeStatusData struct {
Resources         map[v1.ResourceName]NodeResource `json:"resources"`
CustomLabels      map[string]string                `json:"customLabels"`
CustomAnnotations map[string]string                `json:"customAnnotations"`
CustomTaints      []v1.Taint                       `json:"customTaints"`
CustomConditions  []v1.NodeCondition               `json:"customConditions"`
}

// OperationResponseResult is the container operation response result
type OperationResponseResult string

const (
OperationResponseCodeSuccess OperationResponseResult = "SUCCESS"
OperationResponseCodeFailure OperationResponseResult = "FAIL"
)

// ContainerOperationResponseData is the data of base biz operation response.
type ContainerOperationResponseData struct {
ContainerKey string                  `json:"containerKey"`
Result       OperationResponseResult `json:"result"`
Reason       string                  `json:"reason"`
Message      string                  `json:"message"`
}

// ContainerState is the state of a container, will set to pod state and show on k8s
type ContainerState string

const (
ContainerStateActivated   = "ACTIVATED"
ContainerStateResolved    = "RESOLVED"
ContainerStateDeactivated = "DEACTIVATED"
)

// PodKeyAll present container status will share to all pods
const PodKeyAll = "all"

// ContainerStatusData is the status data of a container
type ContainerStatusData struct {
// Key generated by tunnel, need to be the same as Tunnel GetContainerUniqueKey of same container
Key        string         `json:"key"`
// Name container name
Name       string         `json:"name"`
// PodKey is the key of pod which contains this container ,you can set it to PodKeyAll to present a shared container
PodKey     string         `json:"podKey"`
State      ContainerState `json:"state"`
ChangeTime time.Time      `json:"changeTime"`
Reason     string         `json:"reason"`
Message    string         `json:"message"`
}
```

几个需要注意的点
1. 每一个node都需要有一个全局唯一的id，需要在OnNodeDiscovered中传递，这一id将会在后续所有的container操作中由controller传递
2. PodKeyAll这个特殊的PodKey将会标明这个Container是共享的，更新这个Container状态的时候会更新所有这个node下同名的Container状态
   开发流程
   目前通用tunnel还没有合并到主分支上，暂时请follow开发分支：
   https://github.com/koupleless/virtual-kubelet/tree/feat.common_tunnel_implementation
   可以新开一个仓库，import本分支，实现一个CustomTunnel
   启动需要将cmd下的module-controller拷贝出来，更改其中的root.go，将其中Tunnel的实例更改成自己实现的CustomTunnel。
   
```go
// Copyright © 2017 The virtual-kubelet authors
   //
   // Licensed under the Apache License, Version 2.0 (the "License");
   // you may not use this file except in compliance with the License.
   // You may obtain a copy of the License at
   //
   //     http://www.apache.org/licenses/LICENSE-2.0
   //
   // Unless required by applicable law or agreed to in writing, software
   // distributed under the License is distributed on an "AS IS" BASIS,
   // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   // See the License for the specific language governing permissions and
   // limitations under the License.

package app

import (
"context"
"errors"
"github.com/google/uuid"
"github.com/koupleless/virtual-kubelet/common/log"
"github.com/koupleless/virtual-kubelet/common/prometheus"
"github.com/koupleless/virtual-kubelet/common/tracker"
"github.com/koupleless/virtual-kubelet/common/utils"
"github.com/koupleless/virtual-kubelet/controller/base_register_controller"
"github.com/koupleless/virtual-kubelet/controller/module_deployment_controller"
"github.com/koupleless/virtual-kubelet/inspection"
"github.com/koupleless/virtual-kubelet/model"
"github.com/koupleless/virtual-kubelet/tunnel"
"github.com/koupleless/virtual-kubelet/tunnel/koupleless_mqtt_tunnel"
"github.com/koupleless/virtual-kubelet/virtual_kubelet/nodeutil"
"github.com/spf13/cobra"
"time"
)

// NewCommand creates a new top-level command.
// This command is used to start the virtual-kubelet daemon
func NewCommand(ctx context.Context, c Opts) *cobra.Command {
cmd := &cobra.Command{
Use: "run",
RunE: func(cmd *cobra.Command, args []string) error {
return runModuleControllerCommand(ctx, c)
},
}

	installFlags(cmd.Flags(), &c)
	return cmd
}

func runModuleControllerCommand(ctx context.Context, c Opts) error {
ctx, cancel := context.WithCancel(ctx)
defer cancel()

	clientID := uuid.New().String()

	ctx = log.WithLogger(ctx, log.G(ctx).WithFields(log.Fields{
		"operatingSystem": c.OperatingSystem,
		"clientID":        clientID,
		"env":             c.Env,
	}))

	clientSet, err := nodeutil.ClientsetFromEnv(c.KubeConfigPath)
	if err != nil {
		return err
	}

	if c.EnableTracker {
		tracker.SetTracker(&tracker.DefaultTracker{})
	}

	if c.EnablePrometheus {
		go func() {
			err = prometheus.StartPrometheusListen(c.PrometheusPort)
			if err != nil {
				log.G(ctx).WithError(err).Fatal("failed to start prometheus server")
			}
		}()
		log.G(ctx).Infof("Prometheus listening on port %d", c.PrometheusPort)
	}

	if c.EnableInspection {
		for _, insp := range inspection.RegisteredInspection {
			insp.Register(clientSet)
			go utils.TimedTaskWithInterval(ctx, insp.GetInterval(), func(ctx context.Context) {
				insp.Inspect(ctx, c.Env)
			})
		}
	}
    // 注意这里
	tunnels := make([]tunnel.Tunnel, 0)
	if c.EnableMqttTunnel {
        // 将这里的MQTTTunnel更换成个人开发的CustomTunnel
		tunnels = append(tunnels, &koupleless_mqtt_tunnel.MqttTunnel{})
	}

	moduleDeploymentControllerConfig := module_deployment_controller.BuildModuleDeploymentControllerConfig{
		Env: c.Env,
		K8SConfig: &model.K8SConfig{
			KubeClient:         clientSet,
			InformerSyncPeriod: time.Minute,
		},
		Tunnels: tunnels,
	}

	deploymentController, err := module_deployment_controller.NewModuleDeploymentController(&moduleDeploymentControllerConfig)
	if err != nil {
		return err
	}

	if deploymentController == nil {
		return errors.New("deployment controller is nil")
	}

	go deploymentController.Run(ctx)

	// waiting for register controller ready
	if err = deploymentController.WaitReady(ctx, time.Second*30); err != nil {
		return err
	}

	config := base_register_controller.BuildBaseRegisterControllerConfig{
		ClientID: clientID,
		Env:      c.Env,
		K8SConfig: &model.K8SConfig{
			KubeClient:         clientSet,
			InformerSyncPeriod: time.Minute,
		},
		Tunnels: tunnels,
	}

	registerController, err := base_register_controller.NewBaseRegisterController(&config)
	if err != nil {
		return err
	}

	if registerController == nil {
		return errors.New("register controller is nil")
	}

	go registerController.Run(ctx)

	for _, t := range tunnels {
		err = t.Start(ctx, clientID, c.Env)
		if err != nil {
			log.G(ctx).WithError(err).Error("failed to start tunnel", t.Key())
		} else {
			log.G(ctx).Info("Tunnel started: ", t.Key())
		}
	}

	// waiting for register controller ready
	if err = registerController.WaitReady(ctx, time.Second*30); err != nil {
		return err
	}

	log.G(ctx).Info("Module controller running")

	select {
	case <-ctx.Done():
		log.G(ctx).Error("context canceled")
	case <-registerController.Done():
		log.G(ctx).WithError(registerController.Err()).Error("register controller is stopped")
	}

	return registerController.Err()
}
```

编译运行main方法：

### 实现参考
可以参考目前的Koupleless MQTT tunnel管道的实现
https://github.com/koupleless/virtual-kubelet/tree/feat.common_tunnel_implementation/tunnel/koupleless_mqtt_tunnel**

<br/>
