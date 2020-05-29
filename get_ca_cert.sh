#!/bin/bash

# Retrieve and display a server's CA certificate chain given its IP address

function usage {
    echo "Retrieve and display a server's CA certificate chain given its"
    echo "IP address."
    echo
    echo "Usage:"
    echo "   $0 -a|--addr <ip-address> [ -h|--help ]"
    echo
    echo "Example:"
    echo "   $0 -a 192.0.2.1"
}

# Parse command line arguments
while [ "$1" != "" ]; do
    case $1 in
        -a | --addr )     shift
                          ip_addr=$1
                          ;;
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

if [ -z "$ip_addr" ]; then
    usage
    exit 1
fi

echo | openssl s_client -connect "$ip_addr":443 2>&1
