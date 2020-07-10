# Conjur Diagnostics Utility

<p align="center">
  <img src="cyberark_logo.png">
</p>

This repository contains diagnostics scripts that can used to test basic
connectivity for a Conjur server (where the server can be a Conjur master
or follower). The diagnostics scripts can be used to:

- Display a Conjur server's TLS CA certificate.
- Display the subject common name (CN) in a Conjur server's TLS CA certificate.
- Run insecure curl on a Conjur server.
- Run secure curl on a Conjur server.
- Run a "Conjur ping" connectivity test. This test executes a
  'conjur list variables' command repetitively and tabulates success rate.
- Connect with Conjur and run Conjur CLI commands.
- Run connectivity tests in sequence:
  - Insecure curl
  - Secure curl
  - Conjur ping with repeat count of 5


## Table of Contents

- [Environment Variable Settings](#environment-variable-settings)
- [Display Conjur Server's TLS CA Certificate Chain](#display-conjur-servers-tls-ca-certificate-chain)
- [Display Conjur Server's TLS CA Certificate Subject Common Name (CN)](#display-conjur-servers-tls-ca-certificate-subject-common-name-cn)
- [Run Insecure Curl to Conjur Server](#run-insecure-curl-to-conjur-server)
- [Run Secure Curl to Conjur Server](#run-secure-curl-to-conjur-server)
- [Run "Conjur Ping" To Check Connectivity to Conjur Server](#run-conjur-ping-to-check-connectivity-to-conjur-server)
- [Running Conjur Commands](#running-conjur-commands)
- [Run Basic Connectivity Checks for Conjur](#run-basic-connectivity-checks-for-conjur)


## Environment Variable Settings

The Conjur diagnostics scripts require **at least one** of the following
environment variables to be set:
|Environment Variable|Description|
|--------------------|-----------|
|CONJUR_URL|URL for the target Conjur master/follower|
|CONJUR_IP|Public IP address for Conjur master/follower|
|CONJUR_KUBE_SVC|For Kubernetes-based Conjur servers, the load-balanced/ingress Kubernetes service that exposes Conjur service|

_NOTE: If there is no DNS entry registered for the domain name portion of
 CONJUR_URL, then either CONJUR_IP or CONJUR_KUBE_SVC must be set._

Additionally, for scripts that run Conjur commands, the following environment
variables must be set in order to allow connecting and logging into the
Conjur server:
|Environment Variable|Description|
|--------------------|-----------|
|ADMIN_PASSWORD|Password for Conjur user 'admin'|
|CONJUR_ACCOUNT|Conjur account to use for Conjur commands|


## Display Conjur Server's TLS CA Certificate Chain

To retrieve and display a server's TLS CA certificate chain given its IP
address, run:

```
    ./get_ca_cert.sh -a <ip-address>
```


## Display Conjur Server's TLS CA Certificate Subject Common Name (CN)

To retrieve and display the Subject Common Name (CN) contained in a server's
TLS CA certificate chain given its IP address,
run:

```
    ./get_ca_cert_cn.sh -a <ip-address>
```


## Run Insecure Curl to Conjur Server

To run an insecure curl to a Conjur server, first set **at least one** of
the following environment variables:
- CONJUR_URL 
- CONJUR_IP 
- CONJUR_KUBE_SVC

and then run:

```
    ./conjur_curl.sh -k
```


## Run Secure Curl to Conjur Server

To run an secure curl to a Conjur server, first set **at least one** of
the following environment variables:
- CONJUR_URL 
- CONJUR_IP 
- CONJUR_KUBE_SVC

and then run:

```
    ./conjur_curl.sh
```


## Run "Conjur Ping" To Check Connectivity to Conjur Server

A "Conjur ping" test provides a check of basic connectivity (including
backend database access) to a Conjur server, by repetitively running a
`conjur list variables` command and tabulating the success rate.

To run a Conjur ping test, first set required environment variables:
- ADMIN_PASSWORD
- CONJUR_ACCOUNT

and at least one of the following:
- CONJUR_URL 
- CONJUR_IP 
- CONJUR_KUBE_SVC

and then run:

```
    ./conjur_ping.sh
```

or to run commands indefinitely, or for a specific repeat count:

```
    ./conjur_ping.sh -c <count>
```

Example output:

```sh-session
$ ./conjur_ping.sh 
Trust this certificate (yes/no): yes
Logged in
Press CTRL+c to stop...
Command "conjur list variables" returns SUCCESS in 0m0.448s
Command "conjur list variables" returns SUCCESS in 0m0.402s
Command "conjur list variables" returns SUCCESS in 0m0.426s
Command "conjur list variables" returns SUCCESS in 0m0.388s
^C--- "conjur list variables" statistics ---
4 requests, 4 successful, 100% success rate
$
```

## Running Conjur Commands

The `conjur_diags.sh` script can be used run Conjur CLI commands.
This script will execute a `docker run ...` of a Conjur CLI container
(incluging a volume mount of this repository's `container_scripts`
subdirectory to make those scripts available in the container's
`/root/scripts` directory).

By default, the `conjur_diags.sh` will automatically perform the following:
- Initialize a connection to Conjur
- Log into Conjur as user `admin`
unless the `--no-login` argument is included when this script is run.

To run Conjur commands, first set required environment variables:
- ADMIN_PASSWORD
- CONJUR_ACCOUNT

and at least one of the following:
- CONJUR_URL 
- CONJUR_IP 
- CONJUR_KUBE_SVC

Next, to run Conjur commands interactively inside the Conjur CLI container,
simply run:

```
    ./conjur_diags.sh
```

This will leave you in an interactive shell in the Conjur CLI container,
already connected to and logged into Conjur.

Alternatively, to run one or more Conjur commands and exit from the Conjur CLI
container, run:

```
    ./conjur_diags.sh -c "<conjur-commands>"
```

For example:

```sh-session
$ ./conjur_diags.sh -c "conjur list variables"
Trust this certificate (yes/no): yes
Logged in
[
  "myConjurAccount:policy:root",
  "myConjurAccount:policy:BotApp",
  "myConjurAccount:user:Dave@BotApp",
  "myConjurAccount:host:BotApp/myDemoApp",
  "myConjurAccount:variable:BotApp/secretVar"
]
$
```


## Run Basic Connectivity Checks for Conjur

The `conjur_test.sh` script can be used to run Several of the connectivity
checks described above in sequence, including:
- Insecure curl
- Secure curl
- "Conjur ping"

To run `conjur_test.sh`, first set required environment variables:
- ADMIN_PASSWORD
- CONJUR_ACCOUNT

and at least one of the following:
- CONJUR_URL 
- CONJUR_IP 
- CONJUR_KUBE_SVC

and then run:

```
    ./conjur_test.sh
```

