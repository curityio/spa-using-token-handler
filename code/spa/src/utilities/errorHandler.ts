export class ErrorHandler {

    /*
     * Fetch errors occur when the server is not contactable or there is an SSL trust problem
     * They may also occur if there are CORS errors such as an unreadable response
     */
    public static handleFetchError(source: string, e: any): Error {

        let message = `Problem encountered calling the ${source}`;
        if (e.response) {

            if (e.response.status) {
                message += `, Status: ${e.response.status}`;
            }

            if (e.response.data && typeof e.response.data === 'object') {

                if (e.response.data.code) {
                    message += `, Code: ${e.response.data.code}`;

                } else if (e.response.data.error) {
                    message += `, Code: ${e.response.data.error}`;
                }

                if (e.response.data.message) {
                    message += `, Details: ${e.response.data.message}`;

                } else if (e.response.data.error_description) {
                    message += `, Details: ${e.response.data.error_description}`;
                }
            }
        }

        return new Error(message);
    }
}
