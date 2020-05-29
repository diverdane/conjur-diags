#!/bin/bash

# Run an insecure curl command to a Conjur master or follower's status
# endpoint.
#
# Syntax:
#     ./curl_insecure.sh
#
# Required environment variables:
#    CONJUR_URL: URL for the target Conjur master or follower.

source ./utils.sh

curl --fail --silent --show-error --connect-timeout 5 "${CONJUR_URL}" -k

