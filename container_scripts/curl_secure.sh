#!/bin/bash

# Run a secure curl command to a Conjur master or follower's status endpoint.
# Retrieves the master/follower's CA certificate to use for the curl if this
# hasn't been done already.
#
# Syntax:
#     ./curl_secure.sh
#
# Required environment variables:
#    CONJUR_URL: URL for the target Conjur master or follower.
#
# Optional environment variable:
#    CONJUR_PORT: Port for the target Conjur master or follower.
#                 Defaults to 443.

source ./utils.sh

cacert_file=/tmp/conjur_cacert.pem

if [ -z "$CONJUR_URL" ]; then
    echo "ERROR: CONJUR_URL is a required environmental variable"
    exit 1
fi

# Get the Conjur server's CA cert if necessary.
if [ ! -f "$cacert_file" ]; then
    conjur_domain_name=$(echo "$CONJUR_URL" | awk -F[/:] '{print $4}')
    echo quit | openssl s_client -showcerts -servername server -connect "$conjur_domain_name":443 > "$cacert_file"
fi

CONJUR_PORT=${CONJUR_PORT:-443}

curl --cacert "$cacert_file" --fail --silent --show-error --connect-timeout 5 "$CONJUR_URL:$CONJUR_PORT"
