#!/bin/bash

source ./utils.sh

announce "Check connectivity with insecure curl..."
./curl_insecure.sh

announce "Check connectivity with secure curl..."
./curl_secure.sh

announce "Check connectivity with repeated 'conjur list variables'..."
# Make sure that we're logged into Conjur
./conjur_login.sh
./conjur_ping_test.sh -c 5
