#!/bin/bash

# Create a Conjur account. This should be run on a node that has kubectl
# access to the Kubernetes cluster, with kubectl context set to point to
# the namespace in which the Conjur server is running.

# Check for required command argument
if [ -z "$1" ]; then
    echo "ERROR: Conjur account name required."
    echo "Usage:"
    echo "    $0 <conjur-account>"
    exit 1
fi
conjur_account="$1"

export POD_NAME=$(kubectl get pods \
       -l "app=conjur-oss" \
       -o jsonpath="{.items[0].metadata.name}")
echo "Creating account $conjur_account in Conjur server running in pod $POD_NAME"
kubectl exec $POD_NAME --container=conjur-oss conjurctl account create "$conjur_account"

