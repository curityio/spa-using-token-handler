import React, {useState} from 'react';
import {ErrorRenderer} from '../../utilities/errorRenderer';
import {RemoteError} from '../../utilities/remoteError';
import {CallApiProps} from './callApiProps';

export function CallApiView(props: CallApiProps) {

    const [welcomeMessage, setWelcomeMessage] = useState('');
    const [errorText, setErrorText] = useState('');

    function isButtonDisabled(): boolean {
        return false;
    }

    function getAccessTokenDescription(): string {
        return "The SPA makes all API calls using SameSite cookies, with no tokens in the browser";
    }

    async function execute() {

        try {
            const data = await props.apiClient.getWelcomeData();
            if (data.message) {

                setWelcomeMessage(data.message);
                setErrorText('');
            }

        } catch (e: any) {

            if (e instanceof RemoteError && e.isSessionExpiredError()) {
                props.onLoggedOut();
                return;
            }

            setWelcomeMessage('');
            setErrorText(ErrorRenderer.toDisplayFormat(e));
        }
    }

    return (

        <div className='container'>
            <h2>Call APIs</h2>
            <p>{getAccessTokenDescription()}</p>
            <button 
                id='getApiData' 
                className='btn btn-primary operationButton'
                onClick={execute}
                disabled={isButtonDisabled()}>
                    Get Data
            </button>
            {welcomeMessage &&
            <div>
                <p className='alert alert-success' id='getDataResult'>{welcomeMessage}</p>
            </div>}
            {errorText &&
            <div>
                <p className='alert alert-danger' id='getDataErrorResult'>{errorText}</p>
            </div>}
            <hr/>
        </div>
    )
}
