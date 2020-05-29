#!/bin/bash

set -e

# Log in to Conjur server as user 'admin'

function usage {
    echo "Usage:"
    echo "    $0 [ -h|--help ] [ -v|--verbose ]"
    echo "Where the optional arguments are:"
    echo "    (-h | --help)       Show usage"
    echo "    (-v | --verbose)    Enable verbose mode"
    echo
    echo "Required environment variables:"
    echo "    ADMIN_PASSWORD: Conjur password for user 'admin'."
    echo "    CONJUR_ACCOUNT: Conjur account to use for login."
    echo "                    (used implicitly by 'conjur' command)."
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

# Check for required environment variables
if [ -z "$ADMIN_PASSWORD" ]; then
    echo "ERROR: ADMIN_PASSWORD is a required environmental variable"
    exit 1
fi
if [ -z "$CONJUR_ACCOUNT" ]; then
    echo "ERROR: CONJUR_ACCOUNT is a required environmental variable"
    exit 1
fi

# Make sure that connection with Conjur is initialized
if [ "$verbose_mode" = true ]; then
    ./conjur_init.sh -v
    echo "Login to Conjur as user admin..."
else
    ./conjur_init.sh
fi

conjur authn login -u admin -p "$ADMIN_PASSWORD"

