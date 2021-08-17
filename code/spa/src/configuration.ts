import {OAuthConfiguration} from './oauth/oauthConfiguration';

export interface Configuration {
    businessApiBaseUrl: string;
    oauth: OAuthConfiguration;
}
