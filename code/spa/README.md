# Example SPA using Back End for Front End

An SPA code example, secured via OpenID Connect and the Back End for Front End (BFF) pattern.

## Configuration

The SPA uses these configuration settings and does not need to understand details of OAuth flows:

```json
{
    "businessApiBaseUrl": "http://api.example.com:3000/api",
    "oauth": {
        "bffApiBaseUrl": "http://api.example.com:3000/bff"
    }
}
```

## OAuth Requests

The example SPA makes OAuth requests using HTTP Only secure SameSite cookies via the [OAuthClient class](./src/oauth/oauthClient.ts).\
The SPA runs with a web origin of `www.example.com` and calls a BFF API in the `api.example.com` domain.

```ts
const url = await oauthClient.startLogin();
location.href=url;
```

## API Requests

The example SPA makes API requests using HTTP Only secure SameSite cookies via the [ApiClient class](./src/api/apiClient.ts).\
If required the API calls can be routed to a separate domain via a reverse proxy.

```ts
const data = await apiClient.getWelcomeData();
renderData(data);
```

## Results

- The SPA requires only simple code
- The SPA only uses secure cookies during Ajax requests and not during web requests, resulting in best login usability
- The SPA can also be deployed anywhere, such as to a Content Delivery Network