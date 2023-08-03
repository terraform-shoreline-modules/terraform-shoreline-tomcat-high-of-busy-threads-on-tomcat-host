
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# High % of Busy Threads on Tomcat Host (TEST)
---

This incident type is triggered when the percentage of busy threads on a Tomcat host exceeds a certain threshold. This can indicate that the host is experiencing high traffic or that there is a problem with the configuration of the Tomcat server. The incident is resolved when the issue is addressed and the percentage of busy threads returns to a normal level.

### Parameters
```shell
# Environment Variables
export NAMESPACE="PLACEHOLDER"
export NAME_OF_TOMCAT_POD="PLACEHOLDER"
export NAME_OF_TOMCAT_CONTAINER="PLACEHOLDER"
export SERVICE_NAME="PLACEHOLDER"
export DEPLOYMENT_NAME="PLACEHOLDER"
export PATH_TO_JAVA_HOME="PLACEHOLDER"
export LOCATION_OF_THREAD_DUMP_FILE="PLACEHOLDER"
export NAME_OF_THREAD_DUMP_FILE="PLACEHOLDER"
export LOG_FILE_NAME="PLACEHOLDER"
export TOMCAT_CONFIG_FILE="PLACEHOLDER"
export POD_LABEL="PLACEHOLDER"
```

## Debug

### List all pods in the namespace
```shell
kubectl get pods -n ${NAMESPACE}
```

### Check the logs of a specific pod
```shell
kubectl logs ${NAME_OF_TOMCAT_POD} -n ${NAMESPACE}
```

### Check the CPU and memory usage of a specific pod
```shell
kubectl top pod ${NAME_OF_TOMCAT_POD} -n ${NAMESPACE}
```

### Check the status of the Tomcat service
```shell
kubectl describe svc ${SERVICE_NAME} -n ${NAMESPACE}
```

### Check the status of the Tomcat deployment
```shell
kubectl describe deployment ${DEPLOYMENT_NAME} -n ${NAMESPACE}
```

### Check the configuration of the Tomcat server
```shell
kubectl exec ${NAME_OF_TOMCAT_POD} -n ${NAMESPACE} -- cat ${TOMCAT_CONFIG_FILE}
```

### Improper configuration of the Tomcat server leading to inefficient use of threads and high utilization of the available threads.
```shell

#!/bin/bash

# Set variables
POD_NAME=${NAME_OF_TOMCAT_POD}
CONTAINER_NAME=${NAME_OF_TOMCAT_CONTAINER}
THREAD_DUMP_FILE=${NAME_OF_THREAD_DUMP_FILE}
THREAD_DUMP_LOCATION=${LOCATION_OF_THREAD_DUMP_FILE}
JAVA_HOME=${PATH_TO_JAVA_HOME}

# Get the PID of the Tomcat process
PID=$(kubectl exec $POD_NAME -c $CONTAINER_NAME -- bash -c "ps aux | grep tomcat | grep -v grep | awk '{print $2}'")

# Take a thread dump of the Tomcat process
kubectl exec $POD_NAME -c $CONTAINER_NAME -- bash -c "$JAVA_HOME/bin/jstack $PID > $THREAD_DUMP_LOCATION/$THREAD_DUMP_FILE"

# Analyze the thread dump to identify any stuck threads
STUCK_THREADS=$(grep -c "java.lang.Thread.State: WAITING (on object monitor)" $THREAD_DUMP_LOCATION/$THREAD_DUMP_FILE)

# Check if the number of stuck threads is above a certain threshold
if [[ $STUCK_THREADS -gt 10 ]]; then
  echo "High number of stuck threads detected. Possible cause: improper Tomcat configuration."
else
  echo "No stuck threads detected."
fi

```

### Bugs or defects in the application running on the Tomcat server leading to high thread usage.
```shell

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

```

---
### Diagnostics

* Increased traffic to the Tomcat server leading to increased thread usage and high utilization of the available threads.

* Improper configuration of the Tomcat server leading to inefficient use of threads and high utilization of the available threads.

* Inadequate hardware resources allocated to the Tomcat server leading to high utilization of available threads.

* Bugs or defects in the application running on the Tomcat server leading to high thread usage.

* Configuration changes or updates to the Tomcat server leading to unintended consequences that result in high thread utilization.

## Repair
---

### Identify and resolve any bottlenecks in the application code that may be causing excessive thread usage.
```shell
bash
#!/bin/bash

# Set variables
NAMESPACE=${NAMESPACE}
POD_NAME=${NAME_OF_TOMCAT_POD}
CONTAINER_NAME=${NAME_OF_TOMCAT_CONTAINER}
LOG_FILE=${LOG_FILE_NAME}

# Get logs from the container
kubectl logs $POD_NAME -c $CONTAINER_NAME -n $NAMESPACE > $LOG_FILE

# Search for thread-related messages in the logs
grep "Thread" $LOG_FILE

# Analyze thread usage patterns
# ...

# Identify potential bottlenecks in the application code
# ...

# Resolve any bottlenecks found
# ...

```

### Check the configuration of the Tomcat server to ensure that it is optimized for the expected traffic volume.
```shell
bash
#!/bin/bash

# Set variables
NAMESPACE=${NAMESPACE}
POD_LABEL=${POD_LABEL}
CONTAINER_NAME=${NAME_OF_TOMCAT_CONTAINER}
TOMCAT_CONFIG_FILE=${TOMCAT_CONFIG_FILE}

# Get the container ID for the Tomcat server
CONTAINER_ID=$(kubectl get pods -n $NAMESPACE -l $POD_LABEL -o jsonpath='{.items[0].status.containerStatuses[?(@.name=="'$CONTAINER_NAME'")].containerID}')

# Copy the Tomcat configuration file to a temporary location
kubectl cp $NAMESPACE/$POD_LABEL:$TOMCAT_CONFIG_FILE /tmp/tomcat.conf

# Check the configuration file for optimization
# (Replace the command below with the appropriate command for your specific configuration file format)
grep -r "threads" /tmp/tomcat.conf

# Clean up the temporary file
rm /tmp/tomcat.conf

```

---
### Remediations

* Check the configuration of the Tomcat server to ensure that it is optimized for the expected traffic volume.

* Increase the number of threads in the thread pool to handle the increased traffic.

* Identify and resolve any bottlenecks in the application code that may be causing excessive thread usage.

* Monitor the thread usage of the Tomcat server regularly to detect any potential issues before they become critical.

* Implement load balancing to distribute traffic across multiple Tomcat instances to reduce the risk of overloading a single instance.

* Consider upgrading the hardware or infrastructure supporting the Tomcat server if it is consistently experiencing high traffic levels.

* Analyze the logs and metrics of the Tomcat server to identify any patterns or anomalies that may be contributing to the high percentage of busy threads.

* Consult with other team members or subject matter experts to determine if there are any best practices or optimizations that can be implemented to improve the performance of the Tomcat server.