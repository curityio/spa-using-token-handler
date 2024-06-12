import {RemoteError} from './remoteError';

/*
 * The SPA renders OAuth or API errors in its preferred manner
 */
export class ErrorRenderer {

    public static toDisplayFormat(error: any): string {

        let status = 0;
        let code = '';
        let details = '';

        if (error instanceof RemoteError) {

            status = error.getStatus();
            code = error.getCode()
            details = error.message;
        }
        else {

            if (error.status) {
                status = error.status;
            }
            details = error.message || '';
        }

        const parts = [];

        if (status) {
            parts.push(`status: ${status}`);
        }

        if (code) {
            parts.push(`code: ${code}`);
        }

        if (details) {
            parts.push(`details: ${details}`);
        }

        return parts.join(', ');
    }
}
