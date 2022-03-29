import {OAuthClient} from '../../oauth/oauthClient';

export interface SignOutProps {
    oauthClient: OAuthClient;
    onLoggedOut: () => void;
}
