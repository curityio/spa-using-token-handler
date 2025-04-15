import {NextFunction, Request, Response} from 'express';
import {createRemoteJWKSet, jwtVerify, JWTVerifyGetKey, JWTVerifyOptions} from 'jose';
import {Configuration} from './configuration.js';

/*
 * Create a service for getting token signing public keys
 */
export class OAuthFilter {

    private readonly configuration: Configuration;
    private readonly jwksService: JWTVerifyGetKey;

    public constructor(configuration: Configuration) {

        this.configuration = configuration;
        this.jwksService = createRemoteJWKSet(new URL(configuration.jwksUri));
        this.validateAccessToken = this.validateAccessToken.bind(this);
    }

    public async validateAccessToken(request: Request, response: Response, next: NextFunction): Promise<void> {

        const options = {
            issuer: this.configuration.issuer,
            audience: this.configuration.audience,
            algorithms: [this.configuration.algorithm],
        } as JWTVerifyOptions;

        try {

            const accessToken = this.readAccessToken(request);
            if (!accessToken) {
                this.unauthorizedResponse(response);
                return;
            }

            const result = await jwtVerify(accessToken, this.jwksService, options);
            response.locals.claims = result.payload;
            next();

        } catch (e: any) {

            this.unauthorizedResponse(response);
        }

    }

    public readAccessToken(request: Request): string | null {

        const authorizationHeader = request.header('authorization');
        if (authorizationHeader) {
            const parts = authorizationHeader.split(' ');
            if (parts.length === 2 && parts[0].toLowerCase() === 'bearer') {
                return parts[1];
            }
        }

        return null;
    }

    private unauthorizedResponse(response: Response): void {

        const errorMessage = 'Missing, invalid or expired access token';
        console.log(errorMessage);
        response
            .status(401)
            .append('WWW-Authenticate', 'Bearer')
            .append('WWW-Authenticate', 'error="invalid_token"')
            .append('WWW-Authenticate', `error_description="${errorMessage}"`)
            .send();
    }
}
