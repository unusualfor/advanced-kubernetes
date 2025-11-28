# Advanced Kubernetes Class

## Table of Contents
1. [Course Overview](#course-overview)
2. [Prerequisites](#prerequisites)
3. [Kubernetes Distribution: k0s](#kubernetes-distribution-k0s)
4. [Module 0: Environment Setup](#environment-setup)
5. [Module 1: Helm](#module-1-helm)
6. [Module 2: Istio](#module-2-istio)
7. [Module 3: Telemetry](#module-3-telemetry)
8. [Module 4 (Bonus): Multus](#module-4-multus)
9. [Assignment](#assignment-telemetry)
10. [Resources](#resources)
11. [Contributing](#contributing)

---

## Course Overview

This class is designed for users who want to deepen their understanding of Kubernetes and its ecosystem. The course combines theory with hands-on labs to ensure practical experience.

### Objectives
- Master advanced Kubernetes concepts and tools
- Deploy and manage real-world workloads using Helm
- Implement multi-networking with Multus
- Set up telemetry and observability for clusters
- Integrate and operate Istio as a service mesh

### Learning Outcomes
By the end of this course, you will be able to:
- Use Helm to package, deploy, and manage applications
- Configure Multus for multi-network support in Kubernetes
- Monitor and observe clusters using telemetry tools (Prometheus, Grafana)
- Deploy and manage Istio for traffic management, security, and observability
- Work confidently with k0s on major Linux distributions and WSL2

### Course Structure
The course is divided into modules, each focusing on a key advanced concept:
1. Helm
2. Multus
3. Telemetry
4. Istio

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
	k0s status
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
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | VERIFY_CHECKSUM=false bash
```

After installation, verify with:
```bash
helm version
```

### Creating and Managing Charts
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
	  cd helm/ 
	  helm install ciao-app helm/ --set customText="ciao!" -n ciao-app --create-namespace
	  cd ..
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

	  ciaoIP=$(k get po -n ciao-app -o jsonpath="{.items[*].status.podIP}")

	  curl $ciaoIP

	  helloIP=$(k get po -n hello-app -o jsonpath="{.items[*].status.podIP}")

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

### Installing Istio
Refer to the [Istio documentation](https://istio.io/latest/docs/setup/) for advanced options.

**Quick install (recommended for labs):**
```bash
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH="$PWD/bin:$PATH"
istioctl install --set profile=minimal -y
```
Verify installation:
```bash
kubectl get pods -n istio-system
```

### Installing Kiali
Kiali is an observability console for Istio service mesh, providing service graph, traffic flow, and configuration validation.

**Quick install (recommended for labs):**
```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/addons/kiali.yaml
```
Verify installation:
```bash
kubectl get pods -n istio-system | grep kiali
```
Access Kiali dashboard:
```bash
kubectl port-forward -n istio-system svc/kiali 20001:20001
# Then open http://localhost:20001 in your browser
```

### Traffic Management, Security, and Observability
- **Traffic Management:** Control routing, load balancing, and traffic splitting
- **Security:** Mutual TLS, authentication, and authorization between services
- **Observability:** Telemetry, tracing, and monitoring of service interactions

### Hands-on Labs & Exercises Skeleton
Below is a suggested structure for practical Istio exercises:
#### Module Summary & Next Steps
You have deployed Istio and Kiali, and explored traffic management, security, and observability. Continue learning by experimenting with custom policies and advanced mesh features.

#### Exercise 1: Install Istio and Verify
- Objective: Deploy Istio and confirm system components are running
- Steps:
	1. Install Istio using istioctl
	2. Check pods in istio-system namespace

		```bash
		curl -L https://istio.io/downloadIstio | sh -
		cd istio-*
		export PATH="$PWD/bin:$PATH"
		istioctl install --set profile=demo -y
		kubectl get pods -n istio-system
		```

#### Exercise 2: Deploy Sample Application
- Objective: Deploy a sample app with Istio sidecars injected
- Steps:
	1. Label the namespace for automatic sidecar injection
	2. Deploy the sample app
	3. Verify sidecar proxies are running

		```bash
		kubectl create namespace demo
		kubectl label namespace demo istio-injection=enabled
		kubectl apply -n demo -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/helloworld/helloworld.yaml
		kubectl get pods -n demo
		kubectl describe pod <pod-name> | grep istio-proxy
		```

#### Exercise 3: Security
- Objective: Enable mutual TLS between services
- Steps:
	1. Apply Istio PeerAuthentication policy
	2. Verify encrypted communication

		```bash
		kubectl apply -n demo -f - <<EOF
		apiVersion: security.istio.io/v1beta1
		kind: PeerAuthentication
		metadata:
			name: default
			namespace: demo
		spec:
			mtls:
				mode: STRICT
		EOF
		# Check for mTLS in Grafana/Kiali or with istioctl authn tls-check
		istioctl authn tls-check <pod-name>.demo
		```

#### Exercise 4: Observability
- Objective: Monitor service interactions with Istio telemetry
- Steps:
	1. Access built-in dashboards (Grafana, Kiali, Jaeger)
	2. Visualize traffic and traces

		```bash
		# Port-forward Grafana
		kubectl port-forward -n istio-system svc/grafana 3000:3000
		# Port-forward Kiali
		kubectl port-forward -n istio-system svc/kiali 20001:20001
		# Access dashboards in your browser
		# Grafana: http://localhost:3000
		# Kiali: http://localhost:20001
		```

---

## Module 3: Telemetry

### Introduction to Telemetry in Kubernetes
Telemetry refers to the collection, processing, and visualization of metrics, logs, and traces from your Kubernetes cluster. It is essential for monitoring cluster health, troubleshooting issues, and optimizing performance.

**Key Concepts:**
- **Metrics:** Quantitative data about resource usage and application performance (e.g., CPU, memory, request rates)
- **Logs:** Textual records of events and errors from containers and system components
- **Traces:** Distributed request flows across microservices
- **Dashboards:** Visualizations of metrics and logs for quick insights

### Common Tools
- **Prometheus:** Metrics collection and storage
- **Grafana:** Visualization and dashboarding
- **Loki:** Log aggregation (optional)
- **Jaeger/Tempo:** Distributed tracing (optional)

### Installing Prometheus and Grafana
Refer to the official documentation for advanced options.

**Quick install using Helm:**
```bash
# Add the official Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus

# Install Grafana
helm install grafana grafana/grafana --set adminPassword=admin
```
Verify installation:
```bash
kubectl get pods
helm list
```
### Setting Up Telemetry in Kubernetes
- Expose Prometheus and Grafana services for temporary access (e.g., via NodePort or port-forward)
    ```bash
- Configure Prometheus to scrape metrics from cluster components
- Import dashboards in Grafana for Kubernetes monitoring

### Hands-on Labs & Exercises Skeleton
Below is a suggested structure for practical telemetry exercises:
#### Module Summary & Next Steps
You can now monitor and visualize your Kubernetes cluster using Prometheus and Grafana. Next, integrate Istio for advanced service mesh capabilities.

#### Exercise 1: Access Dashboards
- Objective: Access Grafana and import a Kubernetes dashboard
- Steps:
	1. Port-forward Grafana service
	2. Log in and import dashboard

#### Exercise 2: Custom Metrics
- Objective: Expose custom application metrics to Prometheus
- Steps:
	1. Instrument a sample app
	2. Verify metrics in Prometheus

---

## Module 4 (Bonus): Multus

### Introduction to Multus
Multus is a Kubernetes Container Network Interface (CNI) plugin that enables attaching multiple network interfaces to pods. This allows advanced networking scenarios such as connecting pods to multiple networks, integrating with SDN solutions, and supporting NFV workloads.

**Key Concepts:**
- **Primary CNI:** The default network for pods (e.g., flannel, calico)
- **Secondary CNI:** Additional networks attached to pods via Multus
- **NetworkAttachmentDefinition:** Custom resource defining additional networks

### Use Cases for Multi-Networking
- Network isolation for workloads
- Connecting pods to external networks (e.g., storage, monitoring)
- Service chaining and network function virtualization (NFV)
- Advanced SDN integrations

### Installing Multus
Refer to the [Multus GitHub repository](https://github.com/k8snetworkplumbingwg/multus-cni) for the latest installation instructions.

**Quick install (recommended for labs):**
```bash
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml
```
Verify installation:
```bash
kubectl get pods -n kube-system | grep multus
```

### Configuration
- Define additional networks using `NetworkAttachmentDefinition` resources
- Annotate pods to request multiple network interfaces

### Hands-on Labs & Exercises Skeleton
Below is a suggested structure for practical Multus exercises:
#### Module Summary & Next Steps
You have learned how to configure multi-networking in Kubernetes using Multus. Next, set up telemetry and observability for your cluster.

#### Exercise 1: Create a Secondary Network
- Objective: Define a secondary network using NetworkAttachmentDefinition
- Steps:
	1. Create a simple bridge or macvlan network definition
	2. Verify the resource is created
	3. Annotate pod spec to use both primary and secondary networks
	4. Verify pod network interfaces

#### Exercise 2: Attach Multiple Networks to a Pod
- Objective: Deploy a second pod with the same multiple network interfaces
- Steps:
	1. Annotate pod spec to use both primary and secondary networks
	2. Verify pod network interfaces
    3. Verify connectivity between pods

---

## Assignment: Telemetry 

- **Project 1: Cluster Resource Monitoring**
	- Deploy Prometheus and Grafana
	- Import a ready-made Kubernetes cluster dashboard in Grafana
	- Observe CPU, memory, and pod usage over time

##### Ready-made Dashboards & Resources

- **Kubernetes Cluster Monitoring Dashboard**
	- Grafana Dashboard ID: 6417
	- Import from: https://grafana.com/grafana/dashboards/6417
	- In Grafana: Go to Dashboards → Import, enter ID 6417, select Prometheus as data source.
	
	**Step-by-step Import Instructions:**
	1. Port-forward Grafana to your local machine:
	   ```bash
	   kubectl port-forward svc/grafana 3000:80
	   ```
	2. Open your browser and go to http://localhost:3000
	3. Log in (default user: admin, password: admin if not changed)
	4. In the left menu, click "Dashboards" → "Import"
	5. Enter dashboard ID `6417` and click "Load"
	6. Select your Prometheus data source and click "Import"

- **Node Exporter Full Dashboard**
	- Grafana Dashboard ID: 1860
	- Import from: https://grafana.com/grafana/dashboards/1860
	- For node-level metrics.
	
	**Step-by-step Import Instructions:**
	1. Repeat the steps above, but use dashboard ID `1860`.

- **Prometheus Helm Chart**
	- https://artifacthub.io/packages/helm/prometheus-community/prometheus
	- Includes default scrape configs for Kubernetes.
	
	**Step-by-step Deployment:**
	1. Add the Prometheus Helm repo:
	   ```bash
	   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	   helm repo update
	   ```
	2. Install Prometheus:
	   ```bash
	   helm install prometheus prometheus-community/prometheus
	   ```
	3. Verify Prometheus pods:
	   ```bash
	   kubectl get pods
	   helm list
	   ```

	**Automate Adding Prometheus as a Grafana Data Source:**

	After installing Prometheus and Grafana, you can automate adding Prometheus as a data source in Grafana using the Grafana HTTP API:

	1. Port-forward Grafana to your local machine:
	   ```bash
	   kubectl port-forward svc/grafana 3000:80
	   ```
	2. Port-forward Prometheus to your local machine:
	   ```bash
	   kubectl port-forward svc/prometheus-server 9090:9090
	   ```
	3. Add Prometheus as a data source in Grafana using a script:
	   ```bash
	   curl -X POST http://localhost:3000/api/datasources \
	     -H "Content-Type: application/json" \
	     -u admin:admin \
	     -d '{
	       "name":"Prometheus",
	       "type":"prometheus",
	       "url":"http://localhost:9090",
	       "access":"proxy",
	       "basicAuth":false
	     }'
	     # Change admin:admin if you set a different Grafana password.
	   ```

	This will automatically add Prometheus as a data source in Grafana, making dashboards ready to use.

- **Prometheus Operator (Advanced Monitoring)**
	- https://github.com/prometheus-operator/kube-prometheus
	- For advanced monitoring and alerting setups.
	
	**Step-by-step Deployment:**
	1. Follow the official guide: https://github.com/prometheus-operator/kube-prometheus#installing
	2. Clone the repo and apply manifests as described for your environment.

- **Project 2: Alerting Setup**
	- Configure basic alerts in Prometheus (e.g., node down, high CPU)
	- Trigger and acknowledge alerts

---

Feel free to suggest additional topics or improvements!

## Resources

### Official Documentation & Resources
- [Kubernetes](https://kubernetes.io/docs/)
- [k0s](https://docs.k0sproject.io/latest/)
- [Helm](https://helm.sh/docs/)
- [Multus](https://github.com/k8snetworkplumbingwg/multus-cni)
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