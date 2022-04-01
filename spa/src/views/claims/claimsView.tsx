import React, {useState} from 'react';
import {RemoteError} from '../../utilities/remoteError';
import {ClaimsProps} from './claimsProps';
import {ClaimsState} from './claimsState';

export function ClaimsView(props: ClaimsProps) {

    const [state, setState] = useState<ClaimsState>({
        authTime: '',
        error: null,
    });

    function isButtonDisabled(): boolean {
        return false;
    }

    function getAuthenticationTime(): string {
        return `Authenticated at: ${state.authTime}`
    }

    async function execute() {
        
        try {

            let claims = await props.oauthClient.getClaims();
            if (claims.auth_time) {

                setState((state: any) => {
                    return {
                        ...state,
                        authTime: claims.auth_time,
                        error: null,
                    };
                });

            }

        } catch (e) {

            const remoteError = e as RemoteError;
            if (remoteError) {

                if (remoteError.getStatus() === 401) {

                    // A 401 could occur if there is a leftover cookie in the browser that can no longer be processed
                    // Eg if the cookie encryption key is renewed or if the Authorization Server data is redeployed
                    // In this case we return to an unauthenticated state
                    props.onLoggedOut();

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
            <h2>Get Claims</h2>
            <p>The SPA sends the SameSite cookie to the OAuth Agent to get claims from the ID token</p>
            <button 
                id='getUserInfo' 
                className='btn btn-primary operationButton'
                onClick={execute}
                disabled={isButtonDisabled()}>
                    Get ID Token Claims
            </button>
            {state.authTime &&
            <div>
                <p id='getUserInfoResult' className='alert alert-success'>{getAuthenticationTime()}</p>
            </div>}
            {state && state.error &&
            <div>
                <p className='alert alert-danger' id='getUserInfoErrorResult'>{state.error}</p>
            </div>}
            <hr/>
        </div>
    )
}
