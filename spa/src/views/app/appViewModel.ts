import {ApiClient} from '../../api/apiClient';
import {Configuration} from '../../configuration';
import {OAuthClient} from '../../oauth/oauthClient';
import {StorageHelper} from '../../utilities/storageHelper';

export class AppViewModel {

    public configuration: Configuration | null;
    public oauthClient: OAuthClient | null;
    public apiClient: ApiClient | null;
    public storage: StorageHelper | null;

    public constructor() {
        this.configuration = null;
        this.oauthClient = null;
        this.apiClient = null;
        this.storage = null;
    }

    public async initialize(storage: StorageHelper): Promise<void> {

        const response = await fetch('config.json');
        this.configuration = await response.json();

        this.oauthClient = new OAuthClient(this.configuration!.oauth);
        this.apiClient = new ApiClient(this.configuration!.businessApiBaseUrl, this.oauthClient);
        this.storage = storage;
    }
}
