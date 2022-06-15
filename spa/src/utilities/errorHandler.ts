import {RemoteError} from './remoteError';

/*
 * Make errors easy for the rest of the app to deal with
 */
export class ErrorHandler {

    /*
     * Handle errors making OAuth or API calls
     */
    public static handleFetchError(source: string, e: any): RemoteError {

        let status = 0;
        let code = 'fetch_error';
        let message = `Problem encountered calling the ${source}`;

        if (e.response) {

            if (e.response.status) {
                status = e.response.status;
            }

            if (e.response.data && typeof e.response.data === 'object') {

                if (e.response.data.code) {
                    code = e.response.data.code;

                } else if (e.response.data.error) {
                    code = e.response.data.error;
                }

                if (e.response.data.message) {
                    message += `: ${e.response.data.message}`;

                } else if (e.response.data.error_description) {
                    message += `: ${e.response.data.error_description}`;
                }
            }
        }

        return new RemoteError(status, code, message);
    }

    /*
     * The access token can expire when calling an API or calling the user info endpoint
     * In this case the next action will be to try a token refresh then retry the API call
     */
    public static isAccessTokenExpiredError(error: RemoteError): boolean {
        return error.getStatus() === 401;
    }

    /*
     * A session expired error means the user must be prompted to re-authenticate
     * This can happen when the refresh token expires
     * It can also happen if the Authorization Server is redeployed so that the refresh token is not accepted
     * It can also happen if the cookie encryption key is renewed in the OAuth Agent and OAuth Proxy
     */
    public static isSessionExpiredError(error: RemoteError): boolean {
        return error.getStatus() === 401;
    }
}
