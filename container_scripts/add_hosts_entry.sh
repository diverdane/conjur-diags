#!/bin/bash

# Add an entry to the /etc/hosts table. This script is idempotent, i.e.
# redundant calls will not add additional entries in /etc/hosts.

function usage {
    echo "Usage:"
    echo "    $0 -a <ip-address> -d <domain-name> [ -v ] [ -h ]"
    echo "Where the command line arguments are:"
    echo "    (-a | --address)     <ip-address>    IP address, required"
    echo "    (-d | --domain-name) <domain-name>   Domain name, required"
    echo "    (-h | --help)                        Show  usage"
    echo "    (-v | --verbose)                     Verbose mode. Default: disabled"
    echo
    echo "Required environment variables:"
    echo "    CONJUR_ACCOUNT: Conjur account to use for connection initialization"
    echo "    CONJUR_URL:     URL for the target Conjur master or follower"
    echo "Optional environment variable:"
    echo "    CONJUR_IP:      Conjur master/follower IP address. This is required if"
    echo "                    there is no DNS entry registered for the domain name"
    echo "                    portion of the CONJUR_URL."
}

# Parse command line arguments
while [ "$1" != "" ]; do
    case $1 in
        -a | --address )     shift
                             ip_addr="${1}"
                             ;;
        -d | --domain-name ) shift
                             domain_name="${1}"
                             ;;
        -h | --help )        usage
                             exit 0
                             ;;
        -v | --verbose )     verbose_mode=true
                             ;;
        * )                  >&2 echo "Unknown argument: ${1}"
                             usage
                             exit 1
                             ;;
    esac
    shift
done

if [ -z "$ip_addr" ] || [ -z "$domain_name" ]; then
    echo "ERROR: Missing argument(s)"
    usage
    exit 1
fi

function display_entry {
    if [ "$verbose_mode" = true ]; then
        echo "Adding /etc/hosts entry: \"$ip_addr $domain_name\""
    fi
}
    
# Running sed directly on /etc/hosts in docker causes a "Device or
# resource busy" error, so run sed on a copy of this file.
(grep -q $domain_name /etc/hosts && \
     cp /etc/hosts /tmp/hosts.new && \
     sed -i "s/.*$domain_name/$ip_addr $domain_name/" /tmp/hosts.new && \
     cp /tmp/hosts.new /etc/hosts) || \
     (display_entry && \
     echo "$ip_addr $domain_name" >> /etc/hosts)
