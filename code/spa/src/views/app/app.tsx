import React, {useEffect, useRef, useState} from 'react';
import {ApiClient} from '../../api/apiClient';
import {Configuration} from '../../configuration';
import {OAuthClient} from '../../oauth/oauthClient';
import {StorageHelper} from '../../utilities/storageHelper';
import {CallApiView} from '../callApi/callApiView';
import {MultiTabView} from '../multiTab/multiTabView';
import {PageLoadView} from '../pageLoad/pageLoadView';
import {SignOutView} from '../signOut/signOutView';
import {StartAuthenticationView} from '../startAuthentication/startAuthenticationView';
import {TitleView} from '../title/titleView';
import {UserInfoView} from '../userinfo/userInfoView';
import {AppState} from './appState';

export default function App() {

    const [state, setState] = useState<AppState | null>(null);

    // This only runs once to initialize the app
    useEffect(() => {
        
        startup();
        return () => cleanup();

    }, []);

    // This keeps the state ref used in DOM event handlers up to date
    const stateRef = useRef(state);
    useEffect(() => {

        stateRef.current = state;
      }, [state]);

    /*
     * Add global objects to state when the app loads
     */
    async function startup() {

        const configuration = await getConfiguration();
        const oauthClient = new OAuthClient(configuration.oauth);
        const apiClient = new ApiClient(configuration.businessApiBaseUrl, oauthClient);
        const storage = new StorageHelper(() => multiTabLogout());

        window.addEventListener('storage', storage.onChange);

        setState({
            configuration,
            oauthClient,
            apiClient,
            storage,
            isLoaded: false,
            isLoggedIn: false
        });
    }

    /*
     * Download the app's configuration settings
     */
    async function getConfiguration(): Promise<Configuration> {

        const response = await fetch('config.json');
        return await response.json();
    }

    /*
     * Called back from the page load view
     */
    function setIsLoaded() {

        setState((prevState: any) => {
            return {
                ...prevState,
                isLoaded: true,
            };
        });
    }

    /*
     * Called back from the start authentication view
     */
    function setIsLoggedIn() {

        state!.storage.setLoggedOut(false);
        setState((prevState: any) => {
            return {
                ...prevState,
                isLoggedIn: true,
            };
        });
    }

    /*
     * Called back from the sign out view or the multi tab logout handler
     */
    function setIsLoggedOut() {

        const stateToUse = state || stateRef.current;

        stateToUse!.storage.setLoggedOut(true);
        setState((prevState: any) => {
            return {
                ...prevState,
                isLoggedIn: false,
            };
        });
    }

    /*
     * We are notified when logout occurs on another tab, then clean up this tab's state
     */
    async function multiTabLogout() {

        await stateRef.current!.oauthClient.onLoggedOut();
        setIsLoggedOut();
    }

    /*
     * Release event listeners when we exit
     */
    function cleanup() {
        if (state && state.storage) {
            window.removeEventListener('storage', state.storage.onChange);
        }
    }

    /*
     * The simple app's rendering depends only on its state
     */
    return (
        <>
            <TitleView />

            {/* Unauthenticated views */}
            {state && !state.isLoggedIn &&
                <>
                    <PageLoadView 
                        oauthClient={state.oauthClient!}
                        setIsLoaded={setIsLoaded}
                        setIsLoggedIn={setIsLoggedIn} />

                    {state.isLoaded && 
                        <>
                            <StartAuthenticationView 
                                oauthClient={state.oauthClient!} />
                        </>
                    }
                </>
            }

            {/* Authenticated views */}
            {state && state.isLoaded && state.isLoggedIn &&
            <>
                <MultiTabView />

                <UserInfoView 
                    oauthClient={state.oauthClient!} />

                <CallApiView 
                    apiClient={state.apiClient!} />

                <SignOutView 
                    oauthClient={state.oauthClient!}
                    setIsLoggedOut={setIsLoggedOut} />
            </>
            }
        </>
    );
}
