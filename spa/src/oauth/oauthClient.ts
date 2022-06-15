import axios, {AxiosRequestConfig, AxiosRequestHeaders, Method} from 'axios';
import {ErrorHandler} from '../utilities/errorHandler';
import {OAuthConfiguration} from './oauthConfiguration';

/*
 * The entry point for making OAuth calls
 */
export class OAuthClient {

    private readonly configuration: OAuthConfiguration;
    private antiForgeryToken: string | null;

    constructor(configuration: OAuthConfiguration) {

        this.configuration = configuration;
        this.antiForgeryToken = null;
        this.setupCallbacks();
    }

    /*
     * The anti forgery token is made available to the API client during API calls
     */
    public getAntiForgeryToken(): string | null {
        return this.antiForgeryToken;
    }

    /*
     * On every page load the SPA asks the OAuth Agent for login related state
     */
    public async handlePageLoad(pageUrl: string): Promise<any> {

        const request = JSON.stringify({
            pageUrl,
        });

        const response = await this.fetch('POST', 'login/end', request);
        if (response && response.csrf) {
            this.antiForgeryToken = response.csrf;
        }

        return response;
    }

    /*
     * Invoked when the SPA wants to trigger a login redirect
     */
    public async startLogin(): Promise<string> {

        const data = await this.fetch('POST', 'login/start', this.getRedirectOptions())
        return data.authorizationRequestUrl;
    }

    /*
     * Get user info from the API and return it to the UI for display
     */
    public async getUserInfo(): Promise<any> {
        
        try {

            // Try the user info call
            return await this.fetch('GET', 'userInfo', null);

        } catch (e) {

            // Report errors if this is not a 401
            const remoteError = ErrorHandler.handleFetchError('OAuth Agent', e);
            if (!ErrorHandler.isAccessTokenExpiredError(remoteError)) {
                throw remoteError;
            }

            // Handle 401s via a refresh
            await this.refresh();
            try {

                // Retry the user info call
                return await this.fetch('GET', 'userInfo', null);

            } catch (e) {

                // Report retry errors
                throw ErrorHandler.handleFetchError('OAuth Agent', e);
            }
        }
    }

    /*
     * Get ID token claims from the API and return it to the UI for display
     */
    public async getClaims(): Promise<any> {
        
        return await this.fetch('GET', 'claims', null);
    }

    /*
     * Refresh the tokens stored in secure cookies when an API returns a 401 response
     */
    public async refresh(): Promise<void> {

        await this.fetch('POST', 'refresh', null);
    }

    /*
     * Perform logout actions
     */
    public async logout(): Promise<string> {
        
        const data = await this.fetch('POST', 'logout', null);
        this.antiForgeryToken = null;
        return data.url;
    }

    /*
     * Handle logout from another browser tab by clearing any secure values stored
     */
    public async onLoggedOut(): Promise<void> {
        this.antiForgeryToken = null;
    }

    /*
     * Call the OAuth Agent in a parameterized manner
     */
    private async fetch(method: string, path: string, body: any): Promise<any> {

        let url = `${this.configuration.oauthAgentBaseUrl}/${path}`;
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
            var headers = options.headers as AxiosRequestHeaders;
            headers['x-example-csrf'] = this.antiForgeryToken;
        }

        try {

            // Use axios to call the OAuth Agent, due to its support for reading error responses
            const response = await axios.request(options);
            if (response.data) {
                return response.data;
            }

            return null;

        } catch (e) {

            throw ErrorHandler.handleFetchError('OAuth Agent', e);
        }
    }

    /*
     * If required, extra parameters can be provided during authentication redirects like this
     */
    private getRedirectOptions(): any {

        /*
        return {
            extraParams: [
                {
                    key: 'ui_locales',
                    value: 'sv',
                },
            ]
        };
        */

        return null;
    }

    /*
     * Set up methods invoked from DOM event handlers
     */
    private setupCallbacks(): void {
        this.onLoggedOut = this.onLoggedOut.bind(this);
    }
}
