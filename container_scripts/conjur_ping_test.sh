#!/bin/bash

# Run a 'conjur list variables' command repetitively to check connectivity
# to/from a Conjur master or follower and measure command latency.

conjur_command="conjur list variables"
temp_err_file="/tmp/temp_cmd_err.txt"
let cmd_count=0
let success_count=0

function usage {
    echo "Run \"$conjur_command\" repetitively to check connectivity with Conjur."
    echo
    echo "Usage:"
    echo "    $0 [ -c <count> ] [ -i <interval> ] [ -h ] [ -v ]"
    echo "Where the optional arguments are:"
    echo "    (-c | --count)    <count>     Command repeat count"
    echo "                                  (defaults to infinite iterations)"
    echo "    (-h | --help)                 Show usage for this script"
    echo "    (-i | --interval) <interval>  Command repeat interval in seconds"
    echo "                                  (defaults to 1)"
    echo "    (-v | --verbose)              Enable verbose mode"
    echo
    echo "Required environment variable:"
    echo "    CONJUR_ACCOUNT: Conjur account to use. Used implicitly by"
    echo "                    'conjur' command."
}

# Parse command line arguments
max_count=0      # Repeat command indefinitely
interval=1   # 1 second between commands
while [ "$1" != "" ]; do
    case $1 in
        -c | --count )    shift
                          max_count=$1
                          ;;
        -h | --help )     usage
                          exit 0
                          ;;
        -i | --interval ) shift
                          interval=$1
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

# Make sure connection to Conjur is initialized and that we're logged in.
if [ "$verbose_mode" = true ]; then
    echo "Check connectivity with repetitive 'conjur list variables'..."
fi

if [ $max_count -eq 0 ]; then
    run_forever=true
    echo "Press CTRL+c to stop..."
else
    run_forever=false
fi

function show_stats {
    success_rate=$(( $success_count*100/$cmd_count ))
    echo "--- \"$conjur_command\" statistics ---"
    echo "$cmd_count requests, $success_count successful, $success_rate% success rate"
}

function ctrl_c {
    show_stats
    exit 0
}

trap ctrl_c INT
while [ "$run_forever" = true ] || [ $cmd_count -lt $max_count ]; do
    let cmd_count=cmd_count+1
    trap ctrl_c INT
    response_time="$( TIMEFORMAT='%lU';time ($conjur_command 2> $temp_err_file >/dev/null) 2>&1)"
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
        result="ERROR ($(cat $temp_err_file))"
    else
        let success_count=success_count+1
        result="SUCCESS"
    fi
    echo "Command \"$conjur_command\" returns $result in $response_time"
    rm "$temp_err_file"

    sleep $interval

done
show_stats
