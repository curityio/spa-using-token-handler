import axios, {AxiosRequestConfig, Method} from 'axios';
import {OAuthClient} from '../oauth/oauthClient';
import {ErrorHandler} from '../utilities/errorHandler';

/*
 * The entry point for making calls to business APIs after authentication
 */
export class ApiClient {

    private readonly _apiBaseUrl: string;
    private readonly _oauthClient: OAuthClient;

    public constructor(apiBaseUrl: string, oauthClient: OAuthClient) {

        this._apiBaseUrl = apiBaseUrl;
        this._oauthClient = oauthClient;
    }

    /*
     * Call a business API with a secure cookie as a credential
     */
    public async getWelcomeData(): Promise<any> {
        return await this._fetch('POST', 'data');
    }

    /*
     * Call the Business API in a parameterized manner with reliability
     */
    private async _fetch(method: string, path: string): Promise<any> {

        try {

            // Try the API call
            return await this._doFetchImpl(method, path);

        } catch (e) {

            // Report errors
            if (!this._isApi401Error(e)) {
                throw ErrorHandler.handleFetchError('Business API', e);
            }

            // Handle 401s via a refresh
            await this._oauthClient.refresh();
            try {

                // Retry the API call
                return await this._doFetchImpl(method, path);

            } catch (e) {

                // Report retry errors
                throw ErrorHandler.handleFetchError('Business API', e);
            }
        }
    }

    /*
     * Common work for all fetch operations
     */
    private async _doFetchImpl(method: string, path: string): Promise<any> {

        const url = `${this._apiBaseUrl}/${path}`;
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

        // If we have an anti forgery token, add it to POST requests
        if (this._oauthClient.antiForgeryToken) {
            options.headers['x-example-csrf'] = this._oauthClient.antiForgeryToken;
        }

        const response = await axios.request(options);
        if (response.data) {
            return response.data;
        }

        return null;
    }

    /*
     * Determine if this is a 401 response meaning the access token in the secure cookie has expired
     */
    private _isApi401Error(error: any) {

        if (error.response) {
            if (error.response.status === 401 || error.response.status === 403) {
                return true;
            }
        }

        return false;
    }
}
