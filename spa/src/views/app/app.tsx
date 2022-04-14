import React, {useEffect, useState} from 'react';
import {StorageHelper} from '../../utilities/storageHelper';
import {CallApiView} from '../callApi/callApiView';
import {ClaimsView} from '../claims/claimsView';
import {MultiTabView} from '../multiTab/multiTabView';
import {PageLoadView} from '../pageLoad/pageLoadView';
import {SignOutView} from '../signOut/signOutView';
import {StartAuthenticationView} from '../startAuthentication/startAuthenticationView';
import {TitleView} from '../title/titleView';
import {UserInfoView} from '../userInfo/userInfoView';
import {AppProps} from './appProps';
import {AppState} from './appState';

export default function App(props: AppProps) {

    const [state, setState] = useState<AppState | null>(null);

    // This only runs once to initialize the app
    useEffect(() => {
        startup();
        return () => cleanup();
    }, []);

    /*
     * Create global objects when the app loads
     */
    async function startup() {

        const storage = new StorageHelper(() => multiTabLogout());
        await props.viewModel.initialize(storage);
        window.addEventListener('storage', storage.onChange);

        setState({
            isLoaded: false,
            isLoggedIn: false,
            sessionExpired: false,
        });
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

        props.viewModel.storage!.setLoggedOut(false);
        setState((prevState: any) => {
            return {
                ...prevState,
                isLoggedIn: true,
                sessionExpired: false,
            };
        });
    }

    /*
     * Called back from the sign out view or the multi tab logout handler
     */
    function setIsLoggedOut() {

        props.viewModel.storage!.setLoggedOut(true);
        setState((prevState: any) => {
            return {
                ...prevState,
                isLoggedIn: false,
                sessionExpired: true,
            };
        });
    }

    /*
     * We are notified when logout occurs on another tab, then clean up this tab's state
     */
    async function multiTabLogout() {

        await props.viewModel.oauthClient!.onLoggedOut();
        setIsLoggedOut();
    }

    /*
     * Release event listeners when we exit
     */
    function cleanup() {
        if (props.viewModel.storage) {
            window.removeEventListener('storage', props.viewModel.storage.onChange);
        }
    }

    /*
     * This simple app does not use React navigation and just renders the view based on state
     */
    return (
        <>
            <TitleView />

            {/* Unauthenticated views */}
            {state && !state.isLoggedIn &&
                <>
                    <PageLoadView 
                        oauthClient={props.viewModel.oauthClient!}
                        onLoaded={setIsLoaded}
                        onLoggedIn={setIsLoggedIn}
                        onLoggedOut={setIsLoggedOut} />

                    {state.isLoaded && 
                        <>
                            <StartAuthenticationView 
                                oauthClient={props.viewModel.oauthClient!} />
                        </>
                    }
                </>
            }

            {/* Authenticated views */}
            {state && state.isLoaded && state.isLoggedIn &&
            <>
                <MultiTabView />

                <UserInfoView 
                    oauthClient={props.viewModel.oauthClient!}
                    onLoggedOut={setIsLoggedOut} />

                <ClaimsView 
                    oauthClient={props.viewModel.oauthClient!}
                    onLoggedOut={setIsLoggedOut} />

                <CallApiView 
                    apiClient={props.viewModel.apiClient!}
                    onLoggedOut={setIsLoggedOut} />

                <SignOutView 
                    oauthClient={props.viewModel.oauthClient!}
                    onLoggedOut={setIsLoggedOut} />
            </>
            }
        </>
    );
}
