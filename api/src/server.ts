import express from 'express';
import fs from 'fs';
import http from 'http';
import https from 'https';
import {InMemoryCache, jwksService, secure} from 'express-oauth-jwt';
import {Configuration} from './configuration';

/*
 * First load configuration
 */
const buffer = fs.readFileSync('config.json');
const configuration = JSON.parse(buffer.toString()) as Configuration;

/*
 * Create a service for validating JWT access tokens
 */
const client = !configuration.keystoreFilePath ? http : https;
const auth = jwksService(new InMemoryCache(), configuration.jwksUrl, client as any);

/*
 * Configure Express
 */
const app = express();
app.set('etag', false);
app.use('/data', secure(auth));

/*
 * Business logic that runs after JWT validation
 */
app.post('/data', (request: express.Request, response: express.Response) => {

    // TODO: remove after debugging
    const accept = request.headers['accept'];
    if (accept) {
        console.log('*** API received accept header: ' + accept);
    }
    const authorization = request.headers['authorization'];
    if (authorization) {
        console.log('*** API received authorization header: ' + authorization);
    }
    
    const data = {message: 'Success response from the Business API'};
    response.setHeader('content-type', 'application/json');
    response.status(200).send(JSON.stringify(data, null, 2));

    console.log(`Business API returned a success result at ${new Date().toISOString()}`);
});

/*
 * Start listening on either HTTP or HTTPS, depending on configuration
 */
if (configuration.keystoreFilePath) {

    const keystore = fs.readFileSync(configuration.keystoreFilePath);
    const sslOptions = {
        pfx: keystore,
        passphrase: configuration.keystorePassword,
    };

    const httpsServer = https.createServer(sslOptions, app);
    httpsServer.listen(configuration.port, () => {
        console.log(`Business API is listening on HTTPS port ${configuration.port}`);
    });

} else {

    app.listen(configuration.port, () => {
        console.log(`Business API is listening on HTTP port ${configuration.port}`);
    });
}
