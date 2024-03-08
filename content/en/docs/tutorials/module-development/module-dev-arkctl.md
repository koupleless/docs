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
