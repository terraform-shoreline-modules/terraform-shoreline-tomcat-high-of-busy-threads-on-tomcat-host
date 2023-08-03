
#!/bin/bash

# Set the namespace, deployment, and container names
NAMESPACE=${NAMESPACE}
DEPLOYMENT=${DEPLOYMENT_NAME}
CONTAINER=${NAME_OF_TOMCAT_CONTAINER}

# Get the pod name for the deployment
POD=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT -o jsonpath='{.items[0].metadata.name}')

# Check if the pod is running
POD_STATUS=$(kubectl get pods -n $NAMESPACE $POD -o jsonpath='{.status.phase}')

if [[ $POD_STATUS != "Running" ]]; then
    echo "Error: Pod is not running"
    exit 1
fi

# Get the CPU usage of the container for the past 1 minute
CPU_USAGE=$(kubectl top pod $POD -n $NAMESPACE --containers=$CONTAINER --no-headers | awk '{print $2}')

# Check if the CPU usage is high
if (( $(echo "$CPU_USAGE > 80" |bc -l) )); then
    echo "High CPU usage detected"
    # Get logs for the container
    kubectl logs -n $NAMESPACE $POD -c $CONTAINER
fi