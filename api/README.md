# Example API

An example 'business' API that receive JWTs and validates them in a standard way.

## Run the API

- npm install
- npm start

## Test the Deployed API

```bash
curl -i http://api.example.com:3000/api
```

This will return a 401 response due to a missing access token.

## Run the End to End Example

Follow the [Main README](../) so that:

- The SPA gets a secure cookie containing an opaque access token
- The SPA sends the secure cookie to the API via the reverse proxy
- The reverse proxy decrypts the secure cookie
- The reverse proxy introspects the opaque access token to get a JWT
- The reverse proxy forwards the JWT to the API