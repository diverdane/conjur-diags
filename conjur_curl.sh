#!/bin/bash

# Check connectivity to a Conjur server by running curl in either secure
# or insecure mode.

function usage {
    echo "Check connectivity to a Conjur server by running curl in either"
    echo "secure or insecure mode."
    echo
    echo "Usage:"
    echo "   $0 [ <optional-arguments> ]"
    echo
    echo "Where optional arguments include:"
    echo "   -h | --help                 Show usage for this script"
    echo "   -k | --insecure   Run curl in insecure mode"
    echo
    echo "REQUIRED ENVIRONMENT VARIABLES:"
    echo "==============================:"
    echo "At least one of the following environment variables must also be set:"
    echo "    CONJUR_URL:      URL for the target Conjur master/follower."
    echo "    CONJUR_IP:       Public IP address for Conjur master/follower."
    echo "    CONJUR_KUBE_SVC: Kubernetes service that provides an external"
    echo "                     IP address for a Conjur server that is running"
    echo "                     in a Kubernetes cluster."
    echo "If there is no DNS entry registered for the domain name portion of"
    echo "CONJUR_URL, then either CONJUR_IP or CONJUR_KUBE_SVC must be set."
    echo
    echo "Example: Run curl in secure mode"
    echo
    echo "    $0"
    echo
    echo "Example: Run curl in insecure mode"
    echo
    echo "    $0 -k"
}

# Parse command line arguments
insecure=false
while [ "$1" != "" ]; do
    case $1 in
        -h | --help )     usage
                          exit 0
                          ;;
        -k | --insecure )  insecure=true
                          ;;
        * )               >&2 echo "Unknown argument: ${1}"
                          usage
                          exit 1
                          ;;
    esac
    shift
done

if [ "$insecure" == true ]; then
    ./conjur_diags.sh --no-login -c "curl_insecure.sh"
else
    ./conjur_diags.sh --no-login -c "curl_secure.sh"
fi
