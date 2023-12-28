# How to run the SPA with the Financial-grade OAuth Agent

## Overview

The end-to-end solution provides the following behaviour:

- The OAuth Agent performs OAuth work for the SPA in an API driven manner
- Authorization Code Flow with PKCE is used, along with Mutual TLS client authentication
- [PAR](https://tools.ietf.org/id/draft-lodderstedt-oauth-par-00.html) and [JARM](https://openid.net/specs/openid-financial-api-jarm.html) are also used, as state-of-the-art security features
- Only the strongest `SameSite=strict` cookies are used in the browser
- The code example uses HTTPS for all components

## Configure Development Domains

Add these entries to your /etc/hosts file:

```bash
127.0.0.1 localhost www.example.com api.example.com login.example.com
:1        localhost
```

## Install Prerequisites

Ensure that these tools are installed locally:

- [Node.js](https://nodejs.org/en/download/)
- [Java 11 or later](https://openjdk.java.net/projects/jdk/11/)
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [openssl](https://www.openssl.org/source/)
- [jq](https://stedolan.github.io/jq/download/)
- [envsubst](https://www.gnu.org/software/gettext/)

Contact Curity to get a trial license with access to financial grade features.\
Then copy the `license.json` file to the folder where you have cloned this repository.

## Build the Code

This will compile projects, build Docker images and generate development certificates if needed:

```bash
./build.sh 'FINANCIAL'
```

For further control you can override the script with options:

```bash
OAUTH_PROXY=''
./build.sh 'FINANCIAL' "$OAUTH_PROXY" 
```

OAUTH_PROXY supported values:
  - KONG (default)
  - NGINX
  - OPENRESTY

## Configure SSL Trust

Configure the browser to trust the root certificate authority at `./resources/financial/certs/example.ca.pem`.\
For most browsers this can be done by importing it to the system trust store, eg Keychain Access / System / Certificates.

## Deploy the System

Then run this script to spin up all components in a small Docker Compose network:

```bash
./deploy.sh 'FINANCIAL' 
```

If overriding default options, supply the same options to this script:

```bash
OAUTH_PROXY=''
./deploy.sh "FINANCIAL" "$OAUTH_PROXY" 
```

## Developing the SPA Locally

If you want to develop the SPA locally, with deployed token handler components, build it like this.\
The build script will enter webpack watch mode:

```bash
export DEVELOPMENT=true
./build.sh
```

Then run another terminal and deploy it like this, with only token handler components deployed to Docker.\
The simple web host will then run locally.

```bash
export DEVELOPMENT=true
./deploy.sh
```

## Overriding Domains

Deployed domains used can be adjusted depending on your preferences, by editing the deploy.sh script.\
The following configuration can be used if you prefer to run token handler components in the web domain.\
If you use a different domain to example.com, ensure that /etc/hosts is updated accordingly.

```text
export BASE_DOMAIN='example.com'
export WEB_SUBDOMAIN='www'
export API_SUBDOMAIN='www'
export IDSVR_SUBDOMAIN='login'
```

## Use the System

Then browse to https://www.example.com and sign in with the following test user name and password:

- **demouser / Password1**

The SPA has an initial unauthenticated view to focus on triggering a login:

![Unauthenticated View](/doc/ui-unauthenticated-financial.png)

The authenticated view demonstrates multi-tab browsing, which works reliably in all browsers:

![Authenticated View](/doc/ui-authenticated-financial.png)

## Deployed System

Once the system is deployed you can also browse to these URLs:

- Sign in to the [Curity Admin UI](https://localhost:6749/admin) with credentials `admin / Password1`
- Browse to the [Identity Server Metadata Endpoint](https://login.example.com:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration)
- Browse to the SPA's [OAuth Agent Base URL](https://api.example.com/oauth-agent)
- Browse to the [Example API Base URL](https://api.example.com/api), which uses the OAuth proxy to forward JWTs to APIs

## Internal Details

- To better understand deployment, see the [SPA Deployments](https://github.com/curityio/spa-deployments) repository.
- To better understand how the OAuth Agent works, see the [SPA Financial Grade OAuth Agent](https://github.com/curityio/oauth-agent-kotlin-spring-fapi).

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

If required, run the SPA's [automated UI tests](Cypress.md) for login related operations:

```bash
cd spa
npm run uitests
```

## Free Resources

When finished with your development session, run the following script to free resources:

```bash
./teardown.sh financial
```
