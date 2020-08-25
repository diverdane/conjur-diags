# This is an example of how to set environment variables before running
# scripts in this repository. Modify the entries below, and then run:
#
#     source set_env.sh
#

# NOTE: The values for ADMIN_PASSWORD and CONJUR_ACCOUNT are determined
# when you create a default account for your Conjur server. For
# Kubernetes clusters, you can create a Conjur account by using the
# 'kube_create_account.sh' script, e.g.:
#     ./kube_create_account.sh myConjurAccount
export ADMIN_PASSWORD=ADmin123!!!!
export CONJUR_ACCOUNT=myConjurAccount

export CONJUR_IP=172.17.0.2
# NOTE: CONJUR_PORT defaults to 443
# export CONJUR_PORT=30257

# NOTE: The CONJUR_URL needs to include the subject common name that is
# included in the SSL certificate that your Conjur server uses. This can
# be read using the script 'get_ca_cert_cn.sh', e.g.:
#    ./get_ca_cert_cn.sh -a 172.17.0.2 -p 30257
export CONJUR_URL=https://conjur.myorg.com

