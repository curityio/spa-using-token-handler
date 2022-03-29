import React, {useEffect, useState} from 'react';
import {RemoteError} from '../../utilities/remoteError';
import {PageLoadProps} from './pageLoadProps';
import {PageLoadState} from './pageLoadState';

export function PageLoadView(props: PageLoadProps) {

    const [state, setState] = useState<PageLoadState>({
        isLoaded: false,
        error: null,
    });

    useEffect(() => {
        execute();
    }, []);

    async function getLoginState(): Promise<any> {

        if (props.sessionExpired) {
            return {handled: false, isLoggedIn: false};
        }

        try {
            return await props.oauthClient.handlePageLoad(location.href);

        } catch (e) {

            const remoteError = e as RemoteError;
            if (remoteError && remoteError.getStatus() === 401) {

                // A 401 could occur if there is a leftover cookie in the browser that can no longer be processed
                // Eg if the cookie encryption key is renewed or if the Authorization Server data is redeployed
                // In this case we return an unauthenticated state
                return {handled: false, isLoggedIn: false};
            }

            throw e;
        }
    }

    async function execute() {

        try {

            const {handled, isLoggedIn} = await getLoginState();
            if (handled) {
                
                // After a login completes, the SPA can restore its location, page state and control the back navigation
                history.replaceState({}, document.title, '/');
            }

            props.setIsLoaded();
            setState((state: any) => {
                return {
                    ...state,
                    isLoaded: true,
                };
            });

            if (isLoggedIn) {
                props.setIsLoggedIn();
            }

        } catch (e) {

            const remoteError = e as RemoteError;
            if (remoteError) {

                setState((state: any) => {
                    return {
                        ...state,
                        error: remoteError.toDisplayFormat(),
                    };
                });
            }
        }
    }

    return (
        <div className='container'>
            <div>
                <h2>Page Load</h2>
                <p>When the SPA loads it asks the OAuth Agent for the authenticated state and to handle a login response if required</p>
                {state && state.isLoaded && !state.error &&
                <div>
                    <p className='alert alert-success' id='pageLoadResult'>Authentication required</p>
                </div>}
                {state && state.error &&
                <div>
                    <p className='alert alert-danger' id='pageLoadErrorResult'>{state.error}</p>
                </div>}
                <hr/>
            </div>
        </div>
    )
}
