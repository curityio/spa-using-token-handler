import React, {useState} from 'react';
import {RemoteError} from '../../utilities/remoteError';
import {SignOutProps} from './signOutProps';
import {SignOutState} from './signOutState';

export function SignOutView(props: SignOutProps) {

    const [state, setState] = useState<SignOutState>({
        error: null,
    });

    function isButtonDisabled(): boolean {
        return false;
    }
    
    async function execute() {

        try {

            const url = await props.oauthClient.logout();
            props.setIsLoggedOut();
            location.href = url;

        } catch (e) {

            const remoteError = e as RemoteError;
            if (remoteError) {

                if (remoteError.getStatus() === 401) {

                    // A 401 could occur if there is a leftover cookie in the browser that can no longer be processed
                    // Eg if the cookie encryption key is renewed or if the Authorization Server data is redeployed
                    // In this case we return to an unauthenticated state
                    props.setIsLoggedOut();

                } else {

                    setState((state: any) => {
                        return {
                            ...state,
                            error: remoteError.toDisplayFormat(),
                        };
                    });
                }
            }
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
            {state && state.error &&
            <div>
                <p className='alert alert-danger' id='signOutErrorResult'>{state.error}</p>
            </div>}
            <hr/>
        </div>
    )
}
