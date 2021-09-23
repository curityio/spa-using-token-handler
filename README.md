# Web OAuth via a Back End for Front End (BFF)

[![Quality](https://img.shields.io/badge/quality-experiment-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

An Single Page Application (SPA) that implements OpenID Connect security using a `Back End for Front End (BFF)` approach.

## The Token Handler Pattern

A modern evolution of Back End for Front End is used, called the [Token Handler Pattern](https://curity.io/resources/learn/the-token-handler-pattern/).\
This provides the best separation of web and API concerns, to maintain all of the benefits of an SPA architecture.

## Components

The following high level components are used, where companies plug in a token handler provided by Curity:

![Components](/code/spa/doc/components.svg)

This provides the following benefits:

- Standard OpenID Connect security, with only **SameSite=strict** cookies in the browser
- Good usability due to the separation of Web and API concerns
- Deploy the SPA anywhere
- Only simple code is needed in the SPA, by plugging in Curity components

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

## View Back End Components

Once the system is deployed you can also browse to these URLs:

- Sign in to the [Curity Admin UI](https://localhost:6749/admin) with these credentials: **admin / Password1**
- Browse to the [Curity Metadata Endpoint](http://login.example.com:8443/oauth/v2/oauth-anonymous/.well-known/openid-configuration)
- Browse to the [Example API Base URL](http://api.example.com:3000/api)
- Browse to the [OAuth Agent Base URL](http://api.example.com:3000/bff/userinfo)

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
