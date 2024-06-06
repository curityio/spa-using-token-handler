# How to run the SPA with the Standard OAuth Agent

## Overview

The end-to-end solution provides the following behaviour:

- The OAuth Agent performs OAuth work for the SPA in an API driven manner
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

- [Node.js 20 or later](https://nodejs.org/en/download/)
- [Docker](https://www.docker.com/products/docker-desktop)
- [jq](https://stedolan.github.io/jq/download/)
- [envsubst](https://www.gnu.org/software/gettext/)

Also get a License File for the Curity Identity Server and copy it to the root folder:

- Sign in to the [Curity Developer Portal](https://developer.curity.io/) with your Github account.
- You can get a [Free Community Edition License](https://curity.io/product/community/) if you are new to the Curity Identity Server.

## Build the Code

This will compile projects and build Docker images:

```bash
./build.sh
```

For further control you can override the script with options:

```bash
OAUTH_AGENT=''
OAUTH_PROXY=''
./build.sh "$OAUTH_AGENT" "$OAUTH_PROXY" 
```

OAUTH_AGENT supported values:
  - NODE (default)
  - NET
  - KOTLIN

OAUTH_PROXY supported values:
  - KONG (default)
  - NGINX
  - OPENRESTY

## Deploy the System

Then run this script to spin up all components in a small Docker Compose network:

```bash
./deploy.sh
```

If overriding default options, supply the same options to this script: 

```bash
OAUTH_AGENT=''
OAUTH_PROXY=''
./deploy.sh "$OAUTH_AGENT" "$OAUTH_PROXY" 
```

## Use the System

Then browse to http://www.example.com and sign in with the following test user name and password:

- **demouser / Password1**

The SPA has an initial unauthenticated view to focus on triggering a login:

![Unauthenticated View](/doc/images/ui-unauthenticated-standard.png)

The authenticated view demonstrates multi-tab browsing, which works reliably in all browsers:

![Authenticated View](/doc/images/ui-authenticated-standard.png)

## Deployed System

Once the system is deployed you can also browse to these URLs:

- Sign in to the [Curity Admin UI](https://localhost:6749/admin) with credentials `admin / Password1`
- Browse to the [Identity Server Metadata Endpoint](http://login.example.com:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration)
- Browse to the SPA's [OAuth Agent Base URL](http://api.example.com/oauth-agent)
- Browse to the [Example API Base URL](http://api.example.com/api), which uses the OAuth proxy to forward JWTs to APIs

## Deployment Details

To understand token handler deployment details you can study the [build](../deployment/build.sh) and [deployment](../deployment/standard/deploy.sh) scripts.

## Troubleshoot

If you need to troubleshoot, then access logs for the OAuth agent and OAuth proxy with these commands:

```bash
OAUTH_AGENT_CONTAINER_ID=$(docker container ls | grep oauth-agent | awk '{print $1}')
docker logs -f $OAUTH_AGENT_CONTAINER_ID
```

```bash
API_GATEWAY_CONTAINER_ID=$(docker container ls | grep api-gateway | awk '{print $1}')
docker logs -f $API_GATEWAY_CONTAINER_ID
```

## Run UI Tests

If required, run the SPA's [automated UI tests](Cypress.md) for login related operations:

```bash
cd spa
npm run uitests
```

## Free Resources

When finished with your development session, run the following script to free resources:

```bash
./teardown.sh
```
