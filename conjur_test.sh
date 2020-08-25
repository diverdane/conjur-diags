#!/bin/bash

# Check connectivity to a Conjur server by running:
#      - Insecure curl
#      - Secure curl
#      - 'conjur list variables' command, repeated 5 times

function usage {
    echo "Check connectivity to a Conjur server by running:"
    echo "    - Insecure curl"
    echo "    - Secure curl"
    echo "    - 'conjur list variables' command, repeated 5 times"
    echo
    echo "Usage:"
    echo "   $0 [ -h|--help ]"
    echo
    echo "Required environment variables:"
    echo "    ADMIN_PASSWORD: Password for Conjur user 'admin'"
    echo "    CONJUR_ACCOUNT: Conjur account to use for Conjur commands"
    echo
    echo "At least one of the following environment variables must also be set:"
    echo "    CONJUR_URL:      URL for the target Conjur master/follower."
    echo "    CONJUR_IP:       Public IP address for Conjur master/follower."
    echo "    CONJUR_KUBE_SVC: Kubernetes service that provides an external"
    echo "                     IP address for a Conjur server that is running"
    echo "                     in a Kubernetes cluster."
    echo
    echo "If there is no DNS entry registered for the domain name portion of"
    echo "CONJUR_URL, then either CONJUR_IP or CONJUR_KUBE_SVC must be set."
    echo "OPTIONAL ENVIRONMENT VARIABLE:"
    echo "==============================:"
    echo "    CONJUR_PORT:     Port to use for Conjur master/follower."
    echo "                     Defaults to 443."
}

# Parse command line arguments
auto_login=true
interval=1
while [ "$1" != "" ]; do
    case $1 in
        -h | --help )     usage
                          exit 0
                          ;;
        * )               >&2 echo "Unknown argument: ${1}"
                          usage
                          exit 1
                          ;;
    esac
    shift
done

./conjur_diags.sh -c conjur_test.sh
