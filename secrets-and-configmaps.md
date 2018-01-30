# Fun with configmaps, secrets and environment variables.

### Connect to kubernetes dashboard
gcloud dashboard: [https://console.cloud.google.com/kubernetes/workload?project=versus-project-192600](https://console.cloud.google.com/kubernetes/workload?project=versus-project-192600&organizationId=1016801455083  )  

kubernetes dashboard:
```console
gcloud container clusters get-credentials fippy --zone us-central1-a --project versus-project-192600
kubectl proxy
http://localhost:8001/ui
```

#### Logs
[https://console.cloud.google.com/logs/viewer?project=versus-project-192600](https://console.cloud.google.com/logs/viewer?project=versus-project-192600&organizationId=1016801455083&minLogLevel=0&expandAll=false&timestamp=2018-01-29T18:24:38.340000000Z&dateRangeStart=2018-01-29T17:24:38.637Z&dateRangeEnd=2018-01-29T18:24:38.637Z&interval=PT1H&resource=container%2Fcluster_name%2Ffippy%2Fnamespace_id%2Fdefault)

# Set up a release
  - get all namespaces
  ```
  kubectl get namespaces
  ```
  - create your own namespace.
  ```
  gcloud container builds submit --tag gcr.io/versus-project-192600/<your-app-name>:<semver-tag> . --project versus-project-192600
  ```
  - Create a helm chart
  ```
  helm create chart
  ```
  - Update `image.repository` and `image.tag` of the values.yaml file with your image repository and tag.
  - Update:
  ```yaml
  service:
    name: <your-app-name>
    type: LoadBanancer
    externalPort: 80
    internalPort: 3000
  ```
  - Install your release on kubernetes.
  ```
  helm install -n <your-release-name> chart/ --namespace <your-namespace-name>
  ```

# Set environment variables
- Make url quotes url "dynamic"
  - Add an entry to the `values.yaml` file.
  ```yaml
  app:
    url: http://quotes.rest/qod.json
  ```
  - Edit `deployment.yaml` and add environment variable into the container.
  ```yaml
  spec:
    containers:
      - name: {{ .Chart.Name }}
        env:
          name: SERVICE_URL
          value: {{ .Values.app.url }}
      ...
  ```
  - Edit `app.rb` to pull url from the `SERVICE_URL` the environment variable.
  ```
  uri = URI(ENV["SERVICE_URL"])
  ```
  - Submit your app with a new tag.
  - Update values.yaml with your new tag.
  - Upgrade your release.
  ```
  helm upgrade <your-release-name> chart/
  ```

- Add url into a configmap [[docs](https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#create-a-configmap)].
  - create configmap in your namespace.
  ```console
  kubectl create configmap service --from-literal=url=http://quotes.rest/qod.json --namespace <your-namespace-name>
  ```
  - pull configmap value into the environment variable.
  ```yaml
  env:
    name: SERVICE_URL
    valueFrom:
	    configMapKeyRef:
        name: service
        key: url
  ```
	- update your release
	```console
  helm upgrade <your-release-name> chart/
	```
//Eleanor stopped here
	- Make sure there is no errors.

- Connect to an internal service using a secret [[docks](https://kubernetes.io/docs/concepts/configuration/secret/)].
  - Figure out the service's api.
  - Create secret in your namespace.
  ```console
  kubectl create secret generic service --from-literal=url=http://<internal-service-url>/ping
  ```
  - Pull secret value into an environment variable.
  ```yaml
  env:
    name: PING_API_URL
		valueFrom:
			secretKeyRef:
				name: service
				key: url
  ```
	- Update release.
	- try the `/ping` endpoint.

- Update a secret.
Secrets are stored as base64, so before editing any value needs to be encoded into base64
	- edit secret
	```
	kubectl edit secret service --namespace <your-namespace-name>
	```
  - encode new url into base64
  ```
  echo http://<interval-service-url>/pong | base64
  ```
	- update the `data.url` value with the `base64` of the new url.
  ```
  data:
    url: LKYGPKJGOJKLJKHL=
  ```
  - save file.
	- Updating the secret doesn't update the current release, you need to upgrade it.
	```console
  helm upgrade <your-release-name> chart/
	```

NOTE: To update a configmap is a similar process, except that you won't need to encode the value.
