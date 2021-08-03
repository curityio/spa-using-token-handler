import {OAuthClient} from '../../oauth/oauthClient';

export interface PageLoadProps {
    oauthClient: OAuthClient;
    setIsLoaded: () => void;
    setIsLoggedIn: () => void;
}
