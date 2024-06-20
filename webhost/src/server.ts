import express from 'express';
import fs from 'fs';
import https from 'https';
import path from 'path';
import {Configuration} from './configuration';

/*
 * First load configuration
 */
const buffer = fs.readFileSync('config.json');
const configuration = JSON.parse(buffer.toString()) as Configuration;

/*
 * Write security headers when a request is first received
 */
const app = express();
app.use((request: express.Request, response: express.Response, next: express.NextFunction) => {

    let policy = "default-src 'none';";
    policy += " script-src 'self';";
    policy += ` connect-src 'self' ${configuration.apiBaseUrl};`;
    policy += " child-src 'self';";
    policy += " img-src 'self';";
    policy += " style-src 'self' https://cdn.jsdelivr.net;";
    policy += ` font-src 'self';`;
    policy += " object-src 'none';";
    policy += " frame-ancestors 'none';";
    policy += " base-uri 'self';";
    policy += " form-action 'self';";

    response.setHeader('content-security-policy', policy);
    response.setHeader('strict-transport-security', 'max-age=31536000; includeSubdomains; preload');
    response.setHeader('x-frame-options', 'DENY');
    response.setHeader('x-xss-protection', '1; mode=block');
    response.setHeader('x-content-type-options', 'nosniff');
    response.setHeader('referrer-policy', 'same-origin');

    next();
});

/*
 * Then serve static content, which is done from a different path when running in a deployed container
 */
if (process.env.NODE_ENV === 'production') {
    app.use(express.static('./content'));
} else {
    app.use(express.static(path.resolve(__dirname, '../../spa/dist')));
}

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
        console.log(`Web Host is listening on HTTPS port ${configuration.port}`);
    });

} else {

    app.listen(configuration.port, () => {
        console.log(`Web Host is listening on HTTP port ${configuration.port}`);
    });
}
