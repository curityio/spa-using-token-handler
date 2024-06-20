import React, {useState} from 'react';
import {ErrorRenderer} from '../../utilities/errorRenderer';
import {RemoteError} from '../../utilities/remoteError';
import {ClaimsProps} from './claimsProps';

export function ClaimsView(props: ClaimsProps) {

    const [authTime, setAuthTime] = useState('');
    const [errorText, setErrorText] = useState('');

    function isButtonDisabled(): boolean {
        return false;
    }

    function getAuthenticationTime(): string {
        return `auth_time: ${authTime}`
    }

    async function execute() {
        
        try {

            let claims = await props.oauthClient.getClaims();
            if (claims.auth_time) {

                setAuthTime(claims.auth_time);
                setErrorText('');
            }

        } catch (e: any) {

            if (e instanceof RemoteError && e.isSessionExpiredError()) {
                props.onLoggedOut();
                return;
            }

            setAuthTime('');
            setErrorText(ErrorRenderer.toDisplayFormat(e));
        }
    }

    return (

        <div className='container'>
            <h2>Get Claims</h2>
            <p>The SPA sends the SameSite cookie to the OAuth Agent to get claims from the ID token</p>
            <button 
                id='getClaims' 
                className='btn btn-primary operationButton'
                onClick={execute}
                disabled={isButtonDisabled()}>
                    Get ID Token Claims
            </button>
            {authTime &&
            <div>
                <p id='getClaimsResult' className='alert alert-success'>{getAuthenticationTime()}</p>
            </div>}
            {errorText &&
            <div>
                <p className='alert alert-danger' id='getUserInfoErrorResult'>{errorText}</p>
            </div>}
            <hr/>
        </div>
    )
}
