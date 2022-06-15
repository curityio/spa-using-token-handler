import {ApiClient} from '../../api/apiClient';
import {Configuration} from '../../configuration';
import {OAuthClient} from '../../oauth/oauthClient';

export class AppViewModel {

    public configuration: Configuration | null;
    public oauthClient: OAuthClient | null;
    public apiClient: ApiClient | null;
    public initialized: boolean

    public constructor() {
        this.configuration = null;
        this.oauthClient = null;
        this.apiClient = null;
        this.initialized = false;
    }

    public async initialize(): Promise<void> {

        if (!this.initialized) {

            const response = await fetch('config.json');
            this.configuration = await response.json() as Configuration;

            this.oauthClient = new OAuthClient(this.configuration.oauth);
            this.apiClient = new ApiClient(this.configuration.businessApiBaseUrl, this.oauthClient);
            this.initialized = true;
        }
    }
}
