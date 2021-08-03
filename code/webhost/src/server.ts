import express from 'express';

const app = express();

/*
 * First write security headers
 */
app.use((request: express.Request, response: express.Response, next: express.NextFunction) => {

    /*let policy = "default-src 'none';";
    policy += " script-src 'self';";
    policy += ` connect-src 'self' http://api.example.com:3000;`;
    policy += " child-src 'self';";
    policy += " img-src 'self';";
    policy += " style-src 'self' https://cdn.jsdelivr.net;";
    policy += " object-src 'none'";
    response.setHeader('content-security-policy', policy);*/

    // A production ready implementation would also include other recommended headers:
    // https://infosec.mozilla.org/guidelines/web_security

    next();
});

/*
 * Then serve static content
 */
let port: number = 0;
if (process.env.NODE_ENV === 'production') {

    app.use(express.static('./content'));
    port = 3000

} else {

    app.use(express.static('../spa/dist'));
    port = 80
}

app.listen(port, () => {
    console.log(`Web Host is listening on internal HTTP port ${port}`);
});
