import React, {useState} from 'react';
import {RemoteError} from '../../utilities/remoteError';
import {StartAuthenticationProps} from './startAuthenticationProps';
import {StartAuthenticationState} from './startAuthenticationState';

export function StartAuthenticationView(props: StartAuthenticationProps) {

    const [state, setState] = useState<StartAuthenticationState>({
        error: null,
    });

    /*
     * Get the login URL, store state if needed, then redirect
     */
    async function execute() {

        try {

            location.href = await props.oauthClient.startLogin();

        } catch (e) {

            const remoteError = e as RemoteError;
            if (remoteError) {

                setState((state: any) => {
                    return {
                        ...state,
                        authorizationUrl: '',
                        error: remoteError.toDisplayFormat(),
                    };
                });
            }
        }
    }

    return (
        <div className='container'>
            <h2>Start Authentication</h2>
            <p>The SPA asks the BFF API for the Authorization Redirect URL, then manages its own redirect</p>
            <div>
                <button 
                    id='startAuthentication' 
                    className='btn btn-primary operationButton'
                    onClick={execute}
                    disabled={false}>
                        Sign In
                </button>
            </div>
            {state && state.error &&
            <div>
                <p className='alert alert-danger' id='getDataErrorResult'>{state.error}</p>
            </div>}
            <hr/>
        </div>
    )
}
