import React, {useState} from 'react';
import {ErrorRenderer} from '../../utilities/errorRenderer';
import {RemoteError} from '../../utilities/remoteError';
import {SignOutProps} from './signOutProps';

export function SignOutView(props: SignOutProps) {

    const [errorText, setErrorText] = useState('');

    function isButtonDisabled(): boolean {
        return false;
    }
    
    async function execute() {

        try {

            const url = await props.oauthClient.logout();
            props.onLoggedOut();
            location.href = url;

        } catch (e: any) {

            if (e instanceof RemoteError && e.isSessionExpiredError()) {
                props.onLoggedOut();
                return;
            }

            setErrorText(ErrorRenderer.toDisplayFormat(e));
        }
    }

    return (
        <div className='container'>
            <h2>Sign Out</h2>
            <p>The SPA asks the OAuth Agent for the End Session Redirect URL, then manages its own redirect</p>
            <button 
                id='signOut' 
                className='btn btn-primary operationButton'
                onClick={execute}
                disabled={isButtonDisabled()}>
                    Sign Out
            </button>
            {errorText &&
            <div>
                <p className='alert alert-danger' id='signOutErrorResult'>{errorText}</p>
            </div>}
            <hr/>
        </div>
    )
}
