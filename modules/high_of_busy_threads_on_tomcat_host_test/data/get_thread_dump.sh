
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