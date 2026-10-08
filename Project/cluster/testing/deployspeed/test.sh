#!/bin/bash

DEPLOYMENT_NAME="jupyter-notebook-server"
DEPLOYMENT_SELECTOR="app=jupyter-notebook"
DEPLOYMENT_FILE="/home/jon/Desktop/proj/BachelorsThesis/Project/cluster/notebook-server/chart.yaml"
NAMESPACE="arkouda"
IMAGE_TAG="large-image"
IMAGE_NAME="node20.lab.example:31320/arpyter:$IMAGE_TAG"
KUBECONFIG_PATH="/home/jon/.kube/admin.conf"
CONTAINER_SOCKET="unix:///var/run/containerd/containerd.sock"
TEST_ITERATIONS=200 # Number of iterations to test the deployment
LOG_DIR="/home/jon/Desktop/proj/BachelorsThesis/Project/data/pod-startup-time"
LOG_FILE="$LOG_DIR/$IMAGE_TAG-$(date +%s).json"

# Function to delete the deployment if it exists
delete_deployment() {
    kubectl -n $NAMESPACE --kubeconfig=$KUBECONFIG_PATH delete deployment $DEPLOYMENT_NAME  --ignore-not-found
    sleep 5 # Waits for 5 seconds to let the Kubernetes cluster update its state.

}

# Function to remove pulled images from all nodes 
remove_images_from_nodes() {
    run_on_heydar.sh "\
        crictl -r $CONTAINER_SOCKET images ls | \
        grep arpyter  | awk '{print \$3}' | \
        xargs -I {} crictl -r $CONTAINER_SOCKET rmi {}
    "
    sleep 10  # Waits for 10 seconds to ensure that the image removal has propagated to all nodes.
}

pull_image() {
    run_on_heydar.sh "\
        crictl -r $CONTAINER_SOCKET pull $IMAGE_NAME
    "   
    sleep 10 # Waits for 10 seconds to let the image be pulled on all nodes.
}

deploy() {
    local deployment_type=$1
    echo "Deleting deployment..."
    delete_deployment
    echo "Deployment deleted."

    # Record the start time
    local start_time=$(date +%s)

    # Deploy the Jupyter notebook server
    kubectl -n ${NAMESPACE} --kubeconfig=$KUBECONFIG_PATH apply -f ${DEPLOYMENT_FILE}

    # Wait until the deployment is available
    kubectl -n ${NAMESPACE} --kubeconfig=$KUBECONFIG_PATH wait --for=condition=available --timeout=100s deployment/${DEPLOYMENT_NAME} 

    # Record the end time after deployment is available
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Collecting the YAML data of the pod of the deployment and extracting the status conditions
    local conditions=$(kubectl -n ${NAMESPACE} --kubeconfig=$KUBECONFIG_PATH get pod -l ${DEPLOYMENT_SELECTOR} -o json | jq -r '.items[] | select(.status.conditions != null) | {conditions: [.status.conditions[] | {lastTransitionTime, status, type}]} | @json')
    echo "{\"deployment_type\": \"$deployment_type\", \"start_time\": \"$start_time\", \"end_time\": \"$end_time\", \"duration\": \"$duration\", \"conditions\": $conditions}" >> $LOG_FILE

}

test_deployment() {
    # Clear previous log file
    > $LOG_FILE

    # Pull the image on all nodes
    echo "Pulling image on all nodes..."
    pull_image
    echo "Image pulled on all nodes."

    for i in $(seq 1 $TEST_ITERATIONS); do
        echo "Iteration $i of $TEST_ITERATIONS"

        # Test with a pull 
        echo "Testing deployment with image pull..."
        deploy "warm"
        echo "Deployment with pull completed. Duration and conditions logged."

    done

    for i in $(seq 1 $TEST_ITERATIONS); do
        # Remove images from all nodes
        echo "Removing images from all nodes..."
        remove_images_from_nodes
        echo "Image removal from all nodes completed."

        # Test without a pull (should pull the image again since it was removed)
        echo "Testing deployment without image pull..."
        deploy "cold"
        echo "Deployment without pull completed. Duration and conditions logged."

    done
    
}

# Run the test deployment
test_deployment
