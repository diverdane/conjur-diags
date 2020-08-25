#!/bin/bash

# Run diagnostic scripts or Conjur CLI commands from a Conjur CLI
# container to test access to a Conjur server.

function usage {
    echo "Run diagnostic scripts or Conjur commands to test access to a"
    echo "Conjur server. By default, this includes automatically initializing"
    echo "a connection and logging into Conjur (unless '-n' or '--no-login'"
    echo "is included on the command line)."
    echo
    echo "Usage:"
    echo "   $0 [ <optional-arguments> ]"
    echo
    echo "Where optional arguments include:"
    echo "   -c|--cmd \"<cmd-to-execute>\"  # Command/script to execute."
    echo "                                # (If omitted, user is left in"
    echo "                                # an interactive shell in which"
    echo "                                # 'conjur' commands can be run.)"
    echo "   -h|--help                    # Show usage for this script."
    echo "   -n|--no-login                # Do not automatically initialize"
    echo "                                # a connection and log into Conjur"
    echo "                                # before executing commands."
    echo "   -v|--verbose                 # Enable verbose mode."
    echo
    echo "REQUIRED ENVIRONMENT VARIABLES:"
    echo "==============================="
    echo "Unless login is disabled (via `-n` or `--no-login`), the following"
    echo "environment varibles must be set:"
    echo "    ADMIN_PASSWORD: Password for Conjur user 'admin'"
    echo "    CONJUR_ACCOUNT: Conjur account to use for Conjur commands"
    echo
    echo "Additionally, at least one of the following environment variables"
    echo "must be set:" echo "    CONJUR_URL:      URL for the target Conjur master/follower."
    echo "    CONJUR_IP:       Public IP address for Conjur master/follower."
    echo "    CONJUR_KUBE_SVC: Kubernetes service that provides an external"
    echo "                     IP address for a Conjur server that is running"
    echo "                     in a Kubernetes cluster."
    echo "If there is no DNS entry registered for the domain name portion of"
    echo "CONJUR_URL, then either CONJUR_IP or CONJUR_KUBE_SVC must be set."
    echo
    echo "OPTIONAL ENVIRONMENT VARIABLE:"
    echo "==============================:"
    echo "    CONJUR_PORT:     Port to use for Conjur master/follower."
    echo "                     Defaults to 443."
    echo
    echo "EXAMPLES"
    echo "========"
    echo
    echo "Check connectivity to Conjur:"
    echo "    $0 -c conjur_ping_test.sh"
    echo
    echo "Run insecure curl to Conjur:"
    echo "    $0 --no-login -c curl_insecure.sh"
    echo
    echo "Run secure curl to Conjur:"
    echo "    $0 --no-login -c curl_secure.sh"
    echo
    echo "Check connectivity to Conjur with repeat count of 5:"
    echo "    $0 -c \"conjur_ping_test.sh --count 5\""
    echo
    echo "Log into Conjur and run an interactive shell in which"
    echo "'conjur' commands can be run:"
    echo "    $0"
    echo
    echo "Log into Conjur and run \"conjur variable list\":"
    echo "    $0 -c \"conjur variable list\""
    echo
    echo "Run several basic connectivity tests:"
    echo "    $0 -c conjur_test.sh"
}

export CONJUR_PORT=${CONJUR_PORT:-443}

# Parse command line arguments
auto_login=true
while [ "$1" != "" ]; do
    case $1 in
        -c | --cmd )      shift
                          cmd_arg=$1
                          ;;
        -h | --help )     usage
                          exit 0
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

# Check for required environment variables
if [ "$auto_login" = true ]; then
    if [ -z "$ADMIN_PASSWORD" ]; then
        echo "ERROR: ADMIN_PASSWORD is a required environmental variable"
        exit 1
    fi
    if [ -z "$CONJUR_ACCOUNT" ]; then
        echo "ERROR: CONJUR_ACCOUNT is a required environmental variable"
        exit 1
    fi
fi

# Get Conjur server's IP address and CA certificate CN if necessary
if [ -z "$CONJUR_URL" ]; then
    if [ -z "$CONJUR_IP" ]; then
        if [ -z "$CONJUR_KUBE_SVC" ]; then
            echo "ERROR: either CONJUR_URL, CONJUR_IP, or CONJUR_KUBE_SVC"
            echo "       environment variable must be set."
            exit 1
        else
            if [ "$verbose_mode" = true ]; then
                echo "Getting external IP for Kubernetes svc $CONJUR_KUBE_SVC"
            fi
            ext_ip=$(kubectl get svc "$CONJUR_KUBE_SVC" -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
            if [ -z "$ext_ip" ]; then
                echo "ERROR: Could not get ext IP addr for Kubernetes svc $CONJUR_KUBE_SVC"
                exit 1
            fi
            export CONJUR_IP="$ext_ip"
        fi
    fi
    if [ "$verbose_mode" = true ]; then
        echo "CONJUR_URL environment variable is not set. Retrieving Conjur's"
        echo "CA certificate to extract subject Common Name (CN)"
    fi
    domain_name=$(./get_ca_cert_cn.sh -a "$CONJUR_IP")
    if [ $? -ne 0 ]; then
        echo "ERROR: Could not retrieve CA cert CN for address $CONJUR_IP"
        exit 1
    fi
    export CONJUR_URL="https://$domain_name"
    if [ "$verbose_mode" = true ]; then
        echo "CONJUR_URL is set to $CONJUR_URL"
    fi
else
    # Get the domain name from the Conjur URL
    domain_name=$(echo "$CONJUR_URL" | awk -F/ '{print $3}')
    if [ "$verbose_mode" = true ]; then
        echo "Extracted domain name \"$domain_name\" from URL \"$CONJUR_URL\""
    fi
fi

# Set up commands to be run in the container. Start by adding a command
# to append /root/scripts to $PATH so that diag scripts are in the $PATH.
cmds="export PATH=\$PATH:/root/scripts"

# If $CONJUR_IP is set, it's assumed that there is no registered DNS entry
# for Conjur, so add an /etc/hosts entry in the container so that the
# $CONJUR_URL can be resolved.
if [ ! -z "$CONJUR_IP" ]; then
    cmds="$cmds; add_hosts_entry.sh -a $CONJUR_IP -d $domain_name"
fi

# If automatic login is enabled, run a Conjur init/login script
if [ "$auto_login" = true ]; then
    cmds="$cmds; ./conjur_login.sh"
fi

# Finally, if a command was passed to this script, run that. Otherwise,
# run a bash shell interactively.
if [ -z "$cmd_arg" ]; then
    cmds="$cmds; bash"
else
    cmds="$cmds; $cmd_arg"
fi

IFS=""
cmd_args=("-c" "$cmds")

docker run -it --rm \
    --env ADMIN_PASSWORD \
    --env CONJUR_ACCOUNT \
    --env CONJUR_IP \
    --env CONJUR_PORT \
    --env CONJUR_URL \
    -v "$PWD/container_scripts:/root/scripts:ro" \
    -v "$PWD/policy:/root/policy:ro" \
    -w /root/scripts \
    --entrypoint "/bin/bash" \
    cyberark/conjur-cli:5 ${cmd_args[*]}
