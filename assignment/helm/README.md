# demo-app Helm Chart

This Helm chart deploys a simple Python app that exposes Prometheus metrics (requests, latency, memory usage) for Kubernetes monitoring labs.

## Usage

1. **Build and push the app image** (if not already done):
   ```bash
   cd ../demo-app
   docker build -t ghcr.io/<your-github-username>/demo-app:latest .
   docker push ghcr.io/<your-github-username>/demo-app:latest
   ```

2. **Install the chart:**
   ```bash
   helm install demo-app ./demo-app-helm
   ```

3. **Verify deployment:**
   ```bash
   kubectl get pods
   kubectl get svc demo-app
   ```

4. **Prometheus integration:**
   - The deployment includes Prometheus scrape annotations.
   - Metrics are available at `/metrics` on port 8000.

## Customization
- Edit `values.yaml` to change image, replica count, or service port.

## Uninstall
```bash
helm uninstall demo-app
```

---

This chart is designed for hands-on telemetry and observability labs. All code is open source and can be customized for teaching and assignments.
