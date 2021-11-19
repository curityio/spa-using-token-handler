# Web OAuth via a Backend for Frontend (BFF)

[![Quality](https://img.shields.io/badge/quality-experiment-red)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

A Single Page Application (SPA) that implements OpenID Connect using recommended browser security.\
The SPA uses a `Backend for Frontend (BFF)` approach, in line with [best practices for browser based apps](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-browser-based-apps).

## The Token Handler Pattern

A modern evolution of Backend for Frontend is used, called the [Token Handler Pattern](https://curity.io/resources/learn/the-token-handler-pattern/).\
The SPA uses a token handler provided by Curity (or a similar provider) to perform an API driven OAuth flow:

![Logical Components](/doc/logical-components.png)

## Architecture Benefits

This provides the best separation of web and API concerns, to maintain all of the benefits of an SPA architecture:

- `Strongest Browser Security`, with only SameSite=strict cookies
- `Great User Experience` due to the separation of Web and API concerns
- `Productive Developer Experience` with only simple security code needed in the SPA
- `Deploy Anywhere`, such as to a Content Delivery Network

## Simple Code in Apps

This repository demonstrates the business docused components companies should need to develop:

- An SPA coded in React
- A simple Web Host to provide static content
- A simple API that validates JWT access tokens

The token handler should be developed by Curity or another provider, then plugged in.

## Run the End-to-end Flow

The SPA can be quickly run in an end-to-end flow on a development computer by following these guides:

- [Basic SPA using an Authorization Code Flow (PKCE) and a Client Secret](/doc/Basic.md)
- [Financial-grade SPA using Mutual TLS, PAR and JARM](/doc/Financial.md)

## Website Documentation

See the [Curity OAuth for Web Home Page](https://curity.io/product/token-service/oauth-for-web/) for detailed documentation on this design pattern.

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.


