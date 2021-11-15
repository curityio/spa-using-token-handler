import axios, {AxiosRequestConfig, Method} from 'axios';
import {ErrorHandler} from '../utilities/errorHandler';
import {OAuthConfiguration} from './oauthConfiguration';

/*
 * The entry point for making OAuth calls
 */
export class OAuthClient {

    private readonly _configuration: OAuthConfiguration;
    private _antiForgeryToken: string | null;

    constructor(configuration: OAuthConfiguration) {

        this._configuration = configuration;
        this._antiForgeryToken = null;
        this._setupCallbacks();
    }

    /*
     * The anti forgery token is made available to the API client during API calls
     */
    public get antiForgeryToken(): string | null {
        return this._antiForgeryToken;
    }

    /*
     * On every page load the SPA asks the BFF API for login related state
     */
    public async handlePageLoad(pageUrl: string): Promise<any> {

        const request = JSON.stringify({
            pageUrl,
        });

        const response = await this._fetch('POST', 'login/end', request);
        if (response && response.csrf) {
            this._antiForgeryToken = response.csrf;
        }

        return response;
    }

    /*
     * Invoked when the SPA wants to trigger a login redirect
     */
    public async startLogin(): Promise<string> {

        const data = await this._fetch('POST', 'login/start', null)
        return data.authorizationRequestUrl;
    }

    /*
     * Get user info from the API and return it to the UI for display
     */
    public async getUserInfo(): Promise<any> {
        
        return await this._fetch('GET', 'userInfo', null);
    }

    /*
     * Refresh the tokens stored in secure cookies when an API returns a 401 response
     */
    public async refresh(): Promise<void> {

        await this._fetch('POST', 'refresh', null);
    }

    /*
     * Perform logout actions
     */
    public async logout(): Promise<string> {
        
        const data = await this._fetch('POST', 'logout', null);
        this._antiForgeryToken = null;
        return data.url;
    }

    /*
     * Handle logout from another browser tab by clearing any secure values stored
     */
    public async onLoggedOut(): Promise<void> {
        this._antiForgeryToken = null;
    }

    /*
     * Call the BFF API in a parameterized manner
     */
    private async _fetch(method: string, path: string, body: any): Promise<any> {

        let url = `${this._configuration.bffApiBaseUrl}/${path}`;
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

        if (body) {
            options.data = body;
        }

        // If we have an anti forgery token, add it to POST requests
        if (this.antiForgeryToken) {
            options.headers['x-example-csrf'] = this.antiForgeryToken;
        }

        try {

            // We use axios to call the BFF API, due to its support for reading error responses
            const response = await axios.request(options);
            if (response.data) {
                return response.data;
            }

            return null;

        } catch (e) {

            throw ErrorHandler.handleFetchError('BFF API', e);
        }
    }

    /*
     * Set up methods invoked from DOM event handlers
     */
    private _setupCallbacks(): void {
        this.onLoggedOut = this.onLoggedOut.bind(this);
    }
}
