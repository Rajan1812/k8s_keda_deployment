 **Kubernetes Deployment Automation Script**

# 1. Introduction
This script automates Kubernetes cluster setup, tool installation (Helm/KEDA), and application deployment with event-driven autoscaling. It is designed for interview tasks to demonstrate proficiency in Kubernetes operations and scripting.


# 2. Key Features
Cluster Connection
Validates cluster access using a provided kubeconfig file.
Tool Installation
Installs Helm (if missing).
Deploys KEDA (Kubernetes Event-Driven Autoscaling).
Resource Deployment
Applies user-provided manifests for Deployment and KEDA autoscaling.
Health Monitoring
Verifies deployment status and reports metrics (CPU/memory usage).

# 3. Prerequisites
Cluster:
A running Kubernetes cluster.
Files:
kubeconfig file for cluster access.
Deployment YAML (e.g., nginx-dep.yaml).
KEDA ScaledObject/HPA YAML (e.g., nginx-keda-hpa.yaml).
Permissions:
kubectl and helm installed locally.
Cluster-admin privileges for tool installation.

# 4. Usage
Command Syntax
./main.sh <kubeconfig_path> <deployment_yaml_path> <keda_hpa_yaml_path>

>Arguments
```
Argument               Description                         Example </br>
kubeconfig_path        Path to the cluster’s kubeconfig   file ~/cluster/kubeconfig.yaml  </br>
deployment_yaml_path   Path to the Deployment             YAML nginx-dep.yaml  </br>
keda_hpa_yaml_path     Path to the KEDA HPA               YAML nginx-keda-hpa.yaml </br>
```

# 5. Workflow
```
1. Cluster Connection:
2. Validates cluster access using kubectl get nodes.
3. Tool Installation:  </br>
  Installs Helm (if missing). </br>
  Deploys KEDA in the keda namespace.
4.Resource Deployment: </br>
  Applies the provided Deployment and KEDA HPA manifests. </br>
5.Health Checks: </br>
  Monitors deployment status until pods are ready. </br>
  Reports service endpoints and resource metrics. </br>
```
# 6. Example Execution
./main.sh ~/.kube/config nginx-dep.yaml nginx-keda-hpa.yaml

Output
`./main.sh /Users/rajansh/cka_test_config nginx-dep.yaml nginx-kafka-keda.yaml`

```
================
 info: current cluster: -/Users/rajansh/cka_test_config
NAME   	STATUS   ROLES       	AGE   VERSION
master 	Ready	control-plane   92d   v1.30.3
worker-1   Ready	<none>      	92d   v1.30.3
worker-2   Ready	<none>      	92d   v1.30.3
================
 info: connected to the given k8s cluster
================
 info: helm is installed
====
Keda installation verified..
deployment.apps/nginx-deployment configured
service/nginx-service unchanged
scaledobject.keda.sh/nginx-kafka-keda unchanged
================
 info: waiting for 30 sec for the deployment to be complete
================
 info: checking if the deployment went success
The service can be accessed on this address:- 10.103.129.76:30001
================
 info: Number of replicas for the deployment is :-  3
================
```
# 7. Limitations
Assumes Deployment is named nginx-deployment in namespace nginx-ns.
Requires NodePort service on port 30001.
Timeout values may need adjustment for slower clusters.

# 8. Appendix
Script Code:
See attached main.sh file.
Sample YAML Files:
nginx-dep.yaml (Deployment)
nginx-keda-hpa.yaml (KEDA HPA)

 

