#!/bin/bash

# Run an insecure curl command to a Conjur master or follower's status
# endpoint.
#
# Syntax:
#     ./curl_insecure.sh
#
# Required environment variable:
#    CONJUR_URL: URL for the target Conjur master or follower.
#
# Optional environment variable:
#    CONJUR_PORT: Port for the target Conjur master or follower.
#                 Defaults to 443.

source ./utils.sh

CONJUR_PORT=${CONJUR_PORT:-443}

curl --fail --silent --show-error --connect-timeout 5 "$CONJUR_URL:$CONJUR_PORT" -k

