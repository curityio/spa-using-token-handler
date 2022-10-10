import express from 'express';
import fs from 'fs';
import https from 'https';
import {secure} from 'express-oauth-jwt';
import {createRemoteJWKSet} from 'jose';
import {Configuration} from './configuration';

/*
 * First load configuration
 */
const buffer = fs.readFileSync('config.json');
const configuration = JSON.parse(buffer.toString()) as Configuration;

/*
 * Create a service for getting token signing public keys
 */
const jwksService = createRemoteJWKSet(new URL(configuration.jwksUrl));

/*
 * Configure Express
 */
const app = express();
app.set('etag', false);

/*
 * Implement basic JWT validation
 */
app.use('/data', secure(jwksService));

/*
 * Business logic that runs after JWT validation
 */
app.post('/data', (request: express.Request, response: express.Response) => {

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
