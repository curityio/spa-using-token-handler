import {RemoteError} from './remoteError';

/*
 * Make errors easy for the rest of the app to deal with
 */
export class ErrorHandler {

    /*
     * Handle errors making OAuth or API calls
     */
    public static handleFetchError(source: string, e: any): Error {

        let status = 0;
        let code = '';
        let message = `Problem encountered calling the ${source}`;

        if (e.response) {

            if (e.response.status) {
                status = e.response.status;
            }

            if (e.response.data && typeof e.response.data === 'object') {

                if (e.response.data.code) {
                    code = e.response.data.code;

                } else if (e.response.data.error) {
                    code = e.response.data.error;
                }

                if (e.response.data.message) {
                    message += `: ${e.response.data.message}`;

                } else if (e.response.data.error_description) {
                    message += `: ${e.response.data.error_description}`;
                }
            }
        }

        return new RemoteError(status, code, message);
    }
}
