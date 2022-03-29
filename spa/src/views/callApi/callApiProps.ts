import {ApiClient} from '../../api/apiClient';

export interface CallApiProps {
    apiClient: ApiClient;
    onLoggedOut: () => void;
}
