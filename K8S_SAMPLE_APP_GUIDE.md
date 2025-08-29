# Guide: Deploying a Sample Application and Verifying Monitoring

This guide provides step-by-step instructions to:
1.  Deploy a sample "hello-kubernetes" application to your EKS cluster.
2.  Expose the application using the NGINX Ingress Controller.
3.  Verify that Prometheus is scraping metrics from the application.
4.  Visualize application metrics in Grafana.

## Prerequisites
- Your EKS cluster is running and you have configured `kubectl` to connect to it.
- The NGINX Ingress Controller, Prometheus, and Grafana are successfully deployed (as configured in the Terraform setup).

---

## Step 1: Deploy the "Hello World" Application

First, we will create the Kubernetes Deployment and Service for the sample application.

1.  **Create the manifest file:**
    Create a new file named `hello-k8s.yaml` and add the following content. This manifest defines a Service and a Deployment for the application. The `prometheus.io/scrape: 'true'` annotation on the service is crucial for Prometheus to discover and scrape metrics from it.

    ```yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: hello-kubernetes-service
      labels:
        app: hello-kubernetes
      annotations:
        prometheus.io/scrape: 'true'
        prometheus.io/port: '8080'
    spec:
      type: ClusterIP
      ports:
      - port: 80
        targetPort: 8080
      selector:
        app: hello-kubernetes
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: hello-kubernetes-deployment
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: hello-kubernetes
      template:
        metadata:
          labels:
            app: hello-kubernetes
        spec:
          containers:
          - name: hello-kubernetes
            image: paulbouwer/hello-kubernetes:1.10
            ports:
            - containerPort: 8080
    ```

2.  **Apply the manifest:**
    Use `kubectl` to deploy the application to the `default` namespace.
    ```bash
    kubectl apply -f hello-k8s.yaml
    ```

3.  **Verify the deployment:**
    Check that the pods and service have been created successfully.
    ```bash
    # Check for 2 running pods
    kubectl get pods -l app=hello-kubernetes

    # Check for the ClusterIP service
    kubectl get service hello-kubernetes-service
    ```

---

## Step 2: Expose the Application with an Ingress

Now, let's expose the `hello-kubernetes-service` to the internet using the NGINX Ingress Controller.

1.  **Create the Ingress manifest:**
    Create a new file named `hello-ingress.yaml` with the following content. This will route traffic from the Ingress Controller's load balancer to our service.

    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: hello-kubernetes-ingress
      annotations:
        # Use the NGINX Ingress class
        kubernetes.io/ingress.class: "nginx"
    spec:
      rules:
      - http:
          paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: hello-kubernetes-service
                port:
                  number: 80
    ```

2.  **Apply the Ingress manifest:**
    ```bash
    kubectl apply -f hello-ingress.yaml
    ```

3.  **Get the Load Balancer URL:**
    Find the external URL of the NGINX Ingress controller. It might take a minute or two for the external IP/hostname to become available.
    ```bash
    kubectl get svc -n ingress-nginx ingress-nginx-controller
    ```
    Look for the value in the `EXTERNAL-IP` column.

4.  **Access the application:**
    Open a web browser and navigate to the `EXTERNAL-IP` address. You should see the "Hello Kubernetes!" message.

---

## Step 3: Verify Prometheus Integration

Let's confirm that Prometheus is automatically scraping metrics from our new service.

1.  **Access the Prometheus UI:**
    Forward the Prometheus server port to your local machine.
    ```bash
    kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
    ```

2.  **Check Service Discovery Targets:**
    - Open your browser and go to `http://localhost:9090`.
    - Navigate to the **Status** -> **Targets** page.
    - In the list of targets, look for a job named `service/default/hello-kubernetes-service/0`.
    - The state of this target should be **UP**, which confirms that Prometheus is successfully scraping metrics.

3.  **Query a Metric:**
    - Go to the **Graph** page in the Prometheus UI.
    - In the expression bar, you can query for metrics related to the application, for example: `up{job="service/default/hello-kubernetes-service/0"}`.
    - Executing this query should return a value of `1`, confirming the service is up.

---

## Step 4: Visualize Metrics in Grafana

Finally, let's find the application's metrics in Grafana.

1.  **Access the Grafana Dashboard:**
    Forward the Grafana port to your local machine.
    ```bash
    kubectl port-forward -n monitoring svc/grafana 3000:80
    ```

2.  **Log in to Grafana:**
    - Open your browser and go to `http://localhost:3000`.
    - Log in with the default credentials (unless changed): `admin` / `prom-operator`.

3.  **Explore Pod Metrics:**
    - On the left-hand menu, go to **Dashboards**.
    - Find and open the dashboard named **Kubernetes / Compute Resources / Pod**.
    - In the dashboard filters at the top, select the `default` namespace and then select one of the `hello-kubernetes-deployment-xxxxxxxx-xxxxx` pods from the `Pod` dropdown.
    - You will now see detailed CPU and Memory usage graphs for your sample application pod.

You have now successfully deployed a sample application, exposed it via Ingress, and verified that it is being monitored by Prometheus and Grafana.
