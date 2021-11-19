# How to run the SPA and Basic Token Handler

## Overview

The token handler uses the following behaviour:

- OAuth work is done for the SPA by an API
- Authorization Code Flow (PKCE) is used, along with a simple client secret
- Only the strongest `SameSite=strict` cookies are used in the browser
- The code example uses HTTP to reduce infrastructure

## Configure Development Domains

Add these entries to your /etc/hosts file:

```bash
127.0.0.1 localhost www.example.com api.example.com login.example.com
:1        localhost
```

## Install Prerequisites

Ensure that these tools are installed locally:

- [Node.js](https://nodejs.org/en/download/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [jq](https://stedolan.github.io/jq/download/)

Also get a License File for the Curity Identity Server and copy it to the root folder:

- Sign in to the [Curity Developer Portal](https://developer.curity.io/) with your Github account.
- You can get a [Free Community Edition License](https://curity.io/product/community/) if you are new to the Curity Identity Server.

## Build the Code

This will compile projects and build Docker images:

```bash
./build.sh
```

## Deploy the System

Then run this script to spin up all components in a small Docker Compose network:

```bash
./deploy.sh
```

## Use the System

Then browse to http://www.example.com and sign in with the following test user name and password:

- **demouser / Password1**

The SPA has an initial unauthenticated view to focus on triggering a login:

![Unauthenticated View](/doc/ui-unauthenticated-basic.png)

The authenticated view demonstrates multi-tab browsing, which works reliably in all browsers:

![Authenticated View](/doc/ui-authenticated-basic.png)

## Deployed System

Once the system is deployed you can also browse to these URLs:

- Sign in to the [Curity Admin UI](https://localhost:6749/admin) with credentials `admin / Password1`
- Browse to the [Identity Server Metadata Endpoint](http://login.example.com:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration)
- Browse to the SPA's [Token Handler API Base URL](http://api.example.com:3000/tokenhandler), which is the OAuth agent
- Browse to the [Example API Base URL](http://api.example.com:3000/api), which uses the OAuth proxy to forward JWTs to APIs

## Token Handler Details

- To better understand deployment, see the [SPA Deployments](https://github.com/curityio/spa-deployments) repository.
- To better understand how the token handler works, see the [SPA Basic Token Handler](https://github.com/curityio/bff-node-express).

## Troubleshoot

If you need to troubleshoot then access token handler related logs via the following commands:

```bash
export TOKEN_HANDLER_CONTAINER_ID=$(docker container ls | grep token-handler-api | awk '{print $1}')
docker logs -f $TOKEN_HANDLER_CONTAINER_ID
```

```bash
export REVERSE_PROXY_CONTAINER_ID=$(docker container ls | grep reverse-proxy | awk '{print $1}')
docker logs -f $REVERSE_PROXY_CONTAINER_ID
```
