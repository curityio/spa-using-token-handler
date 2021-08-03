import React, {useEffect, useState} from 'react';
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

    async function execute() {

        try {

            // Every time the SPA loads it calls the BFF API, handles OAuth responses and / or reports the login state
            const {handled, isLoggedIn} = await props.oauthClient.handlePageLoad(location.href);
            if (handled) {
                
                // After a login completes, the SPA can restore its location / page state / back navigation
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

            setState((state: any) => {
                return {
                    ...state,
                    error: e.message,
                };
            });
        }

        
    }

    return (
        <div className='container'>
            <div>
                <h2>Page Load</h2>
                <p>When the SPA loads it asks the API for the authenticated state and to handle a login response if required</p>
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
