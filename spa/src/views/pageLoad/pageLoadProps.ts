import {OAuthClient} from '../../oauth/oauthClient';

export interface PageLoadProps {
    oauthClient: OAuthClient;
    sessionExpired: boolean;
    setIsLoaded: () => void;
    setIsLoggedIn: () => void;
}
