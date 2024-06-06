# SPA using the Token Handler Pattern

[![Quality](https://img.shields.io/badge/quality-test-yellow)](https://curity.io/resources/code-examples/status/)
[![Availability](https://img.shields.io/badge/availability-source-blue)](https://curity.io/resources/code-examples/status/)

A Single Page Application (SPA) that implements OpenID Connect using recommended browser security.\
The SPA uses a `Backend for Frontend (BFF)` approach, in line with [best practices for browser based apps](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-browser-based-apps).

A modern evolution of Backend for Frontend is used, called the [Token Handler Pattern](https://curity.io/resources/learn/the-token-handler-pattern/).\
The SPA uses an OAuth Agent to perform an API driven OpenID Connect flow:

![Logical Components](/doc/images/logical-components.png)

## Architecture Benefits

This provides the best separation of web and API concerns, to maintain all of the benefits of an SPA architecture:

- `Strongest Browser Security`, with only SameSite=strict cookies
- `Great User Experience` due to the separation of Web and API concerns
- `Productive Developer Experience` with only simple security code needed in the SPA
- `Deploy Anywhere`, such as to a Content Delivery Network

## Simple Code in Apps

This repository demonstrates the business focused components companies should need to develop:

- A Single Page App coded in React
- A Web Host to provide static content
- An API that validates JWT access tokens

The token handler components should be developed by Curity or another provider, then plugged in.

## Run the End-to-end Flow

The SPA can be quickly run in an end-to-end flow on a development computer by following these guides:

- [Standard SPA using an Authorization Code Flow (PKCE) and a Client Secret](/doc/Standard.md)
- [Financial-grade SPA, adding Mutual TLS, PAR and JARM](/doc/Financial.md)

## Website Documentation

See the [Token Handler Overview](https://curity.io/resources/learn/token-handler-overview) for detailed documentation on this design pattern.

## More Information

Please visit [curity.io](https://curity.io/) for more information about the Curity Identity Server.


