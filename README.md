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
1. Set up a virtualization environment (e.g., VirtualBox, VMware, KVM) for isolated labs or spin up a WSL instance
2. Ensure you have administrative (sudo) access on your system
3. Update your system packages to the latest versions
4. Install a modern web browser for accessing dashboards

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

### Supported Platforms
- Debian/Ubuntu
- SUSE/openSUSE
- Red Hat/CentOS/Fedora
- Windows 10/11 with WSL2

---

### Quick Start: Cloning and Syncing This Repository

To get started with the course materials:

1. **Clone the repository:**
   ```bash
   git clone https://github.com/unusualfor/advanced-kubernetes.git
   cd advanced-kubernetes
   ```
2. **Keep your local copy up to date:**
   ```bash
   git pull
   ```
   Run this command regularly to fetch the latest updates and improvements.

### k0s setup

Depending on the status of your system, you have 3 cases shown below. 
Please consider which one suits your system better before running.

> The script requires sudo privileges and should be run from the repository root.

#### Case 1 - First install: setup k0s

To automate your lab environment setup and avoid common issues, use the unified script:

**Run the setup:**
   ```bash
   ./infra/k0s.sh setup
   ```
   This will stop Docker, clean up iptables, install and start k0s, and configure your kubeconfig.

#### Case 2 - Restart k0s after a reboot

> **Note**: To allow co-existance of Docker and k0s in the lab environment, Docker is only temporarily stopped from running and, at system restart, will start again.
This means that the above script disables k0s from starting at system boot.
In general, in production environments, only k0s (or Docker) would be installed and start at boot.

```bash
./infra/k0s.sh restart
```

#### Case 3 - Reset k0s to start from a clean environment

Should you want to start clean, you can use the below:

   ```bash
   ./infra/k0s.sh reset
   ```
   This will clean up any previous state and start fresh.

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
In this lab we will refer to Helm 4. Helm 3 would work well too, in case you are used to that already.

Refer to the installation instructions below:
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | VERIFY_CHECKSUM=false bash
```

> **Note**: *VERIFY_CHECKSUM=false* is set because most WSL instances do not have complete openssl suites installed. In a production environment, *VERIFY_CHECKSUM* must be set to true (i.e. default option for the Helm install script).
If you are curious, you can try forcing *VERIFY_CHECKSUM=true* and in case the installation fails because of openssl, install it with:
```bash
# Debian / Ubuntu
apt update
apt install openssl -y

# Red Hat / Fedora / CentOS
dnf install openssl -y
```

After installation, verify with:
```bash
helm version
```

### Helm Reference Commands 
Helm charts can be created from scratch or downloaded from repositories. Common operations include:
- Creating a new chart: `helm create <chart-name>`
- Installing a chart: `helm install <release-name> <chart>`
- Upgrading a release: `helm upgrade <release-name> <chart>`
- Uninstalling a release: `helm uninstall <release-name>`
- Listing releases: `helm list`

### Helm Chart Folder Structure (What’s Inside `helm/`)
This repository includes already a helm chart in the helm/ folder.
While the helm chart can be packaged and distributed through a centralized registry, in this example it is provided in the helm/ folder to allow you to explore what this chart is doing file by file.

A typical Helm chart folder contains:
- `README.md` — (Optional) Documentation for the chart
- `Chart.yaml` — Metadata about the chart (name, version, description)
- `values.yaml` — Default configuration values (can be overridden with `--set` or custom files)
- `templates/` — Directory containing Kubernetes manifest templates (e.g., `deployment.yaml`, `service.yaml`, `configmap.yaml`). These files define the resources for your application and are dynamically rendered using values from `values.yaml` and any `--set` parameters provided during installation.

When you run `helm install ... helm/`, Helm dynamically renders all templates using your configuration values, then applies the resulting manifests to the Kubernetes API (equivalent of several *kubectl apply -f file.yaml* operations). 
This automates what would otherwise be a manual, error-prone process of editing and applying each file in `templates/` individually—an approach that quickly becomes unmanageable for large or complex applications.
You can customize deployments by editing `values.yaml`, passing parameters with `--set`, or modifying the files in `templates/`.

### Exercise 1: Hands-on Helm 
- Objective: Deploy a custom app using a local Helm chart
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
	  ```

  4. Check that the custom variables have been deployed correctly in the webserver applications:
	  ```bash
	  ciaoIP=$(kubectl get po -n ciao-app -o jsonpath="{.items[*].status.podIP}")
	  curl $ciaoIP

	  helloIP=$(kubectl get po -n hello-app -o jsonpath="{.items[*].status.podIP}")
	  curl $helloIP	  
	  ```

#### Bonus: Modify the Custom Chart
- Objective: Take the custom Helm chart and change the title of the webpage. You should be able to do it by just changing two lines.
- Steps:
	1. Modify *helm/values.yaml* to include a new line *customPage*. Use *customText* as an example.
	3. Customize the *templates/configmap.yaml* by including the variable *customPage* between *<title>* and *</title>*. Use the line with *<h1>{{ .Values.customText }}</h1>* as an example.
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

## Module 2: Service Mesh


### Introduction to Istio
Istio is a popular open-source service mesh that provides advanced traffic management, security, and observability for microservices running in Kubernetes. It enables you to control, secure, and monitor service-to-service communication without modifying application code. Kiali is an observability console for Istio, offering service mesh visualization, traffic flow analysis, and configuration validation.

> **Why Istio?**  
> Istio is widely adopted in production environments for its rich feature set, strong community support, and seamless integration with Kubernetes. Compared to other service meshes (e.g., Linkerd, Consul), Istio offers advanced traffic control, security policies, and deep observability, making it ideal for telco and enterprise scenarios.

**Key Concepts:**
- **Service Mesh:** An infrastructure layer that transparently manages service-to-service communication, enabling features like traffic control, security, and observability.
- **Envoy Proxy:** A lightweight sidecar proxy deployed with each service, intercepting all inbound and outbound traffic to enable routing, security, and telemetry.
- **Control Plane (Istiod):** The component that manages configuration, policies, and service discovery for the mesh.
- **Data Plane:** The network of Envoy proxies that handle actual traffic between services, enforcing policies and collecting telemetry.

### Traffic Management, Security, and Observability
- **Traffic Management:** Enables advanced routing, load balancing, blue/green deployments, and canary releases for safer application updates.
- **Security:** Provides mutual TLS, authentication, and authorization between services, ensuring secure and compliant communication.
- **Observability:** Offers telemetry, tracing, and monitoring of service interactions, helping you visualize traffic flows and troubleshoot issues quickly.

#### Exercise 1: Install Istio and Verify

- Objective: Deploy Istio and confirm system components are running
- Steps:
  1. **Installation options:** Istio can be installed either via Helm chart or using *istioctl*, the official CLI tool. For simplicity and consistency in labs, we use *istioctl*, which automates many steps and is recommended for beginners. In production, Helm charts are often used for advanced customizations and CI/CD integration.

	  **Quick install (recommended for labs):**

	  ```bash
	  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.28.0 sh - # Downloads and extracts the specified Istio version.
	  export PATH="$PWD/istio-1.28.0/bin:$PATH" # Adds Istio binaries to your PATH for easy access.
	  istioctl install --set profile=minimal -y # Installs Istio with the minimal profile, suitable for labs and quick demos.
	  ```

	  **Verify installation:**
	  ```bash
	  kubectl get pods -n istio-system # Checks that Istio components are running in the `istio-system` namespace.
	  ```

	  Refer to the [Istio documentation](https://istio.io/latest/docs/setup/) for advanced options and production-grade profiles.

	  **Troubleshooting tips:**
	  - If pods are not starting, check events with `kubectl describe pod <pod-name> -n istio-system`.
	  - Ensure your cluster has enough resources (CPU, RAM).
	  - If `istioctl` is not found, verify your PATH and installation steps.

  2. **Install observability tools:** Kiali is an observability console for Istio, providing service graph, traffic flow, and configuration validation. By default, Kiali requires additional telemetry tools such as Prometheus and Grafana to display data in its UI.

	  **Quick install (recommended for labs):**
	  - The following commands deploy Kiali, Prometheus, and Grafana in your cluster:
	  ```bash
	  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/kiali.yaml
	  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/prometheus.yaml
	  kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/addons/grafana.yaml
	  ```
	  **Verify installation:**
	  ```bash
	  kubectl get pods -n istio-system -w # Watches the status of pods in the `istio-system` namespace until they are running.
	  ```

	  **Troubleshooting tips:**
	  - If pods are stuck in `Pending` or `CrashLoopBackOff`, check logs with `kubectl logs <pod-name> -n istio-system`.
	  - Network or resource issues may delay startup; ensure your environment meets requirements.

  3. **Access Kiali dashboard:**
	  We will temporarily forward the Kiali service to your local machine. Ideally, this could be handled differently (e.g. Ingress, NodePort, etc.), but given the scope of the exercise and the nature of the tool (debug, not production) this is the easiest approach.
	  
	  ```bash
	  kubectl port-forward -n istio-system svc/kiali 20001:20001
	  ```
	  The dashboard will be accessible at [http://localhost:20001](http://localhost:20001) while the terminal session is active.
	  > **Note:** The port-forward session must remain open to access Kiali. Close the terminal or interrupt the command to stop access. If you plan to run other commands while the UI stays open, you can consider either to open another terminal shell or append *" &"* by the end of the previous command (in this case, remember to close it when done with *"fg"* command and CTRL+C).

	  You can navigate through the UI, but at this point you will not see much until sample applications are deployed and traffic is generated.

#### Exercise 2: Deploy Sample Application
This is a revised example out of https://istio.io/latest/docs/setup/install/multicluster/verify/


- Objective: Deploy a sample app with Istio sidecars injected
- Steps:
  1. **Namespace labeling and sidecar injection:**
	  - Istio uses automatic sidecar injection to add an Envoy proxy container to each pod in a labeled namespace. This enables traffic management, security, and observability features for all services in that namespace.
	  - The label `istio-injection=enabled` triggers this behavior.
	  ```bash
	  kubectl create namespace demo
	  kubectl label namespace demo istio-injection=enabled
	  ```

  2. **Deploy the sample app:**
	  - The sample app (`helloworld.yaml`) is a simple HTTP service used for demonstration and testing Istio features. Deploy it to the labeled namespace:
	  ```bash
	  kubectl apply -n demo -f https://raw.githubusercontent.com/istio/istio/release-1.28/samples/helloworld/helloworld.yaml
	  kubectl get pods -n demo -w 
	  ```

  3. **Verify sidecar injection:**
	  - Each pod should have two containers: the application and the `istio-proxy` (Envoy sidecar). To check:
	  ```bash
	  kubectl describe pod -n demo | grep -A 5 "Containers:"
	  ```
	  - You should see both the app container and `istio-proxy` listed. Alternatively, use:
	  ```bash
	  kubectl get pods -n demo -o jsonpath='{.items[*].spec.containers[*].name}'
	  ```
	  - In the Kiali UI, the application will appear under the "Applications" tab once pods are running.

  4. **Generate traffic for observability:**
	  - Open the Traffic Graph in Kiali and select the *demo* namespace
	  - The Traffic Graph in Kiali will not show much until traffic is generated. Use the provided script to simulate requests:
	  ```bash
	  istio/helloworld-traffic.sh
	  ```
	  - Kiali UI will now show the ongoing traffic and service interactions.

  **Troubleshooting tips:**
  - If pods do not have the `istio-proxy` sidecar, ensure the namespace is labeled correctly and that Istio's sidecar injector webhook is running (`kubectl get pods -n istio-system | grep injector`).
  - If pods are stuck or not starting, check logs with `kubectl logs <pod-name> -n demo` and describe events with `kubectl describe pod <pod-name> -n demo`.
  - If Kiali UI does not show the app, verify that traffic is being generated and pods are healthy.

#### Exercise 3: Security

- Objective: Enable mutual TLS (mTLS) between services for secure communication
- Steps:
  1. **Apply Istio PeerAuthentication policy:**
	  - Mutual TLS (mTLS) encrypts traffic between services, ensuring both authentication and confidentiality. This is a best practice for production environments.
	  - The PeerAuthentication policy configures Istio to require mTLS for all workloads in the namespace.
	  ```bash
	  kubectl apply -f istio/mtls.yaml
	  ```

  2. **Restart deployments and generate traffic:**
	  - Restarting the deployments ensures that the new mTLS policy is picked up by all pods.
	  ```bash
	  kubectl rollout restart deployment -n demo helloworld-v1 helloworld-v2
	  istio/helloworld-traffic.sh
	  ```

  3. **Verify encrypted communication in Kiali UI:**
	  - In the Traffic Graph, select the Display menu and click on Badges/Security.
	  - A lock icon will appear on the links between services, indicating that mTLS is active and traffic is encrypted.

  **Troubleshooting tips:**
  - If the lock badge does not appear, check that the PeerAuthentication policy was applied and that all pods have been restarted.
  - Use `kubectl get peerauthentication -n demo` to verify the policy is present.
  - Check pod logs and events for errors related to mTLS or sidecar injection.

#### Exercise 4: Complex application traces
This is a simplified example taken from https://kiali.io/docs/tutorials/travels/


- Objective: Deploy a complex sample application composed of multiple microservices and visualize traces in Kiali
- Steps:
  1. **Install and label namespaces for sidecar injection:**
	  - The travel demo application consists of several microservices deployed across three namespaces. Label each namespace to enable automatic Envoy sidecar injection for observability and traffic management.
	  ```bash
	  kubectl create namespace travel-agency
	  kubectl create namespace travel-portal
	  kubectl create namespace travel-control

	  kubectl label namespace travel-agency istio-injection=enabled
	  kubectl label namespace travel-portal istio-injection=enabled
	  kubectl label namespace travel-control istio-injection=enabled
	  ```

  2. **Deploy the travel demo microservices:**
	  - Apply the manifests for each part of the application. These will create multiple interconnected services for a realistic microservices scenario.
	  ```bash
	  kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml) -n travel-agency
	  kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml) -n travel-portal
	  kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml) -n travel-control
	  ```

  3. **Visualize traffic and traces in Kiali UI:**
	  - Once the pods are running and traffic is generated, open the Kiali dashboard and explore the Traffic Graph and Traces tabs. You should see multiple services interacting, with traces showing request flows across namespaces.

  4. **Check mTLS status:**
	  - In Kiali, verify if mTLS is enabled by looking for the lock icon on service links. This shoudl be enabled by default given that the PeerAuthentication resource applied in the previous exercise was applied globally and not restricted to a single namespace.

  **Troubleshooting tips:**
  - If services do not appear in Kiali, check that all namespaces are labeled for injection and pods are healthy.
  - If traffic is not visible, ensure requests are being made between services (some demos include built-in traffic generators).
  - Use `kubectl get pods -n <namespace>` and `kubectl logs <pod-name> -n <namespace>` to diagnose issues.

---

## Istio Cleanup

To remove the sample applications and namespaces deployed for Istio labs, run:

```bash
# Remove helloworld demo
kubectl delete namespace demo

# Remove travel demo applications and namespaces
kubectl delete namespace travel-agency
kubectl delete namespace travel-portal
kubectl delete namespace travel-control
```

These commands may take a few minutes to complete, as Kubernetes will clean up all resources in the specified namespaces. You can safely press CTRL+C after a few seconds—the deletion request will continue in the background.

This cleanup step ensures your cluster is ready for the next exercises and prevents resource conflicts or leftover objects from previous labs.

---

### Istio Recap: Why Istio Is Important

Istio is a powerful service mesh for Kubernetes, providing advanced traffic management, security, and observability. It enables:
- Fine-grained control over service-to-service communication, allowing you to direct, split, and monitor traffic between microservices.
- Secure connections with mutual TLS (mTLS) and policy enforcement, protecting sensitive data and ensuring compliance.
- Deep visibility into microservice interactions and performance, making troubleshooting and optimization much easier.
- Resilient traffic routing, load balancing, and fault injection for robust, production-grade deployments.

**General Kubernetes Usefulness:**
Istio simplifies the management of complex microservice architectures, enforces security policies, and provides actionable insights into application behavior. Its integration with tools like Kiali, Prometheus, and Grafana makes it a cornerstone of modern Kubernetes operations.

**Telco/Enterprise Environment Example:**
In telecommunications and enterprise environments, Istio is especially valuable for:
- Managing network functions and O&M networks with strict security and traffic requirements
- Enabling service chaining, dynamic routing, and multi-tenant architectures
- Providing end-to-end encryption and authentication between network components
- Supporting policy-driven control for compliance and operational efficiency

*Istio empowers operators and developers to deliver secure, observable, and adaptable network services, making it a key technology for cloud-native NFV, SDN, and 5G deployments as well as large-scale enterprise applications.*

---

## Module 3: Telemetry

### Introduction to Telemetry in Kubernetes

Telemetry refers to the collection, processing, and visualization of metrics, logs, and traces from applications. In Kubernetes clusters, where microservices are generally deployed, telemetry is essential for monitoring cluster health, troubleshooting issues, and optimizing performance. This module builds on previous Istio/Kiali exercises and guides you through setting up a production-like observability stack using Helm.

**Key Concepts:**

- **Metrics:** Quantitative data about resource usage and application performance (e.g., CPU, memory, request rates). Collected by Prometheus.
- **Logs:** Textual records of events and errors from containers and system components. Aggregated by tools like Loki.
- **Traces:** Distributed request flows across microservices, useful for debugging and performance analysis. Visualized with Jaeger or Tempo.
- **Dashboards:** Visualizations of metrics and logs for quick insights, typically created in Grafana.

### Common Tools

- **Prometheus:** The de facto standard for metrics collection and storage in Kubernetes. Scrapes metrics from cluster components and applications.
- **Grafana:** Visualization and dashboarding tool. Connects to Prometheus and other data sources to create interactive dashboards.
- **Loki:** Log aggregation system designed for Kubernetes. Integrates with Grafana for unified metrics and logs.
- **Jaeger/Tempo:** Distributed tracing tools that help visualize request flows across microservices. Useful for debugging latency and dependencies.

### Exercise 1: Installing Prometheus and Grafana

We already installed Prometheus and Grafana when working with [Istio and Kiali](#module-2-istio). In this exercise, we install them officially through Helm to simulate a production setup and explore advanced configuration options. This approach allows for easier upgrades, customizations, and integration with CI/CD pipelines.

Refer to the official documentation for advanced options and best practices.

**Quick install using Helm:**

```bash
# Add the official Helm repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Prometheus
helm install prometheus prometheus-community/prometheus --set server.persistentVolume.enabled=false --set server.service.nodePort=30303 --set server.service.type=NodePort --set alertmanager.persistence.enabled=false

# Install Grafana
helm install grafana grafana/grafana --set adminPassword=admin --set service.type=NodePort --set service.nodePort=30405
```

> **Security Note:** The default Grafana credentials are `admin` / `admin`. Change these in production environments to prevent unauthorized access.

Verify installation:

```bash
kubectl get pods
helm list
```

If Prometheus and Grafana pods are not running, check their logs and events:
```bash
kubectl logs <pod-name>
kubectl describe pod <pod-name>
```

Retrieve how to access Prometheus and Grafana services:

```bash
# Get the Prometheus server URL by running these commands in the same shell:
export PNODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services prometheus-server)
export PNODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo "Prometheus UI: http://$PNODE_IP:$PNODE_PORT"

# Get the Grafana URL to visit by running these commands in the same shell:
export GNODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services grafana)
export GNODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
echo "Grafana UI: http://$GNODE_IP:$GNODE_PORT"
```

If you cannot access the UIs, check that your cluster nodes are reachable and that NodePort services are correctly exposed.

### Exercise 2: Setting Up Telemetry in Grafana

- Objective: Configure Prometheus to collect metrics from your Kubernetes cluster and visualize them in Grafana using ready-made dashboards.
- Steps:
  1. **Prerequisites**
	  - Prometheus and Grafana are installed (see [Module 2](#module-2-istio)).
	  - You have access to your cluster via `kubectl` (see [Kubernetes Distribution: k0s](#kubernetes-distribution-k0s)).
	  - Helm is installed and configured (see [Module 1](#module-1-helm)).

  2. **Ensure Prometheus Is Scraping Cluster Metrics**
	  - Prometheus should be configured to scrape metrics from Kubernetes components. If you installed Prometheus using the official Helm chart, default scrape configs are included and you do not need to do anything.
	  - To verify, open the Prometheus UI and check the "Targets" page (or simply, hit http://$PNODE_IP:$PNODE_PORT/targets). All expected Kubernetes endpoints should be listed as "up".

  3. **Access Prometheus and Grafana UIs**
	  - Use the commands above to retrieve the NodePort URLs. Open the Grafana URL in your browser.
	  - Default login: `admin` / `admin` (unless changed during install).

  4. **Add Prometheus as a Data Source in Grafana**
	  - In Grafana, go to **Connection → Data Sources → Add data source**.
	  - Select **Prometheus**.
	  - Set the URL to the Prometheus address found above.
	  - Click **Save & Test**. It should return that Prometheus was successfully queried.

  5. **Import Kubernetes Monitoring Dashboards**
	  - Use the following ready-made dashboards for cluster and node monitoring.
	  - **Kubernetes Cluster Monitoring Dashboard:**
		 - Dashboard ID: `6417`
		 - Source: https://grafana.com/grafana/dashboards/6417
	  - **Node Exporter Full Dashboard:**
		 - Dashboard ID: `1860`
		 - Source: https://grafana.com/grafana/dashboards/1860
	  - To import:
		 1. In Grafana, click **Dashboards → Import**.
		 2. Enter the dashboard ID (`6417` or `1860`) and click **Load**.
		 3. Select your Prometheus data source.
		 4. Click **Import**.
	  - You should now be able to visualize the dashboards and the metrics being collected.

  6. **Explore Cluster Metrics**
	  - Open the imported dashboards.
	  - Review metrics such as CPU, memory, pod status, and node health.
	  - Use filters and time ranges to analyze cluster performance.

  7. **Customize Dashboards and Alerts**
	  - Add panels for custom metrics.
	  - Set up alerts for critical conditions (e.g., high CPU, pod failures).

  **Troubleshooting tips:**
  - If Prometheus targets are not showing up or are down, check the Prometheus configuration and pod logs.
  - If Grafana login fails, reset the admin password using Helm or check the pod logs for errors.
  - If NodePort services are not accessible, verify your cluster networking and firewall settings.

  **Advanced exploration (optional):**
  - Configure custom scrape jobs in Prometheus for additional applications.
  - Add Loki for log aggregation and visualize logs in Grafana.
  - Explore distributed tracing with Jaeger or Tempo for deeper insights into request flows.

---

### Telemetry Recap: Why Telemetry Is Essential

Telemetry in Kubernetes provides deep visibility into cluster and application health, enabling proactive monitoring, troubleshooting, and optimization. By collecting metrics, logs, and traces, you gain actionable insights for both development and operations.

**Key Benefits:**
- Monitor resource usage and application performance in real time
- Detect and troubleshoot issues before they impact users
- Visualize cluster health and trends with dashboards
- Set up alerts for critical conditions (e.g., high CPU, pod failures)
- Support capacity planning and scaling decisions

**General Kubernetes Usefulness:**
Telemetry tools like Prometheus and Grafana are foundational for:
- Observing workloads and infrastructure
- Ensuring reliability and availability
- Enabling data-driven operations and automation
- Integrating with service mesh (Istio) and other observability stacks

**Telco/Enterprise Example:**
In telco and enterprise environments, telemetry is vital for:
- Monitoring network functions and service quality
- Meeting SLAs and compliance requirements
- Rapidly diagnosing and resolving incidents
- Supporting multi-tenant and large-scale deployments

**Lab Takeaway:**
By completing the telemetry module, you learned how to:
- Install and configure Prometheus and Grafana in Kubernetes
- Expose and scrape custom application metrics
- Build and customize Grafana dashboards for real-time insights
- Integrate telemetry with service mesh and other tools
- Use monitoring data to drive operational decisions and improvements

Telemetry is a cornerstone of modern cloud-native operations, empowering teams to deliver robust, observable, and resilient services.

---

## Module 4: Custom Operator Lab (Hello Operator)


### Overview
This module introduces Kubernetes operators by building and deploying a custom operator using Python and Kopf. Operators are controllers that automate complex tasks in Kubernetes, such as managing stateful applications, backups, upgrades, and custom workflows. They extend Kubernetes with domain-specific logic and enable powerful automation.

#### Why Kopf?
Kopf is a Python framework that makes writing Kubernetes operators simple and approachable for developers familiar with Python. It abstracts away much of the boilerplate required for custom controllers, allowing you to focus on your business logic.
Note: While Kopf makes operator development accessible in Python, the majority of production-grade Kubernetes operators are written in Go, which is the native language of Kubernetes and its ecosystem. Python is great for learning and rapid prototyping, but Go is preferred for performance, maintainability, and community support in large-scale deployments.

#### What is the Hello Operator?
The Hello operator is a simple, educational Kubernetes operator written in Python using the Kopf framework. It watches for custom resources of type `Hello` in your cluster, which clearly is not a default Kubernetes resource. When a `Hello` resource is created, updated, or deleted, the operator automatically reconciles the desired state by creating, updating, or removing a corresponding ConfigMap containing a personalized greeting message.

This operator demonstrates:
- How to react to Kubernetes resource events (create, update, delete)
- How to implement reconciliation logic
- How to use RBAC for secure operation (minimal permissions for demo purposes)
- How to package and deploy an operator as a container with Helm

This lab provides a hands-on introduction to the operator pattern and automation in Kubernetes, showing how you can extend the platform with custom controllers.

### Learning Objectives
- Understand the operator pattern in Kubernetes and its real-world applications
- Deploy the operator as a pod and manage Custom Resource Definitions (CRDs) using Helm
- Work with the Custom Resources (CR) and see the reconciliation loop

### Lab Steps


#### 1. Install the Operator with Helm
```bash
helm install hello-operator operator/helm-hello-operator
```
*This will also apply the CRD automatically.*

> **What is a CRD?**
> A Custom Resource Definition (CRD) extends the Kubernetes API to allow you to create and manage new resource types, such as `Hello`. The operator watches for these resources and acts on them.

#### 2. Create a Custom Resource
```bash
kubectl apply -f operator/hello-francesco.yaml
```

#### 3. Verify Operator Pod and Functionality
Check the operator pod:
```bash
kubectl get pods -l app=hello-operator
```

Read the operator logs to see the reconciliation loop happening for the Hello resource created above:
```bash
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

#### 4. Update the Hello resource (or add another Hello resource) and observe reconciliation.
Copy the custom resource:
```bash
cp operator/hello-francesco.yaml operator/hello-$USER.yaml
# Modify operator/hello-$USER.yaml
kubectl apply -f operator/hello-$USER.yaml
```

Check operator logs, ConfigMap and the custom resource as per Step 3.

#### 5. Delete the Hello resource and observe reconciliation.
```bash
kubectl delete hellos.unusualfor.com --all
```

Check operator logs, ConfigMap and the custom resource as per Step 3.

#### 6. Clean Up
To remove the operator and all resources:
```bash
helm uninstall hello-operator
kubectl delete crd hellos.unusualfor.com
```

**Troubleshooting tips:**
- If the operator pod does not start, check its logs and events:
	```bash
	kubectl logs <pod-name>
	kubectl describe pod <pod-name>
	```
- If the ConfigMap is not created, ensure the operator is running and the custom resource was applied correctly.
- If you see RBAC errors, review the operator’s Role and RoleBinding for necessary permissions.

### Operator Recap: Why Operators Matter

Kubernetes operators automate the management of complex applications and resources by extending the Kubernetes API with custom controllers. Operators continuously reconcile the desired state (as defined in custom resources) with the actual state in the cluster.

**Key Benefits:**
- Automate routine tasks (deploy, update, backup, scale, heal)
- Enable custom logic for application lifecycle management
- Integrate domain-specific knowledge into cluster operations
- Improve reliability and reduce manual intervention

**General Kubernetes Usefulness:**
Operators are essential for running stateful, complex, or domain-specific workloads in Kubernetes. They allow you to:
- Package operational knowledge as code
- Respond automatically to changes in resources
- Manage custom resources beyond built-in Kubernetes objects

**Telco/Enterprise Example:**
In telco and enterprise environments, operators can manage network functions, databases, or middleware, ensuring high availability, automated failover, and seamless upgrades.

**Lab Takeaway:**
By building and deploying a custom operator, you learned how to:
- Define a Custom Resource Definition (CRD)
- Write reconciliation logic using Kopf (Python)
- Package and deploy the operator with Helm
- Secure the operator with RBAC
- Observe automated resource management in action

Operators are a powerful pattern for cloud-native automation and are widely used in production Kubernetes environments. By completing this module, you learned how to extend Kubernetes with custom automation using operators and CRDs.

---

## Assignment: Telemetry


**Objective:** Deploy a custom telemetry app, ensure Prometheus scrapes its metrics, and create a Grafana dashboard for visualization and analysis.

**Prerequisites:**
- Prometheus and Grafana are installed and running as per [Module 3](#module-3-telemetry)
- You have access to your cluster via `kubectl` and Helm

**Steps:**

1. **Deploy the telemetry app using Helm in the assignment namespace:**
	 - This command installs or upgrades the telemetry app using the provided Helm chart, creating the `assignment` namespace if it does not exist.
	 ```bash
	 helm upgrade --install assignment-app ./assignment/helm/ -n assignment --create-namespace
	 ```

2. **Verify the app is running in the assignment namespace:**
	 - Check that the pod and service for the demo app are present and running.
	 ```bash
	 kubectl get pods -n assignment -l app=demo-app
	 kubectl get svc -n assignment demo-app
	 ```

3. **Test metrics endpoint:**
	 - Retrieve the ClusterIP of the demo-app service:
		 ```bash
		 CLUSTER_IP=$(kubectl get svc -n assignment demo-app -o jsonpath='{.spec.clusterIP}')
		 ```
	 - Access the metrics endpoint exposed by the app:
		 ```bash
		 curl http://$CLUSTER_IP:8000/metrics
		 ```
	 - You should see Prometheus-formatted metrics output. If not, check the pod logs and service configuration.

4. **Check Prometheus targets:**
	 - Prometheus is exposed via NodePort. Retrieve the Prometheus server URL:
		 ```bash
		 export PNODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services prometheus-server)
		 export PNODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")
		 echo "Prometheus UI: http://$PNODE_IP:$PNODE_PORT"
		 ```
	 - Query Prometheus targets to confirm your app appears in `activeTargets` and is `up`:
		 ```bash
		 curl http://$PNODE_IP:$PNODE_PORT/api/v1/targets | jq .
		 ```
		 or just access http://$PNODE_IP:$PNODE_PORT/targets
	 - If your app does not appear or is not `up`, check the app's service annotations and Prometheus scrape configuration.

5. **Build a dashboard in Grafana:**
	 - After confirming metrics are available, create a custom dashboard or panel in Grafana using the metrics exposed by your app (e.g., request count, latency, memory usage).
	 - Example tasks:
		 - Visualize request rate over time
		 - Show average or maximum latency
		 - Display current memory usage
	 - Use Prometheus as the data source and select your app's metrics for visualization.

**Troubleshooting tips:**
- If the app pod is not running, check its logs and events:
	```bash
	kubectl logs <pod-name> -n assignment
	kubectl describe pod <pod-name> -n assignment
	```
- If metrics are not exposed, verify the app's configuration and that the `/metrics` endpoint is reachable.
- If Prometheus does not scrape the app, check service annotations and Prometheus configuration.
- If Grafana does not display metrics, verify the data source and query settings.

**Clean Up:**
To remove the assignment app and its resources:
```bash
helm uninstall assignment-app -n assignment
```

---

## Resources


### Official Documentation & Resources
- [Kubernetes Documentation](https://kubernetes.io/docs/) — Official docs for all Kubernetes concepts and APIs
- [k0s Documentation](https://docs.k0sproject.io/latest/) — Lightweight Kubernetes distribution used in this course
- [Helm Documentation](https://helm.sh/docs/) — Kubernetes package manager and chart reference
- [Prometheus Documentation](https://prometheus.io/docs/introduction/overview/) — Metrics collection and monitoring
- [Grafana Documentation](https://grafana.com/docs/) — Visualization and dashboarding platform
- [Istio Documentation](https://istio.io/latest/docs/) — Service mesh for traffic management, security, and observability
- [Kiali Documentation](https://kiali.io/) — Istio observability and service mesh visualization

### Recommended Reading
- [Kubernetes Patterns](https://www.oreilly.com/library/view/kubernetes-patterns/9781492050285/) — Design patterns for cloud-native applications
- [Istio Up & Running](https://www.oreilly.com/library/view/istio-up-and/9781492043775/) — Practical guide to Istio service mesh

### Community Forums & Support
- [Kubernetes Slack](https://slack.k8s.io/) — Community chat and support
- [Istio Discuss](https://discuss.istio.io/) — Istio Q&A and community forum
- [Kiali Community](https://kiali.io/community/) — Kiali user and developer community

---

## Contributing


### How to Contribute
All contributions to improve this class material are welcome! You can:
- Submit pull requests for corrections, enhancements, or new modules
- Report issues or suggest improvements via GitHub Issues
- Share feedback and ideas in any form

### Reporting Issues
If you find any errors or have suggestions, please open an issue in this repository or contact the maintainer. Your feedback helps make this course better for everyone.

---

Thank you for participating in the Advanced Kubernetes class! Keep exploring, experimenting, and contributing to the Kubernetes ecosystem. Your curiosity and input drive the community forward.

---