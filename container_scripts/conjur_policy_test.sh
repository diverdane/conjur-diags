#!/bin/bash

set -eo pipefail

# Write a test policy to Conjur (master only).

max_tries=10
policy_yaml_file="../policy/BotApp.yml"
policy_prefix="ConjurPolicyTest"
policy_suffix_len=10

temp_err_file="/tmp/temp_cmd_err.txt"

function usage {
    echo "Write a test policy to Conjur."
    echo
    echo "Usage:"
    echo "    $0 [ -h|--help ] [ -v|--verbose ]"
    echo "Where the optional arguments are:"
    echo "    (-h | --help)                 Show usage for this script"
    echo "    (-v | --verbose)              Enable verbose mode"
    echo
    echo "Required environment variable:"
    echo "    CONJUR_ACCOUNT: Conjur account to use. Used implicitly by"
    echo "                    'conjur' command."
}

# Parse command line arguments
echo "Parsing command line arguments"
while [ "$1" != "" ]; do
    case $1 in
        -h | --help )     usage
                          exit 0
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

function does_policy_exist {
    resource="$CONJUR_ACCOUNT:policy:$1"
    output=$(conjur list variables | grep "$resource")
    if [ -z $output ]; then
        false
    else
        true
    fi
}

function gen_policy_name {
    for (( i=1; i<=$max_tries; i++ )); do
        rand_string=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 10)
        name="$policy_prefix$rand_string"
        does_policy_exist "$name"
        if [[ $? -ne true ]]; then 
            echo "$name"
            return
        fi
    done
    echo "ERROR: Exceeded maximum attempts to generate an unused policy name."
    exit 1
}

if [ "$verbose_mode" = true ]; then
    echo "Attempting to find an unused policy name"
fi
policy_name="$(gen_policy_name)"

echo "Policy name $policy_name does not appear to be used."
echo "About to write a policy using account $CONJUR_ACCOUNT and name $policy_name"
echo "======================================================================"
echo "PLEASE CONFIRM WHETHER POLICY $policy_name SHOULD BE WRITTEN!!!!!"
echo "======================================================================"
read -p "Enter 'yes' to confirm, anything else to cancel:" confirmation
if [ "$confirmation" = "yes" ]; then
    cp $policy_yaml_file /tmp/$policy_name.yaml
    sed -i "s/^  id:.*/  id: $policy_name/" /tmp/$policy_name.yaml
    conjur policy load root /tmp/$policy_name.yaml
fi

