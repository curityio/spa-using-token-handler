# Web OAuth via a Back End for Front End (BFF)

[![Quality](https://img.shields.io/badge/quality-experiment-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

An Single Page Application (SPA) that implements OpenID Connect using recommended browser security.\
A `Back End for Front End (BFF)` approach is used, in line with [best practices for browser based apps](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-browser-based-apps).

## The Token Handler Pattern

A modern evolution of Back End for Front End is used, called the [Token Handler Pattern](https://curity.io/resources/learn/the-token-handler-pattern/).\
Companies plug in a token handler provided by Curity (or a similar provider), to perform OAuth work in an API driven manner:

![Logical Components](/code/spa/doc/logical-components.png)

This provides the best separation of web and API concerns, to maintain all of the benefits of an SPA architecture:

- Standard OpenID Connect security, with only **SameSite=strict** cookies in the browser
- Productive web focused development with only simple security code needed in the SPA
- Good usability due to the separation of Web and API concerns
- Deploy the SPA anywhere

See the [Curity OAuth for Web Home Page](https://curity.io/product/token-service/oauth-for-web/) for further documentation.

## Prerequisites

### Configure Development Domains

Add these entries to your /etc/hosts file:

```bash
127.0.0.1 localhost www.example.com api.example.com login.example.com
:1        localhost
```

### Get a License File for the Curity Identity Server

- Sign in to the [Curity Developer Portal](https://developer.curity.io/) with your Github account.
- You can get a [Free Community Edition License](https://curity.io/product/community/) if you are new to the Curity Identity Server.
- Then copy your `license.json` file into the `idsvr` folder.

## Build the Code

You will need to download and install NodeJS for your operating system.\
Then run the build script to compile projects and build Docker images.

```bash
cd code
./build.sh
```

## Deploy the System

Then run this script to spin up all components in a small Docker Compose network:

```bash
cd deployment
./deploy.sh
```

## Use the System

Then browse to http://www.example.com which first presents unauthenticated views:

![Unauthenticated Views](/code/spa/doc/ui-unauthenticated.png)

Sign in with the following test user name and password:

- **demouser / Password1**

Verify that page reloads and multi tab browsing work in a user friendly manner:

![Authenticated Views](/code/spa/doc/ui-authenticated.png)

The example SPA is developed using only simple React code.

## Deployed System

Use of secure cookies in the browser requires additional components, and the deployed system looks like this:

![Deployed Components](/code/spa/doc/deployed-components.png)

On a web developer's computer, we recommend running the token handler via Docker, and using updated local URLs:

![Developer Setup](/code/spa/doc/deployed-components.png)

Once the system is deployed you can also browse to these URLs:

- Sign in to the [Curity Admin UI](https://localhost:6749/admin) with these credentials: **admin / Password1**
- Browse to the [Identity Server Metadata Endpoint](http://login.example.com:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration)
- Browse to the SPA's [Token Handler API Base URL](http://api.example.com:3000/bff), which invokes the OAuth agent
- Browse to the [Example API Base URL](http://api.example.com:3000/api), which uses the OAuth proxy to forward JWTs to APIs

## View Logs

Use the following type of syntax to find the logs for a particular component:

```bash
export BFF_API_CONTAINER_ID=$(docker container ls | grep bff-api | awk '{print $1}')
docker logs -f $BFF_API_CONTAINER_ID
```

```bash
export CURITY_CONTAINER_ID=$(docker container ls | grep curity-idsvr | awk '{print $1}')
docker logs -f $CURITY_CONTAINER_ID
```

```bash
export KONG_CONTAINER_ID=$(docker container ls | grep reverse-proxy | awk '{print $1}')
docker logs -f $KONG_CONTAINER_ID
```

## Run SPA Locally

To run the SPA code locally, omit the web host component from the Docker Compose file.\
Then build the SPA in a terminal:

```bash
cd code/spa
npm install
npm start
```

Then build and run the webhost in another terminal:
```bash
cd ../webhost
npm install
npm start
```
