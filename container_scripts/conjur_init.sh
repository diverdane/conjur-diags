#!/bin/bash

set -e

# Initialize a connection with a Conjur master or follower and save the CA
# certificate chain that is presented to /root/conjur-$CONJUR_ACCOUNT.pem).

function usage {
    echo "Usage:"
    echo "    $0 [ -h|--help ] [ -v|--verbose ]"
    echo "Where the optional arguments are:"
    echo "    (-h | --help)       Show usage"
    echo "    (-v | --verbose)    Enable verbose mode"
    echo
    echo "Required environment variables:"
    echo "    CONJUR_ACCOUNT: Conjur account to use for connection initialization"
    echo "    CONJUR_URL:     URL for the target Conjur master or follower"
    echo "Optional environment variable:"
    echo "    CONJUR_IP:      Conjur master/follower IP address. This is required if"
    echo "                    there is no DNS entry registered for the domain name"
    echo "                    portion of the CONJUR_URL."
    echo "    CONJUR_PORT:    Conjur master/follower port. Defaults to 443."
}

# Parse command line arguments
while [ "$1" != "" ]; do
    case $1 in
        -h | --help )    usage
                         exit 0
                         ;;
        -v | --verbose ) verbose_mode=true
                         ;;
        * )              >&2 echo "Unknown argument: ${1}"
                         usage
                         exit 1
                         ;;
    esac
    shift
done

CONJUR_PORT=${CONJUR_PORT:-443}

# Check required environmental variables
if [ -z "$CONJUR_ACCOUNT" ]; then
    echo "ERROR: CONJUR_ACCOUNT is a required environmental variable"
    exit 1
fi
if [ -z "$CONJUR_URL" ]; then
    echo "ERROR: CONJUR_URL is a required environmental variable"
    exit 1
fi

# If CONJUR_IP environment variable is provided, it is assumed that the
# domain name in CONJUR_URL is not registered in DNS, so create a local
# /etc/hosts entry so it can be resolved.
if [ -n "$CONJUR_IP" ]; then 
    conjur_domain_name=$(echo "$CONJUR_URL" | awk -F[/:] '{print $4}')
    args="-a $CONJUR_IP -d $conjur_domain_name"
    if [ "$verbose_mode" = true ]; then
        args="$args -v"
    fi
    ./add_hosts_entry.sh $args
fi

if [ "$verbose_mode" = true ]; then
    echo "Initialize connection with Conjur at $CONJUR_URL."
    echo "Writing TLS CA cert chain to /root/conjur-$CONJUR_ACCOUNT.pem)."
fi

yes yes | conjur init -u "$CONJUR_URL:$CONJUR_PORT" -a "$CONJUR_ACCOUNT" --force=true > /dev/null
# Show that an implicit "yes" command was piped to conjur init 
echo "yes"
