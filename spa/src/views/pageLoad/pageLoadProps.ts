import {OAuthClient} from '../../oauth/oauthClient';

export interface PageLoadProps {
    oauthClient: OAuthClient;
    onLoaded: () => void;
    onLoggedIn: () => void;
    onLoggedOut: () => void;
}
