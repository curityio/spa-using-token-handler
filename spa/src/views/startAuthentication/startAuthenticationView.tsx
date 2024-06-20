import React, {useState} from 'react';
import {ErrorRenderer} from '../../utilities/errorRenderer';
import {StartAuthenticationProps} from './startAuthenticationProps';

export function StartAuthenticationView(props: StartAuthenticationProps) {

    const [errorText, setErrorText] = useState('');

    /*
     * Get the login URL, store state if needed, then redirect
     */
    async function execute() {

        try {

            location.href = await props.oauthClient.startLogin();

        } catch (e: any) {

            setErrorText(ErrorRenderer.toDisplayFormat(e));
        }
    }

    return (
        <div className='container'>
            <h2>Start Authentication</h2>
            <p>The SPA asks the OAuth Agent for the Authorization Redirect URL, then manages its own redirect</p>
            <div>
                <button 
                    id='startAuthentication' 
                    className='btn btn-primary operationButton'
                    onClick={execute}
                    disabled={false}>
                        Sign In
                </button>
            </div>
            {errorText &&
            <div>
                <p className='alert alert-danger' id='getDataErrorResult'>{errorText}</p>
            </div>}
            <hr/>
        </div>
    )
}
