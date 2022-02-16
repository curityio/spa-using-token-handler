import {OAuthClient} from '../../oauth/oauthClient';

export interface UserInfoProps {
    oauthClient: OAuthClient;
    setIsLoggedOut: () => void;
}
