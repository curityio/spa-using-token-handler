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

- [Node.js](https://nodejs.org/en/download/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [openssl](https://www.openssl.org/source/)
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
OAUTH_AGENT=""
OAUTH_PROXY=""
./build.sh "$OAUTH_AGENT" "$OAUTH_PROXY" 
```

Options:

- `OAUTH_AGENT`
  - NODE (default)
  - NET
  - KOTLIN
  - FINANCIAL
- `OAUTH_PROXY`
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
OAUTH_AGENT=""
OAUTH_PROXY=""
./deploy.sh "$OAUTH_AGENT" "$OAUTH_PROXY" 
```

Domains used can be adjusted depending on your preferences, by editing the deploy.sh script.\
The following configuration can be used if you prefer to run token handler components in the web domain.\
If you use a different domain to example.com, ensure that /etc/hosts is updated accordingly.

```text
export BASE_DOMAIN='example.com'
export WEB_SUBDOMAIN='www'
export API_SUBDOMAIN='www'
export IDSVR_SUBDOMAIN='login'
```

## Use the System

Then browse to http://www.example.com and sign in with the following test user name and password:

- **demouser / Password1**

The SPA has an initial unauthenticated view to focus on triggering a login:

![Unauthenticated View](/doc/ui-unauthenticated-standard.png)

The authenticated view demonstrates multi-tab browsing, which works reliably in all browsers:

![Authenticated View](/doc/ui-authenticated-standard.png)

## Deployed System

Once the system is deployed you can also browse to these URLs:

- Sign in to the [Curity Admin UI](https://localhost:6749/admin) with credentials `admin / Password1`
- Browse to the [Identity Server Metadata Endpoint](http://login.example.com:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration)
- Browse to the SPA's [OAuth Agent Base URL](http://api.example.com/oauth-agent)
- Browse to the [Example API Base URL](http://api.example.com/api), which uses the OAuth proxy to forward JWTs to APIs

## Internal Details

- To better understand deployment, see the [SPA Deployments](https://github.com/curityio/spa-deployments) repository.
- To better understand how the OAuth Agent works, see the [Node.js OAuth Agent](https://github.com/curityio/oauth-agent-node-express) repository.

## Troubleshoot

If you need to troubleshoot then access logs for token handler components via these commands:

```bash
export OAUTH_AGENT_CONTAINER_ID=$(docker container ls | grep oauth-agent | awk '{print $1}')
docker logs -f $OAUTH_AGENT_CONTAINER_ID
```

```bash
export REVERSE_PROXY_CONTAINER_ID=$(docker container ls | grep reverse-proxy | awk '{print $1}')
docker logs -f $REVERSE_PROXY_CONTAINER_ID
```

## Run UI Tests

If required, run the SPA's [autoamted UI tests](Cypress.md) for login related operations:

```bash
export LOGIN_START_URL='http://api.example.com/oauth-agent/login/start'
export IDSVR_BASE_URL='http://login.example.com:8443'
cd spa
npm run uitests
```

## Free Resources

When finished with your development session, run the following script to free resources:

```bash
./teardown.sh
```
