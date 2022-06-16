import React, {useEffect, useState} from 'react';
import {ErrorHandler} from '../../utilities/errorHandler';
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

        try {
            return await props.oauthClient.handlePageLoad(location.href);

        } catch (e) {

            const remoteError = e as RemoteError;
            if (ErrorHandler.isSessionExpiredError(remoteError)) {

                return {
                    handled: false,
                    isLoggedIn: false
                };
            }

            throw e;

        } finally {

            history.replaceState({}, document.title, '/');
        }
    }

    async function execute() {

        try {

            const {handled, isLoggedIn} = await getLoginState();
            if (handled) {
                
                // After a login completes, restore the location and remove the OAuth response from back navigation
                history.replaceState({}, document.title, '/');
            }

            props.onLoaded();
            setState((state: any) => {
                return {
                    ...state,
                    isLoaded: true,
                };
            });

            if (isLoggedIn) {
                props.onLoggedIn();
            } else {
                props.onLoggedOut();
            }

        } catch (e) {

            const remoteError = e as RemoteError;
            if (remoteError) {

                // Ensure there are no leftover OAuth response details, then render the error
                history.replaceState({}, document.title, '/');
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
