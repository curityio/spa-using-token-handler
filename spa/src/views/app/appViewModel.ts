import {ApiClient} from '../../api/apiClient';
import {Configuration} from '../../configuration';
import {OAuthClient} from '../../oauth/oauthClient';
import { PageLoadResponse } from '../../utilities/pageLoadResponse';

export class AppViewModel {

    public configuration: Configuration | null;
    public oauthClient: OAuthClient | null;
    public apiClient: ApiClient | null;
    public isLoaded: boolean;
    public pageLoadResponse: PageLoadResponse | null;

    public constructor() {
        this.configuration = null;
        this.oauthClient = null;
        this.apiClient = null;
        this.isLoaded = false;
        this.pageLoadResponse = null;
    }

    /*
     * Download configuration from the web host to get the backend for frontend details
     */
    public async loadConfiguration(): Promise<void> {

        if (!this.isLoaded) {

            const response = await fetch('config.json');
            this.configuration = await response.json() as Configuration;
            this.oauthClient = new OAuthClient(this.configuration.oauthAgentBaseUrl);
            this.apiClient = new ApiClient(this.configuration.businessApiBaseUrl, this.oauthClient);
            this.isLoaded = true;
        }
    }

    /*
     * Handle the page load event when the app loads
     */
    public async handlePageLoad(): Promise<void> {

        try {

            this.pageLoadResponse =  await this.oauthClient!.handlePageLoad(location.href);

        } finally {
            
            if (this.pageLoadResponse?.handled) {
                history.replaceState({}, document.title, '/');
            }
        }
    }
}
