## Module Scaling and Replacement

### Module Scaling

Due to the fact that ModuleController V2 fully leverages Kubernetes (K8S) Pod orchestration mechanisms, scaling operations occur exclusively on entities like ReplicaSets, Deployments, and StatefulSets. Scaling can be executed in accordance with the respective scaling methods of these deployment objects. Below, we illustrate using Deployments as an example:

```bash
kubectl scale deployments/yourdeploymentname --namespace=yournamespace --replicas=3
```

In this command, replace `yourdeploymentname` with your actual Deployment name and `yournamespace` with your target namespace. The `replicas` parameter is set to the desired number of replicas after scaling up or down.

Alternatively, scaling operations can also be facilitated through API calls, enabling the implementation of scaling strategies programmatically.

### Module Replacement

Within ModuleController v2, there exists a strong binding between modules and containers. To effect module replacement, an update process must be initiated to modify the Image reference of the module associated with the Pods where they reside.

The specific method for replacement varies slightly depending on the deployment mode of the module. For instance, directly updating Pod information leads to an in-place module replacement. In the case of Deployments, the configured update strategy is executed (such as rolling updates, which involve creating new version Pods before removing old ones). DaemonSets also adhere to their configured update strategies; however, unlike Deployments, they follow a delete-then-create logic, which may momentarily disrupt traffic or lead to a brief downtime.

---

This translation maintains the technical accuracy of the original content while adapting it into fluent English, ensuring that computer terminology and Kubernetes-specific terms are used correctly.