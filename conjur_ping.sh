#!/bin/bash

# Check connectivity to a Conjur server (including backend database access)
# by running a 'conjur list variables' command repetitively.

function usage {
    echo "Check connectivity to a Conjur server (including backend database"
    echo "access) by running a 'conjur list variables' command repetitively."
    echo
    echo "Usage:"
    echo "   $0 [ <optional-arguments> ]"
    echo
    echo "Where optional arguments include:"
    echo "   -c | --count    <count>     Command repeat count"
    echo "                               (defaults to infinite iterations)"
    echo "   -h | --help                 Show usage for this script"
    echo "   -i | --interval <interval>  Command repeat interval in seconds"
    echo "                               (defaults to 1)"
    echo
    echo "Required environment variable:"
    echo "    ADMIN_PASSWORD: Password for Conjur user 'admin'"
    echo "    CONJUR_ACCOUNT: Conjur account to use for Conjur commands"
    echo
    echo "At least one of the following environment variables must also be set:"
    echo "    CONJUR_URL:      URL for the target Conjur master/follower."
    echo "    CONJUR_IP:       Public IP address for Conjur master/follower."
    echo "    CONJUR_KUBE_SVC: Kubernetes service that provides an external"
    echo "                     IP address for a Conjur server that is running"
    echo "                     in a Kubernetes cluster."
    echo "If there is no DNS entry registered for the domain name portion of"
    echo "CONJUR_URL, then either CONJUR_IP or CONJUR_KUBE_SVC must be set."
    echo
    echo "Example: Check connectivity to Conjur, repeating until CTRL-C"
    echo "is entered:"
    echo
    echo "    $0"
    echo
    echo "Example: Check connectivity to Conjur with repeat count of 5:"
    echo
    echo "    $0 -c 5"
    echo
}

# Parse command line arguments
auto_login=true
interval=1
while [ "$1" != "" ]; do
    case $1 in
        -c | --count )    shift
                          count=$1
                          ;;
        -h | --help )     usage
                          exit 0
                          ;;
        -i | --interval ) shift
                          interval=$1
                          ;;
        -n | --no-login ) auto_login=false
                          ;;
        -v | --verbose )  verbose_mode=true
                          ;;
        * )               >&2 echo "Unknown argument: ${1}"
                          usage
                          exit 1
                          ;;
    esac
    shift
done

if [ -z "$count" ]; then
    ./conjur_diags.sh -c "conjur_ping_test.sh -i $interval"
else
    ./conjur_diags.sh -c "conjur_ping_test.sh -c $count -i $interval"
fi
