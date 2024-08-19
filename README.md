# K8S Live Node.js Debugger Example

## How To
Minikube will be used as the k8s environment. If you don't have it installed check [the official doc](https://minikube.sigs.k8s.io/docs/).

1. start minikube 
```sh
minikube start
```
2. make the shell point to minikube's docker-daemon
```sh
eval $(minikube -p minikube docker-env)
```
3. build the docker image
```sh
docker build -t temp/myapp .
```
4. deploy the deployment and the service
```sh
kubectl apply -f .k8s/deployment.yaml
kubectl apply -f .k8s/service.yaml
```
5. execute the script and follwow the instructions
```sh
./.scripts/node_debugger.sh
```

## Cleanup
Execute this commands to clean minikube
```sh
k delete -f .k8s/deployment.yaml
k delete -f .k8s/service.yaml
minikube stop
```
