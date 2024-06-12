import axios, {AxiosRequestConfig, AxiosRequestHeaders, Method} from 'axios';
import {OAuthClient} from '../oauth/oauthClient';
import {ErrorHandler} from '../utilities/errorHandler';

/*
 * The entry point for making calls to business APIs after authentication
 */
export class ApiClient {

    private readonly apiBaseUrl: string;
    private readonly oauthClient: OAuthClient;

    public constructor(apiBaseUrl: string, oauthClient: OAuthClient) {

        this.apiBaseUrl = apiBaseUrl;
        this.oauthClient = oauthClient;
    }

    /*
     * Call a business API with a secure cookie as a credential
     */
    public async getWelcomeData(): Promise<any> {
        return await this.fetch('POST', 'data');
    }

    /*
     * Call the Business API and handle retries due to expired access tokens
     */
    private async fetch(method: string, path: string): Promise<any> {

        try {

            // Try the API call
            return await this.fetchImpl(method, path);

        } catch (e: any) {

            // Report errors if this is not a 401
            const remoteError = ErrorHandler.handleFetchError('Business API', e);
            if (!remoteError.isAccessTokenExpiredError()) {
                throw remoteError;
            }

            // Handle 401s by refreshing the access token in the HTTP only cookie
            await this.oauthClient.refresh();
            try {

                // Retry the API call
                return await this.fetchImpl(method, path);

            } catch (e: any) {

                // Report retry errors
                throw ErrorHandler.handleFetchError('Business API', e);
            }
        }
    }

    /*
     * Common fetch implementation work
     */
    private async fetchImpl(method: string, path: string): Promise<any> {

        const url = `${this.apiBaseUrl}/${path}`;
        const options = {
            url,
            method: method as Method,
            headers: {
                accept: 'application/json',
                'content-type': 'application/json',
            },

            // Send the secure cookie to the API
            withCredentials: true,
        } as AxiosRequestConfig;
        const headers = options.headers as AxiosRequestHeaders

        // If we have an anti forgery token, add it to POST requests
        const antiForgeryToken = this.oauthClient.getAntiForgeryToken();
        if (antiForgeryToken) {
            headers['x-example-csrf'] = antiForgeryToken;
        }

        const response = await axios.request(options);
        if (response.data) {
            return response.data;
        }

        return null;
    }
}
