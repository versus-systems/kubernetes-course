## Connect to an app internally.

You can talk to an internal app through the internal DNS on this format.
```
http://<service-name>.<service-namespace>
```
There is a release called `internal-service`, you can run `helm status internal-service` or go to the dashboard to get more information about it. 

The service name is `internal-service-pingpong` and it's on the `default` namespace.
So the internal URL will be `http://internal-service-pingpong.default`.

1. Set the service url into an environment variable.
```
env:
  - name: PING_API_URL
    value: http://internal-service-pingpong.default/ping
```
2. Update your release.
```
helm upgrade <release-name> chart
```
3. Get your service's ip, visit your app on the browser and check the `/ping` endpoint. if you see `POING` you're good!.
4. 10 extra points to the first one that fixes the pingpong app to return `PONG` instead of `POING` and explain to everyone the process. The code is under the `ping-app` folder.

## Work with secrets
Add the url into a secret, and use the secret to pull out the pingpoing url into the environment variable instead.

how to delete a secret.
```
kubectl delete secret <secret-name> --namepsace <namespace-name>
```

1. Create a secret with the pingpoing url.
```
kubectl create secret generic <secret-name> --from-literal=url=http://internal-service-pingpong.default/ping
```
2. Instead of the hardcoded value, pull the pingpoing url from the secret into the `PING_API_URL` environment variable.
```
env:
  - name: PING_API_URL
    valueFrom:
      secretKeyRef:
        name: <secret-name>
        key: url
```
3. Update your release
```
helm upgrade <release-name> chart
```
4. Get your service's ip, visit your app on the browser and make sure the `/ping` endpoint is still working.

Updating a secret doesn't update the current pod's value, we'd have to create another secret, and update our environment variable to pull the url from the new secret.

1. Create v2 of the last secret with the new url.
```
kubectl create secret generic <secret-name>-v2 --from-literal=url=http://internal-service-pingpong.default/pong
```
2. Update `deployment.yaml` to pull url from the new secret.
```
  - name: PING_API_URL
    valueFrom:
      secretKeyRef:
        name: <secret-name>-v2
        key: url
```
3. Update release
```
helm upgrade <release-name> --namespace <namspace-name> chart
```
4. Get your service's ip, visit your app on the browser and make sure the `/ping` endpoint is still working. It should return "PING" now.
