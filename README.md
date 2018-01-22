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

# Kubernetes curse

Connect to fippy cluster
```console
gcloud container clusters get-credentials fippy --zone us-central1-a --project versus-project-192600
```
Kubernetes Dashboard
- [google](https://console.cloud.google.com/kubernetes/workload?project=versus-project-192600&workload_list_tablesize=50)
- kubernetes ui
```
kubectl proxy
# http://localhost:8001/ui
```

# Execise

- Clone course
```
git@github.com:versus-systems/kubernetes-course.git
cd kubernetes-course
```
- Edit `app.rb` to return something else
- **Submit your app to the registry**
```console
# Don't forget the `.` at the end which is the directory you'll upload to gcloud

gcloud container builds submit --tag gcr.io/versus-project-192600/<your-app-name>:<your-app-tag> .

# https://console.cloud.google.com/gcr/images/versus-project-192600?project=versus-project-192600
```
- Edit `kube/deployment.yaml` with your own image and your own app name.
- **Create kubernetes deployment**
```console
kubectl create -f kube/deployment.yaml
```
- **Get deployment info**
```console
kubectl get deployment <your-app-name>
kubectl describe deployment <your-app-name>
```
- Edit `kube/service.yaml` with your own app name
- **Create kubernetes service**
```console
kubectl create -f kube/service.yaml
```
- **get service info**
```console
kubectl get service <your-service-name>
kubectl describe service <your-service-name>
```
- Wait for load balancer to get created and visit its ip
```console
kubectl get service -w <your-app-name>
```
- Add another endpoint to your app
- Submit your app to the registry with a new tag
- Update `kube/deployment.yaml` with your new tag
- **Update kubernetes deployment**
```console
kubectl apply -f kube/deployment.yaml
```
- Visit your new endpoint
- Read your app logs
  - visit: https://console.cloud.google.com/logs/viewer?project=versus-project-192600&resource=container%2Fcluster_name%2Ffippy%2Fnamespace_id%2Fdefault
  - filter by `<your-app-name>` from "All Logs" dropdown
- Delete deployment and service
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

- Create a helm chart
```console
helm create chart/
```
- Upgrade `chart/values.yaml`
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
- Upgrade `Chart.yaml`
```yaml
# Chart.yaml
description: <your-app-description>
name: <your-app-name>
```
- Install your helm charts as a new release into kubernetes
```console
helm install -n <your-app-release-name> chart/
```
- Add another endpoint to your app
- Submit a new image with a new tag with your changes
- Update `chart/values.yaml` with your new tag
- Upgrade helm release
```console
helm upgrade <your-app-release-name> chart/
```