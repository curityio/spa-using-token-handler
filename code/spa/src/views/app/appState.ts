import {ApiClient} from '../../api/apiClient';
import {Configuration} from '../../configuration';
import {OAuthClient} from '../../oauth/oauthClient';
import {StorageHelper} from '../../utilities/storageHelper';

export interface AppState {
    configuration: Configuration,
    oauthClient: OAuthClient;
    apiClient: ApiClient;
    storage: StorageHelper
    isLoaded: boolean;
    isLoggedIn: boolean;
}
