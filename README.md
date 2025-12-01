# Advanced Kubernetes Class

## Table of Contents
1. [Course Overview](#course-overview)
2. [Prerequisites](#prerequisites)
3. [Kubernetes Distribution: k0s](#kubernetes-distribution-k0s)
4. [Environment Setup](#environment-setup)
5. [Module 1: Helm](#module-1-helm)
6. [Module 2: Istio](#module-2-istio)
7. [Module 3: Telemetry](#module-3-telemetry)
8. [Module 4: Operators](#module-4-custom-operator-lab-hello-operator)
9. [Assignment](#assignment-telemetry)
10. [Resources](#resources)
11. [Contributing](#contributing)

---

## Course Overview

This class is designed for users who want to deepen their understanding of Kubernetes and its ecosystem. The course combines theory with hands-on labs to ensure practical experience.

### Objectives
- Master advanced Kubernetes concepts and tools
- Deploy, manage, and customize applications using Helm and existing charts
- Set up and extend telemetry and observability for clusters and applications
- Integrate and operate Istio as a service mesh for traffic management and security
- Work with operators to automate and extend cluster functionality
- Analyze, visualize, and alert on application and infrastructure metrics using Prometheus and Grafana

### Learning Outcomes
By the end of this course, you will be able to:
- Use Helm to package, deploy, and manage applications
- Deploy a Kubernetes operator and handle its custom resources to actionate its reconciliation loop 
- Monitor and observe clusters using telemetry tools (Prometheus, Grafana)
- Deploy and manage Istio for traffic management, security, and observability

### Course Structure
The course is divided into modules, each focusing on a key advanced concept:
1. Helm
2. Istio
3. Telemetry (Prometheus, Grafana)
4. Operators

Each module includes:
- Conceptual overview
- Installation and configuration steps
- Hands-on labs and exercises

You will use **k0s** as the Kubernetes distribution, which is lightweight and easy to run on various Linux platforms and WSL2.

---

## Prerequisites

To get the most out of this class, you should have:

### Technical Prerequisites
- Basic understanding of Kubernetes concepts (pods, deployments, services)
- Experience with Linux command line operations
- Familiarity with YAML configuration files
- Basic networking knowledge (IP addresses, subnets, interfaces)

### Hardware & Software Requirements
- A computer with at least 2 CPU cores and 4GB RAM (8GB recommended)
- Internet access for downloading packages and images
- Ability to run virtual machines or containers (for labs)

### Supported Operating Systems
- Debian/Ubuntu
- SUSE/openSUSE
- Red Hat/CentOS/Fedora
- Windows 10/11 with WSL2

### Preparation Steps
1. Ensure you have administrative (sudo) access on your system
2. Update your system packages to the latest versions
3. Install a modern web browser for accessing dashboards
4. Set up a virtualization environment (e.g., VirtualBox, VMware, KVM) for isolated labs or spin up a WSL instance

---

## Kubernetes Distribution: k0s

### Overview of k0s
k0s is a modern, lightweight Kubernetes distribution designed for simplicity and flexibility. It is fully conformant, runs as a single binary, and is ideal for labs, edge, and production environments.

**Key features:**
- Single binary for easy installation and upgrades
- Minimal system requirements
- Supports all major Linux distributions and WSL2
- Built-in support for high availability and multi-node clusters

### Why k0s for this class?
- Fast setup and minimal configuration
- Works well on laptops, VMs, and cloud instances
- Great for learning, prototyping, and real-world deployments

---

## Environment Setup

Follow these steps to prepare your environment for the labs:

### 1. Supported Platforms
- Debian/Ubuntu
- SUSE/openSUSE
- Red Hat/CentOS/Fedora
- Windows 10/11 with WSL2

### 2. Preparing Your System: Disabling Docker and Cleaning Up

Before starting any Kubernetes work, it's important to ensure Docker is not running and to clean up any Docker-related artifacts (such as iptables rules) that may interfere with your cluster networking.

#### Safely Disable Docker

Stop the Docker service:
```bash
sudo systemctl stop docker
sudo systemctl disable docker
```
Verify Docker is stopped:
```bash
sudo systemctl status docker
```

#### Clean Up Docker Artifacts

As an alternative to restarting the Linux system (e.g. restart the Linux system or *wsl ---shutdown* for WSL2), we can remove Docker iptables rules (if present):
```bash
# Flush Docker-related chains
sudo iptables -F DOCKER || true
sudo iptables -F DOCKER-USER || true
sudo iptables -F FORWARD
# Delete Docker chains
sudo iptables -X DOCKER || true
sudo iptables -X DOCKER-USER || true
```

> **Note:** These steps are safe for most Linux systems. 

### 2. Install k0s (Kubernetes Distribution)
A quick installation guide will be provided here. 
Refer to the [official k0s documentation](https://docs.k0sproject.io/latest/) for advanced options.

**Quick install (Linux):**
```bash
curl -sSL https://get.k0s.sh | sudo bash
sudo k0s install controller --single
sudo k0s start
sudo mount --make-rshared /
```

### 3. Post-installation:
- To access your cluster, export the kubeconfig:
	```bash
	sudo k0s kubeconfig admin > ~/.kube/config
	```
- Check cluster status:
	```bash
	sudo k0s status
	```

### 4. kubectl Installation

kubectl is the Kubernetes command-line tool. 
k0s comes by default with its minimal kubectl accessible with *k0s kubectl version*.
To allow you to use the official kubectl tool from Kubernetes, we will now download the version that matches your k0s cluster:

**Scripted install (recommended):**
```bash
# Get the Kubernetes version from k0s
K8S_VERSION=$(sudo k0s kubectl version | grep 'Client Version' | awk '{print $3}')
echo $K8S_VERSION
# Download the matching kubectl binary
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
If you cannot parse the version automatically, you can manually check the version with:
```bash
sudo k0s kubectl version
# In the case of k0s, either 'Client Version' or 'Server Version' will be aligned (e.g., v1.34.2). 
```
Then substitute the version in the download URL above.

---

### Restarting k0s After a System Reboot
If k0s was installed previously and your system was restarted, you may need to start the k0s service again:
```bash
sudo k0s start
```
If you installed k0s as a system service, it should start automatically. To check status or restart manually:
```bash
sudo systemctl status k0scontroller
sudo systemctl restart k0scontroller
```

---

## Module 1: Helm

### Introduction to Helm
Helm is the package manager for Kubernetes. It simplifies the deployment and management of applications by using charts, which are collections of files describing a related set of Kubernetes resources. Helm helps you:
- Install, upgrade, and uninstall applications easily
- Manage complex Kubernetes manifests as reusable templates
- Share and reuse application definitions via public or private chart repositories

**Key Concepts:**
- **Chart:** A Helm package containing all resource definitions
- **Release:** An instance of a chart running in a Kubernetes cluster
- **Values:** Customizable configuration for charts
- **Repository:** A collection of published charts

### Installing Helm
Refer to the installation instructions below:
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | VERIFY_CHECKSUM=false bash
```

After installation, verify with:
```bash
helm version
```

### Helm 3 Reference Commands 
Helm charts can be created from scratch or downloaded from repositories. Common operations include:
- Creating a new chart: `helm create <chart-name>`
- Installing a chart: `helm install <release-name> <chart>`
- Upgrading a release: `helm upgrade <release-name> <chart>`
- Uninstalling a release: `helm uninstall <release-name>`
- Listing releases: `helm list`

### Exercise 1: Hands-on Helm 
Below is a suggested structure for practical Helm exercises:

- Objective: Deploy a custom app using an Helm chart
- Steps:
  1. Using the locally provided Helm chart we can install the custom nginx application:
	  ```bash
	  helm install ciao-app helm/ --set customText="ciao!" -n ciao-app --create-namespace
	  ```
  2. Install another version of the application:
	  ```bash
	  helm install hello-app helm/ --set customText="hello!" -n hello-app --create-namespace
	  ```
  3. Verify deployment:
	  ```bash
	  kubectl get pods -n ciao-app
	  kubectl get pods -n hello-app
	  helm list -n ciao-app
	  helm list -n hello-app

	  ciaoIP=$(kubectl get po -n ciao-app -o jsonpath="{.items[*].status.podIP}")
	  curl $ciaoIP

	  helloIP=$(kubectl get po -n hello-app -o jsonpath="{.items[*].status.podIP}")
	  curl $helloIP	  
	  ```

#### Bonus: Modify the Custom Chart
- Objective: Take the custom Helm chart and change the title of the webpage
- Steps:
	1. Inside the helm folder there are all the files used to install the application
	2. Customize the values available in values.yaml with a new parameter called *customPage*
	3. Customize the templates/configmap.yaml by including the variable *customPage*
	3. Install and test the chart with
		```bash
		helm install goodbye-app helm/ --set customPage="Goodbye!" --set customText="goodbye!" -n goodbye-app --create-namespace
		```

#### Uninstall and Cleanup
- Objective: Remove releases and clean up resources
- Steps:
	1. Uninstall releases
		```bash
		helm uninstall -n ciao-app ciao-app
		helm uninstall -n hello-app hello-app
		helm uninstall -n goodbye-app goodbye-app
		```
	2. Verify resource removal

---

### Helm Recap: Why Helm Is Essential

Helm is a powerful tool for Kubernetes application deployment and management. It allows you to:
- Package complex applications as reusable charts
- Parameterize deployments for different environments and use cases
- Upgrade, rollback, and manage releases with ease
- Share and reuse application definitions across teams

**General Kubernetes Usefulness:**
Helm simplifies the deployment of any Kubernetes app, making it easy to customize, replicate, and maintain applications at scale. It is the de facto standard for managing Kubernetes workloads in production.

**Telco Environment Example:**
In telecommunications (telco) environments, Helm is especially valuable. For example, a single Helm chart ("recipe") for a 5G RAN Central Unit (CU) can deploy either a CU-Control Plane (CU-CP) or a CU-User Plane (CU-UP) simply by setting different parameters. This flexibility enables:
- Rapid adaptation to different network functions
- Consistent deployment practices for complex, multi-component systems
- Easier automation and lifecycle management for NFV and SDN workloads

*Helm empowers both developers and operators to deliver reliable, repeatable, and customizable Kubernetes deployments—whether for web apps, microservices, or advanced telco workloads.*

---

## Module 2: Istio

### Introduction to Istio
Istio is a popular open-source service mesh that provides advanced traffic management, security, and observability for microservices running in Kubernetes. It enables you to control, secure, and monitor service-to-service communication without modifying application code. Kiali is an observability console for Istio, offering service mesh visualization, traffic flow analysis, and configuration validation.

**Key Concepts:**
- **Service Mesh:** Infrastructure layer for managing service-to-service communication
- **Envoy Proxy:** Sidecar proxy deployed with each service to intercept traffic
- **Control Plane:** Manages configuration and policies (Istiod)
- **Data Plane:** Handles actual traffic between services (Envoy)

### Traffic Management, Security, and Observability
- **Traffic Management:** Control routing, load balancing, and traffic splitting
- **Security:** Mutual TLS, authentication, and authorization between services
- **Observability:** Telemetry, tracing, and monitoring of service interactions

#### Exercise 1: Install Istio and Verify
- Objective: Deploy Istio and confirm system components are running
- Steps:
	1. It is possible to install istio through Helm chart or *istioctl*, which is a utility developed by the community for in-depth evaluation.
	We will focus on istioctl for its simplified approach.

		**Quick install (recommended for labs):**
		```bash
		curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.28.0 sh -
		export PATH="$PWD/istio-1.28.0/bin:$PATH"
		istioctl install --set profile=minimal -y
		```
		Verify installation:
		```bash
		kubectl get pods -n istio-system
		```

		Refer to the [Istio documentation](https://istio.io/latest/docs/setup/) for advanced options.

	2. Kiali is an observability console for Istio service mesh, providing service graph, traffic flow, and configuration validation.
	By default Kiali requires additional Telemetry tools such as Prometheus and Grafana to display data in its UI.

		**Quick install (recommended for labs):**
		```bash
		kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/kiali.yaml
		kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/prometheus.yaml
		kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/grafana.yaml
		```
		Verify installation:
		```bash
		kubectl get pods -n istio-system -w 
		```
	3. You can now access Kiali dashboard:
		```bash
		kubectl port-forward -n istio-system svc/kiali 20001:20001
		```
		Kiali is now accessible temporarily in your browser at http://localhost:20001 

		You can navigate through the UI, but at this point you will not see anything of interest in terms of Istio.

#### Exercise 2: Deploy Sample Application
- Objective: Deploy a sample app with Istio sidecars injected
- Steps:
	1. Label the namespace for automatic sidecar injection
		```bash
		kubectl create namespace demo
		kubectl label namespace demo istio-injection=enabled
		```
	2. Deploy the sample app
		```bash
		kubectl apply -n demo -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/helloworld/helloworld.yaml
		kubectl get pods -n demo
		```
	3. Verify sidecar proxies are running both in CLI 
		```bash
		kubectl get pods -n demo # Copy the name of the pod you prefer to inspect
		kubectl describe pod <pod-name> | grep istio-proxy # Substitute <pod-name> with the name of the pod from the previous command
		```
		In the Kiali UI you will start seeing the application by looking at the different tabs, e.g. Applications.

		In the Traffic Graph tab, select the "*demo*" namespace. 
		The application is not yet generating any traffic, so let's generate some!
	
	4. Generate sample traffic and watch Kiali UI getting populated
		```bash
		istio/helloworld-traffic.sh
		```
		Kiali UI will now show the ongoing traffic. 

#### Exercise 3: Security
- Objective: Enable mutual TLS between services
- Steps:
	1. Apply Istio PeerAuthentication policy
		```bash
		kubectl apply -f istio/mtls.yaml
		```
	2. Restart the helloworld application and generate some traffic between the components as before.
		```bash
		kubectl rollout restart deployment -n demo helloworld-v1 helloworld-v2
		istio/helloworld-traffic.sh
		```
	3. Verify encrypted communication in the Kiali UI. 
	In the Traffic Graph, select Display menu and click on Badges/Security.
	You will now notice that a Lock is displayed on the links, meaning that mTLS is in place.

#### Exercise 4: Complex application traces
- Objective: Deploy another sample application composed by multiple microservices
- Steps:
	1. Install the sample application
		```bash
		kubectl create namespace travel-agency
		kubectl create namespace travel-portal
		kubectl create namespace travel-control

		kubectl label namespace travel-agency istio-injection=enabled
		kubectl label namespace travel-portal istio-injection=enabled
		kubectl label namespace travel-control istio-injection=enabled

		kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml) -n travel-agency
		kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml) -n travel-portal
		kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml) -n travel-control
		```
	2. Visualize traffic and traces in the Kiali UI

---

### Istio Recap: Why Istio Is Important

Istio is a powerful service mesh for Kubernetes, providing advanced traffic management, security, and observability. It enables:
- Fine-grained control over service-to-service communication
- Secure connections with mutual TLS and policy enforcement
- Deep visibility into microservice interactions and performance
- Resilient traffic routing, load balancing, and fault injection

**General Kubernetes Usefulness:**
Istio makes it easy to manage complex microservice architectures, enforce security policies, and gain insights into application behavior. It is widely adopted for production-grade Kubernetes environments where reliability, security, and observability are critical.

**Telco Environment Example:**
In telecommunications (telco) environments, Istio is especially valuable for:
- Managing network functions O&M networks with strict security and traffic requirements
- Enabling service chaining and dynamic routing
- Providing end-to-end encryption and authentication between network components
- Supporting multi-tenant, multi-network scenarios with policy-driven control

Istio empowers telco operators to deliver secure, observable, and adaptable network services, making it a key technology for cloud-native NFV, SDN, and 5G deployments.

---

## Module 3: Telemetry

### Introduction to Telemetry in Kubernetes
Telemetry refers to the collection, processing, and visualization of metrics, logs, and traces from the applications. It becomes essential in Kubernetes clusters, where microservices are generally deployed. 
It is overall fundamental for monitoring cluster health, troubleshooting issues, and optimizing performance.

**Key Concepts:**
- **Metrics:** Quantitative data about resource usage and application performance (e.g., CPU, memory, request rates)
- **Logs:** Textual records of events and errors from containers and system components
- **Traces:** Distributed request flows across microservices
- **Dashboards:** Visualizations of metrics and logs for quick insights

### Common Tools
- **Prometheus:** Metrics collection and storage
- **Grafana:** Visualization and dashboarding
- **Loki:** Log aggregation 
- **Jaeger/Tempo:** Distributed tracing 

### Exercise 1: Installing Prometheus and Grafana
We already installed Prometheus and Grafana when working with [Istio and Kiali](#module-2-istio). However now, we will install it officially through Helm, as if we were on a production environment.

Refer to the official documentation for advanced options.

**Quick install using Helm:**
```bash
# Add the official Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus --set server.persistentVolume.enabled=false --set server.service.nodePort=30303 --set server.service.type=NodePort --set alertmanager.persistence.enabled=false

# Install Grafana
helm install grafana grafana/grafana --set adminPassword=admin 
```

Verify installation:
```bash
kubectl get pods
helm list
```

Retrieve how to access Prometheus and Grafana services:
```bash
#Get the Prometheus server URL by running these commands in the same shell:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services prometheus-server)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo "Prometheus UI: http://$NODE_IP:$NODE_PORT"

#Get the Grafana URL to visit by running these commands in the same shell:
  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services grafana)
  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
  echo "Grafana UI: http://$NODE_IP:$NODE_PORT"
```

### Exercise 2: Setting Up Telemetry in Grafana
- Objective: Configure Prometheus to collect metrics from your Kubernetes cluster and visualize them in Grafana using ready-made dashboards.
- Steps:
	1. Prerequisites
		- Prometheus and Grafana are installed (see [Module 2](#module-2-istio)).
		- You have access to your cluster via `kubectl` (see [Kubernetes Distribution: k0s](#kubernetes-distribution-k0s)).
		- Helm is installed and configured (see [Module 1](#module-1-helm)).

	2. Ensure Prometheus Is Scraping Cluster Metrics
		Prometheus should be configured to scrape metrics from Kubernetes components. If you installed Prometheus using the official Helm chart (i.e. the instructions in [Exercise 1](#exercise-1-installing-prometheus-and-grafana)), default scrape configs are included.

	3. Access Prometheus and Grafana UIs

	```bash
		#Get the Prometheus server URL by running these commands in the same shell:
		  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services prometheus-server)
		  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
		  echo "Prometheus UI: http://$NODE_IP:$NODE_PORT"

		#Get the Grafana URL to visit by running these commands in the same shell:
		  export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services grafana)
		  export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
		  echo "Grafana UI: http://$NODE_IP:$NODE_PORT"
	```

	Open the Grafana URL address provided in your browser.
	- Default login: `admin` / `admin` (unless changed during install)

	4. Add Prometheus as a Data Source in Grafana

		* In Grafana, go to **Settings → Data Sources → Add data source**.
		* Select **Prometheus**.
		* Set the URL to the Prometheus URL address found above.
		* Click **Save & Test**.

	5. Import Kubernetes Monitoring Dashboards

		Use ready-made dashboards for cluster and node monitoring.

		**Kubernetes Cluster Monitoring Dashboard:**
		- Dashboard ID: `6417`
		- Source: https://grafana.com/grafana/dashboards/6417

		**Node Exporter Full Dashboard:**
		- Dashboard ID: `1860`
		- Source: https://grafana.com/grafana/dashboards/1860

		**To import:**
		1. In Grafana, click **Dashboards → Import**.
		2. Enter the dashboard ID (`6417` or `1860`) and click **Load**.
		3. Select your Prometheus data source.
		4. Click **Import**.

		**It is now possible to visualize the dashboards and the metrics getting pulled.**

	6. Explore Cluster Metrics
		- Open the imported dashboards.
		- Review metrics such as CPU, memory, pod status, and node health.
		- Use filters and time ranges to analyze cluster performance.

	7. Customize Dashboards
		- Add panels for custom metrics.
		- Set up alerts for critical conditions (e.g., high CPU).

---

**Recap:**  
You have now set up telemetry in Grafana, visualizing real-time metrics from your Kubernetes cluster. 
This workflow is essential for monitoring, troubleshooting, and optimizing production environments—especially in telco and cloud-native scenarios.

---

## Module 4: Custom Operator Lab (Hello Operator)

### Overview
This module introduces Kubernetes operators by building and deploying a custom operator using Python and Kopf.

#### What is the Hello Operator?
The Hello operator is a simple, educational Kubernetes operator written in Python using the Kopf framework. 

It watches for custom resources of type `Hello` in your cluster. 

When a `Hello` resource is created, updated, or deleted, the operator automatically reconciles the desired state by creating, updating, or removing a corresponding ConfigMap containing a personalized greeting message. The operator demonstrates:
- How to react to Kubernetes resource events (create, update, delete)
- How to implement reconciliation logic
- How to use RBAC for secure operation
- How to package and deploy an operator as a container with Helm

This lab provides a hands-on introduction to the operator pattern and automation in Kubernetes.

### Learning Objectives
- Understand the operator pattern in Kubernetes
- Deploy the operator as a container
- Use Helm to install the operator and manage CRDs

### Lab Steps

#### 1. Install the Operator with Helm
```bash
helm install hello-operator operator/helm-hello-operator
```
*This will also apply the CRD automatically.*

#### 2. Create a Custom Resource
```bash
kubectl apply -f operator/hello-francesco.yaml
```

#### 3. Verify Operator Pod and Functionality
Check the operator pod:
```bash
kubectl get pods -l app=hello-operator
kubectl logs $(kubectl get pods -l app=hello-operator -o jsonpath="{.items[0].metadata.name}")
```
Check the ConfigMap created by the operator:
```bash
kubectl get configmap hello-francesco -o yaml
```
Check the custom resource:
```bash
kubectl get hello
```

Try updating or deleting the Hello resource and observe reconciliation.

#### 4. Clean Up
To remove the operator and all resources:
```bash
helm uninstall hello-operator
kubectl delete crd hellos.unusualfor.com
```

---

## Assignment: Telemetry

Objective: Deploy a custom telemetry app, ensure Prometheus scrapes its metrics, and create a Grafana dashboard.

Steps:

1. **Deploy the telemetry app using Helm in the assignment namespace:**
   ```bash
   helm upgrade --install assignment-app ./assignment/helm/ -n assignment --create-namespace
   ```
2. **Verify the app is running in the assignment namespace:**
   ```bash
   kubectl get pods -n assignment -l app=demo-app
   kubectl get svc -n assignment demo-app
   ```
3. **Test metrics endpoint:**
   - Retrieve the ClusterIP of the demo-app service:
     ```bash
     CLUSTER_IP=$(kubectl get svc -n assignment demo-app -o jsonpath='{.spec.clusterIP}')
     ```
   - Then, from any pod in the cluster (or using a tool like `kubectl run`), you can access the metrics endpoint:
     ```bash
     curl http://<CLUSTER_IP>:8000/metrics
     ```
   - You should see Prometheus metrics output.

5. **Check Prometheus targets:**
   - Prometheus is exposed via NodePort. Retrieve the Prometheus server URL:
     ```bash
     export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services prometheus-server)
     export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
     echo "Prometheus UI: http://$NODE_IP:$NODE_PORT"
     ```
   - Query targets:
     ```bash
     curl http://$NODE_IP:$NODE_PORT/api/v1/targets | jq .
     ```
   - Confirm your app appears in `activeTargets` and is `up`.
7. **Build a dashboard in Grafana:**
   - After confirming metrics are available, create a custom dashboard or panel in Grafana using the metrics exposed by your app (e.g., request count, latency, memory usage).
   - Example tasks:
     - Visualize request rate over time
     - Show average or maximum latency
     - Display current memory usage
   - Use Prometheus as the data source and select your app's metrics for visualization.

### Clean Up
```bash
helm uninstall assignment-app -n assignment
```

---

Feel free to suggest additional topics or improvements!

## Resources

### Official Documentation & Resources
- [Kubernetes](https://kubernetes.io/docs/)
- [k0s](https://docs.k0sproject.io/latest/)
- [Helm](https://helm.sh/docs/)
- [Prometheus](https://prometheus.io/docs/introduction/overview/)
- [Grafana](https://grafana.com/docs/)
- [Istio](https://istio.io/latest/docs/)
- [Kiali](https://kiali.io/)

### Recommended Reading
- [Kubernetes Patterns](https://www.oreilly.com/library/view/kubernetes-patterns/9781492050285/)
- [Istio Up & Running](https://www.oreilly.com/library/view/istio-up-and/9781492043775/)

### Community Forums
- [Kubernetes Slack](https://slack.k8s.io/)
- [Istio Discuss](https://discuss.istio.io/)
- [Kiali Community](https://kiali.io/community/)

---

## Contributing

### How to Contribute
All contributions to improve this class material are welcome! You can:
- Submit pull requests for corrections, enhancements, or new modules
- Report issues or suggest improvements via GitHub Issues
- Share feedback and ideas in the community forums

### Reporting Issues
If you find any errors or have suggestions, please open an issue in this repository or contact the maintainer.

---

Thank you for participating in the Advanced Kubernetes class. Continue exploring, experimenting, and contributing to the Kubernetes ecosystem!