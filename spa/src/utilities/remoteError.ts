/*
 * A simple error object for remote problems
 */
export class RemoteError extends Error {

    private readonly status: number;
    private readonly code: string;

    public constructor(status: number, code: string, message: string) {
        super(message);
        this.status = status;
        this.code = code;
    }

    public getStatus(): number {
        return this.status;
    }

    public getCode(): string {
        return this.code;
    }

    /*
     * The access token can expire when calling an API or calling the user info endpoint
     * In this case the next action will be to try a token refresh then retry the API call
     */
    public isAccessTokenExpiredError(): boolean {
        return this.status === 401;
    }

    /*
     * A session expired error means the user must be prompted to re-authenticate
     * This can happen when the refresh token expires
     * It can also happen if the authorization server is redeployed so that the refresh token is not accepted
     * It can also happen if the cookie encryption key is renewed in the OAuth Agent and OAuth Proxy
     */
    public isSessionExpiredError(): boolean {
        return this.status === 401;
    }
}
