import axios, {AxiosRequestConfig, AxiosRequestHeaders, Method} from 'axios';
import {ErrorHandler} from '../utilities/errorHandler';
import {PageLoadResponse} from '../utilities/pageLoadResponse';
import {RemoteError} from '../utilities/remoteError';

/*
 * The entry point for making OAuth calls
 */
export class OAuthClient {

    private readonly oauthAgentBaseUrl: string;
    private antiForgeryToken: string | null;

    constructor(oauthAgentBaseUrl: string) {

        this.oauthAgentBaseUrl = oauthAgentBaseUrl;
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
    public async handlePageLoad(pageUrl: string): Promise<PageLoadResponse> {

        const request = JSON.stringify({
            pageUrl,
        });

        const response = await this.fetch('POST', 'login/end', request);
        if (response && response.csrf) {
            this.antiForgeryToken = response.csrf;
        }

        return {
            isLoggedIn: response.isLoggedIn,
            handled: response.handled,
        }
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

        } catch (remoteError) {

            // Report errors if this is not a 401
            if (!(remoteError instanceof RemoteError)) {
                throw remoteError;
            }

            if (!remoteError.isAccessTokenExpiredError()) {
                throw remoteError;
            }

            // Handle 401s by refreshing the access token in the HTTP only cookie
            await this.refresh();
            try {

                // Retry the user info call
                return await this.fetch('GET', 'userInfo', null);

            } catch (e: any) {

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

        let url = `${this.oauthAgentBaseUrl}/${path}`;
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

        if (body) {
            options.data = body;
        }

        // If we have an anti forgery token, add it to POST requests
        if (this.antiForgeryToken) {
            headers['x-example-csrf'] = this.antiForgeryToken;
        }

        try {

            // Use axios to call the OAuth Agent, due to its support for reading error responses
            const response = await axios.request(options);
            if (response.data) {
                return response.data;
            }

            return null;

        } catch (e: any) {

            throw ErrorHandler.handleFetchError('OAuth Agent', e);
        }
    }

    /*
     * If required, extra parameters can be provided during authentication redirects like this
     */
    private getRedirectOptions(): any {

        /*return {
            extraParams: [
                {
                    key: 'ui_locales',
                    value: 'sv',
                },
            ]
        };*/

        return null;
    }

    /*
     * Set up methods invoked from DOM event handlers
     */
    private setupCallbacks(): void {
        this.onLoggedOut = this.onLoggedOut.bind(this);
    }
}
