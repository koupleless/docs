---
title: Local Development of Modules
date: 2024-01-25T10:28:32+08:00
description: Koupleless Local Development of Modules
weight: 400
---

## Installation of Arkctl Tool

The Arkctl module installation mainly provides automatic packaging and deployment capabilities. Automatic packaging calls the mvn command to build the module jar package, and automatic deployment calls the api interface provided by [arklet](/docs/contribution-guidelines/arklet/architecture/) for deployment. If you don't want to use the command-line tool, you can also directly use the api interface provided by arklet to initiate deployment operations.

Method 1:

1. Install the go environment locally, with a go dependency version of 1.21 or higher.
2. Execute the command `go install <independent arkctl go repository>` to install the arkctl tool.

Method 2:

1. Download the corresponding binary from the [binary list](https://github.com/koupleless/koupleless/releases/tag/arkctl-release-0.1.0) and add it to the local 
   path.

### Local Quick Deployment

You can quickly build and deploy modules using the arkctl tool, which improves local debugging and development efficiency.

#### Scenario 1: Module jar package build + deployment to the local running base.

Preparation:

1. Start a base locally.
2. Open a module project repository.

Execute the command:

```shell
# Need to be executed in the root directory of the repository.
# For example, if it's a maven project, it needs to be executed in the directory where the root pom.xml is located.
arkctl deploy
```

After the command execution is completed, the deployment is successful, and users can debug and verify related module functions.

#### Scenario 2: Deploy a locally pre-built jar package to the locally running base.

Preparation:

1. Start a base locally.
2. Prepare a pre-built jar package.

Execute the command:

```shell
arkctl deploy /path/to/your/pre/built/bundle-biz.jar
```

After the command execution is completed, the deployment is successful, and users can debug and verify related module functions.

#### Scenario 3: Module jar package build + deployment to the k8s base running remotely.

Preparation:

1. Base pod running remotely.
2. Open a module project repository.
3. Locally, you need to have k8s certificates with exec permissions and the kubectl command-line tool.

Execute the command:

```shell
# Need to be executed in the root directory of the repository.
# For example, if it's a maven project, it needs to be executed in the directory where the root pom.xml is located.
arkctl deploy --pod {namespace}/{podName}
```

After the command execution is completed, the deployment is successful, and users can debug and verify related module functions.

#### Scenario 4: Build and deploy sub-module jar packages in a multi-module Maven project at Root.

Preparation:

1. Start a base locally.
2. Open a multi-module Maven project repository.

Execute the command:

```shell
# Need to be executed in the root directory of the repository.
# For example, if it's a maven project, it needs to be executed in the directory where the root pom.xml is located.
arkctl deploy --sub ./path/to/your/sub/module
```

After the command execution is completed, the deployment is successful, and users can debug and verify related module functions.

#### Scenario 5: Query the modules already deployed in the current base.

Preparation:

1. Start a base locally.

Execute the command:

```shell
arkctl status
```

#### Scenario 6: Query the modules already deployed in the remote k8s environment base.

Preparation:

1. Start a base in the remote k8s environment.
2. Ensure that local kube certificates and related permissions are available.

Execute the command:

```shell
arkctl status --pod {namespace}/{name}
```

### Use Arthas to view runtime module status and information
#### Get all Biz information
```shell
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100
```
Example: <br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961335431-516ae20b-16c8-48f3-8241-43e414a9f988.png#clientId=ue9573504-0f91-4&from=paste&height=165&id=uf5756bf0&originHeight=330&originWidth=1792&originalType=binary&ratio=2&rotation=0&showTitle=false&size=75826&status=done&style=none&taskId=ue37b95ce-9ff0-4e2b-8c76-c4ac6d3c852&title=&width=896)
<a name="EXU39"></a>
#### Get specific Biz information
```shell
# Please replace ${bizName}
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100 | grep ${bizName}  -A 4
```
Example: <br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961580662-719aa62b-735d-4443-8208-11f16dc74613.png#clientId=ue9573504-0f91-4&from=paste&height=87&id=u99973d00&originHeight=174&originWidth=1970&originalType=binary&ratio=2&rotation=0&showTitle=false&size=46592&status=done&style=none&taskId=ud87e82e9-b349-4c47-b6c2-a441f096de0&title=&width=985)
<a name="aQc2j"></a>
#### Get Biz information corresponding to a specific BizClassLoader
```shell
# Please replace ${BizClassLoaderHashCode}
vmtool -x 1 --action getInstances --className com.alipay.sofa.ark.container.model.BizModel --limit 100 | grep ${BizClassLoaderHashCode}  -B 1 -A 3
```
Example: <br />![image.png](https://intranetproxy.alipay.com/skylark/lark/0/2024/png/67256811/1711961557440-865e8681-e5be-4e09-81da-ba1e93d6650f.png#clientId=ue9573504-0f91-4&from=paste&height=92&id=ue02744a4&originHeight=184&originWidth=2086&originalType=binary&ratio=2&rotation=0&showTitle=false&size=51618&status=done&style=none&taskId=u9423d30f-c7f2-45ca-baaa-70f1a358b7d&title=&width=1043)
