#!/bin/bash

echo -e "Choose a deployment from the following list:\n"
kubectl get deployments -o json | jq -r '.items[].metadata.name'
echo -e ""
read -p "Deployment name: " deployment_name
read -p "Insert the port on which the app is running: " app_port

echo -e "\n---\nStarting the debugger..."

podname="debugger-${deployment_name}"

kubectl get pods --selector app==$deployment_name -o json | \
jq ".items[0] | .metadata.labels.app = \"${podname}\" | .metadata.name = \"${podname}\" | del(.spec.containers[0].livenessProbe) | {apiVersion, kind, metadata: {labels: {app: .metadata.labels.app}, name: .metadata.name, namespace: .metadata.namespace}, spec}" | \
kubectl apply -f - > /dev/null

if [ $? -ne 0 ]; then
    echo -e "\nError starting the debugger"
    exit 1
fi

kubectl wait --for=condition=ready pod ${podname} > /dev/null
echo -e "Debugger started\n"

echo "Enabling debugger on port 9229..."
kubectl exec -it ${podname} -- sh -c 'kill -USR1 $(pgrep node)'
echo -e "Port 9229 enabled\n"

echo "Forwarding debugger to port 9229 and the app to port ${app_port}..."
kubectl port-forward ${podname} 9229 ${app_port} &
port_forward_pid=$!

echo -e "\n---\nPress 'q' to stop port forwarding and exit the script\n---\n"
while true; do
    read -n 1 -s key
    if [[ $key == "q" ]]; then
        kill $port_forward_pid
        wait $port_forward_pid 2>/dev/null
        echo -e "\n---\nPort forwarding stopped"
        break
    fi
done

echo "Stopping the debugger..."
kubectl delete pod ${podname} > /dev/null
echo "Debugger stopped"
