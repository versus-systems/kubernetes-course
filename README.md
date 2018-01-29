# Hello world app

Just another Sinatra app with a Dockerfile with instruction to set it up on kubernetes.

- Build image
```console
docker build . -t <your-app-name>:<tag-name>
```
- Run image
```console
docker run -p 3000:3000 <your-app-name>:<tag-name>
```

# Kubernetes course

Connect to fippy cluster
```console
gcloud container clusters get-credentials fippy --zone us-central1-a --project versus-project-192600
```
Kubernetes Dashboard
- [google](https://console.cloud.google.com/kubernetes/workload?project=versus-project-192600&workload_list_tablesize=50)
- kubernetes ui
```console
kubectl proxy
# http://localhost:8001/ui
```

# Exercise

1. Clone course
```
git@github.com:versus-systems/kubernetes-course.git
cd kubernetes-course
```
2. Edit `app.rb` to return something else
3. **Submit your app to the registry**
```console
# Don't forget the `.` at the end which is the directory you'll upload to gcloud

gcloud container builds submit --tag gcr.io/versus-project-192600/<your-app-name>:<your-app-tag> . --project versus-project-192600

# https://console.cloud.google.com/gcr/images/versus-project-192600?project=versus-project-192600
```
4. Edit `kube/deployment.yaml` with your own image and your own app name.
5. **Create kubernetes deployment**
```console
kubectl create -f kube/deployment.yaml
```
6. **Get deployment info**
```console
kubectl get deployment <your-app-name>
kubectl describe deployment <your-app-name>
```
7. Edit `kube/service.yaml` with your own app name
8. **Create kubernetes service**
```console
kubectl create -f kube/service.yaml
```
9. **get service info**
```console
kubectl get service <your-service-name>
kubectl describe service <your-service-name>
```
10. Wait for load balancer to get created and visit its ip
```console
kubectl get service -w <your-app-name>
```
11. Add another endpoint to your app
12. Submit your app to the registry with a new tag
13. Update `kube/deployment.yaml` with your new tag
14. **Update kubernetes deployment**
```console
kubectl apply -f kube/deployment.yaml
```
15. Visit your new endpoint
16. Read your app logs
  - visit: [https://console.cloud.google.com/logs/](https://console.cloud.google.com/logs/viewer?project=versus-project-192600&resource=container%2Fcluster_name%2Ffippy%2Fnamespace_id%2Fdefault)
  - filter by `<your-app-name>` from "All Logs" dropdown
17. Delete deployment and service
```console
 kubectl delete deployment <your-app-name>
 kubectl delete service <your-app-name>
```

# [HELM](https://helm.sh/)
> The package manager for Kubernetes.
> Helm Charts helps you define, install, and upgrade even the most complex Kubernetes application.

## Useful helm commands

Install helm
```console
brew install kubernetes-helm
```

Install helm into kubernetes cluster
```console
helm init
```

Create new chart files
```console
helm create chart/
```

Finding charts
```console
helm search
helm search mysql
```

Install a chart
```console
helm install stable/mariadb --name <release-name> --namespace <default>
helm install <chart-path-folder> --name <deployment-name> --namespace <default>
```

Get releases installed
```console
helm list
```

Upgrade a release
```console
helm upgrade <release-name> -f <values.yaml>
```

# Exercise

1. Create a helm chart
```console
helm create chart
```
2. Upgrade `chart/values.yaml`
```yaml
# values.yaml
image:
  repository: gcr.io/versus-project-192600/<your-app-name>
  tag: <your-latest-tag>
service:
  name: <your-app-name>
  type: LoadBalancer
  internalPort: 3000
```
3. Upgrade `Chart.yaml`
```yaml
# Chart.yaml
description: <your-app-description>
name: <your-app-name>
```
4. Install your helm charts as a new release into kubernetes
```console
helm install -n <your-app-release-name> chart/
```
5. Add another endpoint to your app
6. Submit a new image with a new tag with your changes
7. Update `chart/values.yaml` with your new tag
8. Upgrade helm release
```console
helm upgrade <your-app-release-name> chart/
```
