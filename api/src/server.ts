import express from 'express';
import fs from 'fs';
import https from 'https';
import {Configuration} from './configuration.js';
import {OAuthFilter} from './oauthFilter.js';

/*
 * First load configuration
 */
const configurationJson = fs.readFileSync('config.json', 'utf8');
const configuration = JSON.parse(configurationJson) as Configuration;

/*
 * Configure Express
 */
const app = express();
app.set('etag', false);

/*
 * Run an OAuth filter before the API's business logic
 */
const oauthFilter = new OAuthFilter(configuration);
app.use('/data', oauthFilter.validateAccessToken);

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
