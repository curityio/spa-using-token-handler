import {OAuthClient} from '../../oauth/oauthClient';

export interface ClaimsProps {
    oauthClient: OAuthClient;
    onLoggedOut: () => void;
}
